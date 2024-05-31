import 'dart:ui';



class TransactionNewModel {
  String? member_key;
  String? account_key;
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

  TransactionNewModel({
    this.key,
    this.member_key,
    this.account_key,
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

  factory TransactionNewModel.fromJson(Map<String, dynamic> json) {
    return TransactionNewModel(
      key: json['key'],
      member_key: json['member_key'],
      account_key: json['account_key'],
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

  factory TransactionNewModel.fromMap(Map<dynamic, dynamic> map) {
    return TransactionNewModel(
      key: map['key'],
      member_key: map['member_key'],
      account_key: map['account_key'],
      amount: map['amount'],
      expense_cat_id: map['expense_cat_id'],
      income_cat_id: map['income_cat_id'],
      sub_expense_cat_id: map['sub_expense_cat_id'],
      sub_income_cat_id: map['sub_income_cat_id'],
      // cat_name: map['cat_name'],
      cat_type: map['cat_type'],
      // cat_color: Color(map['cat_color']),
      // cat_icon: map['cat_icon'],
      payment_method_id: map['payment_method_id'],
      // payment_method_name: map['payment_method_name'],
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

  factory TransactionNewModel.fromMapForCSV(Map<dynamic, dynamic> map) {
    return TransactionNewModel(
      member_key: map['member_key'],
      account_key: map['account_key'],
      amount: map['amount'],
      cat_name: map['cat_name'],
      cat_type: map['cat_type'],
      payment_method_name: map['payment_method_name'],
      transaction_date: map['transaction_date'],
      description: map['description'],
      transaction_type: map['transaction_type'],
      receipt_image1: map['receipt_image1'],
      receipt_image2: map['receipt_image2'],
      receipt_image3: map['receipt_image3'],
      key: map['key'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'member_key': member_key,
      'account_key': account_key,
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

  Map<String, dynamic> toMap() {
    return {
      'key': key,
      'member_key': member_key,
      'account_key': account_key,
      'amount': amount,
      'expense_cat_id': expense_cat_id,
      'income_cat_id': income_cat_id,
      'sub_expense_cat_id': sub_expense_cat_id,
      'sub_income_cat_id': sub_income_cat_id,
      // 'cat_name': cat_name,
      'cat_type': cat_type,
      // 'cat_icon': cat_icon,
      // 'cat_color': cat_color!.value,
      'payment_method_id': payment_method_id,
      // 'payment_method_name': payment_method_name,
      'status': status,
      'transaction_date': transaction_date,
      'transaction_type': transaction_type,
      'description': description,
      'currency_id': currency_id,
      'receipt_image1': receipt_image1,
      'receipt_image2': receipt_image2,
      'receipt_image3': receipt_image3,
      'created_at': created_at ,
      'last_updated': last_updated
    };
  }
}
