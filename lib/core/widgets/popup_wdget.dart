import 'package:flutter/material.dart';

/// A utility class for showing custom popups relative to widgets.
class PopupUtil {
  static OverlayEntry show({
    required BuildContext context,
    required GlobalKey targetKey,
    required Widget child,
    PopupDirection direction = PopupDirection.bottom,
    Color? backgroundColor,
    bool showArrow = true,
    bool barrierDismissible = true,
    Offset offset = Offset.zero,
    Duration animationDuration = const Duration(milliseconds: 200),
    // When true the popup is centered in the safe-area instead of anchored
    // to targetKey. Useful for timed/auto nudges where the anchor may be
    // scrolled out of view or behind the bottom nav bar.
    bool centerOnScreen = false,
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (ctx) => _PopupOverlay(
        targetKey: targetKey,
        direction: direction,
        backgroundColor: backgroundColor,
        showArrow: showArrow,
        barrierDismissible: barrierDismissible,
        offset: offset,
        animationDuration: animationDuration,
        centerOnScreen: centerOnScreen,
        onDismiss: () => overlayEntry.remove(),
        child: child,
      ),
    );

    overlay.insert(overlayEntry);
    return overlayEntry;
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

// ---------------------------------------------------------------------------

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
  final bool centerOnScreen;

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
    required this.centerOnScreen,
  });

  @override
  State<_PopupOverlay> createState() => _PopupOverlayState();
}

