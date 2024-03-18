
const String expence_category_table = 'expence_category_table';

class ExpenceCategoryFields {
  static final List<String> values = [
    /// Add all fields
    id,
    name,
    parent_id,
    path,
    status
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String parent_id = 'parent_id';
  static const String path = 'path';
  static const String status = 'status';
}

class ExpenseCategory {
  int? id;
  String? name;
  int? parentId;
  String? path;
  int? status;

  ExpenseCategory({
    this.id,
    this.name,
    this.parentId,
    this.path,
    this.status,
  });

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id'],
      name: map['name'],
      parentId: map['parent_id'],
      path: map['path'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'path': path,
      'status': status,
    };
  }
}


/*
import 'dart:convert';

import 'package:flutter/material.dart';

class ExpenseCategory{
  final int? id;
  final String? name;
  final int? parentId;
  final String? path;
  final int? status;

  ExpenseCategory({
    this.id,
    required this.name,
    required this.parentId,
    required this.path,
    required this.status,
  });

  // Convert a ExpenseCategory into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'parent_id': parentId,
      'path': path,
      'status': status,
    };
  }

  factory ExpenseCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseCategory(
      id: map['id']?.toInt() ?? 0,
      name: map['name'] ?? '',
      parentId: Color(map['color']),
      icons: map['icon']?.toInt() ?? 0,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExpenseCategory.fromJson(String source) => ExpenseCategory.fromMap(json.decode(source));

  // Implement toString to make it easier to see information about
  // each Category when using the print statement.
  @override
  String toString() {
    return 'ExpenseCategory(id: $id, name: $name, color: $color, icon: $icons)';
  }
}*/
