import 'dart:ui';

const String income_category_table = 'income_category_table';

class CategoryFields {
  static final List<String> values = [
    /// Add all fields
    id,
    name,
    parent_id,
    path,
    status,
    color,
  created_by,
  created_at,
  updated_at
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String parent_id = 'parent_id';
  static const String path = 'path';
  static const String status = 'status';
  static const String color = 'color';
  static const String created_by = 'created_by';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
}

class IncomeCategory {
  int? id;
  String? name;
  int? parentId;
  String? path;
  int? status;
  Color color;
  String? created_by;
  String? created_at;
  String? updated_at;

  IncomeCategory(
      {this.id,
      this.name,
      this.parentId,
      this.path,
      this.status,
      required this.color,this.created_at,this.created_by,this.updated_at});

  factory IncomeCategory.fromMap(Map<String, dynamic> map) {
    return IncomeCategory(
      id: map['id'],
      name: map['name'],
      parentId: map['parent_id'],
      path: map['path'],
      status: map['status'],
      color: Color(map['color']),
      created_by: map['created_by'],
      created_at: map['created_at'],
      updated_at: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'path': path,
      'status': status,
      'color': color.value,
      'created_by': created_by,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }

  static IncomeCategory fromJson(Map<String, Object?> json) => IncomeCategory(
    //   user_id: json[ProfileTableFields.user_id] as int,
    id: json[CategoryFields.id] as int,
    name: json[CategoryFields.name] as String,
    color: Color(json[CategoryFields.color] as int),
    path: json[CategoryFields.path] as String,
  );
}
