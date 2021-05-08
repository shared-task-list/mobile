// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `Task List already exist`
  String get taskListExists {
    return Intl.message(
      'Task List already exist',
      name: 'taskListExists',
      desc: '',
      args: [],
    );
  }

  /// `Username`
  String get username {
    return Intl.message(
      'Username',
      name: 'username',
      desc: '',
      args: [],
    );
  }

  /// `Task List`
  String get taskListName {
    return Intl.message(
      'Task List',
      name: 'taskListName',
      desc: '',
      args: [],
    );
  }

  /// `Password`
  String get password {
    return Intl.message(
      'Password',
      name: 'password',
      desc: '',
      args: [],
    );
  }

  /// `Open`
  String get open {
    return Intl.message(
      'Open',
      name: 'open',
      desc: '',
      args: [],
    );
  }

  /// `Could not be empty`
  String get required {
    return Intl.message(
      'Could not be empty',
      name: 'required',
      desc: '',
      args: [],
    );
  }

  /// `Error`
  String get error {
    return Intl.message(
      'Error',
      name: 'error',
      desc: '',
      args: [],
    );
  }

  /// `Wrong Task List or Password`
  String get openError {
    return Intl.message(
      'Wrong Task List or Password',
      name: 'openError',
      desc: '',
      args: [],
    );
  }

  /// `New Name`
  String get newName {
    return Intl.message(
      'New Name',
      name: 'newName',
      desc: '',
      args: [],
    );
  }

  /// `Cancel`
  String get cancel {
    return Intl.message(
      'Cancel',
      name: 'cancel',
      desc: '',
      args: [],
    );
  }

  /// `Update`
  String get update {
    return Intl.message(
      'Update',
      name: 'update',
      desc: '',
      args: [],
    );
  }

  /// `Task Title`
  String get taskTitle {
    return Intl.message(
      'Task Title',
      name: 'taskTitle',
      desc: '',
      args: [],
    );
  }

  /// `Create`
  String get create {
    return Intl.message(
      'Create',
      name: 'create',
      desc: '',
      args: [],
    );
  }

  /// `New Category`
  String get newCategory {
    return Intl.message(
      'New Category',
      name: 'newCategory',
      desc: '',
      args: [],
    );
  }

  /// `New Task`
  String get newTask {
    return Intl.message(
      'New Task',
      name: 'newTask',
      desc: '',
      args: [],
    );
  }

  /// `Task`
  String get task {
    return Intl.message(
      'Task',
      name: 'task',
      desc: '',
      args: [],
    );
  }

  /// `Comment`
  String get comment {
    return Intl.message(
      'Comment',
      name: 'comment',
      desc: '',
      args: [],
    );
  }

  /// `Category`
  String get category {
    return Intl.message(
      'Category',
      name: 'category',
      desc: '',
      args: [],
    );
  }

  /// `Category List (tap or drag)`
  String get categoryList {
    return Intl.message(
      'Category List (tap or drag)',
      name: 'categoryList',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Default Category`
  String get defaultCategory {
    return Intl.message(
      'Default Category',
      name: 'defaultCategory',
      desc: '',
      args: [],
    );
  }

  /// `No Category`
  String get noCategory {
    return Intl.message(
      'No Category',
      name: 'noCategory',
      desc: '',
      args: [],
    );
  }

  /// `Category Name`
  String get categoryName {
    return Intl.message(
      'Category Name',
      name: 'categoryName',
      desc: '',
      args: [],
    );
  }

  /// `Exit`
  String get exit {
    return Intl.message(
      'Exit',
      name: 'exit',
      desc: '',
      args: [],
    );
  }

  /// `Background`
  String get background {
    return Intl.message(
      'Background',
      name: 'background',
      desc: '',
      args: [],
    );
  }

  /// `Image`
  String get image {
    return Intl.message(
      'Image',
      name: 'image',
      desc: '',
      args: [],
    );
  }

  /// `Color`
  String get color {
    return Intl.message(
      'Color',
      name: 'color',
      desc: '',
      args: [],
    );
  }

  /// `Clear`
  String get clear {
    return Intl.message(
      'Clear',
      name: 'clear',
      desc: '',
      args: [],
    );
  }

  /// `Show Quick Add`
  String get show_quick_add {
    return Intl.message(
      'Show Quick Add',
      name: 'show_quick_add',
      desc: '',
      args: [],
    );
  }

  /// `Tasks`
  String get tasks {
    return Intl.message(
      'Tasks',
      name: 'tasks',
      desc: '',
      args: [],
    );
  }

  /// `Categories`
  String get categories {
    return Intl.message(
      'Categories',
      name: 'categories',
      desc: '',
      args: [],
    );
  }

  /// `Add New`
  String get add_new {
    return Intl.message(
      'Add New',
      name: 'add_new',
      desc: '',
      args: [],
    );
  }

  // skipped getter for the 'current' key

  /// `Current List Changed`
  String get current_list_changed {
    return Intl.message(
      'Current List Changed',
      name: 'current_list_changed',
      desc: '',
      args: [],
    );
  }

  /// `You current list was changed to `
  String get current_list_changed_to {
    return Intl.message(
      'You current list was changed to ',
      name: 'current_list_changed_to',
      desc: '',
      args: [],
    );
  }

  /// `Delete List `
  String get delete_list {
    return Intl.message(
      'Delete List ',
      name: 'delete_list',
      desc: '',
      args: [],
    );
  }

  /// `All tasks in list also will be deleted`
  String get task_delete_too {
    return Intl.message(
      'All tasks in list also will be deleted',
      name: 'task_delete_too',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `New List`
  String get new_list {
    return Intl.message(
      'New List',
      name: 'new_list',
      desc: '',
      args: [],
    );
  }

  /// `My Lists`
  String get my_lists {
    return Intl.message(
      'My Lists',
      name: 'my_lists',
      desc: '',
      args: [],
    );
  }

  /// `Field is required`
  String get field_required {
    return Intl.message(
      'Field is required',
      name: 'field_required',
      desc: '',
      args: [],
    );
  }

  /// `Recent Lists`
  String get recent_lists {
    return Intl.message(
      'Recent Lists',
      name: 'recent_lists',
      desc: '',
      args: [],
    );
  }

  /// `Select Color`
  String get select_color {
    return Intl.message(
      'Select Color',
      name: 'select_color',
      desc: '',
      args: [],
    );
  }

  /// `Select Shade Color`
  String get select_shade_color {
    return Intl.message(
      'Select Shade Color',
      name: 'select_shade_color',
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
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
