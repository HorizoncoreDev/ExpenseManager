const String profile_table = 'profile_table';

class ProfileTableFields {
  static final List<String> values = [
    /// Add all fields
    id,
    key,
    first_name,
    last_name,
    email,
    full_name,
    dob,
    user_code,
    profile_image,
    mobile_number,
    current_balance,
    current_income,
    actual_budget,
    gender,
    fcm_token
  ];

  static const String id = 'id';
  static const String key = 'key';
  static const String first_name = 'first_name';
  static const String last_name = 'last_name';
  static const String email = 'email';
  static const String user_code = 'user_code';
  static const String full_name = 'full_name';
  static const String dob = 'dob';
  static const String profile_image = 'profile_image';
  static const String mobile_number = 'mobile_number';
  static const String gender = 'gender';
  static const String current_balance = 'current_balance';
  static const String current_income = 'current_income';
  static const String actual_budget = 'actual_budget';
  static const String fcm_token = 'fcm_token';
}

class ProfileModel {
  int? id;
  String? key;
  String? first_name;
  String? last_name;
  String? email;
  String? full_name;
  String? user_code;
  String? dob;
  String? profile_image;
  String? mobile_number;
  String? current_balance;
  String? current_income;
  String? actual_budget;
  String? gender;
  String? fcm_token;

  ProfileModel({
    this.id,
    this.key,
    this.first_name,
    this.last_name,
    this.email,
    this.full_name,
    this.user_code,
    this.dob,
    this.profile_image,
    this.mobile_number,
    this.current_balance,
    this.current_income,
    this.actual_budget,
    this.gender,
    this.fcm_token,
  });

  factory ProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      key: map['key'],
      first_name: map['first_name'],
      last_name: map['last_name'],
      email: map['email'],
      user_code: map['user_code'],
      full_name: map['full_name'],
      dob: map['dob'],
      profile_image: map['profile_image'],
      mobile_number: map['mobile_number'],
      gender: map['gender'],
      current_balance: map['current_balance'],
      current_income: map['current_income'],
      actual_budget: map['actual_budget'],
      fcm_token: map['fcm_token']
    );
  }

  factory ProfileModel.fromInsertMap(Map<dynamic, dynamic> map) {
    return ProfileModel(
     // id: map['id'],
      key: map['key'],
      first_name: map['first_name'],
      last_name: map['last_name'],
      email: map['email'],
      user_code: map['user_code'],
      full_name: map['full_name'],
      dob: map['dob'],
      profile_image: map['profile_image'],
      mobile_number: map['mobile_number'],
      gender: map['gender'],
      current_balance: map['current_balance'],
      current_income: map['current_income'],
      actual_budget: map['actual_budget'],
      fcm_token: map['fcm_token']
    );
  }

  static ProfileModel fromJson(Map<String, Object?> json) => ProfileModel(
        id: json[ProfileTableFields.id] as int,
        key: json[ProfileTableFields.key] as String,
        first_name: json[ProfileTableFields.first_name] as String,
        last_name: json[ProfileTableFields.last_name] as String,
        email: json[ProfileTableFields.email] as String,
    user_code: json[ProfileTableFields.user_code] as String,
        full_name: json[ProfileTableFields.full_name] as String,
        dob: json[ProfileTableFields.dob] as String,
        profile_image: json[ProfileTableFields.profile_image] as String,
        mobile_number: json[ProfileTableFields.mobile_number] as String,
        gender: json[ProfileTableFields.gender] as String,
        current_balance: json[ProfileTableFields.current_balance] as String,
    current_income: json[ProfileTableFields.current_income] as String,
    actual_budget: json[ProfileTableFields.actual_budget] as String,
    fcm_token: json[ProfileTableFields.fcm_token] as String
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'key': key,
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'full_name': full_name,
      'user_code': user_code,
      'dob': dob,
      'profile_image': profile_image,
      'mobile_number': mobile_number,
      'gender': gender,
      'current_balance': current_balance,
      'current_income': current_income,
      'actual_budget': actual_budget,
      'fcm_token': fcm_token
    };
  }
}
