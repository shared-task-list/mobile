import 'package:get/get.dart';
import 'package:shared_task_list/category_list/category_list_repository.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/extension/color_extension.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/task_detail/task_detail_repository.dart';
import 'package:shared_task_list/task_list/task_list_repository.dart';

class CategoryListCtrl extends GetxController {
  late CategoryListRepository _repo;
  late TaskDetailRepository _taskDetailRepo;
  late TaskListRepository _taskListRepo;
  var categories = List<Category>.empty().obs;

  @override
  void onInit() async {
    super.onInit();

    _taskDetailRepo = TaskDetailRepository();
    _taskListRepo = TaskListRepository();

    _repo = CategoryListRepository();
    _repo.categories.listen((catList) => categories.value = catList);

    await _repo.getList();
  }

  @override
  void onClose() {
    super.onClose();
    _repo.dispose();
  }

  Future getList() async {
    await _repo.getList();
  }

  Future updateOrder(int oldIndex, int newIndex) async {
    List<Category> cats = categories.toList();
    final updatedCat = cats[oldIndex];
    cats.removeAt(oldIndex);

    if (newIndex >= cats.length) {
      cats.add(updatedCat);
    } else {
      cats.insert(newIndex, updatedCat);
    }

    categories.value = cats;

    for (int i = 0; i < cats.length; ++i) {
      cats[i].order = i + 1;
      await _repo.update(cats[i]);
    }
  }

  Future deleteCategory(Category category) async {
    categories.removeWhere((cat) => cat.id == category.id);
    await _repo.delete(category);
    // _repo.getList();

    final fbClient = FbClient();
    final tasks = await _taskListRepo.getTasks();
    final categoryTask = tasks.where((task) => task.category == category.name);
    categoryTask.forEach((task) {
      fbClient.removeTask(task);
      _taskListRepo.remove(task);
    });
  }

  Future updateCategoryName(Category category, String newName) async {
    // _repo.getList();
    int index = categories.indexOf(category);

    if (index == -1) {
      return;
    }

    String oldName = category.name;
    category.name = newName;

    categories[index] = category;
    await _repo.update(category);

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

    int id = await _repo.create(category);
    // await _repo.getList();
    category.id = id;
    categories.add(category);
  }
}
