// models/housing_quotation_model.dart
import 'package:agriflock/core/utils/type_safe_utils.dart';

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
    final dataMap = TypeUtils.toMapSafe(json['data']);

    return HousingQuotationResponse(
      success: TypeUtils.toBoolSafe(json['success']),
      message: TypeUtils.toStringSafe(json['message']),
      data: HousingQuotationData.fromJson(dataMap ?? {}),
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
    final userMap = TypeUtils.toMapSafe(json['user']);
    final materialsList = TypeUtils.toListSafe<dynamic>(json['materials']);

    return HousingQuotationData(
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      user: userMap != null ? QuotationUser.fromJson(userMap) : null,
      birdCapacity: TypeUtils.toIntSafe(json['bird_capacity']),
      materials: materialsList
          .map((x) => QuotationMaterial.fromJson(
          x is Map<String, dynamic> ? x : {}))
          .toList(),
      materialsSubtotal: TypeUtils.toDoubleSafe(json['materials_subtotal']),
      laborPercentage: TypeUtils.toStringSafe(json['labor_percentage'], defaultValue: '0.00'),
      laborCost: TypeUtils.toDoubleSafe(json['labor_cost']),
      grandTotal: TypeUtils.toDoubleSafe(json['grand_total']),
      currency: TypeUtils.toStringSafe(json['currency'], defaultValue: 'KES'),
      status: TypeUtils.toStringSafe(json['status'], defaultValue: 'draft'),
      notes: TypeUtils.toNullableStringSafe(json['notes']),
      metadata: json['metadata'], // Keep as dynamic
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
    );
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
      id: TypeUtils.toStringSafe(json['id']),
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
      materialId: TypeUtils.toStringSafe(json['material_id']),
      materialName: TypeUtils.toStringSafe(json['material_name']),
      category: TypeUtils.toStringSafe(json['category']),
      unit: TypeUtils.toStringSafe(json['unit']),
      unitPrice: TypeUtils.toDoubleSafe(json['unit_price']),
      quantity: TypeUtils.toIntSafe(json['quantity']),
      totalCost: TypeUtils.toDoubleSafe(json['total_cost']),
      specifications: TypeUtils.toNullableStringSafe(json['specifications']),
    );
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

// Request model for generating quotation - NOT using TypeUtils as per rules
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