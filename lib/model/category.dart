import 'dart:convert';

import 'package:meta/meta.dart';
import 'package:shared_task_list/common/db/db_provider.dart';

class Category {
  int id;
  final String name;

  Category({
    this.id,
    @required this.name,
  });

  factory Category.fromJson(String str) => Category.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory Category.fromMap(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
      };

  Future save() async {
    var db = await DBProvider.db.database;
    await db.insert('categories', toMap());
  }
}
