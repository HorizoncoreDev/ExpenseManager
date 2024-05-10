import 'dart:ui';

const String transaction_table = 'transaction_table';

class TransactionFields {
  static final List<String> values = [
    /// Add all fields
    // id,
    key,
    // member_id,
    member_email,
    amount,
    expense_cat_id,
    income_cat_id,
    sub_expense_cat_id,
    sub_income_cat_id,
    cat_name,
    cat_color,
    cat_icon,
    payment_method_id,
    payment_method_name,
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

  // static const String id = 'id';
  static const String key = 'key';
  // static const String member_id = 'member_id';
  static const String member_email = 'member_email';
  static const String amount = 'amount';
  static const String expense_cat_id = 'expense_cat_id';
  static const String income_cat_id = 'income_cat_id';
  static const String sub_expense_cat_id = 'sub_expense_cat_id';
  static const String sub_income_cat_id = 'sub_income_cat_id';
  static const String cat_name = 'cat_name';
  static const String cat_type = 'cat_type';
  static const String cat_color = 'cat_color';
  static const String cat_icon = 'cat_icon';
  static const String payment_method_id = 'payment_method_id';
  static const String payment_method_name = 'payment_method_name';
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
  // int? id;
  // int? member_id;
  String? member_email;
  String? key;
  int? amount;
  int? expense_cat_id;
  int? income_cat_id;
  int? sub_expense_cat_id;
  int? sub_income_cat_id;
  String? cat_name;
  int? cat_type;
  Color? cat_color;
  String? cat_icon;
  String? payment_method_name;
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
    // this.id,
    // this.member_id,
    this.key,
    this.member_email,
    this.amount,
    this.expense_cat_id,
    this.income_cat_id,
    this.sub_expense_cat_id,
    this.sub_income_cat_id,
    this.cat_name,
    this.cat_type,
    this.cat_color,
    this.cat_icon,
    this.payment_method_id,
    this.payment_method_name,
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

  factory TransactionModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionModel(
      // id: map['id'],
      key: map['key'],
      // member_id: map['member_id'],
      member_email: map['member_email'],
      amount: map['amount'],
      expense_cat_id: map['expense_cat_id'],
      income_cat_id: map['income_cat_id'],
      sub_expense_cat_id: map['sub_expense_cat_id'],
      sub_income_cat_id: map['sub_income_cat_id'],
      cat_name: map['cat_name'],
      cat_type: map['cat_type'],
      cat_color: Color(map['cat_color']),
      cat_icon: map['cat_icon'],
      payment_method_id: map['payment_method_id'],
      payment_method_name: map['payment_method_name'],
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
      // 'id': id,
      'key': key,
      // 'member_id': member_id,
      'member_email': member_email,
      'amount': amount,
      'expense_cat_id': expense_cat_id,
      'income_cat_id': income_cat_id,
      'sub_expense_cat_id': sub_expense_cat_id,
      'sub_income_cat_id': sub_income_cat_id,
      'cat_name': cat_name,
      'cat_type': cat_type,
      'cat_icon': cat_icon,
      'cat_color': cat_color!.value,
      'payment_method_id': payment_method_id,
      'payment_method_name': payment_method_name,
      'status': status,
      'transaction_date': transaction_date,
      'transaction_type': transaction_type,
      'description': description,
      'currency_id': currency_id,
      'receipt_image1': receipt_image1,
      'receipt_image2': receipt_image2,
      'receipt_image3': receipt_image3,
      'created_at': created_at /*DateTime.parse(createdAt as String)*/,
      // Convert String to DateTime
      'last_updated': last_updated /*DateTime.parse(lastUpdated as String)*/,
    };
  }

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      // id: json['id'],
      key: json['key'],
      // member_id: json['member_id'],
      member_email: json['member_email'],
      amount: json['amount'],
      expense_cat_id: json['expense_cat_id'],
      income_cat_id: json['income_cat_id'],
      sub_expense_cat_id: json['sub_expense_cat_id'],
      sub_income_cat_id: json['sub_income_cat_id'],
      cat_name: json['cat_name'],
      cat_type: json['cat_type'],
      cat_icon: json['cat_icon'],
      cat_color: json['cat_color'],
      payment_method_id: json['payment_method_id'],
      payment_method_name: json['payment_method_name'],
      status: json['status'],
      transaction_date: json['transaction_date'],
      transaction_type: json['transaction_type'],
      description: json['description'],
      currency_id: json['currency_id'],
      receipt_image1: json['receipt_image1'],
      receipt_image2: json['receipt_image2'],
      receipt_image3: json['receipt_image3'],
      created_at: json['created_at'],
      last_updated: json['last_updated'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      // 'id': id,
      'key': key,
      // 'member_id': member_id,
      'member_email': member_email,
      'amount': amount,
      'expense_cat_id': expense_cat_id,
      'income_cat_id': income_cat_id,
      'sub_expense_cat_id': sub_expense_cat_id,
      'sub_income_cat_id': sub_income_cat_id,
      'cat_name': cat_name,
      'cat_typ': cat_type,
      'cat_icon': cat_icon,
      'cat_color': cat_color,
      'payment_method_id': payment_method_id,
      'payment_method_name': payment_method_name,
      'status': status,
      'transaction_date': transaction_date,
      'transaction_type': transaction_type,
      'description': description,
      'currency_id': currency_id,
      'receipt_image1': receipt_image1,
      'receipt_image2': receipt_image2,
      'receipt_image3': receipt_image3,
      'created_at': created_at,
      'last_updated': last_updated,
    };
  }
}
