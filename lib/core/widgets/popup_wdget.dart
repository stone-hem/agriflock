import 'package:flutter/material.dart';

/// A utility class for showing custom popups relative to widgets
class PopupUtil {
  /// Shows a popup relative to a widget
  ///
  /// [context] - BuildContext to show the popup in
  /// [targetKey] - GlobalKey of the widget to attach the popup to
  /// [child] - The content to display in the popup
  /// [direction] - Where to position the popup relative to the target
  /// [backgroundColor] - Background color of the popup
  /// [showArrow] - Whether to show an arrow pointing to the target
  /// [barrierDismissible] - Whether tapping outside dismisses the popup
  /// [offset] - Additional offset from the target widget
  static void show({
    required BuildContext context,
    required GlobalKey targetKey,
    required Widget child,
    PopupDirection direction = PopupDirection.bottom,
    Color? backgroundColor,
    bool showArrow = true,
    bool barrierDismissible = true,
    Offset offset = Offset.zero,
    Duration animationDuration = const Duration(milliseconds: 200),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _PopupOverlay(
        targetKey: targetKey,
        direction: direction,
        backgroundColor: backgroundColor,
        showArrow: showArrow,
        barrierDismissible: barrierDismissible,
        offset: offset,
        animationDuration: animationDuration,
        onDismiss: () => overlayEntry.remove(),
        child: child,
      ),
    );

    overlay.insert(overlayEntry);
  }
}

enum PopupDirection {
  top,
  bottom,
  left,
  right,
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
}

class _PopupOverlay extends StatefulWidget {
  final GlobalKey targetKey;
  final Widget child;
  final PopupDirection direction;
  final Color? backgroundColor;
  final bool showArrow;
  final bool barrierDismissible;
  final Offset offset;
  final Duration animationDuration;
  final VoidCallback onDismiss;

  const _PopupOverlay({
    required this.targetKey,
    required this.child,
    required this.direction,
    required this.backgroundColor,
    required this.showArrow,
    required this.barrierDismissible,
    required this.offset,
    required this.animationDuration,
    required this.onDismiss,
  });

  @override
  State<_PopupOverlay> createState() => _PopupOverlayState();
}

