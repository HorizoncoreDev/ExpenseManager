import 'package:expense_manager/db_models/transaction_model.dart';

class MultipleEmailModel {
  String? csv;
  List<String>? receiversName;

  MultipleEmailModel({
    this.csv,
    this.receiversName,
  });

  factory MultipleEmailModel.fromMap(Map<String, dynamic> map) {
    return MultipleEmailModel(
      csv: map['csv'],
      receiversName: map['receiversName'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'csv': csv,
      'receiversName': receiversName,
    };
  }
}

