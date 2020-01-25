import 'dart:convert';

class TaskList {
  int id;
  String name;
  String password;
  DateTime updatedAt;

  TaskList({
    this.id,
    this.name,
    this.password,
    this.updatedAt,
  });

  factory TaskList.fromJson(String str) => TaskList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TaskList.fromMap(Map<String, dynamic> json) => TaskList(
        id: json["id"],
        name: json["name"],
        password: json["password"],
        updatedAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "password": password,
        "updated_at": updatedAt.toIso8601String(),
      };
}
