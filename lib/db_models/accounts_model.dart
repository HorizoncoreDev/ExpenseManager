
const String accounts_table = 'accounts_table';

class AccountTableFields {
  static final List<String> values = [
    /// Add all fields
   // account_id,
    key,
    owner_user_key,
    account_name,
    description,
    budget,
    balance,
    income,
    balance_date,
    account_status,
    created_at,
    updated_at
  ];

 // static const String account_id = 'account_id';
  static const String key = 'key';
  static const String owner_user_key = 'owner_user_key';
  static const String account_name = 'account_name';
  static const String description = 'description';
  static const String budget = 'budget';
  static const String balance = 'balance';
  static const String income = 'income';
  static const String balance_date = 'balance_date';
  static const String account_status = 'account_status';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
}

class AccountsModel {
 // int? account_id;
  String? key;
  String? owner_user_key;
  String? account_name;
  String? description;
  String? budget;
  String? balance;
  String? income;
  String? balance_date;
  int? account_status;
  String? created_at;
  String? updated_at;

  AccountsModel(
      {
       // this.account_id,
        this.key,
        this.owner_user_key,
        this.account_name,
        this.description,
        this.budget,
        this.balance,
        this.income,
        this.balance_date,
        this.account_status,
        this.created_at,
        this.updated_at
      });

  factory AccountsModel.fromMap(Map<dynamic, dynamic> map) {
    return AccountsModel(
     // account_id: map['account_id'],
      key: map['key'],
      owner_user_key: map['owner_user_key'],
      account_name: map['account_name'],
      description: map['description'],
      budget: map['budget'],
      balance: map['balance'],
      income: map['income'],
      balance_date: map['balance_date'],
      account_status: map['account_status'],
      created_at: map['created_at'],
      updated_at: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
     // 'account_id': account_id,
      'key': key,
      'owner_user_key': owner_user_key,
      'account_name': account_name,
      'description': description,
      'budget': budget,
      'balance': balance,
      'income': income,
      'balance_date': balance_date,
      'account_status': account_status,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
}
