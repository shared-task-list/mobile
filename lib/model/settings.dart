import 'dart:convert';

import 'package:meta/meta.dart';

class Settings {
  final int id;
  String defaultCategory;
  String name;
  bool isShowCategories;

  Settings({this.id, @required this.defaultCategory, @required this.isShowCategories, this.name});

  factory Settings.fromJson(String str) => Settings.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Settings.fromMap(Map<String, dynamic> json) => Settings(
        id: json["id"],
        defaultCategory: json["default_category"],
        isShowCategories: json["is_show_categories"] == 1 ? true : false,
        name: json["default_category"] ?? '',
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "default_category": defaultCategory ?? '',
        "is_show_categories": isShowCategories ? 1 : 0,
        "name": name,
      };
}
