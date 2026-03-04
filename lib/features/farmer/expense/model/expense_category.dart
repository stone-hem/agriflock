import 'dart:convert';
import 'package:agriflock/core/utils/type_safe_utils.dart';

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
      metadata: json['metadata'],
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
  final String categoryItemUnit;
  final List<String>? categoryItemPackagingOptions;
  final String? description;
  final dynamic components;
  final bool useFromStore;
  final String? userId;
  final num quantityInStore;
  final List<Breed> breeds;
  final List<String> feedingRecommendationIds;
  final List<String> vaccineCatalogIds;
  final bool isSuggestedForAge;
  final String? suggestionContext;

  CategoryItem({
    required this.id,
    required this.categoryItemName,
    required this.categoryItemUnit,
    this.categoryItemPackagingOptions,
    this.description,
    required this.components,
    required this.useFromStore,
    this.userId,
    required this.quantityInStore,
    required this.breeds,
    required this.feedingRecommendationIds,
    required this.vaccineCatalogIds,
    required this.isSuggestedForAge,
    this.suggestionContext,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    // Parse breeds list using TypeUtils
    final breedsList = TypeUtils.toListSafe<dynamic>(json['breeds']);

    // Parse packaging options using TypeUtils.toListSafe
    final packagingOptionsList = TypeUtils.toListSafe<dynamic>(json['category_item_packaging_options']);

    // Convert to List<String> and filter out empty strings
    final parsedPackagingOptions = packagingOptionsList.isNotEmpty
        ? packagingOptionsList
        .map((e) => TypeUtils.toStringSafe(e))
        .where((e) => e.isNotEmpty)
        .toList()
        : null;

    // Parse feeding recommendation IDs using TypeUtils
    final feedingRecIds = TypeUtils.toListSafe<dynamic>(json['feeding_recommendation_ids']);

    // Parse vaccine catalog IDs using TypeUtils
    final vaccineIds = TypeUtils.toListSafe<dynamic>(json['vaccine_catalog_ids']);

    // Parse breeds
    final breeds = breedsList
        .map((x) => Breed.fromJson(x is Map<String, dynamic> ? x : {}))
        .where((breed) => breed.id.isNotEmpty) // Filter out invalid breeds
        .toList();

    return CategoryItem(
      id: TypeUtils.toStringSafe(json['id']),
      categoryItemName: TypeUtils.toStringSafe(json['category_item_name']),
      categoryItemUnit: TypeUtils.toStringSafe(json['category_item_unit']),
      categoryItemPackagingOptions: parsedPackagingOptions,
      description: TypeUtils.toNullableStringSafe(json['description']),
      components: json['components'],
      useFromStore: TypeUtils.toBoolSafe(json['use_from_store']),
      userId: TypeUtils.toNullableStringSafe(json['user_id']),
      quantityInStore: TypeUtils.toDoubleSafe(json['quantity_in_store']),
      breeds: breeds,
      feedingRecommendationIds: feedingRecIds
          .map((e) => TypeUtils.toStringSafe(e))
          .where((e) => e.isNotEmpty)
          .toList(),
      vaccineCatalogIds: vaccineIds
          .map((e) => TypeUtils.toStringSafe(e))
          .where((e) => e.isNotEmpty)
          .toList(),
      isSuggestedForAge: TypeUtils.toBoolSafe(json['is_suggested_for_age']),
      suggestionContext: TypeUtils.toNullableStringSafe(json['suggestion_context']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_item_name': categoryItemName,
      'category_item_unit': categoryItemUnit,
      'category_item_packaging_options': categoryItemPackagingOptions,
      'description': description,
      'components': components,
      'use_from_store': useFromStore,
      'user_id': userId,
      'quantity_in_store': quantityInStore,
      'breeds': breeds.map((x) => x.toJson()).toList(),
      'feeding_recommendation_ids': feedingRecommendationIds,
      'vaccine_catalog_ids': vaccineCatalogIds,
      'is_suggested_for_age': isSuggestedForAge,
      'suggestion_context': suggestionContext,
    };
  }
}

class Breed {
  final String id;
  final String name;
  final String type;

  Breed({
    required this.id,
    required this.name,
    required this.type,
  });

  factory Breed.fromJson(Map<String, dynamic> json) {
    return Breed(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      type: TypeUtils.toStringSafe(json['type']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
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