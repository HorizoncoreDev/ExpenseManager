class CommonCategoryModel {
  int? catId;
  String? catName;
  int? catType;
  bool isSelected;

  CommonCategoryModel({
    this.catId,
    this.catName,
    this.catType,
    this.isSelected = false, // Default value is false
  });

  factory CommonCategoryModel.fromJson(Map<String, dynamic> json) {
    return CommonCategoryModel(
      catId: json['catId'],
      catName: json['catName'],
      catType: json['catType'],
      isSelected: json['isSelected'] ??
          false, // Set isSelected from JSON or default to false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'catId': catId,
      'catName': catName,
      'catType': catType,
      'isSelected': isSelected,
    };
  }
}
