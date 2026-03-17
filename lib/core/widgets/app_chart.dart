import 'dart:math';
import 'package:agriflock/core/theme/theme.dart';
import 'package:flutter/material.dart';

// ─── Theme accessor ───────────────────────────────────────────────────────────

class _AppChartColors {
  const _AppChartColors();
  Color get border => AppColors.border;
  Color get textMuted => AppColors.textMuted;
  Color get textSecondary => AppColors.textSecondary;
}

extension _BuildContextColors on BuildContext {
  _AppChartColors get colors => const _AppChartColors();
}

// ─── Data Models ──────────────────────────────────────────────────────────────

class AppBarData {
  final String label;
  final double value;
  final Color? color;
  const AppBarData({required this.label, required this.value, this.color});
}

class AppLinePoint {
  final double x; // 0..n (index or days offset)
  final double y; // value
  const AppLinePoint(this.x, this.y);
}

// ─── Bar Chart ────────────────────────────────────────────────────────────────

class AppBarChart extends StatefulWidget {
  final List<AppBarData> bars;
  final double? maxValue;
  final double height;
  final bool showLabels;
  final bool showValues;
  final Color? defaultBarColor;
  final bool animate;

  const AppBarChart({
    super.key,
    required this.bars,
    this.maxValue,
    this.height = 120,
    this.showLabels = true,
    this.showValues = false,
    this.defaultBarColor,
    this.animate = true,
  });

  @override
  State<AppBarChart> createState() => _AppBarChartState();
}

