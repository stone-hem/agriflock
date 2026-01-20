import 'dart:math';

import 'package:flutter/material.dart';

class FinancialPerformanceGraph extends StatefulWidget {
  const FinancialPerformanceGraph({super.key});

  @override
  State<FinancialPerformanceGraph> createState() => _FinancialPerformanceGraphState();
}

class _FinancialPerformanceGraphState extends State<FinancialPerformanceGraph> {
  // Sample data - replace with your actual data
  final List<FinancialDataPoint> _dataPoints = [
    FinancialDataPoint(month: 'Jan', expenditure: 12000, income: 15000),
    FinancialDataPoint(month: 'Feb', expenditure: 14000, income: 18000),
    FinancialDataPoint(month: 'Mar', expenditure: 11000, income: 16000),
    FinancialDataPoint(month: 'Apr', expenditure: 13000, income: 19000),
    FinancialDataPoint(month: 'May', expenditure: 16000, income: 22000),
    FinancialDataPoint(month: 'Jun', expenditure: 15000, income: 21000),
  ];

  double _maxValue = 0;
  late List<double> _profitValues;

  @override
  void initState() {
    super.initState();
    _calculateMetrics();
  }

  void _calculateMetrics() {
    // Find max value for scaling
    _maxValue = 0;
    for (var point in _dataPoints) {
      if (point.income > _maxValue) _maxValue = point.income.toDouble();
      if (point.expenditure > _maxValue) _maxValue = point.expenditure.toDouble();
    }

    // Calculate profit values
    _profitValues = _dataPoints
        .map((point) => point.income - point.expenditure)
        .map((profit) => profit.toDouble())
        .toList();

    // Add some padding to max value for better visualization
    _maxValue *= 1.1;
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
                  'Last 6 Months',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatCard(
                    'Total Income',
                    '${_calculateTotalIncome()}',
                    Colors.green,
                  ),
                  _buildStatCard(
                    'Total Expenditure',
                    '${_calculateTotalExpenditure()}',
                    Colors.red,
                  ),
                  _buildStatCard(
                    'Net Profit',
                    '${_calculateNetProfit()}',
                    _calculateNetProfit() >= 0 ? Colors.blue : Colors.orange,
                  ),
                ],
              ),
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

  int _calculateTotalIncome() {
    return _dataPoints.fold(0, (sum, point) => sum + point.income);
  }

  int _calculateTotalExpenditure() {
    return _dataPoints.fold(0, (sum, point) => sum + point.expenditure);
  }

  int _calculateNetProfit() {
    return _calculateTotalIncome() - _calculateTotalExpenditure();
  }
}

class FinancialDataPoint {
  final String month;
  final int expenditure;
  final int income;

