import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/type_safe_utils.dart';
import 'dart:convert';

class InventoryCategory {
  final String id;
  final String name;
  final String description;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryCategory.fromJson(Map<String, dynamic> json) {
    return InventoryCategory(
      id: TypeUtils.toStringSafe(json['id']),
      name: TypeUtils.toStringSafe(json['name']),
      description: TypeUtils.toStringSafe(json['description']),
      isActive: TypeUtils.toBoolSafe(json['is_active'], defaultValue: true),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at'])?.toLocal() ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at'])?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }
}

class InventoryItem {
  final String id;
  final String userId;
  final String? farmId;
  final dynamic farm;
  final String categoryId;
  final InventoryCategory category;
  final String itemName;
  final String itemCode;
  final String description;
  final String unitOfMeasurement;
  final double currentStock;
  final double minimumStockLevel;
  final double reorderPoint;
  final double costPerUnit;
  final String supplier;
  final String? supplierContact;
  final String? storageLocation;
  final DateTime? lastRestockDate;
  final DateTime? expiryDate;
  final String notes;
  final String status;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  InventoryItem({
    required this.id,
    required this.userId,
    this.farmId,
    this.farm,
    required this.categoryId,
    required this.category,
    required this.itemName,
    required this.itemCode,
    required this.description,
    required this.unitOfMeasurement,
    required this.currentStock,
    required this.minimumStockLevel,
    required this.reorderPoint,
    required this.costPerUnit,
    required this.supplier,
    this.supplierContact,
    this.storageLocation,
    this.lastRestockDate,
    this.expiryDate,
    required this.notes,
    required this.status,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    final categoryMap = TypeUtils.toMapSafe(json['category']);

    return InventoryItem(
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      farmId: TypeUtils.toNullableStringSafe(json['farm_id']),
      farm: json['farm'], // Keep as dynamic
      categoryId: TypeUtils.toStringSafe(json['category_id']),
      category: categoryMap != null
          ? InventoryCategory.fromJson(categoryMap)
          : InventoryCategory(
        id: '',
        name: 'Unknown',
        description: '',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      itemName: TypeUtils.toStringSafe(json['item_name']),
      itemCode: TypeUtils.toStringSafe(json['item_code']),
      description: TypeUtils.toStringSafe(json['description']),
      unitOfMeasurement: TypeUtils.toStringSafe(json['unit_of_measurement']),
      currentStock: TypeUtils.toDoubleSafe(json['current_stock']),
      minimumStockLevel: TypeUtils.toDoubleSafe(json['minimum_stock_level']),
      reorderPoint: TypeUtils.toDoubleSafe(json['reorder_point']),
      costPerUnit: TypeUtils.toDoubleSafe(json['cost_per_unit']),
      supplier: TypeUtils.toStringSafe(json['supplier']),
      supplierContact: TypeUtils.toNullableStringSafe(json['supplier_contact']),
      storageLocation: TypeUtils.toNullableStringSafe(json['storage_location']),
      lastRestockDate: TypeUtils.toDateTimeSafe(json['last_restock_date'])?.toLocal(),
      expiryDate: TypeUtils.toDateTimeSafe(json['expiry_date'])?.toLocal(),
      notes: TypeUtils.toStringSafe(json['notes']),
      status: TypeUtils.toStringSafe(json['status'], defaultValue: 'in_stock'),
      metadata: TypeUtils.toMapSafe(json['metadata']),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at'])?.toLocal() ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updated_at'])?.toLocal() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'farm_id': farmId,
      'farm': farm,
      'category_id': categoryId,
      'category': category.toJson(),
      'item_name': itemName,
      'item_code': itemCode,
      'description': description,
      'unit_of_measurement': unitOfMeasurement,
      'current_stock': currentStock,
      'minimum_stock_level': minimumStockLevel,
      'reorder_point': reorderPoint,
      'cost_per_unit': costPerUnit,
      'supplier': supplier,
      'supplier_contact': supplierContact,
      'storage_location': storageLocation,
      'last_restock_date': lastRestockDate?.toUtc().toIso8601String(),
      'expiry_date': expiryDate?.toUtc().toIso8601String(),
      'notes': notes,
      'status': status,
      'metadata': metadata,
      'created_at': createdAt.toUtc().toIso8601String(),
      'updated_at': updatedAt.toUtc().toIso8601String(),
    };
  }

