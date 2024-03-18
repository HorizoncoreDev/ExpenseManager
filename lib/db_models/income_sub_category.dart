const String income_sub_category_table = 'income_sub_category_table';

class IncomeSubCategoryFields {
  static final List<String> values = [
    /// Add all fields
    id,
    name,
    categoryId,
    priority
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String categoryId = 'category_id';
  static const String priority = 'priority';
}

class IncomeSubCategory{
  int? id;
  String? name;
  int? categoryId;
  String? priority;

  IncomeSubCategory({
    this.id,
    this.name,
    this.categoryId,
    this.priority,
  });

  factory IncomeSubCategory.fromMap(Map<String, dynamic> map) {
    return IncomeSubCategory(
      id: map['id'],
      name: map['name'],
      categoryId: map['category_id'],
      priority: map['priority'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'priority': priority,
    };
  }
}