class _AppBarChartState extends State<AppBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    if (widget.animate) _ctrl.forward();
    else _ctrl.value = 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final maxVal = widget.maxValue ??
        (widget.bars.isEmpty ? 1.0 : widget.bars.map((b) => b.value).reduce(max));
    final effectiveMax = maxVal <= 0 ? 1.0 : maxVal;
    final labelHeight = widget.showLabels ? 18.0 : 0.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: widget.height + labelHeight,
        child: CustomPaint(
          painter: _BarChartPainter(
            bars: widget.bars,
            maxValue: effectiveMax,
            progress: _anim.value,
            showLabels: widget.showLabels,
            showValues: widget.showValues,
            labelHeight: labelHeight,
            defaultColor: widget.defaultBarColor ?? AppColors.primary,
            gridColor: c.border,
            labelColor: c.textMuted,
            valueColor: c.textSecondary,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  final List<AppBarData> bars;
  final double maxValue;
  final double progress;
  final bool showLabels;
  final bool showValues;
  final double labelHeight;
  final Color defaultColor;
  final Color gridColor;
  final Color labelColor;
  final Color valueColor;

  _BarChartPainter({
    required this.bars,
    required this.maxValue,
    required this.progress,
    required this.showLabels,
    required this.showValues,
    required this.labelHeight,
    required this.defaultColor,
    required this.gridColor,
    required this.labelColor,
    required this.valueColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;

    final chartH = size.height - labelHeight;
    final barW = (size.width / bars.length) * 0.55;
    final gap = (size.width / bars.length) * 0.45;
    final barPaint = Paint()..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    // Draw subtle grid lines
    for (int i = 1; i <= 4; i++) {
      final y = chartH - (chartH * i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final frac = (bar.value / maxValue).clamp(0.0, 1.0) * progress;
      final barH = max(frac * chartH, bar.value > 0 ? 2.0 : 0.0);
      final x = i * (size.width / bars.length) + gap / 2;
      final y = chartH - barH;

      final color = bar.color ?? defaultColor;
      barPaint.color = color;

      final rrect = RRect.fromRectAndCorners(
        Rect.fromLTWH(x, y, barW, barH),
        topLeft: const Radius.circular(4),
        topRight: const Radius.circular(4),
      );
      canvas.drawRRect(rrect, barPaint);

      // Value label on top of bar
      if (showValues && bar.value > 0) {
        final tp = TextPainter(
          text: TextSpan(
            text: bar.value == bar.value.roundToDouble()
                ? '${bar.value.round()}'
                : bar.value.toStringAsFixed(1),
            style: TextStyle(
                color: valueColor, fontSize: 9, fontWeight: FontWeight.w600),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(
            canvas, Offset(x + barW / 2 - tp.width / 2, y - tp.height - 2));
      }

      // Bottom label
      if (showLabels) {
        final tp = TextPainter(
          text: TextSpan(
              text: bar.label,
              style: TextStyle(color: labelColor, fontSize: 9)),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: size.width / bars.length);
        tp.paint(canvas,
            Offset(x + barW / 2 - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_BarChartPainter old) => old.progress != progress;
}

// ─── Stacked Bar Chart (e.g. done vs undone) ──────────────────────────────────

class AppStackedBarData {
  final String label;
  final double bottom; // e.g. completed
  final double top; // e.g. remaining
  final Color bottomColor;
  final Color topColor;
  const AppStackedBarData({
    required this.label,
    required this.bottom,
    required this.top,
    required this.bottomColor,
    required this.topColor,
  });
}

class AppStackedBarChart extends StatefulWidget {
  final List<AppStackedBarData> bars;
  final double height;
  final bool showLabels;

  const AppStackedBarChart({
    super.key,
    required this.bars,
    this.height = 120,
    this.showLabels = true,
  });

  @override
  State<AppStackedBarChart> createState() => _AppStackedBarChartState();
}

class _AppStackedBarChartState extends State<AppStackedBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final maxVal = widget.bars.isEmpty
        ? 1.0
        : widget.bars.map((b) => b.bottom + b.top).reduce(max);
    final effectiveMax = maxVal <= 0 ? 1.0 : maxVal;
    final labelH = widget.showLabels ? 18.0 : 0.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: widget.height + labelH,
        child: CustomPaint(
          painter: _StackedBarPainter(
            bars: widget.bars,
            maxValue: effectiveMax,
            progress: _anim.value,
            showLabels: widget.showLabels,
            labelHeight: labelH,
            gridColor: c.border,
            labelColor: c.textMuted,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _StackedBarPainter extends CustomPainter {
  final List<AppStackedBarData> bars;
  final double maxValue;
  final double progress;
  final bool showLabels;
  final double labelHeight;
  final Color gridColor;
  final Color labelColor;

  _StackedBarPainter({
    required this.bars,
    required this.maxValue,
    required this.progress,
    required this.showLabels,
    required this.labelHeight,
    required this.gridColor,
    required this.labelColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (bars.isEmpty) return;
    final chartH = size.height - labelHeight;
    final barW = (size.width / bars.length) * 0.55;
    final gap = (size.width / bars.length) * 0.45;

    final paint = Paint()..style = PaintingStyle.fill;
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;

    for (int i = 1; i <= 3; i++) {
      final y = chartH - (chartH * i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    for (int i = 0; i < bars.length; i++) {
      final bar = bars[i];
      final total = bar.bottom + bar.top;
      final totalFrac = (total / maxValue).clamp(0.0, 1.0) * progress;
      final totalH = totalFrac * chartH;
      final bottomH = total > 0 ? (bar.bottom / total) * totalH : 0.0;
      final topH = totalH - bottomH;

      final x = i * (size.width / bars.length) + gap / 2;

      // Top segment
      if (topH > 0) {
        paint.color = bar.topColor;
        canvas.drawRRect(
          RRect.fromRectAndCorners(
            Rect.fromLTWH(x, chartH - totalH, barW, topH),
            topLeft: const Radius.circular(4),
            topRight: const Radius.circular(4),
          ),
          paint,
        );
      }

      // Bottom segment
      if (bottomH > 0) {
        paint.color = bar.bottomColor;
        canvas.drawRect(
            Rect.fromLTWH(x, chartH - bottomH, barW, bottomH), paint);
      }

      if (showLabels) {
        final tp = TextPainter(
          text: TextSpan(
              text: bar.label,
              style: TextStyle(color: labelColor, fontSize: 9)),
          textDirection: TextDirection.ltr,
        )..layout(maxWidth: size.width / bars.length);
        tp.paint(canvas, Offset(x + barW / 2 - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_StackedBarPainter old) => old.progress != progress;
}

// ─── Line Chart ───────────────────────────────────────────────────────────────

class AppLineChart extends StatefulWidget {
  final List<AppLinePoint> points;
  final double height;
  final Color? lineColor;
  final Color? fillColor;
  final bool showDots;
  final bool animate;
  final List<String>? xLabels;

  const AppLineChart({
    super.key,
    required this.points,
    this.height = 120,
    this.lineColor,
    this.fillColor,
    this.showDots = true,
    this.animate = true,
    this.xLabels,
  });

  @override
  State<AppLineChart> createState() => _AppLineChartState();
}

class _AppLineChartState extends State<AppLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    if (widget.animate) _ctrl.forward();
    else _ctrl.value = 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final labelH = widget.xLabels != null ? 18.0 : 0.0;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: widget.height + labelH,
        child: CustomPaint(
          painter: _LineChartPainter(
            points: widget.points,
            progress: _anim.value,
            lineColor: widget.lineColor ?? AppColors.primary,
            fillColor: widget.fillColor ??
                AppColors.primary.withValues(alpha: 0.12),
            showDots: widget.showDots,
            gridColor: c.border,
            xLabels: widget.xLabels,
            labelColor: c.textMuted,
            labelHeight: labelH,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  final List<AppLinePoint> points;
  final double progress;
  final Color lineColor;
  final Color fillColor;
  final bool showDots;
  final Color gridColor;
  final List<String>? xLabels;
  final Color labelColor;
  final double labelHeight;

  _LineChartPainter({
    required this.points,
    required this.progress,
    required this.lineColor,
    required this.fillColor,
    required this.showDots,
    required this.gridColor,
    required this.xLabels,
    required this.labelColor,
    required this.labelHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    final chartH = size.height - labelHeight;

    final minX = points.map((p) => p.x).reduce(min);
    final maxX = points.map((p) => p.x).reduce(max);
    final maxY = points.map((p) => p.y).reduce(max);
    final xRange = (maxX - minX).abs() < 0.001 ? 1.0 : maxX - minX;
    final yRange = maxY <= 0 ? 1.0 : maxY;

    Offset toCanvas(AppLinePoint p) => Offset(
      (p.x - minX) / xRange * (size.width - 16) + 8,
      chartH - (p.y / yRange) * (chartH - 8) - 4,
    );

    // Grid lines
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.4)
      ..strokeWidth = 0.5;
    for (int i = 1; i <= 3; i++) {
      final y = chartH - (chartH * i / 4);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Animated points (draw only up to progress)
    final totalPts = points.length;
    final visibleCount = max(2, (totalPts * progress).ceil());
    final visiblePoints = points.take(visibleCount).toList();

    if (visiblePoints.isEmpty) return;

    // Build path
    final path = Path();
    final firstOffset = toCanvas(visiblePoints.first);
    path.moveTo(firstOffset.dx, firstOffset.dy);
    for (int i = 1; i < visiblePoints.length; i++) {
      final prev = toCanvas(visiblePoints[i - 1]);
      final curr = toCanvas(visiblePoints[i]);
      final cpx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
    }

    // Fill
    final fillPath = Path.from(path);
    final lastPt = toCanvas(visiblePoints.last);
    fillPath.lineTo(lastPt.dx, chartH);
    fillPath.lineTo(firstOffset.dx, chartH);
    fillPath.close();
    canvas.drawPath(fillPath, Paint()..color = fillColor);

    // Line
    canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Dots
    if (showDots) {
      for (final p in visiblePoints) {
        final o = toCanvas(p);
        canvas.drawCircle(o, 3.5, Paint()..color = lineColor);
        canvas.drawCircle(o, 2, Paint()..color = Colors.white.withValues(alpha: 0.9));
      }
    }

    // X labels
    if (xLabels != null) {
      for (int i = 0; i < min(xLabels!.length, points.length); i++) {
        if (i >= visibleCount) break;
        final o = toCanvas(points[i]);
        final tp = TextPainter(
          text: TextSpan(
              text: xLabels![i],
              style: TextStyle(color: labelColor, fontSize: 9)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(o.dx - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_LineChartPainter old) => old.progress != progress;
}

// ─── Sparkline (tiny, no axes) ────────────────────────────────────────────────

class AppSparkline extends StatelessWidget {
  final List<double> values;
  final Color? color;
  final double width;
  final double height;

  const AppSparkline({
    super.key,
    required this.values,
    this.color,
    this.width = 60,
    this.height = 24,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _SparklinePainter(values: values, color: c),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final List<double> values;
  final Color color;
  _SparklinePainter({required this.values, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;
    final maxV = values.reduce(max);
    final minV = values.reduce(min);
    final range = (maxV - minV).abs() < 0.001 ? 1.0 : maxV - minV;

    final pts = List.generate(values.length, (i) {
      final x = i / (values.length - 1) * size.width;
      final y = size.height - ((values[i] - minV) / range) * size.height;
      return Offset(x, y);
    });

    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      final cx = (prev.dx + curr.dx) / 2;
      path.cubicTo(cx, prev.dy, cx, curr.dy, curr.dx, curr.dy);
    }

    canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_SparklinePainter old) => false;
}

// ─── Donut / Ring Chart ───────────────────────────────────────────────────────

class AppRingChart extends StatefulWidget {
  final double progress; // 0.0 – 1.0
  final Color color;
  final Color bgColor;
  final double size;
  final double strokeWidth;
  final Widget? center;

  const AppRingChart({
    super.key,
    required this.progress,
    required this.color,
    required this.bgColor,
    this.size = 72,
    this.strokeWidth = 8,
    this.center,
  });

  @override
  State<AppRingChart> createState() => _AppRingChartState();
}

class _AppRingChartState extends State<AppRingChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RingPainter(
            progress: widget.progress * _anim.value,
            color: widget.color,
            bgColor: widget.bgColor,
            strokeWidth: widget.strokeWidth,
          ),
          child: widget.center != null
              ? Center(child: widget.center!)
              : null,
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color bgColor;
  final double strokeWidth;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.bgColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background ring
    canvas.drawCircle(
        center,
        radius,
        Paint()
          ..color = bgColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth);

    // Progress arc
    if (progress > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -pi / 2,
        2 * pi * progress.clamp(0.0, 1.0),
        false,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = strokeWidth
          ..strokeCap = StrokeCap.round,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress || old.color != color;
}

// ─── Multi-Series Line Chart ──────────────────────────────────────────────────

class AppMultiLineSeries {
  final String label;
  final List<AppLinePoint> points;
  final Color color;
  final bool showFill;

  const AppMultiLineSeries({
    required this.label,
    required this.points,
    required this.color,
    this.showFill = false,
  });
}

class AppMultiLineChart extends StatefulWidget {
  final List<AppMultiLineSeries> series;
  final double height;
  final bool showDots;
  final bool animate;
  final List<String>? xLabels;

  const AppMultiLineChart({
    super.key,
    required this.series,
    this.height = 160,
    this.showDots = true,
    this.animate = true,
    this.xLabels,
  });

  @override
  State<AppMultiLineChart> createState() => _AppMultiLineChartState();
}

class _AppMultiLineChartState extends State<AppMultiLineChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900));
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    if (widget.animate) _ctrl.forward();
    else _ctrl.value = 1.0;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final labelH = widget.xLabels != null ? 18.0 : 0.0;

    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => SizedBox(
        height: widget.height + labelH,
        child: CustomPaint(
          painter: _MultiLineChartPainter(
            series: widget.series,
            progress: _anim.value,
            showDots: widget.showDots,
            gridColor: c.border,
            xLabels: widget.xLabels,
            labelColor: c.textMuted,
            labelHeight: labelH,
          ),
          size: Size.infinite,
        ),
      ),
    );
  }
}

class _MultiLineChartPainter extends CustomPainter {
  final List<AppMultiLineSeries> series;
  final double progress;
  final bool showDots;
  final Color gridColor;
  final List<String>? xLabels;
  final Color labelColor;
  final double labelHeight;

  _MultiLineChartPainter({
    required this.series,
    required this.progress,
    required this.showDots,
    required this.gridColor,
    required this.xLabels,
    required this.labelColor,
    required this.labelHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (series.isEmpty) return;

    final allPoints = series.expand((s) => s.points).toList();
    if (allPoints.isEmpty) return;

    final chartH = size.height - labelHeight;

    // Left margin reserved for Y-axis labels
    const leftMargin = 40.0;
    final chartW = size.width - leftMargin;

    // X range
    final minX = allPoints.map((p) => p.x).reduce(min);
    final maxX = allPoints.map((p) => p.x).reduce(max);
    final xRange = (maxX - minX).abs() < 0.001 ? 1.0 : maxX - minX;

    // Y range — always include 0 so positive/negative are correctly anchored
    final rawMinY = allPoints.map((p) => p.y).reduce(min);
    final rawMaxY = allPoints.map((p) => p.y).reduce(max);
    final dataMinY = min(0.0, rawMinY);
    final dataMaxY = max(0.0, rawMaxY);
    final ySpan = dataMaxY - dataMinY;
    // 8% padding top and bottom so lines don't touch edges
    final paddedMin = dataMinY - ySpan * 0.08;
    final paddedMax = dataMaxY + ySpan * 0.08;
    final yRange = (paddedMax - paddedMin) < 0.001 ? 1.0 : paddedMax - paddedMin;

    // Maps a data point to canvas coordinates
    Offset toCanvas(AppLinePoint p) => Offset(
      leftMargin + (p.x - minX) / xRange * (chartW - 8) + 4,
      chartH - ((p.y - paddedMin) / yRange) * chartH,
    );

    // ── Y-axis grid lines + labels ──
    const ySteps = 4;
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.35)
      ..strokeWidth = 0.5;

    for (int i = 0; i <= ySteps; i++) {
      final value = paddedMin + yRange * i / ySteps;
      final y = chartH - chartH * i / ySteps;

      canvas.drawLine(Offset(leftMargin, y), Offset(size.width, y), gridPaint);

      // Format: ±Xk or ±X
      final absV = value.abs();
      final sign = value < -0.5 ? '-' : '';
      final labelStr = absV >= 1000
          ? '$sign${(absV / 1000).toStringAsFixed(absV >= 10000 ? 0 : 1)}k'
          : '$sign${absV.toStringAsFixed(0)}';

      final tp = TextPainter(
        text: TextSpan(
            text: labelStr,
            style: TextStyle(color: labelColor, fontSize: 8.5)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(leftMargin - tp.width - 4, y - tp.height / 2));
    }

    // ── Zero baseline (prominent when negatives exist) ──
    if (paddedMin < -0.5) {
      final zeroY = chartH - ((0 - paddedMin) / yRange) * chartH;
      canvas.drawLine(
        Offset(leftMargin, zeroY),
        Offset(size.width, zeroY),
        Paint()
          ..color = gridColor.withValues(alpha: 0.9)
          ..strokeWidth = 1.0,
      );
    }

    // ── Draw each series ──
    for (final s in series) {
      if (s.points.isEmpty) continue;

      final visibleCount = max(2, (s.points.length * progress).ceil());
      final visible = s.points.take(visibleCount).toList();

      // Build smooth bezier path
      final path = Path();
      final first = toCanvas(visible.first);
      path.moveTo(first.dx, first.dy);
      for (int i = 1; i < visible.length; i++) {
        final prev = toCanvas(visible[i - 1]);
        final curr = toCanvas(visible[i]);
        final cpx = (prev.dx + curr.dx) / 2;
        path.cubicTo(cpx, prev.dy, cpx, curr.dy, curr.dx, curr.dy);
      }

      // Fill under line (clamped to zero line so fill doesn't go below 0)
      if (s.showFill) {
        final zeroY = chartH - ((0 - paddedMin) / yRange) * chartH;
        final fill = Path.from(path);
        final last = toCanvas(visible.last);
        fill.lineTo(last.dx, zeroY);
        fill.lineTo(first.dx, zeroY);
        fill.close();
        canvas.drawPath(
            fill, Paint()..color = s.color.withValues(alpha: 0.10));
      }

      // Line stroke
      canvas.drawPath(
        path,
        Paint()
          ..color = s.color
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // Dots
      if (showDots) {
        for (final p in visible) {
          final o = toCanvas(p);
          canvas.drawCircle(o, 3.5, Paint()..color = s.color);
          canvas.drawCircle(
              o, 2, Paint()..color = Colors.white.withValues(alpha: 0.9));
        }
      }
    }

    // ── X-axis labels (from first series) ──
    if (xLabels != null && series.isNotEmpty) {
      final pts = series.first.points;
      final visibleCount = max(2, (pts.length * progress).ceil());
      for (int i = 0; i < min(xLabels!.length, pts.length); i++) {
        if (i >= visibleCount) break;
        final o = toCanvas(pts[i]);
        final tp = TextPainter(
          text: TextSpan(
              text: xLabels![i],
              style: TextStyle(color: labelColor, fontSize: 9)),
          textDirection: TextDirection.ltr,
        )..layout();
        tp.paint(canvas, Offset(o.dx - tp.width / 2, chartH + 4));
      }
    }
  }

  @override
  bool shouldRepaint(_MultiLineChartPainter old) => old.progress != progress;
}
