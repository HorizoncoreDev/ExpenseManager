const String spending_sub_category_table = 'expense_sub_category_table';

class ExpenseSubCategory {
  int? id;
  String? name;
  int? categoryId;
  String? priority;

  ExpenseSubCategory({
    this.id,
    this.name,
    this.categoryId,
    this.priority,
  });

  factory ExpenseSubCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseSubCategory(
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

class ExpenseSubCategoryFields {
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
