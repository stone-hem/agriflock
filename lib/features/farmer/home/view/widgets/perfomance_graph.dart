import 'dart:math';

import 'package:agriflock/core/utils/format_util.dart';
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
  State<FinancialPerformanceGraph> createState() => _FinancialPerformanceGraphState();
}

class _FinancialPerformanceGraphState extends State<FinancialPerformanceGraph> {
  List<FinancialDataPoint> _dataPoints = [];
  double _maxValue = 0;
  late List<double> _profitValues;
  String _currency='';


  @override
  void initState() {
    super.initState();
    _loadCurrency();
    _convertData();
    _calculateMetrics();
  }

  Future<void> _loadCurrency() async {
      var currency = await secureStorage.getCurrency();
      setState(() {
        _currency = currency;
      });
  }

  @override
  void didUpdateWidget(FinancialPerformanceGraph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.financialData != widget.financialData) {
      _convertData();
      _calculateMetrics();
    }
  }

  void _convertData() {
    _dataPoints = widget.financialData.graph
        .map((data) => FinancialDataPoint(
      month: _formatMonth(data.month),
      expenditure: data.totalExpenditure.toInt(),
      income: data.totalIncome.toInt(),
      profit: data.netProfit, 
    ))
        .toList()
        .reversed
        .toList();
  }
  String _formatMonth(String monthYear) {
    // Convert "Jan 2026" to "Jan"
    return monthYear.split(' ').first;
  }


  void _calculateMetrics() {
    // Find max value for scaling
    _maxValue = 0;
    for (var point in _dataPoints) {
      if (point.income > _maxValue) _maxValue = point.income.toDouble();
      if (point.expenditure > _maxValue) _maxValue = point.expenditure.toDouble();
      if (point.profit.abs() > _maxValue) _maxValue = point.profit.abs();
    }

    // Get profit values directly from data points
    _profitValues = _dataPoints.map((point) => point.profit).toList();

    // Add some padding to max value for better visualization
    _maxValue *= 1.1;

    // Guard against all-zero data (new user) — prevents division by zero / NaN
    if (_maxValue == 0) _maxValue = 1;
  }

  int _calculateTotalIncome() {
    return widget.financialData.totalIncome.toInt();
  }

  int _calculateTotalExpenditure() {
    return widget.financialData.totalExpenditure.toInt();
  }

  int _calculateNetProfit() {
    return widget.financialData.netProfit.toInt();
  }

  @override
  Widget build(BuildContext context) {
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
            Text(
              'Financial Performance',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                Icon(Icons.calendar_month, size: 16, color: Colors.grey),
                SizedBox(width: 4),
                Text(
                  'Last 6 Months in $_currency',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 4),
            const Text(
              'Income, Expenditure & Net Profit',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),

            // The Custom Graph
            Container(
              height: 220,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: CustomPaint(
                size: const Size(double.infinity, 180),
                painter: FinancialGraphPainter(
                  dataPoints: _dataPoints,
                  maxValue: _maxValue,
                  profitValues: _profitValues,
                ),
              ),
            ),

            // Legend
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Income'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.red, 'Expenditure'),
                const SizedBox(width: 16),
                _buildLegendItem(Colors.blue, 'Net Profit'),
              ],
            ),

            // Summary Stats
            const SizedBox(height: 20),
            _buildStatCard(
              'Total Income',
              '${FormatUtil.formatAmount(widget.financialData.totalIncome)} $_currency',
              Colors.green,
            ),
            _buildStatCard(
              'Total Expenditure',
              '${FormatUtil.formatAmount(widget.financialData.totalExpenditure)} $_currency',
              Colors.red,
            ),
            _buildStatCard(
              'Net Profit',
              '${FormatUtil.formatAmount(widget.financialData.netProfit)} $_currency',
              widget.financialData.netProfit >= 0 ? Colors.blue : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }


}

class FinancialDataPoint {
  final String month;
  final int expenditure;
  final int income;
  final double profit; 

  FinancialDataPoint({
    required this.month,
    required this.expenditure,
    required this.income,
    required this.profit, 
  });
}

class FinancialGraphPainter extends CustomPainter {
  final List<FinancialDataPoint> dataPoints;
  final double maxValue;
  final List<double> profitValues;

