const String profile_table = 'profile_table';

class ProfileModel {
 // int? user_id;
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
  String? lang_code;
  String? currency_code;
  String? currency_symbol;
 /* int? register_type;//(1=Gmail, 2=Facebook, 3=Mobile, 4=Email)
  String? register_otp;*/
  String? created_at;
  String? updated_at;


  ProfileModel({
   // this.user_id,
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
    this.lang_code,
    this.currency_code,
    this.currency_symbol,
   /* this.register_type,
    this.register_otp,*/
    this.created_at,
    this.updated_at
  });

  factory ProfileModel.fromMap(Map<dynamic, dynamic> map) {
    return ProfileModel(
        // user_id: map['user_id'],
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
        fcm_token: map['fcm_token'],
        lang_code: map['lang_code'],
        currency_code: map['currency_code'],
       /* register_type: map['register_type'],
        register_otp: map['register_otp'],*/
        created_at: map['created_at'] ,
        updated_at: map['updated_at'],
        currency_symbol: map['currency_symbol']);

  }

  Map<String, dynamic> toMap() {
    return {
     //  'user_id': user_id,
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
      'fcm_token': fcm_token,
      'lang_code': lang_code,
      'currency_code': currency_code,
      'currency_symbol': currency_symbol,
      /*'register_type': register_type,
      'register_otp': register_otp,*/
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }

  static ProfileModel fromJson(Map<String, Object?> json) => ProfileModel(
      //   user_id: json[ProfileTableFields.user_id] as int,
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
        fcm_token: json[ProfileTableFields.fcm_token] as String,
        lang_code: json[ProfileTableFields.lang_code] as String,
        currency_code: json[ProfileTableFields.currency_code] as String,
        currency_symbol: json[ProfileTableFields.currency_symbol] as String,
     /*   register_type: json[ProfileTableFields.register_type] as int,
        register_otp: json[ProfileTableFields.register_otp] as String,*/
        created_at: json[ProfileTableFields.created_at] as String,
        updated_at: json[ProfileTableFields.updated_at] as String,
      );
}

class ProfileTableFields {
  static final List<String> values = [
    /// Add all fields
   //  user_id,
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
    fcm_token,
    lang_code,
    currency_code,
    currency_symbol,
  /*  register_type,
    register_otp,*/
    created_at,
    updated_at
  ];

   static const String user_id = 'user_id';
  /* static const String register_type = 'register_type';
   static const String register_otp = 'register_otp';*/
   static const String created_at = 'created_at';
   static const String updated_at = 'updated_at';
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
  static const String lang_code = 'lang_code';
  static const String currency_code = 'currency_code';
  static const String currency_symbol = 'currency_symbol';
}
