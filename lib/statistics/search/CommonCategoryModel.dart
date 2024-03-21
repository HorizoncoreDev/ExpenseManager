import 'dart:ui';

import 'package:expense_manager/db_models/transaction_model.dart';


class CommonCategoryModel {
  int? catId;
  String? catName;
  bool isSelected;

  CommonCategoryModel({
    this.catId,
    this.catName,
    this.isSelected = false, // Default value is false
  });

  factory CommonCategoryModel.fromJson(Map<String, dynamic> json) {
    return CommonCategoryModel(
      catId: json['catId'],
      catName: json['catName'],
      isSelected: json['isSelected'] ?? false, // Set isSelected from JSON or default to false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catId': catId,
      'catName': catName,
      'isSelected': isSelected,
    };
  }
}
