import 'package:rxdart/rxdart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/category_provider.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_repository.dart';
import 'package:uuid/uuid.dart';

class TaskDetailBloc {
  final _repository = TaskDetailRepository();
  final _fbClient = FbClient();
  final categories = BehaviorSubject<List<Category>>();
  final categoryButtonTitle = BehaviorSubject<String>();
  final _categoryTitle = 'Category';

  String title = '';
  String comment = '';
  String category = '';
//  String newCategory = '';

  Future getCategories() async {
    final categoryList = await CategoryProvider.getList();
    categories.add(categoryList);
  }

  Future createTask() async {
    if (title.isEmpty) {
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String userUid = prefs.getString(Constant.authorUidKey);

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
    await _fbClient.addTask(task);
  }

  Future updateTask(UserTask task) async {
    task.title = title;
    task.comment = comment;
    task.category = category;

    _repository.updateTask(task);
    await _fbClient.updateTask(task);
  }

  Future createNewCategory(String newCategory) async {
    if (newCategory.isEmpty) {
      return;
    }
    await Category(name: newCategory).save();
    await getCategories();
  }

  void setCategoryTitle(String category) {
    String title = _categoryTitle + ' - $category';
    categoryButtonTitle.add(title);
  }

  void dispose() {
    categories.close();
    categoryButtonTitle.close();
  }
}
