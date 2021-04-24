import 'package:rxdart/subjects.dart';
import 'package:shared_task_list/category_list/category_list_repository.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/extension/color_extension.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/task_detail/task_detail_repository.dart';
import 'package:shared_task_list/task_list/task_list_repository.dart';

class CategoryListBloc {
  final categories = BehaviorSubject<List<Category>>();
  final _taskListRepo = TaskListRepository();
  final _taskDetailRepo = TaskDetailRepository();
  final _repo = CategoryListRepository();

  CategoryListBloc() {
    // _repo.getList();
    _repo.categories.listen((taskList) => categories.add(taskList));
  }

  Future getList() async {
    await _repo.getList();
  }

  Future updateOrder(int oldIndex, int newIndex, List<Category> cats) async {
    final updatedCat = cats[oldIndex];
    cats.removeAt(oldIndex);

    if (newIndex >= cats.length) {
      cats.add(updatedCat);
    } else {
      cats.insert(newIndex, updatedCat);
    }

    categories.add(cats);

    for (int i = 0; i < cats.length; ++i) {
      cats[i].order = i + 1;
      await _repo.update(cats[i]);
    }
  }

  Future deleteCategory(Category category) async {
    await _repo.delete(category);
    _repo.getList();

    final fbClient = FbClient();
    final tasks = await _taskListRepo.getTasks();
    final categoryTask = tasks.where((task) => task.category == category.name);
    categoryTask.forEach((task) {
      fbClient.removeTask(task);
      _taskListRepo.remove(task);
    });
  }

  Future updateCategoryName(Category category, String newName) async {
    String oldName = category.name;
    category.name = newName;
    await _repo.update(category);
    _repo.getList();

    final fbClient = FbClient();
    final tasks = await _taskListRepo.getTasks();
    final categoryTask = tasks.where((task) => task.category == oldName);
    categoryTask.forEach((task) {
      task.category = newName;
      fbClient.updateTask(task);
      _taskDetailRepo.updateTask(task);
    });
  }

  Future createNewCategory(String name) async {
    if (name.isEmpty) {
      return;
    }

    final category = Category(
      name: name,
      colorString: Constant.defaultCategoryColor.toRgbString(),
      order: DateTime.now().millisecondsSinceEpoch,
    );

    // await category.save();
    await _repo.create(category);
    await _repo.getList();
  }

  void dispose() {
    categories.close();
    _repo.dispose();
  }
}
