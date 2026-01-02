import 'package:agriflock360/core/utils/result.dart';
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
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      isActive: json['is_active'] ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
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
    return InventoryItem(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      farmId: json['farm_id'],
      farm: json['farm'],
      categoryId: json['category_id'] ?? '',
      category: json['category'] != null
          ? InventoryCategory.fromJson(json['category'])
          : InventoryCategory(
        id: '',
        name: 'Unknown',
        description: '',
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      itemName: json['item_name'] ?? '',
      itemCode: json['item_code'] ?? '',
      description: json['description'] ?? '',
      unitOfMeasurement: json['unit_of_measurement'] ?? '',
      currentStock: double.tryParse(json['current_stock']?.toString() ?? '0') ?? 0,
      minimumStockLevel:
      double.tryParse(json['minimum_stock_level']?.toString() ?? '0') ?? 0,
      reorderPoint: double.tryParse(json['reorder_point']?.toString() ?? '0') ?? 0,
      costPerUnit: double.tryParse(json['cost_per_unit']?.toString() ?? '0') ?? 0,
      supplier: json['supplier'] ?? '',
      supplierContact: json['supplier_contact'],
      storageLocation: json['storage_location'],
      lastRestockDate: json['last_restock_date'] != null
          ? DateTime.parse(json['last_restock_date']).toLocal()
          : null,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date']).toLocal()
          : null,
      notes: json['notes'] ?? '',
      status: json['status'] ?? 'in_stock',
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at']).toLocal()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at']).toLocal()
          : DateTime.now(),
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
    List<InventoryItem> items = [];

    if (json['data'] is List) {
      items = (json['data'] as List)
          .map((item) => InventoryItem.fromJson(item))
          .toList();
    }

    final pagination = json['pagination'] as Map<String, dynamic>?;

    return InventoryResponse(
      items: items,
      total: pagination?['total'] ?? items.length,
      page: pagination?['page'] ?? 1,
      limit: pagination?['limit'] ?? 20,
      totalPages: pagination?['totalPages'] ?? 1,
    );
  }

  bool get hasMore => page < totalPages;
}

class InventoryCategoryResponse {
  final List<InventoryCategory> categories;

  InventoryCategoryResponse({required this.categories});

  factory InventoryCategoryResponse.fromJson(Map<String, dynamic> json) {
    List<InventoryCategory> categories = [];

    if (json['data'] is List) {
      categories = (json['data'] as List)
          .map((category) => InventoryCategory.fromJson(category))
          .toList();
    }

    return InventoryCategoryResponse(categories: categories);
  }
}

class CreateInventoryItemRequest {
  final String categoryId;
  final String? farmId;
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
  final DateTime? expiryDate;
  final String notes;
  final Map<String, dynamic>? metadata;

  CreateInventoryItemRequest({
    required this.categoryId,
    this.farmId,
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
    this.expiryDate,
    required this.notes,
    this.metadata,
  });

  Map<String, dynamic> toJson() {
    return {
      'category_id': categoryId,
      if (farmId != null) 'farm_id': farmId,
      'item_name': itemName,
      'item_code': itemCode,
      'description': description,
      'unit_of_measurement': unitOfMeasurement,
      'current_stock': currentStock,
      'minimum_stock_level': minimumStockLevel,
      'reorder_point': reorderPoint,
      'cost_per_unit': costPerUnit,
      'supplier': supplier,
      if (supplierContact != null) 'supplier_contact': supplierContact,
      if (storageLocation != null) 'storage_location': storageLocation,
      if (expiryDate != null) 'expiry_date': expiryDate!.toUtc().toIso8601String(),
      'notes': notes,
      if (metadata != null) 'metadata': metadata,
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