  FinancialDataPoint({
    required this.month,
    required this.expenditure,
    required this.income,
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
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

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

    // Draw grid lines
    for (int i = 0; i <= 4; i++) {
      final y = size.height - (i * size.height / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );

      // Draw grid labels
      final value = (maxValue * i / 4).toInt();
      textPainter.text = TextSpan(
        text: '${(value / 1000).toStringAsFixed(0)}k',
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-textPainter.width - 4, y - 8));
    }

    // Calculate point positions
    final pointSpacing = size.width / (dataPoints.length - 1);
    final List<Offset> incomePoints = [];
    final List<Offset> expenditurePoints = [];
    final List<Offset> profitPoints = [];

    for (int i = 0; i < dataPoints.length; i++) {
      final x = i * pointSpacing;

      // Income points (green)
      final incomeY = size.height - (dataPoints[i].income / maxValue) * size.height;
      incomePoints.add(Offset(x, incomeY));

      // Expenditure points (red)
      final expenditureY = size.height - (dataPoints[i].expenditure / maxValue) * size.height;
      expenditurePoints.add(Offset(x, expenditureY));

      // Profit points (blue)
      // Adjust profit to be centered around the middle
      final profitY = size.height / 2 - (profitValues[i] / maxValue) * size.height * 0.5;
      profitPoints.add(Offset(x, profitY));

      // Draw month labels at bottom
      textPainter.text = TextSpan(
        text: dataPoints[i].month,
        style: textStyle,
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(x - textPainter.width / 2, size.height + 4));
    }

    // Draw income area (green)
    if (incomePoints.length > 1) {
      final incomePath = Path();
      incomePath.moveTo(incomePoints.first.dx, incomePoints.first.dy);
      for (int i = 1; i < incomePoints.length; i++) {
        incomePath.lineTo(incomePoints[i].dx, incomePoints[i].dy);
      }

      // Close the area path
      incomePath.lineTo(incomePoints.last.dx, size.height);
      incomePath.lineTo(incomePoints.first.dx, size.height);
      incomePath.close();

      areaPaint.color = Colors.green.withOpacity(0.1);
      canvas.drawPath(incomePath, areaPaint);

      // Draw income line
      paint.color = Colors.green;
      canvas.drawPath(incomePath, paint);
    }

    // Draw expenditure line (red)
    if (expenditurePoints.length > 1) {
      final expenditurePath = Path();
      expenditurePath.moveTo(expenditurePoints.first.dx, expenditurePoints.first.dy);
      for (int i = 1; i < expenditurePoints.length; i++) {
        expenditurePath.lineTo(expenditurePoints[i].dx, expenditurePoints[i].dy);
      }

      paint.color = Colors.red;
      canvas.drawPath(expenditurePath, paint);

      // Draw expenditure points
      for (final point in expenditurePoints) {
        canvas.drawCircle(point, 3, paint..color = Colors.red);
      }
    }

    // Draw profit line (blue, dashed for negative)
    if (profitPoints.length > 1) {
      final profitPath = Path();
      profitPath.moveTo(profitPoints.first.dx, profitPoints.first.dy);

      for (int i = 1; i < profitPoints.length; i++) {
        final isNegative = profitValues[i] < 0;

        if (isNegative) {
          // Draw dashed line for negative profit
          final dashPaint = Paint()
            ..color = Colors.orange
            ..strokeWidth = 2
            ..style = PaintingStyle.stroke;

          // Simple dashed line effect
          final dx = profitPoints[i].dx - profitPoints[i-1].dx;
          final dy = profitPoints[i].dy - profitPoints[i-1].dy;
          final distance = sqrt(dx * dx + dy * dy);
          final steps = (distance / 6).floor();

          for (int j = 0; j < steps; j++) {
            if (j % 2 == 0) {
              final startX = profitPoints[i-1].dx + (dx * j / steps);
              final startY = profitPoints[i-1].dy + (dy * j / steps);
              final endX = profitPoints[i-1].dx + (dx * (j + 1) / steps);
              final endY = profitPoints[i-1].dy + (dy * (j + 1) / steps);
              canvas.drawLine(Offset(startX, startY), Offset(endX, endY), dashPaint);
            }
          }
        } else {
          // Solid line for positive profit
          paint.color = Colors.blue;
          canvas.drawLine(profitPoints[i-1], profitPoints[i], paint);
        }
      }

      // Draw profit points
      for (int i = 0; i < profitPoints.length; i++) {
        final isNegative = profitValues[i] < 0;
        canvas.drawCircle(
          profitPoints[i],
          4,
          paint..color = isNegative ? Colors.orange : Colors.blue,
        );

        // Draw profit value near point
        textPainter.text = TextSpan(
          text: '${profitValues[i].toInt().abs()}',
          style: TextStyle(
            color: isNegative ? Colors.orange : Colors.blue,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(
            profitPoints[i].dx - textPainter.width / 2,
            profitPoints[i].dy - (profitValues[i] >= 0 ? 15 : -15),
          ),
        );
      }
    }

    // Draw income points
    for (final point in incomePoints) {
      canvas.drawCircle(point, 3, paint..color = Colors.green);
    }
  }

  @override
  bool shouldRepaint(covariant FinancialGraphPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints ||
        oldDelegate.maxValue != maxValue;
  }
}