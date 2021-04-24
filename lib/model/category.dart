import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_task_list/common/constant.dart';
import 'package:shared_task_list/common/db/db_provider.dart';
import 'package:shared_task_list/common/extension/string_extension.dart';

class Category {
  int? id;
  int order;
  String name;
  String colorString;
  bool isExpand;

  Category({
    this.id,
    required this.name,
    this.colorString = '',
    this.order = 0,
    this.isExpand = true,
  });

  factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        colorString: json["color_string"],
        order: json["order"] ?? 0,
        isExpand: json["is_expand"] == 1 ? true : false,
      );

  Map<String, dynamic> toMap() => {
        // "id": id,
        "name": name,
        "color_string": colorString,
        "order": order,
        "is_expand": getExpand(),
      };

  Future save() async {
    var db = await DBProvider.db.database;
    await db.insert('categories', toMap());
  }

  Color getColor() {
    if (colorString.isEmpty) {
      return Constant.defaultCategoryColor;
    }

    return colorString.toColor();
  }

  int getExpand() {
    return isExpand ? 1 : 0;
  }
}
