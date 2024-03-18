const String profile_table = 'profile_table';

class ProfileTableFields {
  static final List<String> values = [
    /// Add all fields
    id,
    first_name,
    last_name,
    email,
    full_name,
    dob,
    profile_image,
    mobile_number,
    gender
  ];

  static const String id = 'id';
  static const String first_name = 'first_name';
  static const String last_name = 'last_name';
  static const String email = 'email';
  static const String full_name = 'full_name';
  static const String dob = 'dob';
  static const String profile_image = 'profile_image';
  static const String mobile_number = 'mobile_number';
  static const String gender = 'gender';
}

class ProfileModel {
  int? id;
  String? first_name;
  String? last_name;
  String? email;
  String? full_name;
  String? dob;
  String? profile_image;
  String? mobile_number;
  String? gender;

  ProfileModel({
    this.id,
    this.first_name,
    this.last_name,
    this.email,
    this.full_name,
    this.dob,
    this.profile_image,
    this.mobile_number,
    this.gender,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
        id: map['id'],
        first_name: map['first_name'],
        last_name: map['last_name'],
        email: map['email'],
        full_name: map['full_name'],
        dob: map['dob'],
        profile_image: map['profile_image'],
        mobile_number: map['mobile_number'],
        gender: map['gender'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'first_name': first_name,
      'last_name': last_name,
      'email': email,
      'full_name': full_name,
      'dob': dob,
      'profile_image': profile_image,
      'mobile_number': mobile_number,
      'gender': gender,
    };
  }
}