  FinancialGraphPainter({
    required this.dataPoints,
    required this.maxValue,
    required this.profitValues,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) return;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 0;

    final gridPaint = Paint()
      ..color = Colors.grey.shade300
      ..strokeWidth = 0.5;

    final textStyle = TextStyle(
      color: Colors.grey.shade600,
      fontSize: 10,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    // Effective maxValue — never zero to avoid NaN from division
    final effectiveMax = maxValue > 0 ? maxValue : 1.0;

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (i * size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Draw grid labels
      final value = (effectiveMax * i / 4).toInt();
      textPainter.text = TextSpan(
        text: '${(value / 1000).toStringAsFixed(0)}k',
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width - 4, y - 8));
    }

    // Calculate point positions
    final pointSpacing = dataPoints.length > 1
        ? size.width / (dataPoints.length - 1)
        : size.width;
    final List<Offset> incomePoints = [];
    final List<Offset> expenditurePoints = [];
    final List<Offset> profitPoints = [];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * pointSpacing;

      final incomeY = size.height - (dataPoints[i].income / effectiveMax) * size.height;
      incomePoints.add(Offset(x, incomeY));

      final expenditureY = size.height - (dataPoints[i].expenditure / effectiveMax) * size.height;
      expenditurePoints.add(Offset(x, expenditureY));

      final profitValue = profitValues[i];
      double profitY = size.height - (profitValue.abs() / effectiveMax) * size.height;
      if (profitValue < 0) {
         // for visualization, we'll keep negative profit near the baseline but distinguishable
         profitY = size.height - 2; 
      }
      profitPoints.add(Offset(x, profitY));

      // Month labels
      textPainter.text = TextSpan(
        text: dataPoints[i].month,
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 4));
    }

    // --- Draw Smooth Curves ---

    // 1. Income Area and Curve
    if (incomePoints.length > 1) {
      final curvePath = _createSmoothPath(incomePoints);
      final areaPath = Path.from(curvePath);
      areaPath.lineTo(incomePoints.last.dx, size.height);
      areaPath.lineTo(incomePoints.first.dx, size.height);
      areaPath.close();

      areaPaint.color = Colors.green.withOpacity(0.1);
      canvas.drawPath(areaPath, areaPaint);

      paint.color = Colors.green;
      canvas.drawPath(curvePath, paint);
    }

    // 2. Expenditure Curve
    if (expenditurePoints.length > 1) {
      final curvePath = _createSmoothPath(expenditurePoints);
      paint.color = Colors.red;
      canvas.drawPath(curvePath, paint);
    }

    // 3. Profit Curve
    if (profitPoints.length > 1) {
      final curvePath = _createSmoothPath(profitPoints);
      
      // Handle positive/negative transition roughly
      paint.color = Colors.blue;
      canvas.drawPath(curvePath, paint);
    }

    // Draw dots at actual data points for clarity
    for (int i = 0; i < dataPoints.length; i++) {
      canvas.drawCircle(incomePoints[i], 3.5, Paint()..color = Colors.green);
      canvas.drawCircle(expenditurePoints[i], 3.5, Paint()..color = Colors.red);
      
      final isNegative = profitValues[i] < 0;
      canvas.drawCircle(
        profitPoints[i], 
        4, 
        Paint()..color = isNegative ? Colors.orange : Colors.blue
      );
    }
  }

  Path _createSmoothPath(List<Offset> points) {
    final path = Path();
    if (points.isEmpty) return path;

    path.moveTo(points[0].dx, points[0].dy);

    if (points.length == 2) {
      path.lineTo(points[1].dx, points[1].dy);
      return path;
    }

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      
      // Control points for Bezier curve
      final controlPoint1 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p0.dy);
      final controlPoint2 = Offset(p0.dx + (p1.dx - p0.dx) / 2, p1.dy);

      path.cubicTo(
        controlPoint1.dx, controlPoint1.dy,
        controlPoint2.dx, controlPoint2.dy,
        p1.dx, p1.dy,
      );
    }

    return path;
  }

  @override
  bool shouldRepaint(covariant FinancialGraphPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.maxValue != maxValue;
  }
}
