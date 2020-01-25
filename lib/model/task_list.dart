import 'dart:convert';

class TaskList {
  int id;
  String name;
  String password;

  TaskList({
    this.id,
    this.name,
    this.password,
  });

  factory TaskList.fromJson(String str) => TaskList.fromMap(json.decode(str));

  String toJson() => json.encode(toMap());

  factory TaskList.fromMap(Map<String, dynamic> json) => TaskList(
        id: json["id"],
        name: json["name"],
        password: json["password"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "name": name,
        "password": password,
      };
}
