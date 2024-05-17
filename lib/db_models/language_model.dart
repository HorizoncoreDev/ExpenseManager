const String language_table = 'language_table';

class LanguageFields {
  static final List<String> values = [
    /// Add all fields
    id,
    name,
    code,
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String code = 'code';
}

class LanguageCategory {
  int? id;
  String? name;
  String? code;

  LanguageCategory({
    this.id,
    this.name,
    this.code,
  });

  factory LanguageCategory.fromMap(Map<String, dynamic> map) {
    return LanguageCategory(
      id: map['id'],
      name: map['name'],
      code: map['code'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }
}