  double get totalValue => currentStock * costPerUnit;

  bool get isLowStock => currentStock <= minimumStockLevel;

  bool get needsReorder => currentStock <= reorderPoint;

  String get formattedStatus {
    switch (status) {
      case 'low_stock':
        return 'Low Stock';
      case 'in_stock':
        return 'In Stock';
      case 'out_of_stock':
        return 'Out of Stock';
      case 'expired':
        return 'Expired';
      default:
        return status.replaceAll('_', ' ').toTitleCase();
    }
  }
}

class InventoryResponse {
  final List<InventoryItem> items;
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  InventoryResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory InventoryResponse.fromJson(Map<String, dynamic> json) {
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);
    final paginationMap = TypeUtils.toMapSafe(json['pagination']);

    final items = dataList
        .map((item) => InventoryItem.fromJson(
        item is Map<String, dynamic> ? item : {}))
        .toList();

    return InventoryResponse(
      items: items,
      total: TypeUtils.toIntSafe(paginationMap?['total'], defaultValue: items.length),
      page: TypeUtils.toIntSafe(paginationMap?['page'], defaultValue: 1),
      limit: TypeUtils.toIntSafe(paginationMap?['limit'], defaultValue: 20),
      totalPages: TypeUtils.toIntSafe(paginationMap?['totalPages'], defaultValue: 1),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': items.map((item) => item.toJson()).toList(),
      'pagination': {
        'total': total,
        'page': page,
        'limit': limit,
        'totalPages': totalPages,
      },
    };
  }

  bool get hasMore => page < totalPages;
}

class InventoryCategoryResponse {
  final List<InventoryCategory> categories;

  InventoryCategoryResponse({required this.categories});

  factory InventoryCategoryResponse.fromJson(Map<String, dynamic> json) {
    final dataList = TypeUtils.toListSafe<dynamic>(json['data']);

    final categories = dataList
        .map((category) => InventoryCategory.fromJson(
        category is Map<String, dynamic> ? category : {}))
        .toList();

    return InventoryCategoryResponse(categories: categories);
  }

  Map<String, dynamic> toJson() {
    return {
      'data': categories.map((category) => category.toJson()).toList(),
    };
  }
}

// Request classes - NOT using TypeUtils as per rules
class CreateInventoryItemRequest {
  final String categoryId;
  final String? farmId;
  final String itemName;
  final String description;
  final String unitOfMeasurement;
  final double currentStock;
  final double minimumStockLevel;
  final double reorderPoint;
  final double cost;
  final String supplier;
  final DateTime? expiryDate;
  final String notes;

  CreateInventoryItemRequest({
    required this.categoryId,
    this.farmId,
    required this.itemName,
    required this.description,
    required this.unitOfMeasurement,
    required this.currentStock,
    required this.minimumStockLevel,
    required this.reorderPoint,
    required this.cost,
    required this.supplier,
    this.expiryDate,
    required this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      if (farmId != null) 'farm_id': farmId,
      'item_name': itemName,
      'description': description,
      'unit_of_measurement': unitOfMeasurement,
      'current_stock': currentStock,
      'minimum_stock_level': minimumStockLevel,
      'reorder_point': reorderPoint,
      'cost': cost,
      'supplier': supplier,
      if (expiryDate != null) 'expiry_date': expiryDate!.toUtc().toIso8601String(),
      'notes': notes,
    };
  }
}

class AdjustStockRequest {
  final double adjustmentAmount;
  final String adjustmentType; // 'add' or 'remove'
  final String reason;
  final String? batchId;
  final String? notes;
  final Map<String, dynamic>? metadata;

  AdjustStockRequest({
    required this.adjustmentAmount,
    required this.adjustmentType,
    required this.reason,
    this.batchId,
    this.notes,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'adjustment_amount': adjustmentAmount,
      'adjustment_type': adjustmentType,
      'reason': reason,
      if (batchId != null) 'batch_id': batchId,
      if (notes != null) 'notes': notes,
      if (metadata != null) 'metadata': metadata,
    };
  }
}

extension StringExtension on String {
  String toTitleCase() {
    return split(' ')
        .map((word) => word.isNotEmpty
        ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}'
        : '')
        .join(' ');
  }
}