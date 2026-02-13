import 'package:agriflock360/core/utils/type_safe_utils.dart';

class FarmFinancialStatsResponse {
  final bool success;
  final FarmFinancialStats data;

  const FarmFinancialStatsResponse({
    required this.success,
    required this.data,
  });

  factory FarmFinancialStatsResponse.fromJson(Map<String, dynamic> json) {
    final dataMap = TypeUtils.toMapSafe(json['data']);

    return FarmFinancialStatsResponse(
      success: TypeUtils.toBoolSafe(json['success']),
      data: FarmFinancialStats.fromJson(dataMap ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': data.toJson(),
    };
  }
}

class FarmFinancialStats {
  final double productIncome;
  final double eggIncome;
  final double meatIncome;
  final double otherIncome;
  final double feedCost;
  final double medicationCost;
  final double vaccineCost;
  final double laborCost;
  final double utilitiesCost;
  final double equipmentCost;
  final double otherCosts;
  final double totalIncome;
  final double totalExpenditure;
  final double netProfit;
  final double profitMargin;
  final List<ExpenditureByCategory> expenditureByCategory;
  final List<IncomeByProductType> incomeByProductType;

  const FarmFinancialStats({
    required this.productIncome,
    required this.eggIncome,
    required this.meatIncome,
    required this.otherIncome,
    required this.feedCost,
    required this.medicationCost,
    required this.vaccineCost,
    required this.laborCost,
    required this.utilitiesCost,
    required this.equipmentCost,
    required this.otherCosts,
    required this.totalIncome,
    required this.totalExpenditure,
    required this.netProfit,
    required this.profitMargin,
    required this.expenditureByCategory,
    required this.incomeByProductType,
  });

  factory FarmFinancialStats.fromJson(Map<String, dynamic> json) {
    final expenditureList = TypeUtils.toListSafe<dynamic>(json['expenditure_by_category']);
    final incomeList = TypeUtils.toListSafe<dynamic>(json['income_by_product_type']);

    return FarmFinancialStats(
      productIncome: TypeUtils.toDoubleSafe(json['product_income']),
      eggIncome: TypeUtils.toDoubleSafe(json['egg_income']),
      meatIncome: TypeUtils.toDoubleSafe(json['meat_income']),
      otherIncome: TypeUtils.toDoubleSafe(json['other_income']),
      feedCost: TypeUtils.toDoubleSafe(json['feed_cost']),
      medicationCost: TypeUtils.toDoubleSafe(json['medication_cost']),
      vaccineCost: TypeUtils.toDoubleSafe(json['vaccine_cost']),
      laborCost: TypeUtils.toDoubleSafe(json['labor_cost']),
      utilitiesCost: TypeUtils.toDoubleSafe(json['utilities_cost']),
      equipmentCost: TypeUtils.toDoubleSafe(json['equipment_cost']),
      otherCosts: TypeUtils.toDoubleSafe(json['other_costs']),
      totalIncome: TypeUtils.toDoubleSafe(json['total_income']),
      totalExpenditure: TypeUtils.toDoubleSafe(json['total_expenditure']),
      netProfit: TypeUtils.toDoubleSafe(json['net_profit']),
      profitMargin: TypeUtils.toDoubleSafe(json['profit_margin']),
      expenditureByCategory: expenditureList
          .map((e) => ExpenditureByCategory.fromJson(
          e is Map<String, dynamic> ? e : {}))
          .toList(),
      incomeByProductType: incomeList
          .map((e) => IncomeByProductType.fromJson(
          e is Map<String, dynamic> ? e : {}))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_income': productIncome,
      'egg_income': eggIncome,
      'meat_income': meatIncome,
      'other_income': otherIncome,
      'feed_cost': feedCost,
      'medication_cost': medicationCost,
      'vaccine_cost': vaccineCost,
      'labor_cost': laborCost,
      'utilities_cost': utilitiesCost,
      'equipment_cost': equipmentCost,
      'other_costs': otherCosts,
      'total_income': totalIncome,
      'total_expenditure': totalExpenditure,
      'net_profit': netProfit,
      'profit_margin': profitMargin,
      'expenditure_by_category': expenditureByCategory.map((e) => e.toJson()).toList(),
      'income_by_product_type': incomeByProductType.map((e) => e.toJson()).toList(),
    };
  }
}

class ExpenditureByCategory {
  final String category;
  final double amount;

  const ExpenditureByCategory({
    required this.category,
    required this.amount,
  });

  factory ExpenditureByCategory.fromJson(Map<String, dynamic> json) {
    return ExpenditureByCategory(
      category: TypeUtils.toStringSafe(json['category']),
      amount: TypeUtils.toDoubleSafe(json['amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'amount': amount,
    };
  }
}

class IncomeByProductType {
  final String productType;
  final double amount;

  const IncomeByProductType({
    required this.productType,
    required this.amount,
  });

  factory IncomeByProductType.fromJson(Map<String, dynamic> json) {
    return IncomeByProductType(
      productType: TypeUtils.toStringSafe(json['product_type']),
      amount: TypeUtils.toDoubleSafe(json['amount']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product_type': productType,
      'amount': amount,
    };
  }
}