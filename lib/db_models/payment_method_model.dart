const String payment_method_table = 'payment_method_table';

class PaymentMethod {
  int? id;
  String? name;
  int? status;
  String? icon;

  PaymentMethod({this.id, this.name, this.status, this.icon});

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      name: map['name'],
      status: map['status'],
      icon: map['icon'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'icon': icon,
    };
  }

  static PaymentMethod fromJson(Map<String, Object?> json) => PaymentMethod(
    //   user_id: json[ProfileTableFields.user_id] as int,
    id: json[PaymentMethodFields.id] as int,
    name: json[PaymentMethodFields.name] as String,
    icon: json[PaymentMethodFields.icon] as String,
    status: json[PaymentMethodFields.status] as int,
  );
}

class PaymentMethodFields {
  static final List<String> values = [
    /// Add all fields
    id,
    name,
    icon,
    status
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String icon = 'icon';
  static const String status = 'status';
}
