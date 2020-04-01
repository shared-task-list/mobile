import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:meta/meta.dart';
import 'package:shared_task_list/common/db/db_provider.dart';

class Category {
  int id;
  final String name;
  String colorString;

  Category({
    this.id,
    @required this.name,
    this.colorString,
  });

  factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        colorString: json["color_string"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "color_string": colorString,
      };

  Future save() async {
    var db = await DBProvider.db.database;
    await db.insert('categories', toMap());
  }

  Color getColor() {
    if (colorString == null || colorString.isEmpty) {
      return Colors.grey.shade600;
    }

    var nums = colorString.split(',').map((num) => int.parse(num)).toList();
    return Color.fromARGB(255, nums[0], nums[1], nums[2]);
  }
}
