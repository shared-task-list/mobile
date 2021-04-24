import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/category_provider.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_repository.dart';
import 'package:uuid/uuid.dart';

class TaskDetailBloc {
  final _repository = TaskDetailRepository();
  final categories = BehaviorSubject<List<Category>>();
  final categoryButtonTitle = BehaviorSubject<String>();

  String title = '';
  String comment = '';
  String category = '';
//  String newCategory = '';

  Future getCategories() async {
    final categoryList = await CategoryProvider.getList();
    categoryList.sort((cat1, cat2) => cat1.order.compareTo(cat2.order));
    categories.add(categoryList);
  }

  Future createTask() async {
    if (title.isEmpty) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userUid = prefs.getString(Constant.authorUidKey) ?? '';

    final task = UserTask(
      title: title,
      comment: comment,
      timestamp: DateTime.now(),
      uid: Uuid().v4(),
      author: Constant.userName,
      category: category.isEmpty ? Constant.noCategory : category,
      authorUid: userUid,
    );

    await _repository.createTask(task);
  }

  Future updateTask(UserTask task) async {
    task.title = title;
    task.comment = comment;
    task.category = category;

    _repository.updateTask(task);
  }

  Future createNewCategory(String newCategory) async {
    if (newCategory.isEmpty) {
      return;
    }
    await Category(name: newCategory).save();
    await getCategories();
  }

  void setCategoryTitle(String category) {
    categoryButtonTitle.add(category);
  }

  void dispose() {
    categories.close();
    categoryButtonTitle.close();
  }
}
