class AddAccountModel {
  String? name;
  String? description;
  String? budget;
  String? balance;
  String? balanceDate;
  String? status;

  AddAccountModel({
    this.name,
    this.description,
    this.budget,
    this.balance,
    this.balanceDate,
    this.status,
  });

  factory AddAccountModel.fromMap(Map<String, dynamic> map) {
    return AddAccountModel(
      name: map['name'],
      description: map['description'],
      budget: map['budget'],
      balance: map['balance'],
      balanceDate: map['balanceDate'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'budget': budget,
      'balance': balance,
      'balanceDate': balanceDate,
      'status': status,
    };
  }
}

