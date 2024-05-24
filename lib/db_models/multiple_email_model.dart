import 'package:expense_manager/db_models/transaction_model.dart';

class MultipleEmailModel {
  Map<String, String> csv;
  List<String> receiversName;

  MultipleEmailModel({
    Map<String, String>? csv,
    List<String>? receiversName,
  })  : csv = csv ?? {},
        receiversName = receiversName ?? [];

  factory MultipleEmailModel.fromMap(Map<String, dynamic> map) {
    return MultipleEmailModel(
      csv: Map<String, String>.from(map['csv']),
      receiversName: List<String>.from(map['receiversName']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'csv': csv,
      'receiversName': receiversName,
    };
  }
}
