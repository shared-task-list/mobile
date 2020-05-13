import 'package:flutter/material.dart';
import 'package:rxdart/subjects.dart';
import 'package:shared_task_list/common/category_provider.dart';
import 'package:shared_task_list/common/fb_client.dart';
import 'package:shared_task_list/model/category.dart';
import 'package:shared_task_list/task_detail/task_detail_repository.dart';
import 'package:shared_task_list/task_list/task_list_repository.dart';

class CategoryListBloc {
  final categories = BehaviorSubject<List<Category>>();
  final _categoryList = List<Category>();
  final _taskListRepo = TaskListRepository();
  final _taskDetailRepo = TaskDetailRepository();

  Future getCategories() async {
    _categoryList.clear();
    var cats = await CategoryProvider.getList();
    _categoryList.addAll(cats);
    categories.add(_categoryList);
  }

  Future updateOrder(int oldIndex, int newIndex) async {
    final updatedCat = _categoryList[oldIndex];
    _categoryList.removeAt(oldIndex);

    if (newIndex >= _categoryList.length) {
      _categoryList.add(updatedCat);
    } else {
      _categoryList.insert(newIndex, updatedCat);
    }

    categories.add(_categoryList);

    for (int i = 0; i < _categoryList.length; ++i) {
      _categoryList[i].order = i + 1;
      await CategoryProvider.save(_categoryList[i]);
    }
  }

  Future deleteCategory(Category category) async {
    _categoryList.removeWhere((cat) => cat.id == category.id);
    categories.add(_categoryList);

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

    for (int i = 0; i < _categoryList.length; ++i) {
      if (_categoryList[i].id == category.id) {
        _categoryList[i].name = newName;
      }
    }

    categories.add(_categoryList);

    final fbClient = FbClient();
    final tasks = await _taskListRepo.getTasks();
    final categoryTask = tasks.where((task) => task.category == oldName);
    categoryTask.forEach((task) {
      task.category = newName;
      fbClient.updateTask(task);
      _taskDetailRepo.updateTask(task);
    });

    CategoryProvider.save(category);
  }

  Future createNewCategory(String name) async {
    if (name.isEmpty) {
      return;
    }

    final category = Category(
      name: name,
      colorString: _colorToString(Colors.grey.shade600),
      order: DateTime.now().millisecondsSinceEpoch,
    );

    _categoryList.add(category);
    categories.add(_categoryList);
    await category.save();
  }

  void dispose() {
    categories.close();
  }

  String _colorToString(Color color) {
    return "${color.red},${color.green},${color.blue}";
  }
}
