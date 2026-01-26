class Expenditure {
  final String id;
  final String userId;
  final String farmId;
  final String? houseId;
  final String? batchId;
  final String categoryId;
  final ExpenditureCategory category;
  final String description;
  final double amount;
  final double quantity;
  final String unit;
  final DateTime date;
  final String? supplier;
  final String? inventoryItemId;
  final InventoryItem? inventoryItem;
  final String? inventoryTransactionId;
  final DateTime? expiryDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Expenditure({
    required this.id,
    required this.userId,
    required this.farmId,
    required this.houseId,
    required this.batchId,
    required this.categoryId,
    required this.category,
    required this.description,
    required this.amount,
    required this.quantity,
    required this.unit,
    required this.date,
    this.supplier,
    this.inventoryItemId,
    this.inventoryItem,
    this.inventoryTransactionId,
    this.expiryDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expenditure.fromJson(Map<String, dynamic> json) {
    return Expenditure(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      farmId: json['farm_id'] as String,
      houseId: json['house_id'] as String?,
      batchId: json['batch_id'] as String?,
      categoryId: json['category_id'] as String,
      category: ExpenditureCategory.fromJson(json['category']),
      description: json['description'] as String,
      amount: double.parse(json['amount'] as String),
      quantity: double.parse(json['quantity'] as String),
      unit: json['unit'] as String,
      date: DateTime.parse(json['date'] as String),
      supplier: json['supplier'] as String?,
      inventoryItemId: json['inventory_item_id'] as String?,
      inventoryItem: json['inventory_item'] != null
          ? InventoryItem.fromJson(json['inventory_item'])
          : null,
      inventoryTransactionId: json['inventory_transaction_id'] as String?,
      expiryDate: json['expiry_date'] != null
          ? DateTime.parse(json['expiry_date'] as String)
          : null,
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
      'description': description,
      'amount': amount.toString(),
      'quantity': quantity.toString(),
      'unit': unit,
      'date': date.toIso8601String(),
      'supplier': supplier,
      'inventory_item_id': inventoryItemId,
      'inventory_item': inventoryItem?.toJson(),
      'inventory_transaction_id': inventoryTransactionId,
      'expiry_date': expiryDate?.toIso8601String(),
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
  final DateTime createdAt;
  final DateTime updatedAt;

  ExpenditureCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ExpenditureCategory.fromJson(Map<String, dynamic> json) {
    return ExpenditureCategory(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      isActive: json['is_active'] as bool,
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
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
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
  final String farmId;
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
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;

  const InventoryItem({
    required this.id,
    required this.userId,
    required this.farmId,
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
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      farmId: json['farm_id'] as String,
      categoryId: json['category_id'] as String,
      itemName: json['item_name'] as String,
      itemCode: json['item_code'] as String,
      description: json['description'] as String,
      unitOfMeasurement: json['unit_of_measurement'] as String,
      currentStock: double.parse(json['current_stock'] as String),
      minimumStockLevel: double.parse(json['minimum_stock_level'] as String),
      reorderPoint: double.parse(json['reorder_point'] as String),
      cost: double.parse(json['cost'] as String),
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
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}