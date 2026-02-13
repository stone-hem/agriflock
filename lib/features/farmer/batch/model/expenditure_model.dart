import 'package:agriflock360/core/utils/type_safe_utils.dart'; // Adjust the import path as needed

class Expenditure {
  final String id;
  final String batchId;
  final String type; // feed, medication, utilities, labor, equipment, other
  final String category; // recurring, one-time, emergency
  final String description;
  final double amount;
  final int quantity;
  final String unit; // kg, liter, unit, etc.
  final DateTime date;
  final String? supplier;
  final String? receiptNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  Expenditure({
    required this.id,
    required this.batchId,
    required this.type,
    required this.category,
    required this.description,
    required this.amount,
    this.quantity = 1,
    this.unit = 'unit',
    required this.date,
    this.supplier,
    this.receiptNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Expenditure.fromJson(Map<String, dynamic> json) {
    return Expenditure(
      id: TypeUtils.toStringSafe(json['id']),
      batchId: TypeUtils.toStringSafe(json['batchId']),
      type: TypeUtils.toStringSafe(json['type']),
      category: TypeUtils.toStringSafe(json['category']),
      description: TypeUtils.toStringSafe(json['description']),
      amount: TypeUtils.toDoubleSafe(json['amount']),
      quantity: TypeUtils.toIntSafe(json['quantity'], defaultValue: 1),
      unit: TypeUtils.toStringSafe(json['unit'], defaultValue: 'unit'),
      date: TypeUtils.toDateTimeSafe(json['date']) ?? DateTime.now(),
      supplier: TypeUtils.toNullableStringSafe(json['supplier']),
      receiptNumber: TypeUtils.toNullableStringSafe(json['receiptNumber']),
      createdAt: TypeUtils.toDateTimeSafe(json['createdAt']) ?? DateTime.now(),
      updatedAt: TypeUtils.toDateTimeSafe(json['updatedAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'batchId': batchId,
      'type': type,
      'category': category,
      'description': description,
      'amount': amount,
      'quantity': quantity,
      'unit': unit,
      'date': date.toIso8601String(),
      'supplier': supplier,
      'receiptNumber': receiptNumber,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ExpenditureDashboard {
  final double totalAmount;
  final double averageDailyCost;
  final Map<String, double> categoryBreakdown;
  final double feedCost;
  final double medicationCost;
  final double utilitiesCost;
  final double laborCost;
  final double otherCost;

  ExpenditureDashboard({
    required this.totalAmount,
    required this.averageDailyCost,
    required this.categoryBreakdown,
    required this.feedCost,
    required this.medicationCost,
    required this.utilitiesCost,
    required this.laborCost,
    required this.otherCost,
  });

  factory ExpenditureDashboard.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> breakdownMap = TypeUtils.toMapSafe(json['category_breakdown']) ?? {};
    Map<String, double> categoryBreakdown = {};
    breakdownMap.forEach((key, value) {
      categoryBreakdown[key] = TypeUtils.toDoubleSafe(value);
    });

    return ExpenditureDashboard(
      totalAmount: TypeUtils.toDoubleSafe(json['totalAmount']),
      averageDailyCost: TypeUtils.toDoubleSafe(json['averageDailyCost']),
      categoryBreakdown: categoryBreakdown,
      feedCost: TypeUtils.toDoubleSafe(json['feedCost']),
      medicationCost: TypeUtils.toDoubleSafe(json['medicationCost']),
      utilitiesCost: TypeUtils.toDoubleSafe(json['utilitiesCost']),
      laborCost: TypeUtils.toDoubleSafe(json['laborCost']),
      otherCost: TypeUtils.toDoubleSafe(json['otherCost']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'averageDailyCost': averageDailyCost,
      'category_breakdown': categoryBreakdown,
      'feedCost': feedCost,
      'medicationCost': medicationCost,
      'utilitiesCost': utilitiesCost,
      'laborCost': laborCost,
      'otherCost': otherCost,
    };
  }
}