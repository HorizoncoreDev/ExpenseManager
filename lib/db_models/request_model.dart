const String request_table = 'request_table';

class RequestTableFields {
  static final List<String> values = [
    /// Add all fields
    id,
    key,
    requester_email,
    requester_name,
    receiver_email,
    receiver_name,
    status,
   created_at
  ];

  static const String id = 'id';
  static const String key = 'key';
  static const String requester_email = 'requester_email';
  static const String requester_name = 'requester_name';
  static const String receiver_email = 'receiver_email';
  static const String receiver_name = 'receiver_name';
  static const String status = 'status';
  static const String created_at = 'created_at';

}

class RequestModel {
  int? id;
  String? requester_email;
  String? requester_name;
  String? receiver_email;
  String? receiver_name;
  int? status;
  String? created_at;
  String? key;

  RequestModel({
    this.id,
    this.key,
    this.requester_email,
    this.requester_name,
    this.receiver_email,
    this.receiver_name,
    this.status,
    this.created_at,
  });

  factory RequestModel.fromMap(Map<String, dynamic> map) {
    return RequestModel(
      id: map['id'],
      key: map['key'],
      requester_email: map['requester_email'],
      requester_name: map['requester_name'],
      receiver_email: map['receiver_email'],
      receiver_name: map['receiver_name'],
      status: map['status'],
      created_at: map['created_at'],
    );
  }

  static RequestModel fromJson(Map<String, Object?> json) => RequestModel(
        id: json[RequestTableFields.id] as int,
    requester_email: json[RequestTableFields.requester_email] as String,
    key: json[RequestTableFields.key] as String,
    requester_name: json[RequestTableFields.requester_name] as String,
    receiver_email: json[RequestTableFields.receiver_email] as String,
    receiver_name: json[RequestTableFields.receiver_name] as String,
    status: json[RequestTableFields.status] as int,
    created_at: json[RequestTableFields.created_at] as String,
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'requester_email': requester_email,
      'requester_name': requester_name,
      'receiver_email': receiver_email,
      'receiver_name': receiver_name,
      'status': status,
      'created_at': created_at,
    };
  }


}
