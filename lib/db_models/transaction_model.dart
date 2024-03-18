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
    payer_id,
    payee_id,
    payment_method_id,
    status,
    check_no,
    description,
    currency_id,
    receipt_image,
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
  static const String payer_id = 'payer_id';
  static const String payee_id = 'payee_id';
  static const String payment_method_id = 'payment_method_id';
  static const String status = 'status';
  static const String check_no = 'check_no';
  static const String description = 'description';
  static const String currency_id = 'currency_id';
  static const String receipt_image = 'receipt_image';
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
  int? payer_id;
  int? payee_id;
  int? payment_method_id;
  int? status;
  String? check_no;
  String? description;
  int? currency_id;
  String? receipt_image;
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
    this.payer_id,
    this.payee_id,
    this.payment_method_id,
    this.status,
    this.check_no,
    this.description,
    this.currency_id,
    this.receipt_image,
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
      payer_id: map['payer_id'],
      payee_id: map['payee_id'],
      payment_method_id: map['payment_method_id'],
      status: map['status'],
      check_no: map['check_no'],
      description: map['description'],
      currency_id: map['currency_id'],
      receipt_image: map['receipt_image'],
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
      'payer_id': payer_id,
      'payee_id': payee_id,
      'payment_method_id': payment_method_id,
      'status': status,
      'check_no': check_no,
      'description': description,
      'currency_id': currency_id,
      'receipt_image': receipt_image,
      'created_at': created_at/*DateTime.parse(createdAt as String)*/, // Convert String to DateTime
      'last_updated': last_updated/*DateTime.parse(lastUpdated as String)*/,
    };
  }
}
