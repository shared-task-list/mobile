import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_task_list/common/category_provider.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/model/task.dart';
import 'package:shared_task_list/task_detail/task_detail_repository.dart';
import 'package:uuid/uuid.dart';

class TaskDetailCtrl extends GetxController {
  late TaskDetailRepository _repository;
  var categories = List<Category>.empty().obs;
  var categoryButtonTitle = ''.obs;

  String title = '';
  String comment = '';
  String category = '';

  @override
  void onInit() async {
    super.onInit();
    _repository = TaskDetailRepository();
  }

  Future getCategories() async {
    final categoryList = await CategoryProvider.getList();
    categoryList.sort((cat1, cat2) => cat1.order.compareTo(cat2.order));

    int cindex = categories.indexWhere((c) => c.name == Constant.noCategory);

    if (cindex == -1) {
      categoryList.insert(0, AppData.noCategory);
    }

    categories.value = categoryList;
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
}
