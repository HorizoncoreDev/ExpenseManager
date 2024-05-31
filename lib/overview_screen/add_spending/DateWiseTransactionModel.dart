import 'package:expense_manager/db_models/transaction_model.dart';

import '../../db_models/transaction_new_model.dart';

class DateWiseTransactionModel {
  String? transactionDate;
  int? transactionTotal;
  String? transactionDay;
  List<TransactionNewModel>? transactions;

  DateWiseTransactionModel({
    this.transactionDate,
    this.transactionTotal,
    this.transactionDay,
    this.transactions,
  });

  factory DateWiseTransactionModel.fromJson(Map<String, dynamic> json) {
    return DateWiseTransactionModel(
      transactionDate: json['transactionDate'],
      transactionTotal: json['transactionTotal'],
      transactionDay: json['transactionDay'],
      transactions: List<TransactionNewModel>.from((json['transactions'] ?? [])
          .map((transaction) => TransactionNewModel.fromJson(transaction))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transactionDate': transactionDate,
      'transactionTotal': transactionTotal,
      'transactionDay': transactionDay,
      'transactions':
          transactions?.map((transaction) => transaction.toJson()).toList(),
    };
  }
}
