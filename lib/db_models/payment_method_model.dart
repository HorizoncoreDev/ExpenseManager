const String payment_method_table = 'payment_method_table';

class PaymentMethodFields {
  static final List<String> values = [
    /// Add all fields
    id,
    name,
    status
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String status = 'status';
}

class PaymentMethod {
  int? id;
  String? name;
  int? status;

  PaymentMethod({
    this.id,
    this.name,
    this.status,
  });

  factory PaymentMethod.fromMap(Map<String, dynamic> map) {
    return PaymentMethod(
      id: map['id'],
      name: map['name'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'status': status,
    };
  }
}
