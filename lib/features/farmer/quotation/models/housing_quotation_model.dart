// models/housing_quotation_model.dart

class HousingQuotationResponse {
  final bool success;
  final String message;
  final HousingQuotationData data;

  HousingQuotationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory HousingQuotationResponse.fromJson(Map<String, dynamic> json) {
    return HousingQuotationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: HousingQuotationData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class HousingQuotationData {
  final String id;
  final String userId;
  final QuotationUser? user;
  final int birdCapacity;
  final List<QuotationMaterial> materials;
  final double materialsSubtotal;
  final String laborPercentage;
  final double laborCost;
  final double grandTotal;
  final String currency;
  final String status;
  final String? notes;
  final dynamic metadata;
  final DateTime createdAt;

  HousingQuotationData({
    required this.id,
    required this.userId,
    this.user,
    required this.birdCapacity,
    required this.materials,
    required this.materialsSubtotal,
    required this.laborPercentage,
    required this.laborCost,
    required this.grandTotal,
    required this.currency,
    required this.status,
    this.notes,
    this.metadata,
    required this.createdAt,
  });

  factory HousingQuotationData.fromJson(Map<String, dynamic> json) {
    return HousingQuotationData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      user: json['user'] != null ? QuotationUser.fromJson(json['user']) : null,
      birdCapacity: json['bird_capacity'] ?? 0,
      materials: (json['materials'] as List<dynamic>?)
          ?.map((x) => QuotationMaterial.fromJson(x as Map<String, dynamic>))
          .toList() ??
          [],
      materialsSubtotal: _parseDouble(json['materials_subtotal']),
      laborPercentage: json['labor_percentage']?.toString() ?? '0.00',
      laborCost: _parseDouble(json['labor_cost']),
      grandTotal: _parseDouble(json['grand_total']),
      currency: json['currency'] ?? 'KES',
      status: json['status'] ?? 'draft',
      notes: json['notes'],
      metadata: json['metadata'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'user': user?.toJson(),
      'bird_capacity': birdCapacity,
      'materials': materials.map((x) => x.toJson()).toList(),
      'materials_subtotal': materialsSubtotal,
      'labor_percentage': laborPercentage,
      'labor_cost': laborCost,
      'grand_total': grandTotal,
      'currency': currency,
      'status': status,
      'notes': notes,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class QuotationUser {
  final String id;

  QuotationUser({
    required this.id,
  });

  factory QuotationUser.fromJson(Map<String, dynamic> json) {
    return QuotationUser(
      id: json['id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}

class QuotationMaterial {
  final String materialId;
  final String materialName;
  final String category;
  final String unit;
  final double unitPrice;
  final int quantity;
  final double totalCost;
  final String? specifications;

  QuotationMaterial({
    required this.materialId,
    required this.materialName,
    required this.category,
    required this.unit,
    required this.unitPrice,
    required this.quantity,
    required this.totalCost,
    this.specifications,
  });

  factory QuotationMaterial.fromJson(Map<String, dynamic> json) {
    return QuotationMaterial(
      materialId: json['material_id'] ?? '',
      materialName: json['material_name'] ?? '',
      category: json['category'] ?? '',
      unit: json['unit'] ?? '',
      unitPrice: _parseDouble(json['unit_price']),
      quantity: json['quantity'] ?? 0,
      totalCost: _parseDouble(json['total_cost']),
      specifications: json['specifications'],
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'material_id': materialId,
      'material_name': materialName,
      'category': category,
      'unit': unit,
      'unit_price': unitPrice,
      'quantity': quantity,
      'total_cost': totalCost,
      'specifications': specifications,
    };
  }
}

// Request model for generating quotation
class GenerateQuotationRequest {
  final int birdCapacity;

  GenerateQuotationRequest({
    required this.birdCapacity,
  });

  Map<String, dynamic> toJson() {
    return {
      'bird_capacity': birdCapacity,
    };
  }
}