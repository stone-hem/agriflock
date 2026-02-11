
class ProductionQuotationData {
  final String id;
  final String userId;
  final String breedId;
  final int quantity;
  final double totalProductionCost;
  final double equipmentCost;
  final double expectedRevenue;
  final double expectedProfit;
  final double costPerBird;
  final double profitPerBird;
  final Breakdown breakdown;
  final DateTime createdAt;

  ProductionQuotationData({
    required this.id,
    required this.userId,
    required this.breedId,
    required this.quantity,
    required this.totalProductionCost,
    required this.equipmentCost,
    required this.expectedRevenue,
    required this.expectedProfit,
    required this.costPerBird,
    required this.profitPerBird,
    required this.breakdown,
    required this.createdAt,
  });

  factory ProductionQuotationData.fromJson(Map<String, dynamic> json) {
    return ProductionQuotationData(
      id: json['id'] ?? '',
      userId: json['user_id'] ?? '',
      breedId: json['breed_id'] ?? '',
      quantity: json['quantity'] ?? 0,
      totalProductionCost: (json['total_production_cost'] ?? 0).toDouble(),
      equipmentCost: (json['equipment_cost'] ?? 0).toDouble(),
      expectedRevenue: (json['expected_revenue'] ?? 0).toDouble(),
      expectedProfit: (json['expected_profit'] ?? 0).toDouble(),
      costPerBird: (json['cost_per_bird'] ?? 0).toDouble(),
      profitPerBird: (json['profit_per_bird'] ?? 0).toDouble(),
      breakdown: Breakdown.fromJson(json['breakdown'] ?? {}),
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'breed_id': breedId,
      'quantity': quantity,
      'total_production_cost': totalProductionCost,
      'equipment_cost': equipmentCost,
      'expected_revenue': expectedRevenue,
      'expected_profit': expectedProfit,
      'cost_per_bird': costPerBird,
      'profit_per_bird': profitPerBird,
      'breakdown': breakdown.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Utility method to group items by category
  Map<String, List<BreakdownItem>> getItemsGroupedByCategory() {
    return breakdown.groupItemsByCategory();
  }

  // Utility method to get total cost by category
  Map<String, double> getTotalCostsByCategory() {
    return breakdown.getTotalCostsByCategory();
  }
}

class Breakdown {
  final double feedCosts;
  final double medicationCosts;
  final double chicksCost;
  final double utilitiesCost;
  final double otherCosts;
  final List<BreakdownItem> items;

  Breakdown({
    required this.feedCosts,
    required this.medicationCosts,
    required this.chicksCost,
    required this.utilitiesCost,
    required this.otherCosts,
    required this.items,
  });

  factory Breakdown.fromJson(Map<String, dynamic> json) {
    return Breakdown(
      feedCosts: (json['feed_costs'] ?? 0).toDouble(),
      medicationCosts: (json['medication_costs'] ?? 0).toDouble(),
      chicksCost: (json['chicks_cost'] ?? 0).toDouble(),
      utilitiesCost: (json['utilities_cost'] ?? 0).toDouble(),
      otherCosts: (json['other_costs'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => BreakdownItem.fromJson(item))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feed_costs': feedCosts,
      'medication_costs': medicationCosts,
      'chicks_cost': chicksCost,
      'utilities_cost': utilitiesCost,
      'other_costs': otherCosts,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }

  // Utility method to group items by category
  Map<String, List<BreakdownItem>> groupItemsByCategory() {
    final Map<String, List<BreakdownItem>> grouped = {};

    for (final item in items) {
      if (!grouped.containsKey(item.category)) {
        grouped[item.category] = [];
      }
      grouped[item.category]!.add(item);
    }

    return grouped;
  }

  // Utility method to get total cost by category
  Map<String, double> getTotalCostsByCategory() {
    final Map<String, double> totals = {};

    for (final item in items) {
      totals[item.category] = (totals[item.category] ?? 0) + (item.total ?? 0);
    }

    // Add the main category totals from the breakdown
    totals['feed'] = feedCosts;
    totals['medication'] = medicationCosts;
    totals['chicks'] = chicksCost;
    totals['utilities'] = utilitiesCost;
    totals['equipment'] = otherCosts;

    return totals;
  }

  // Get only equipment items
  List<BreakdownItem> get equipmentItems {
    return items.where((item) => item.isEquipment).toList();
  }

  // Get only non-equipment items (consumables)
  List<BreakdownItem> get consumableItems {
    return items.where((item) => !item.isEquipment).toList();
  }
}

class BreakdownItem {
  final String name;
  final int quantity;
  final String unit;
  final String unitPrice;
  final double total;
  final String category;
  final bool isEquipment;

  BreakdownItem({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.unitPrice,
    required this.total,
    required this.category,
    required this.isEquipment,
  });

  factory BreakdownItem.fromJson(Map<String, dynamic> json) {
    return BreakdownItem(
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 0,
      unit: json['unit'] ?? '',
      unitPrice: json['unit_price'] ?? '0.00',
      total: (json['total'] ?? 0).toDouble(),
      category: json['category'] ?? '',
      isEquipment: json['is_equipment'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'unit_price': unitPrice,
      'total': total,
      'category': category,
      'is_equipment': isEquipment,
    };
  }
}