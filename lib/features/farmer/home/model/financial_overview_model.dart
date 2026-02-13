import 'dart:convert';
import 'package:agriflock360/core/utils/type_safe_utils.dart';

class FinancialOverview {
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
    final graphList = TypeUtils.toListSafe<dynamic>(json['graph']);

    return FinancialOverview(
      totalIncome: TypeUtils.toDoubleSafe(json['total_income']),
      totalExpenditure: TypeUtils.toDoubleSafe(json['total_expenditure']),
      netProfit: TypeUtils.toDoubleSafe(json['net_profit']),
      graph: graphList
          .map((e) => FinancialGraphData.fromJson(
          e is Map<String, dynamic> ? e : {}))
          .toList(),
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

class FinancialGraphData {
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
      month: TypeUtils.toStringSafe(json['month']),
      totalIncome: TypeUtils.toDoubleSafe(json['total_income']),
      totalExpenditure: TypeUtils.toDoubleSafe(json['total_expenditure']),
      netProfit: TypeUtils.toDoubleSafe(json['net_profit']),
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