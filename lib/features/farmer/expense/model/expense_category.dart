import 'dart:convert';
import 'package:agriflock360/core/utils/type_safe_utils.dart';

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
    final categoryItemsList = TypeUtils.toListSafe<dynamic>(json['category_items']);

    return InventoryCategory(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      description: TypeUtils.toStringSafe(json['description']),
      useFromStore: TypeUtils.toBoolSafe(json['use_from_store']),
      metadata: json['metadata'], // Keep as dynamic
      categoryItems: categoryItemsList
          .map((x) => CategoryItem.fromJson(
          x is Map<String, dynamic> ? x : {}))
          .toList(),
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
      id: TypeUtils.toStringSafe(json['id']),
      categoryItemName: TypeUtils.toStringSafe(json['category_item_name']),
      description: TypeUtils.toStringSafe(json['description']),
      components: json['components'], // Keep as dynamic
      useFromStore: TypeUtils.toBoolSafe(json['use_from_store']),
      quantityInStore: json['quantity_in_store'] as num? ?? 0,
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
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    return CategoriesResponse(
      success: TypeUtils.toBoolSafe(json['success']),
      data: dataList
          .map((x) => InventoryCategory.fromJson(
          x is Map<String, dynamic> ? x : {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((x) => x.toJson()).toList(),
    };
  }
}