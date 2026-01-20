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
      id: json['id'],
      batchId: json['batchId'],
      type: json['type'],
      category: json['category'],
      description: json['description'],
      amount: (json['amount'] as num).toDouble(),
      quantity: json['quantity'] ?? 1,
      unit: json['unit'] ?? 'unit',
      date: DateTime.parse(json['date']),
      supplier: json['supplier'],
      receiptNumber: json['receiptNumber'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
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
}