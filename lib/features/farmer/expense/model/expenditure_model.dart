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
    return Expenditure(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      farmId: json['farm_id'] as String?,
      houseId: json['house_id'] as String?,
      batchId: json['batch_id'] as String?,
      categoryId: json['category_id'] as String,
      category: ExpenditureCategory.fromJson(json['category']),
      categoryItemId: json['category_item_id'] as String?,
      categoryItem: json['category_item'] != null
          ? CategoryItem.fromJson(json['category_item'])
          : null,
      description: json['description'] as String,
      amount: double.parse(json['amount'].toString()),
      quantity: double.parse(json['quantity'].toString()),
      unit: json['unit'] as String,
      date: DateTime.parse(json['date'] as String),
      supplier: json['supplier'] as String?,
      usedImmediately: json['used_immediately'] as bool? ?? false,
      inventoryItemId: json['inventory_item_id'] as String?,
      inventoryItem: json['inventory_item'] != null
          ? InventoryItem.fromJson(json['inventory_item'])
          : null,
      inventoryTransactionId: json['inventory_transaction_id'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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
      'amount': amount.toString(),
      'quantity': quantity.toString(),
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
    return ExpenditureResponse(
      success: json['success'] as bool,
      data: (json['data'] as List)
          .map((item) => Expenditure.fromJson(item))
          .toList(),
      count: json['count'] as int,
    );
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
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['is_active'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>?,
      useFromStore: json['use_from_store'] as bool,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
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
  final dynamic components; // Changed from Map<String, dynamic>? to dynamic
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
      id: json['id'] as String,
      inventoryCategoryId: json['inventory_category_id'] as String,
      categoryItemName: json['category_item_name'] as String,
      categoryItemUnit: json['category_item_unit'] as String,
      useFromStore: json['use_from_store'] as bool,
      description: json['description'] as String,
      components: json['components'], // Keep as dynamic, don't cast
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
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

  // Helper methods to safely access components
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
    return CategoriesResponse(
      success: json['success'] as bool,
      data: List<ExpenditureCategory>.from(
        (json['data'] as List).map((x) => ExpenditureCategory.fromJson(x)),
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

class InventoryItem {
  final String id;
  final String userId;
  final String? farmId;
  final String? batchId; // Add this
  final String? houseId; // Add this
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
    this.batchId, // Add this
    this.houseId, // Add this
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
      id: json['id'] as String,
      userId: json['user_id'] as String,
      farmId: json['farm_id'] as String?,
      batchId: json['batch_id'] as String?, // Add this
      houseId: json['house_id'] as String?, // Add this
      categoryId: json['category_id'] as String,
      itemName: json['item_name'] as String,
      itemCode: json['item_code'] as String,
      description: json['description'] as String,
      unitOfMeasurement: json['unit_of_measurement'] as String,
      currentStock: double.parse(json['current_stock'].toString()),
      minimumStockLevel: double.parse(json['minimum_stock_level'].toString()),
      reorderPoint: double.parse(json['reorder_point'].toString()),
      cost: double.parse(json['cost'].toString()),
      supplier: json['supplier'] as String?,
      supplierContact: json['supplier_contact'] as String?,
      storageLocation: json['storage_location'] as String?,
      lastRestockDate: json['last_restock_date'] != null
          ? DateTime.parse(json['last_restock_date'] as String)
          : null,
      currency: json['currency'] as String,
      region: json['region'] as String,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
      notes: json['notes'] as String?,
      status: json['status'] as String,
      quantityUsed: json['quantity_used'] != null
          ? double.parse(json['quantity_used'].toString())
          : null,
      lastUpdated: json['last_updated'] != null
          ? DateTime.parse(json['last_updated'] as String)
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'farm_id': farmId,
      'batch_id': batchId, // Add this
      'house_id': houseId, // Add this
      'category_id': categoryId,
      'item_name': itemName,
      'item_code': itemCode,
      'description': description,
      'unit_of_measurement': unitOfMeasurement,
      'current_stock': currentStock.toString(),
      'minimum_stock_level': minimumStockLevel.toString(),
      'reorder_point': reorderPoint.toString(),
      'cost': cost.toString(),
      'supplier': supplier,
      'supplier_contact': supplierContact,
      'storage_location': storageLocation,
      'last_restock_date': lastRestockDate?.toIso8601String(),
      'currency': currency,
      'region': region,
      'expiry_date': expiryDate?.toIso8601String(),
      'notes': notes,
      'status': status,
      'quantity_used': quantityUsed?.toString(),
      'last_updated': lastUpdated?.toIso8601String(),
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}