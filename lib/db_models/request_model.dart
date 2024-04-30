const String request_table = 'request_table';

class RequestTableFields {
  static final List<String> values = [
    /// Add all fields
    id,
    requester_email,
    requester_name,
    receiver_email,
    status,
   created_at
  ];

  static const String id = 'id';
  static const String requester_email = 'requester_email';
  static const String requester_name = 'requester_name';
  static const String receiver_email = 'receiver_email';
  static const String status = 'status';
  static const String created_at = 'created_at';

}

class RequestModel {
  int? id;
  String? requester_email;
  String? requester_name;
  String? receiver_email;
  int? status;
  String? created_at;

  RequestModel({
    this.id,
    this.requester_email,
    this.requester_name,
    this.receiver_email,
    this.status,
    this.created_at,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'],
      requester_email: map['requester_email'],
      requester_name: map['requester_name'],
      receiver_email: map['receiver_email'],
      status: map['status'],
      created_at: map['created_at'],
    );
  }

  static RequestModel fromJson(Map<String, Object?> json) => RequestModel(
        id: json[RequestTableFields.id] as int,
    requester_email: json[RequestTableFields.requester_email] as String,
    requester_name: json[RequestTableFields.requester_name] as String,
    receiver_email: json[RequestTableFields.receiver_email] as String,
    status: json[RequestTableFields.status] as int,
    created_at: json[RequestTableFields.created_at] as String,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'requester_email': requester_email,
      'requester_name': requester_name,
      'receiver_email': receiver_email,
      'status': status,
      'created_at': created_at,
    };
  }
}
