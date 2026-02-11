import 'dart:convert';

class InventoryCategory {
  final String id;
  final String name;
  final String description;
  final bool useFromStore;
  final dynamic metadata;
  final List<CategoryItem> categoryItems;

  InventoryCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.useFromStore,
    required this.metadata,
    required this.categoryItems,
  });

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      useFromStore: json['use_from_store'] as bool,
      metadata: json['metadata'],
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
      'use_from_store': useFromStore,
      'metadata': metadata,
      'category_items': categoryItems.map((x) => x.toJson()).toList(),
    };
  }
}

class CategoryItem {
  final String id;
  final String categoryItemName;
  final String description;
  final dynamic components;
  final bool useFromStore;
  final num quantityInStore;

  CategoryItem({
    required this.id,
    required this.categoryItemName,
    required this.description,
    required this.components,
    required this.useFromStore,
    required this.quantityInStore,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: json['id'] as String,
      categoryItemName: json['category_item_name'] as String,
      description: json['description'] as String,
      components: json['components'],
      useFromStore: json['use_from_store'] as bool,
      quantityInStore: json['quantity_in_store'] as num,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_item_name': categoryItemName,
      'description': description,
      'components': components,
      'use_from_store': useFromStore,
      'quantity_in_store': quantityInStore,
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