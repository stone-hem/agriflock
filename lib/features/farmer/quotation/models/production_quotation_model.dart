import 'package:agriflock360/core/utils/type_safe_utils.dart';

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
    final breakdownMap = TypeUtils.toMapSafe(json['breakdown']);

    return ProductionQuotationData(
      id: TypeUtils.toStringSafe(json['id']),
      userId: TypeUtils.toStringSafe(json['user_id']),
      breedId: TypeUtils.toStringSafe(json['breed_id']),
      quantity: TypeUtils.toIntSafe(json['quantity']),
      totalProductionCost: TypeUtils.toDoubleSafe(json['total_production_cost']),
      equipmentCost: TypeUtils.toDoubleSafe(json['equipment_cost']),
      expectedRevenue: TypeUtils.toDoubleSafe(json['expected_revenue']),
      expectedProfit: TypeUtils.toDoubleSafe(json['expected_profit']),
      costPerBird: TypeUtils.toDoubleSafe(json['cost_per_bird']),
      profitPerBird: TypeUtils.toDoubleSafe(json['profit_per_bird']),
      breakdown: Breakdown.fromJson(breakdownMap ?? {}),
      createdAt: TypeUtils.toDateTimeSafe(json['created_at']) ?? DateTime.now(),
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
    final itemsList = TypeUtils.toListSafe<dynamic>(json['items']);

    return Breakdown(
      feedCosts: TypeUtils.toDoubleSafe(json['feed_costs']),
      medicationCosts: TypeUtils.toDoubleSafe(json['medication_costs']),
      chicksCost: TypeUtils.toDoubleSafe(json['chicks_cost']),
      utilitiesCost: TypeUtils.toDoubleSafe(json['utilities_cost']),
      otherCosts: TypeUtils.toDoubleSafe(json['other_costs']),
      items: itemsList
          .map((item) => BreakdownItem.fromJson(
          item is Map<String, dynamic> ? item : {}))
          .toList(),
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
      name: TypeUtils.toStringSafe(json['name']),
      quantity: TypeUtils.toIntSafe(json['quantity']),
      unit: TypeUtils.toStringSafe(json['unit']),
      unitPrice: TypeUtils.toStringSafe(json['unit_price'], defaultValue: '0.00'),
      total: TypeUtils.toDoubleSafe(json['total']),
      category: TypeUtils.toStringSafe(json['category']),
      isEquipment: TypeUtils.toBoolSafe(json['is_equipment']),
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