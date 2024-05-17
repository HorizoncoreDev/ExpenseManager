import 'package:expense_manager/db_models/transaction_model.dart';

class DateWiseTransactionModel {
  String? transactionDate;
  int? transactionTotal;
  String? transactionDay;
  List<TransactionModel>? transactions;

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
      transactions: List<TransactionModel>.from((json['transactions'] ?? [])
          .map((transaction) => TransactionModel.fromJson(transaction))),
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
