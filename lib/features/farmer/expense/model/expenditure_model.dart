import 'dart:convert';
import 'package:agriflock360/core/utils/type_safe_utils.dart';

class Expenditure {
  final String id;
  final String userId;
  final String? farmId;
  final String? houseId;
  final String? batchId;
  final String categoryId;
  final ExpenditureCategory category;
  final String? categoryItemId;
  final CategoryItem? categoryItem;
  final String description;
  final double amount;
  final double quantity;
  final String unit;
  final DateTime date;
  final String? supplier;
  final bool usedImmediately;
  final String? inventoryItemId;
  final InventoryItem? inventoryItem;
  final String? inventoryTransactionId;
  final DateTime? expiryDate;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expenditure({
    required this.id,
    required this.userId,
    this.farmId,
    this.houseId,
    this.batchId,
    required this.categoryId,
    required this.category,
    this.categoryItemId,
    this.categoryItem,
    required this.description,
    required this.amount,
    required this.quantity,
    required this.unit,
    required this.date,
    this.supplier,
    required this.usedImmediately,
    this.inventoryItemId,
    this.inventoryItem,
    this.inventoryTransactionId,
    this.expiryDate,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expenditure.fromJson(Map<String, dynamic> json) {
    final categoryMap = TypeUtils.toMapSafe(json['category']);
    final categoryItemMap = TypeUtils.toMapSafe(json['category_item']);
    final inventoryItemMap = TypeUtils.toMapSafe(json['inventory_item']);

    return Expenditure(
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      farmId: TypeUtils.toNullableStringSafe(json['farm_id']),
      houseId: TypeUtils.toNullableStringSafe(json['house_id']),
      batchId: TypeUtils.toNullableStringSafe(json['batch_id']),
      categoryId: TypeUtils.toStringSafe(json['category_id']),
      category: ExpenditureCategory.fromJson(categoryMap ?? {}),
      categoryItemId: TypeUtils.toNullableStringSafe(json['category_item_id']),
      categoryItem: categoryItemMap != null
          ? CategoryItem.fromJson(categoryItemMap)
          : null,
      description: TypeUtils.toStringSafe(json['description']),
      amount: TypeUtils.toDoubleSafe(json['amount']),
      quantity: TypeUtils.toDoubleSafe(json['quantity']),
      unit: TypeUtils.toStringSafe(json['unit']),
      date: TypeUtils.toDateTimeSafe(json['date']) ?? DateTime.now(),
      supplier: TypeUtils.toNullableStringSafe(json['supplier']),
      usedImmediately: TypeUtils.toBoolSafe(json['used_immediately']),
      inventoryItemId: TypeUtils.toNullableStringSafe(json['inventory_item_id']),
      inventoryItem: inventoryItemMap != null
          ? InventoryItem.fromJson(inventoryItemMap)
          : null,
      inventoryTransactionId: TypeUtils.toNullableStringSafe(json['inventory_transaction_id']),
      expiryDate: TypeUtils.toDateTimeSafe(json['expiry_date']),
      metadata: TypeUtils.toMapSafe(json['metadata']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'farm_id': farmId,
      'house_id': houseId,
      'batch_id': batchId,
      'category_id': categoryId,
      'category': category.toJson(),
      'category_item_id': categoryItemId,
      'category_item': categoryItem?.toJson(),
      'description': description,
      'amount': amount,
      'quantity': quantity,
      'unit': unit,
      'date': date.toIso8601String(),
      'supplier': supplier,
      'used_immediately': usedImmediately,
      'inventory_item_id': inventoryItemId,
      'inventory_item': inventoryItem?.toJson(),
      'inventory_transaction_id': inventoryTransactionId,
      'expiry_date': expiryDate?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class ExpenditureResponse {
  final bool success;
  final List<Expenditure> data;
  final int count;

  const ExpenditureResponse({
    required this.success,
    required this.data,
    required this.count,
  });

  factory ExpenditureResponse.fromJson(Map<String, dynamic> json) {
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    return ExpenditureResponse(
      success: TypeUtils.toBoolSafe(json['success']),
      data: dataList
          .map((item) => Expenditure.fromJson(
          item is Map<String, dynamic> ? item : {}))
          .toList(),
      count: TypeUtils.toIntSafe(json['count']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.map((x) => x.toJson()).toList(),
      'count': count,
    };
  }
}

class ExpenditureCategory {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final Map<String, dynamic>? metadata;
  final bool useFromStore;
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenditureCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    this.metadata,
    required this.useFromStore,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenditureCategory.fromJson(Map<String, dynamic> json) {
    return ExpenditureCategory(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      description: TypeUtils.toStringSafe(json['description']),
      isActive: TypeUtils.toBoolSafe(json['is_active']),
      metadata: TypeUtils.toMapSafe(json['metadata']),
      useFromStore: TypeUtils.toBoolSafe(json['use_from_store']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
      'metadata': metadata,
      'use_from_store': useFromStore,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}

class CategoryItem {
  final String id;
  final String inventoryCategoryId;
  final String categoryItemName;
  final String categoryItemUnit;
  final bool useFromStore;
  final String description;
  final dynamic components;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryItem({
    required this.id,
    required this.inventoryCategoryId,
    required this.categoryItemName,
    required this.categoryItemUnit,
    required this.useFromStore,
    required this.description,
    this.components,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryItem.fromJson(Map<String, dynamic> json) {
    return CategoryItem(
      id: TypeUtils.toStringSafe(json['id']),
      inventoryCategoryId: TypeUtils.toStringSafe(json['inventory_category_id']),
      categoryItemName: TypeUtils.toStringSafe(json['category_item_name']),
      categoryItemUnit: TypeUtils.toStringSafe(json['category_item_unit']),
      useFromStore: TypeUtils.toBoolSafe(json['use_from_store']),
      description: TypeUtils.toStringSafe(json['description']),
      components: json['components'], // Keep as dynamic
      metadata: TypeUtils.toMapSafe(json['metadata']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_category_id': inventoryCategoryId,
      'category_item_name': categoryItemName,
      'category_item_unit': categoryItemUnit,
      'use_from_store': useFromStore,
      'description': description,
      'components': components,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  bool get isComponentsList => components is List;
  bool get isComponentsMap => components is Map;

  List<dynamic>? get componentsAsList {
    if (components is List) {
      return components as List<dynamic>;
    }
    return null;
  }

  Map<String, dynamic>? get componentsAsMap {
    if (components is Map) {
      return components as Map<String, dynamic>;
    }
    return null;
  }
}

class CategoriesResponse {
  final bool success;
  final List<ExpenditureCategory> data;

  CategoriesResponse({
    required this.success,
    required this.data,
  });

  factory CategoriesResponse.fromJson(Map<String, dynamic> json) {
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    return CategoriesResponse(
      success: TypeUtils.toBoolSafe(json['success']),
      data: dataList
          .map((x) => ExpenditureCategory.fromJson(
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

class InventoryItem {
  final String id;
  final String userId;
  final String? farmId;
  final String? batchId;
  final String? houseId;
  final String categoryId;
  final String itemName;
  final String itemCode;
  final String description;
  final String unitOfMeasurement;
  final double currentStock;
  final double minimumStockLevel;
  final double reorderPoint;
  final double cost;
  final String? supplier;
  final String? supplierContact;
  final String? storageLocation;
  final DateTime? lastRestockDate;
  final String currency;
  final String region;
  final DateTime? expiryDate;
  final String? notes;
  final String status;
  final double? quantityUsed;
  final DateTime? lastUpdated;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.userId,
    this.farmId,
    this.batchId,
    this.houseId,
    required this.categoryId,
    required this.itemName,
    required this.itemCode,
    required this.description,
    required this.unitOfMeasurement,
    required this.currentStock,
    required this.minimumStockLevel,
    required this.reorderPoint,
    required this.cost,
    this.supplier,
    this.supplierContact,
    this.storageLocation,
    this.lastRestockDate,
    required this.currency,
    required this.region,
    this.expiryDate,
    this.notes,
    required this.status,
    this.quantityUsed,
    this.lastUpdated,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      farmId: TypeUtils.toNullableStringSafe(json['farm_id']),
      batchId: TypeUtils.toNullableStringSafe(json['batch_id']),
      houseId: TypeUtils.toNullableStringSafe(json['house_id']),
      categoryId: TypeUtils.toStringSafe(json['category_id']),
      itemName: TypeUtils.toStringSafe(json['item_name']),
      itemCode: TypeUtils.toStringSafe(json['item_code']),
      description: TypeUtils.toStringSafe(json['description']),
      unitOfMeasurement: TypeUtils.toStringSafe(json['unit_of_measurement']),
      currentStock: TypeUtils.toDoubleSafe(json['current_stock']),
      minimumStockLevel: TypeUtils.toDoubleSafe(json['minimum_stock_level']),
      reorderPoint: TypeUtils.toDoubleSafe(json['reorder_point']),
      cost: TypeUtils.toDoubleSafe(json['cost']),
      supplier: TypeUtils.toNullableStringSafe(json['supplier']),
      supplierContact: TypeUtils.toNullableStringSafe(json['supplier_contact']),
      storageLocation: TypeUtils.toNullableStringSafe(json['storage_location']),
      lastRestockDate: TypeUtils.toDateTimeSafe(json['last_restock_date']),
      currency: TypeUtils.toStringSafe(json['currency'], defaultValue: 'KES'),
      region: TypeUtils.toStringSafe(json['region']),
      expiryDate: TypeUtils.toDateTimeSafe(json['expiry_date']),
      notes: TypeUtils.toNullableStringSafe(json['notes']),
      status: TypeUtils.toStringSafe(json['status'], defaultValue: 'active'),
      quantityUsed: TypeUtils.toNullableDoubleSafe(json['quantity_used']),
      lastUpdated: TypeUtils.toDateTimeSafe(json['last_updated']),
      metadata: TypeUtils.toMapSafe(json['metadata']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'farm_id': farmId,
      'batch_id': batchId,
      'house_id': houseId,
      'category_id': categoryId,
      'item_name': itemName,
      'item_code': itemCode,
      'description': description,
      'unit_of_measurement': unitOfMeasurement,
      'current_stock': currentStock,
      'minimum_stock_level': minimumStockLevel,
      'reorder_point': reorderPoint,
      'cost': cost,
      'supplier': supplier,
      'supplier_contact': supplierContact,
      'storage_location': storageLocation,
      'last_restock_date': lastRestockDate?.toIso8601String(),
      'currency': currency,
      'region': region,
      'expiry_date': expiryDate?.toIso8601String(),
      'notes': notes,
      'status': status,
      'quantity_used': quantityUsed,
      'last_updated': lastUpdated?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}