class FarmFinancialStatsResponse {
  final bool success;
  final FarmFinancialStats data;

  const FarmFinancialStatsResponse({
    required this.success,
    required this.data,
  });

  factory FarmFinancialStatsResponse.fromJson(Map<String, dynamic> json) {
    return FarmFinancialStatsResponse(
      success: json['success'] ?? false,
      data: FarmFinancialStats.fromJson(json['data'] ?? {}),
    );
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
    return FarmFinancialStats(
      productIncome: (json['product_income'] ?? 0).toDouble(),
      eggIncome: (json['egg_income'] ?? 0).toDouble(),
      meatIncome: (json['meat_income'] ?? 0).toDouble(),
      otherIncome: (json['other_income'] ?? 0).toDouble(),
      feedCost: (json['feed_cost'] ?? 0).toDouble(),
      medicationCost: (json['medication_cost'] ?? 0).toDouble(),
      vaccineCost: (json['vaccine_cost'] ?? 0).toDouble(),
      laborCost: (json['labor_cost'] ?? 0).toDouble(),
      utilitiesCost: (json['utilities_cost'] ?? 0).toDouble(),
      equipmentCost: (json['equipment_cost'] ?? 0).toDouble(),
      otherCosts: (json['other_costs'] ?? 0).toDouble(),
      totalIncome: (json['total_income'] ?? 0).toDouble(),
      totalExpenditure: (json['total_expenditure'] ?? 0).toDouble(),
      netProfit: (json['net_profit'] ?? 0).toDouble(),
      profitMargin: (json['profit_margin'] ?? 0).toDouble(),
      expenditureByCategory: (json['expenditure_by_category'] as List?)
              ?.map((e) => ExpenditureByCategory.fromJson(e))
              .toList() ??
          [],
      incomeByProductType: (json['income_by_product_type'] as List?)
              ?.map((e) => IncomeByProductType.fromJson(e))
              .toList() ??
          [],
    );
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
      category: json['category'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
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
      productType: json['product_type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
    );
  }
}
