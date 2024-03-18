const String user_table = 'user_table';

class UserTableFields {
  static final List<String> values = [
    /// Add all fields
    id,
    username,
    password,
    email,
    full_name,
    current_balance,
    profile_image,
    mobile_number,
    created_at,
    last_updated
  ];

  static const String id = 'id';
  static const String username = 'username';
  static const String password = 'password';
  static const String email = 'email';
  static const String full_name = 'full_name';
  static const String current_balance = 'current_balance';
  static const String profile_image = 'profile_image';
  static const String mobile_number = 'mobile_number';
  static const String created_at = 'created_at';
  static const String last_updated = 'last_updated';

}

class UserModel {
  int? id;
  String? username;
  String? password;
  String? email;
  String? full_name;
  String? current_balance;
  String? profile_image;
  String? mobile_number;
  String? created_at;
  String? last_updated;

  UserModel({
    this.id,
    this.username,
    this.password,
    this.email,
    this.full_name,
    this.current_balance,
    this.profile_image,
    this.mobile_number,
    this.created_at,
    this.last_updated
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      username: map['username'],
      password: map['password'],
      email: map['email'],
      full_name: map['full_name'],
      current_balance: map['current_balance'],
      profile_image: map['profile_image'],
      mobile_number: map['mobile_number'],
      created_at: map['created_at'],
      last_updated: map['last_updated']
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'email': email,
      'full_name': full_name,
      'current_balance': current_balance,
      'profile_image': profile_image,
      'mobile_number': mobile_number,
      'created_at': created_at,
      'last_updated': last_updated
    };
  }
}