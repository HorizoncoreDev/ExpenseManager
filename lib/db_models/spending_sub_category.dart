const String spending_sub_category_table = 'spending_sub_category_table';

class SpendingSubCategoryFields {
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

class SpendingSubCategory {
  int? id;
  String? name;
  int? categoryId;
  String? priority;

  SpendingSubCategory({
    this.id,
    this.name,
    this.categoryId,
    this.priority,
  });

  factory SpendingSubCategory.fromMap(Map<String, dynamic> map) {
    return SpendingSubCategory(
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