class _PopupOverlayState extends State<_PopupOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final GlobalKey _popupKey = GlobalKey();
  Offset? _resolvedPosition;
  bool _positioned = false;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(duration: widget.animationDuration, vsync: this);
    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _opacityAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    WidgetsBinding.instance.addPostFrameCallback((_) => _resolvePosition());
  }

  void _resolvePosition() {
    final popupBox =
    _popupKey.currentContext?.findRenderObject() as RenderBox?;
    if (popupBox == null) return;
    final popupSize = popupBox.size;

    Offset pos;

    if (widget.centerOnScreen) {
      pos = _centerPosition(popupSize);
    } else {
      final targetBox =
      widget.targetKey.currentContext?.findRenderObject() as RenderBox?;
      // Fall back to centered if the anchor is not currently rendered/visible
      pos = targetBox == null
          ? _centerPosition(popupSize)
          : _anchoredPosition(
          targetBox.size, targetBox.localToGlobal(Offset.zero), popupSize);
    }

    if (mounted) {
      setState(() {
        _resolvedPosition = pos;
        _positioned = true;
      });
      _controller.forward();
    }
  }

  /// Place the popup centered horizontally and ~40 % down the safe area.
  Offset _centerPosition(Size popupSize) {
    final mq = MediaQuery.of(context);
    final screen = mq.size;
    final topPad = mq.padding.top;
    final navBarH = mq.viewPadding.bottom.clamp(0.0, 80.0);
    final bottomPad = mq.padding.bottom + mq.viewInsets.bottom + navBarH;
    final safeHeight = screen.height - topPad - bottomPad;

    final x = (screen.width - popupSize.width) / 2;
    final y = topPad + safeHeight * 0.40 - popupSize.height / 2;

    return Offset(
      x.clamp(8.0, screen.width - popupSize.width - 8.0),
      y.clamp(topPad + 8.0,
          screen.height - popupSize.height - bottomPad - 8.0),
    );
  }

  /// Place the popup anchored to a target widget, fully clamped to the safe area.
  Offset _anchoredPosition(
      Size targetSize, Offset targetPos, Size popupSize) {
    double x = targetPos.dx;
    double y = targetPos.dy;

    const double arrow = 8.0;
    const double gap = 4.0;

    switch (widget.direction) {
      case PopupDirection.bottom:
        x += (targetSize.width - popupSize.width) / 2;
        y += targetSize.height + gap + arrow;
        break;
      case PopupDirection.top:
        x += (targetSize.width - popupSize.width) / 2;
        y -= popupSize.height + gap + arrow;
        break;
      case PopupDirection.left:
        x -= popupSize.width + gap + arrow;
        y += (targetSize.height - popupSize.height) / 2;
        break;
      case PopupDirection.right:
        x += targetSize.width + gap + arrow;
        y += (targetSize.height - popupSize.height) / 2;
        break;
      case PopupDirection.bottomLeft:
        x -= popupSize.width - targetSize.width;
        y += targetSize.height + gap + arrow;
        break;
      case PopupDirection.bottomRight:
        y += targetSize.height + gap + arrow;
        break;
      case PopupDirection.topLeft:
        x -= popupSize.width - targetSize.width;
        y -= popupSize.height + gap + arrow;
        break;
      case PopupDirection.topRight:
        y -= popupSize.height + gap + arrow;
        break;
    }

    final mq = MediaQuery.of(context);
    final screen = mq.size;
    final topPad = mq.padding.top;
    // viewPadding.bottom includes the bottom nav bar height on most devices
    final navBarH = mq.viewPadding.bottom.clamp(0.0, 80.0);
    final bottomPad = mq.padding.bottom + mq.viewInsets.bottom + navBarH;

    x = x.clamp(8.0, screen.width - popupSize.width - 8.0);
    y = y.clamp(
      topPad + 8.0,
      screen.height - popupSize.height - bottomPad - 8.0,
    );

    return Offset(x, y) + widget.offset;
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

  Alignment _scaleOrigin() {
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

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dimmed barrier
        Positioned.fill(
          child: GestureDetector(
            onTap: widget.barrierDismissible ? _dismiss : null,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: Container(color: Colors.black.withOpacity(0.15)),
            ),
          ),
        ),

        // Hidden first-pass for measurement
        if (!_positioned)
          Positioned(
            left: -9999,
            top: -9999,
            child: _PopupContent(
              key: _popupKey,
              direction: widget.direction,
              backgroundColor: widget.backgroundColor,
              showArrow: widget.showArrow && !widget.centerOnScreen,
              child: widget.child,
            ),
          ),

        // Visible popup after measurement
        if (_positioned && _resolvedPosition != null)
          Positioned(
            left: _resolvedPosition!.dx,
            top: _resolvedPosition!.dy,
            child: FadeTransition(
              opacity: _opacityAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                alignment: widget.centerOnScreen ? Alignment.center : _scaleOrigin(),
                child: _PopupContent(
                  direction: widget.direction,
                  backgroundColor: widget.backgroundColor,
                  showArrow: widget.showArrow && !widget.centerOnScreen,
                  child: widget.child,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------

class _PopupContent extends StatelessWidget {
  final Widget child;
  final PopupDirection direction;
  final Color? backgroundColor;
  final bool showArrow;

  const _PopupContent({
    super.key,
    required this.child,
    required this.direction,
    required this.backgroundColor,
    required this.showArrow,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? Theme.of(context).colorScheme.surface;

    return Material(
      color: Colors.transparent,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (showArrow) _buildArrow(bgColor),
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
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
    const double s = 8.0;
    switch (direction) {
      case PopupDirection.bottom:
      case PopupDirection.bottomLeft:
      case PopupDirection.bottomRight:
        return Positioned(
          top: -s,
          left: direction == PopupDirection.bottomRight ? 20 : null,
          right: direction == PopupDirection.bottomLeft ? 20 : null,
          child: CustomPaint(
            size: Size(s * 2, s),
            painter: _TrianglePainter(color: color, direction: AxisDirection.up),
          ),
        );
      case PopupDirection.top:
      case PopupDirection.topLeft:
      case PopupDirection.topRight:
        return Positioned(
          bottom: -s,
          left: direction == PopupDirection.topRight ? 20 : null,
          right: direction == PopupDirection.topLeft ? 20 : null,
          child: CustomPaint(
            size: Size(s * 2, s),
            painter:
            _TrianglePainter(color: color, direction: AxisDirection.down),
          ),
        );
      case PopupDirection.left:
        return Positioned(
          right: -s,
          top: 0,
          bottom: 0,
          child: Align(
            child: CustomPaint(
              size: Size(s, s * 2),
              painter: _TrianglePainter(
                  color: color, direction: AxisDirection.right),
            ),
          ),
        );
      case PopupDirection.right:
        return Positioned(
          left: -s,
          top: 0,
          bottom: 0,
          child: Align(
            child: CustomPaint(
              size: Size(s, s * 2),
              painter:
              _TrianglePainter(color: color, direction: AxisDirection.left),
            ),
          ),
        );
    }
  }
}

// ---------------------------------------------------------------------------

class _TrianglePainter extends CustomPainter {
  final Color color;
  final AxisDirection direction;
  const _TrianglePainter({required this.color, required this.direction});

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
    canvas.drawShadow(path, Colors.black.withOpacity(0.1), 2, true);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

// ---------------------------------------------------------------------------

extension PopupContext on BuildContext {
  void showPopup({
    required GlobalKey targetKey,
    required Widget child,
    PopupDirection direction = PopupDirection.bottom,
    Color? backgroundColor,
    bool showArrow = true,
    bool barrierDismissible = true,
    Offset offset = Offset.zero,
    bool centerOnScreen = false,
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
      centerOnScreen: centerOnScreen,
    );
  }
}