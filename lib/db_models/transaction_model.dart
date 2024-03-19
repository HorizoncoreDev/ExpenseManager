const String transaction_table = 'transaction_table';

class TransactionFields {
  static final List<String> values = [
    /// Add all fields
    id,
    member_id,
    amount,
    expense_cat_id,
    income_cat_id,
    sub_expense_cat_id,
    sub_income_cat_id,
    payment_method_id,
    status,
    transaction_date,
    transaction_type,
    description,
    currency_id,
    receipt_image1,
    receipt_image2,
    receipt_image3,
    created_at,
    last_updated
  ];

  static const String id = 'id';
  static const String member_id = 'member_id';
  static const String amount = 'amount';
  static const String expense_cat_id = 'expense_cat_id';
  static const String income_cat_id = 'income_cat_id';
  static const String sub_expense_cat_id = 'sub_expense_cat_id';
  static const String sub_income_cat_id = 'sub_income_cat_id';
  static const String payment_method_id = 'payment_method_id';
  static const String status = 'status';
  static const String transaction_date = 'transaction_date';
  static const String transaction_type = 'transaction_type';
  static const String description = 'description';
  static const String currency_id = 'currency_id';
  static const String receipt_image1 = 'receipt_image1';
  static const String receipt_image2 = 'receipt_image2';
  static const String receipt_image3 = 'receipt_image3';
  static const String created_at = 'created_at';
  static const String last_updated = 'last_updated';
}

class TransactionModel {
  int? id;
  int? member_id;
  double? amount;
  int? expense_cat_id;
  int? income_cat_id;
  int? sub_expense_cat_id;
  int? sub_income_cat_id;
  int? payment_method_id;
  int? status;
  String? description;
  int? transaction_type;
  String? transaction_date;
  int? currency_id;
  String? receipt_image1;
  String? receipt_image2;
  String? receipt_image3;
  String? created_at;
  String? last_updated;

  TransactionModel({
    this.id,
    this.member_id,
    this.amount,
    this.expense_cat_id,
    this.income_cat_id,
    this.sub_expense_cat_id,
    this.sub_income_cat_id,
    this.payment_method_id,
    this.status,
    this.transaction_date,
    this.transaction_type,
    this.description,
    this.currency_id,
    this.receipt_image1,
    this.receipt_image2,
    this.receipt_image3,
    this.created_at,
    this.last_updated,
  });

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      member_id: map['member_id'],
      amount: map['amount'],
      expense_cat_id: map['expense_cat_id'],
      income_cat_id: map['income_cat_id'],
      sub_expense_cat_id: map['sub_expense_cat_id'],
      sub_income_cat_id: map['sub_income_cat_id'],
      payment_method_id: map['payment_method_id'],
      status: map['status'],
      transaction_date: map['transaction_date'],
      description: map['description'],
      transaction_type: map['transaction_type'],
      currency_id: map['currency_id'],
      receipt_image1: map['receipt_image1'],
      receipt_image2: map['receipt_image2'],
      receipt_image3: map['receipt_image3'],
      created_at: map['created_at'],
      last_updated: map['last_updated'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': member_id,
      'amount': amount,
      'expense_cat_id': expense_cat_id,
      'income_cat_id': income_cat_id,
      'sub_expense_cat_id': sub_expense_cat_id,
      'sub_income_cat_id': sub_income_cat_id,
      'payment_method_id': payment_method_id,
      'status': status,
      'transaction_date': transaction_date,
      'transaction_type': transaction_type,
      'description': description,
      'currency_id': currency_id,
      'receipt_image1': receipt_image1,
      'receipt_image2': receipt_image2,
      'receipt_image3': receipt_image3,
      'created_at': created_at/*DateTime.parse(createdAt as String)*/, // Convert String to DateTime
      'last_updated': last_updated/*DateTime.parse(lastUpdated as String)*/,
    };
  }
}
