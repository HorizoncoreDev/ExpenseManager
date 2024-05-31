const String spending_sub_category_table = 'expense_sub_category_table';

class ExpenseSubCategory {
  int? id;
  String? name;
  int? categoryId;
  String? priority;
  String? created_by;
  String? created_at;
  String? updated_at;

  ExpenseSubCategory({
    this.id,
    this.name,
    this.categoryId,
    this.priority,this.created_at,this.created_by,this.updated_at
  });

  factory ExpenseSubCategory.fromMap(Map<String, dynamic> map) {
    return ExpenseSubCategory(
      id: map['id'],
      name: map['name'],
      categoryId: map['category_id'],
      priority: map['priority'],
      created_by: map['created_by'],
      created_at: map['created_at'],
      updated_at: map['updated_at'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category_id': categoryId,
      'priority': priority,
      'created_by': created_by,
      'created_at': created_at,
      'updated_at': updated_at,
    };
  }
  static ExpenseSubCategory fromJson(Map<String, Object?> json) => ExpenseSubCategory(
    id: json[ExpenseSubCategoryFields.id] as int,
    name: json[ExpenseSubCategoryFields.name] as String,
  );
}

class ExpenseSubCategoryFields {
  static final List<String> values = [
    /// Add all fields
    id,
    name,
    categoryId,
    priority,
    created_by,
    created_at,
    updated_at
  ];

  static const String id = 'id';
  static const String name = 'name';
  static const String categoryId = 'category_id';
  static const String priority = 'priority';
  static const String created_by = 'created_by';
  static const String created_at = 'created_at';
  static const String updated_at = 'updated_at';
}
