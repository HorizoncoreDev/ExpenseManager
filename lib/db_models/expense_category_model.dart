/*
import 'dart:convert';

import 'package:flutter/material.dart';

class Category{
  final int? id;
  final String name;
  final Color color;
  final int? icons;

  Category({
    this.id,
    required this.name,
    required this.color,
    this.icons
  });

  // Convert a Category into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icons,
    };
  }

  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      color: Color(map['color']),
      icons: map['icon']?.toInt() ?? 0*/
/*IconData(map['icon'], fontFamily: 'MaterialIcons')*/ /*
,
    );
  }

  String toJson() => json.encode(toMap());

  factory Category.fromJson(String source) => Category.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each Category when using the print statement.
  @override
  String toString() {
    return 'Category(id: $id, name: $name, color: $color, icon: $icons)';
  }
}*/

import 'package:flutter/material.dart';

const String expense_category_table = 'expense_category_table';

class ExpenseCategory {
  int? id;
  String? name;
  Color color;
  String? icons;
  String? created_by;
  String? created_at;
  String? updated_at;

  ExpenseCategory({this.id, this.name, required this.color, this.icons,this.created_at,this.created_by,this.updated_at});

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'],
      name: map['name'],
      color: Color(map['color']),
      icons: map['icon'],
      created_by: map['created_by'],
      created_at: map['created_at'],
      updated_at: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'color': color.value,
      'icon': icons,
      'created_by': created_by,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}

class ExpenseCategoryField {
  static final List<String> values = [
    /// Add all fields
    id,
    name,
    color,
    icons,
    created_by,
    created_at,
    updated_at
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String color = 'color';
  static const String icons = 'icon';
  static const String created_by = 'created_by';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
}
