class FinancialOverview  {
  final double totalIncome;
  final double totalExpenditure;
  final double netProfit;
  final List<FinancialGraphData> graph;

  const FinancialOverview({
    required this.totalIncome,
    required this.totalExpenditure,
    required this.netProfit,
    required this.graph,
  });

  factory FinancialOverview.fromJson(Map<String, dynamic> json) {
    return FinancialOverview(
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpenditure: (json['total_expenditure'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['net_profit'] as num?)?.toDouble() ?? 0.0,
      graph: json['graph'] != null
          ? (json['graph'] as List)
          .map((e) => FinancialGraphData.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_income': totalIncome,
      'total_expenditure': totalExpenditure,
      'net_profit': netProfit,
      'graph': graph.map((e) => e.toJson()).toList(),
    };
  }

  List<Object?> get props => [totalIncome, totalExpenditure, netProfit, graph];
}

class FinancialGraphData  {
  final String month;
  final double totalIncome;
  final double totalExpenditure;
  final double netProfit;

  const FinancialGraphData({
    required this.month,
    required this.totalIncome,
    required this.totalExpenditure,
    required this.netProfit,
  });

  factory FinancialGraphData.fromJson(Map<String, dynamic> json) {
    return FinancialGraphData(
      month: json['month'] as String? ?? '',
      totalIncome: (json['total_income'] as num?)?.toDouble() ?? 0.0,
      totalExpenditure: (json['total_expenditure'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['net_profit'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'month': month,
      'total_income': totalIncome,
      'total_expenditure': totalExpenditure,
      'net_profit': netProfit,
    };
  }

  List<Object?> get props => [month, totalIncome, totalExpenditure, netProfit];
}