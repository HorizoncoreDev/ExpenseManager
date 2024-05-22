import 'package:expense_manager/db_models/transaction_model.dart';

class ReceiverEmailData {
  String? receiverEmail;
  String? receiverName;
  List<TransactionModel>? transactionModel;

  ReceiverEmailData({
    this.receiverEmail,
    this.receiverName,
    this.transactionModel,
  });

  factory ReceiverEmailData.fromMap(Map<String, dynamic> map) {
    return ReceiverEmailData(
      receiverEmail: map['receiverEmail'],
      receiverName: map['receiverName'],
      transactionModel: map['transactionModel'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'receiverEmail': receiverEmail,
      'receiverName': receiverName,
      'transactionModel': transactionModel,
    };
  }
}

