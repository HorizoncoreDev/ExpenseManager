import 'dart:ui';

import 'package:expense_manager/db_models/transaction_model.dart';


class CommonCategoryModel {
  int? catId;
  String? catName;

  CommonCategoryModel({
    this.catId,
    this.catName,
  });

  factory CommonCategoryModel.fromJson(Map<String, dynamic> json) {
    return CommonCategoryModel(
      catId: json['catId'],
      catName: json['catName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catId': catId,
      'catName': catName,
    };
  }
}
