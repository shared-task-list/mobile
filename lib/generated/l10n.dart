// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

class S {
  S();
  
  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
    final localeName = Intl.canonicalizedLocale(name); 
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      return S();
    });
  } 

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  String get taskListExists {
    return Intl.message(
      'Task List already exist',
      name: 'taskListExists',
      desc: '',
      args: [],
    );
  }

  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  String get taskListName {
    return Intl.message(
      'Task List',
      name: 'taskListName',
      desc: '',
      args: [],
    );
  }

  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  String get open {
    return Intl.message(
      'Open',
      name: 'open',
      desc: '',
      args: [],
    );
  }

  String get required {
    return Intl.message(
      'Could not be empty',
      name: 'required',
      desc: '',
      args: [],
    );
  }

  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  String get openError {
    return Intl.message(
      'Wrong Task List or Password',
      name: 'openError',
      desc: '',
      args: [],
    );
  }

  String get newName {
    return Intl.message(
      'New Name',
      name: 'newName',
      desc: '',
      args: [],
    );
  }

  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  String get taskTitle {
    return Intl.message(
      'Task Title',
      name: 'taskTitle',
      desc: '',
      args: [],
    );
  }

  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  String get newCategory {
    return Intl.message(
      'New Category',
      name: 'newCategory',
      desc: '',
      args: [],
    );
  }

  String get newTask {
    return Intl.message(
      'New Task',
      name: 'newTask',
      desc: '',
      args: [],
    );
  }

  String get task {
    return Intl.message(
      'Task',
      name: 'task',
      desc: '',
      args: [],
    );
  }

  String get comment {
    return Intl.message(
      'Comment',
      name: 'comment',
      desc: '',
      args: [],
    );
  }

  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  String get categoryList {
    return Intl.message(
      'Category List (tap or drag)',
      name: 'categoryList',
      desc: '',
      args: [],
    );
  }

  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  String get defaultCategory {
    return Intl.message(
      'Default Category',
      name: 'defaultCategory',
      desc: '',
      args: [],
    );
  }

  String get noCategory {
    return Intl.message(
      'No Category',
      name: 'noCategory',
      desc: '',
      args: [],
    );
  }

  String get categoryName {
    return Intl.message(
      'Category Name',
      name: 'categoryName',
      desc: '',
      args: [],
    );
  }

  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  String get background {
    return Intl.message(
      'Background',
      name: 'background',
      desc: '',
      args: [],
    );
  }

  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  String get color {
    return Intl.message(
      'Color',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  String get show_quick_add {
    return Intl.message(
      'Show Quick Add',
      name: 'show_quick_add',
      desc: '',
      args: [],
    );
  }

  String get tasks {
    return Intl.message(
      'Tasks',
      name: 'tasks',
      desc: '',
      args: [],
    );
  }

  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  String get add_new {
    return Intl.message(
      'Add New',
      name: 'add_new',
      desc: '',
      args: [],
    );
  }

  String get current {
    return Intl.message(
      'current',
      name: 'current',
      desc: '',
      args: [],
    );
  }

  String get current_list_changed {
    return Intl.message(
      'Current List Changed',
      name: 'current_list_changed',
      desc: '',
      args: [],
    );
  }

  String get current_list_changed_to {
    return Intl.message(
      'You current list was changed to ',
      name: 'current_list_changed_to',
      desc: '',
      args: [],
    );
  }

  String get delete_list {
    return Intl.message(
      'Delete List ',
      name: 'delete_list',
      desc: '',
      args: [],
    );
  }

  String get task_delete_too {
    return Intl.message(
      'All tasks in list also will be deleted',
      name: 'task_delete_too',
      desc: '',
      args: [],
    );
  }

  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  String get new_list {
    return Intl.message(
      'New List',
      name: 'new_list',
      desc: '',
      args: [],
    );
  }

  String get my_lists {
    return Intl.message(
      'My Lists',
      name: 'my_lists',
      desc: '',
      args: [],
    );
  }

  String get field_required {
    return Intl.message(
      'Field is required',
      name: 'field_required',
      desc: '',
      args: [],
    );
  }

  String get recent_lists {
    return Intl.message(
      'Recent Lists',
      name: 'recent_lists',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ru', countryCode: 'RU'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    if (locale != null) {
      for (var supportedLocale in supportedLocales) {
        if (supportedLocale.languageCode == locale.languageCode) {
          return true;
        }
      }
    }
    return false;
  }
}