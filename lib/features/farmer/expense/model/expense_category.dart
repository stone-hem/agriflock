import 'dart:convert';

class InventoryCategory {
  final String id;
  final String name;
  final String description;
  final List<CategoryItem> categoryItems;

  InventoryCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryItems,
  });

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      categoryItems: json['category_items'] != null
          ? List<CategoryItem>.from(
        (json['category_items'] as List)
            .map((x) => CategoryItem.fromJson(x)),
      )
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category_items': categoryItems.map((x) => x.toJson()).toList(),
    };
  }
}

class CategoryItem {
  final String id;
  final String categoryItemName;
  final String description;
  final List<String> components;

  CategoryItem({
    required this.id,
    required this.categoryItemName,
    required this.description,
    required this.components,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String,
      categoryItemName: json['category_item_name'] as String,
      description: json['description'] as String,
      components: json['components'] != null
          ? List<String>.from(json['components'] as List)
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_item_name': categoryItemName,
      'description': description,
      'components': components,
    };
  }
}

class CategoriesResponse {
  final bool success;
  final List<InventoryCategory> data;

  CategoriesResponse({
    required this.success,
    required this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    return CategoriesResponse(
      success: json['success'] as bool,
      data: List<InventoryCategory>.from(
        (json['data'] as List).map((x) => InventoryCategory.fromJson(x)),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}