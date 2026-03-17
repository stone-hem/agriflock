import 'package:agriflock/core/utils/format_util.dart';
import 'package:agriflock/core/widgets/app_chart.dart';
import 'package:agriflock/features/farmer/home/model/financial_overview_model.dart';
import 'package:agriflock/main.dart';
import 'package:flutter/material.dart';

class FinancialPerformanceGraph extends StatefulWidget {
  final FinancialOverview financialData;

  const FinancialPerformanceGraph({
    super.key,
    required this.financialData,
  });

  @override
  State<FinancialPerformanceGraph> createState() =>
      _FinancialPerformanceGraphState();
}

class _FinancialPerformanceGraphState extends State<FinancialPerformanceGraph> {
  String _currency = '';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    final currency = await secureStorage.getCurrency();
    if (mounted) setState(() => _currency = currency);
  }

  @override
  void didUpdateWidget(FinancialPerformanceGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  /// Builds the three AppMultiLineSeries from the graph data.
  List<AppMultiLineSeries> _buildSeries() {
    final points = widget.financialData.graph.reversed.toList();
    if (points.isEmpty) return [];

    final incomePoints = <AppLinePoint>[];
    final expenditurePoints = <AppLinePoint>[];
    final profitPoints = <AppLinePoint>[];

    for (int i = 0; i < points.length; i++) {
      final x = i.toDouble();
      incomePoints.add(AppLinePoint(x, points[i].totalIncome));
      expenditurePoints.add(AppLinePoint(x, points[i].totalExpenditure));
      profitPoints.add(AppLinePoint(x, points[i].netProfit));
    }

    return [
      AppMultiLineSeries(
        label: 'Income',
        points: incomePoints,
        color: Colors.green.shade600,
        showFill: true,
      ),
      AppMultiLineSeries(
        label: 'Expenditure',
        points: expenditurePoints,
        color: Colors.red.shade500,
      ),
      AppMultiLineSeries(
        label: 'Net Profit',
        points: profitPoints,
        color: Colors.blue.shade500,
      ),
    ];
  }

  List<String> _buildXLabels() {
    return widget.financialData.graph.reversed
        .map((d) => d.month.split(' ').first)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final series = _buildSeries();
    final xLabels = _buildXLabels();

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Financial Performance',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Text(
                  'Last 6 Months${_currency.isNotEmpty ? ' · $_currency' : ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Chart
            AppMultiLineChart(
              series: series,
              height: 160,
              showDots: true,
              xLabels: xLabels.isNotEmpty ? xLabels : null,
            ),

            // Legend
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LegendDot(color: Colors.green.shade600, label: 'Income'),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.red.shade500, label: 'Expenditure'),
                const SizedBox(width: 16),
                _LegendDot(color: Colors.blue.shade500, label: 'Net Profit'),
              ],
            ),

            // Summary stats
            const SizedBox(height: 20),
            _StatRow(
              label: 'Total Income',
              value: '$_currency ${FormatUtil.formatAmount(widget.financialData.totalIncome)}',
              color: Colors.green.shade600,
            ),
            const SizedBox(height: 8),
            _StatRow(
              label: 'Total Expenditure',
              value: '$_currency ${FormatUtil.formatAmount(widget.financialData.totalExpenditure)}',
              color: Colors.red.shade500,
            ),
            const SizedBox(height: 8),
            _StatRow(
              label: 'Net Profit',
              value: '$_currency ${FormatUtil.formatAmount(widget.financialData.netProfit)}',
              color: widget.financialData.netProfit >= 0
                  ? Colors.blue.shade600
                  : Colors.orange.shade700,
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
      ],
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatRow({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
        Text(value,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}
