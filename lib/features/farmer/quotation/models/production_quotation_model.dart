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
  /// True when the API returned a layers-style breakdown (stage1/stage2).
  final bool isLayersBreed;
  /// Non-null for regular breeds (broilers, kienyeji, etc.).
  final Breakdown? breakdown;
  /// Non-null when [isLayersBreed] is true.
  final LayersBreakdown? layersBreakdown;
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
    this.isLayersBreed = false,
    this.breakdown,
    this.layersBreakdown,
    required this.createdAt,
  });

  factory ProductionQuotationData.fromJson(Map<String, dynamic> json) {
    final breakdownMap = TypeUtils.toMapSafe(json['breakdown']);
    final isLayers = TypeUtils.toBoolSafe(breakdownMap?['is_layers_breed']);

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
      isLayersBreed: isLayers,
      breakdown: isLayers
          ? null
          : (breakdownMap != null ? Breakdown.fromJson(breakdownMap) : null),
      layersBreakdown: isLayers && breakdownMap != null
          ? LayersBreakdown.fromJson(breakdownMap)
          : null,
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
      'is_layers_breed': isLayersBreed,
      'breakdown': breakdown?.toJson(),
      'layers_breakdown': layersBreakdown?.toJson(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  // Utility method to group items by category (non-layers only)
  Map<String, List<BreakdownItem>> getItemsGroupedByCategory() {
    return breakdown?.groupItemsByCategory() ?? {};
  }

  // Utility method to get total cost by category (non-layers only)
  Map<String, double> getTotalCostsByCategory() {
    return breakdown?.getTotalCostsByCategory() ?? {};
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

// ─── Layers-specific models ────────────────────────────────────────────────

/// One stage (rearing or laying) from a layers quotation response.
class LayersStage {
  final List<BreakdownItem> items;
  final double total;

  LayersStage({required this.items, required this.total});

  factory LayersStage.fromJson(Map<String, dynamic> json) {
    final itemsList = TypeUtils.toListSafe<dynamic>(json['items']);
    return LayersStage(
      items: itemsList
          .map((item) => BreakdownItem.fromJson(
              item is Map<String, dynamic> ? item : {}))
          .toList(),
      total: TypeUtils.toDoubleSafe(json['total']),
    );
  }

  Map<String, dynamic> toJson() => {
        'items': items.map((i) => i.toJson()).toList(),
        'total': total,
      };
}

/// Financial analysis block returned for layers quotations.
class LayersAnalysis {
  final double totalInvestment;
  final int traysAt70LayRate;
  final double costPerEgg;
  final double breakEvenCostPerTray;

  LayersAnalysis({
    required this.totalInvestment,
    required this.traysAt70LayRate,
    required this.costPerEgg,
    required this.breakEvenCostPerTray,
  });

  factory LayersAnalysis.fromJson(Map<String, dynamic> json) {
    return LayersAnalysis(
      totalInvestment: TypeUtils.toDoubleSafe(json['total_investment']),
      traysAt70LayRate: TypeUtils.toIntSafe(json['trays_at_70_lay_rate']),
      costPerEgg: TypeUtils.toDoubleSafe(json['cost_per_egg']),
      breakEvenCostPerTray: TypeUtils.toDoubleSafe(json['break_even_cost_per_tray']),
    );
  }

  Map<String, dynamic> toJson() => {
        'total_investment': totalInvestment,
        'trays_at_70_lay_rate': traysAt70LayRate,
        'cost_per_egg': costPerEgg,
        'break_even_cost_per_tray': breakEvenCostPerTray,
      };
}

/// Top-level breakdown for layers quotations.
class LayersBreakdown {
  final LayersStage stage1;
  final LayersStage stage2;
  final LayersAnalysis analysis;

  LayersBreakdown({
    required this.stage1,
    required this.stage2,
    required this.analysis,
  });

  factory LayersBreakdown.fromJson(Map<String, dynamic> json) {
    final s1 = TypeUtils.toMapSafe(json['stage1']) ?? {};
    final s2 = TypeUtils.toMapSafe(json['stage2']) ?? {};
    final an = TypeUtils.toMapSafe(json['analysis']) ?? {};
    return LayersBreakdown(
      stage1: LayersStage.fromJson(s1),
      stage2: LayersStage.fromJson(s2),
      analysis: LayersAnalysis.fromJson(an),
    );
  }

  Map<String, dynamic> toJson() => {
        'is_layers_breed': true,
        'stage1': stage1.toJson(),
        'stage2': stage2.toJson(),
        'analysis': analysis.toJson(),
      };
}