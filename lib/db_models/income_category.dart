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
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String parent_id = 'parent_id';
  static const String path = 'path';
  static const String status = 'status';
  static const String color = 'color';
}

class IncomeCategory {
  int? id;
  String? name;
  int? parentId;
  String? path;
  int? status;
  Color color;

  IncomeCategory(
      {this.id,
      this.name,
      this.parentId,
      this.path,
      this.status,
      required this.color});

  factory IncomeCategory.fromMap(Map<String, dynamic> map) {
    return IncomeCategory(
      id: map['id'],
      name: map['name'],
      parentId: map['parent_id'],
      path: map['path'],
      status: map['status'],
      color: Color(map['color']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'path': path,
      'status': status,
      'color': color.value
    };
  }
}