class _PopupOverlayState extends State<_PopupOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _opacityAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _dismiss() async {
    await _controller.reverse();
    widget.onDismiss();
  }

  Offset _calculatePosition(Size targetSize, Offset targetPosition, Size popupSize) {
    double x = targetPosition.dx;
    double y = targetPosition.dy;

    const double arrowSize = 8.0;
    const double spacing = 4.0;

    switch (widget.direction) {
      case PopupDirection.bottom:
        x += (targetSize.width - popupSize.width) / 2;
        y += targetSize.height + spacing + arrowSize;
        break;
      case PopupDirection.top:
        x += (targetSize.width - popupSize.width) / 2;
        y -= popupSize.height + spacing + arrowSize;
        break;
      case PopupDirection.left:
        x -= popupSize.width + spacing + arrowSize;
        y += (targetSize.height - popupSize.height) / 2;
        break;
      case PopupDirection.right:
        x += targetSize.width + spacing + arrowSize;
        y += (targetSize.height - popupSize.height) / 2;
        break;
      case PopupDirection.bottomLeft:
        x -= popupSize.width - targetSize.width;
        y += targetSize.height + spacing + arrowSize;
        break;
      case PopupDirection.bottomRight:
        y += targetSize.height + spacing + arrowSize;
        break;
      case PopupDirection.topLeft:
        x -= popupSize.width - targetSize.width;
        y -= popupSize.height + spacing + arrowSize;
        break;
      case PopupDirection.topRight:
        y -= popupSize.height + spacing + arrowSize;
        break;
    }

    return Offset(x, y) + widget.offset;
  }

  @override
  Widget build(BuildContext context) {
    final RenderBox? renderBox =
    widget.targetKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null) {
      return const SizedBox.shrink();
    }

    final targetSize = renderBox.size;
    final targetPosition = renderBox.localToGlobal(Offset.zero);

    return Stack(
      children: [
        // Semi-transparent barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.barrierDismissible ? _dismiss : null,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(
                color: Colors.black.withOpacity(0.1),
              ),
            ),
          ),
        ),
        // Popup content
        Positioned(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FutureBuilder<Size>(
                future: _measureWidget(widget.child),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final popupSize = snapshot.data!;
                  final position = _calculatePosition(
                    targetSize,
                    targetPosition,
                    popupSize,
                  );

                  return Positioned(
                    left: position.dx,
                    top: position.dy,
                    child: FadeTransition(
                      opacity: _opacityAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        alignment: _getScaleAlignment(),
                        child: _PopupContent(
                          direction: widget.direction,
                          backgroundColor: widget.backgroundColor,
                          showArrow: widget.showArrow,
                          child: widget.child,
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Alignment _getScaleAlignment() {
    switch (widget.direction) {
      case PopupDirection.top:
      case PopupDirection.topLeft:
      case PopupDirection.topRight:
        return Alignment.bottomCenter;
      case PopupDirection.bottom:
      case PopupDirection.bottomLeft:
      case PopupDirection.bottomRight:
        return Alignment.topCenter;
      case PopupDirection.left:
        return Alignment.centerRight;
      case PopupDirection.right:
        return Alignment.centerLeft;
    }
  }

  Future<Size> _measureWidget(Widget widget) async {
    final key = GlobalKey();
    final measuringWidget = Directionality(
      textDirection: TextDirection.ltr,
      child: Material(
        child: Opacity(
          opacity: 0,
          child: Container(
            key: key,
            child: widget,
          ),
        ),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {});

    await Future.delayed(const Duration(milliseconds: 1));

    final RenderBox? renderBox =
    key.currentContext?.findRenderObject() as RenderBox?;
    return renderBox?.size ?? const Size(200, 100);
  }
}

class _PopupContent extends StatelessWidget {
  final Widget child;
  final PopupDirection direction;
  final Color? backgroundColor;
  final bool showArrow;

  const _PopupContent({
    required this.child,
    required this.direction,
    required this.backgroundColor,
    required this.showArrow,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? theme.colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Arrow
          if (showArrow) _buildArrow(bgColor),
          // Content
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 0,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: child,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrow(Color color) {
    const double arrowSize = 8.0;

    switch (direction) {
      case PopupDirection.bottom:
      case PopupDirection.bottomLeft:
      case PopupDirection.bottomRight:
        return Positioned(
          top: -arrowSize,
          left: direction == PopupDirection.bottomLeft
              ? null
              : direction == PopupDirection.bottomRight
              ? 20
              : null,
          right: direction == PopupDirection.bottomLeft ? 20 : null,
          child: CustomPaint(
            size: const Size(arrowSize * 2, arrowSize),
            painter: _TrianglePainter(color: color, direction: AxisDirection.up),
          ),
        );
      case PopupDirection.top:
      case PopupDirection.topLeft:
      case PopupDirection.topRight:
        return Positioned(
          bottom: -arrowSize,
          left: direction == PopupDirection.topLeft
              ? null
              : direction == PopupDirection.topRight
              ? 20
              : null,
          right: direction == PopupDirection.topLeft ? 20 : null,
          child: CustomPaint(
            size: const Size(arrowSize * 2, arrowSize),
            painter: _TrianglePainter(color: color, direction: AxisDirection.down),
          ),
        );
      case PopupDirection.left:
        return Positioned(
          right: -arrowSize,
          top: 0,
          bottom: 0,
          child: Align(
            child: CustomPaint(
              size: const Size(arrowSize, arrowSize * 2),
              painter: _TrianglePainter(color: color, direction: AxisDirection.right),
            ),
          ),
        );
      case PopupDirection.right:
        return Positioned(
          left: -arrowSize,
          top: 0,
          bottom: 0,
          child: Align(
            child: CustomPaint(
              size: const Size(arrowSize, arrowSize * 2),
              painter: _TrianglePainter(color: color, direction: AxisDirection.left),
            ),
          ),
        );
    }
  }
}

class _TrianglePainter extends CustomPainter {
  final Color color;
  final AxisDirection direction;

  _TrianglePainter({required this.color, required this.direction});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();

    switch (direction) {
      case AxisDirection.up:
        path.moveTo(size.width / 2, 0);
        path.lineTo(size.width, size.height);
        path.lineTo(0, size.height);
        break;
      case AxisDirection.down:
        path.moveTo(0, 0);
        path.lineTo(size.width, 0);
        path.lineTo(size.width / 2, size.height);
        break;
      case AxisDirection.left:
        path.moveTo(0, size.height / 2);
        path.lineTo(size.width, 0);
        path.lineTo(size.width, size.height);
        break;
      case AxisDirection.right:
        path.moveTo(0, 0);
        path.lineTo(size.width, size.height / 2);
        path.lineTo(0, size.height);
        break;
    }

    path.close();
    canvas.drawPath(path, paint);

    // Add subtle shadow to arrow
    canvas.drawShadow(path, Colors.black.withOpacity(0.1), 2, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Helper extension for easy access
extension PopupContext on BuildContext {
  void showPopup({
    required GlobalKey targetKey,
    required Widget child,
    PopupDirection direction = PopupDirection.bottom,
    Color? backgroundColor,
    bool showArrow = true,
    bool barrierDismissible = true,
    Offset offset = Offset.zero,
  }) {
    PopupUtil.show(
      context: this,
      targetKey: targetKey,
      child: child,
      direction: direction,
      backgroundColor: backgroundColor,
      showArrow: showArrow,
      barrierDismissible: barrierDismissible,
      offset: offset,
    );
  }
}