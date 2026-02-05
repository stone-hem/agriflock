import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A compact scrolling marquee banner for expense recording.
/// Displays continuously scrolling text that links to record-expenditure screen.
class ExpenseMarqueeBannerCompact extends StatefulWidget {
  const ExpenseMarqueeBannerCompact({super.key});

  @override
  State<ExpenseMarqueeBannerCompact> createState() => _ExpenseMarqueeBannerCompactState();
}

class _ExpenseMarqueeBannerCompactState extends State<ExpenseMarqueeBannerCompact>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late ScrollController _scrollController;
  double _textWidth = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(seconds: 20),
      vsync: this,
    );

    _animationController.addListener(_onAnimationUpdate);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isDisposed && mounted) {
        _startAnimation();
      }
    });
  }

  void _startAnimation() {
    if (_scrollController.hasClients) {
      _textWidth = _scrollController.position.maxScrollExtent;
      if (_textWidth > 0) {
        _animationController.repeat();
      }
    }
  }

  void _onAnimationUpdate() {
    if (_isDisposed || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll > 0) {
      final scrollPosition = _animationController.value * maxScroll;
      _scrollController.jumpTo(scrollPosition);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.removeListener(_onAnimationUpdate);
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/record-expenditure'),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade100,
              Colors.amber.shade100,
            ],
          ),
          border: Border(
            top: BorderSide(color: Colors.orange.shade200),
          ),
        ),
        child: Row(
          children: [
            // Left icon
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
              ),
              child: Icon(
                Icons.trending_up,
                color: Colors.orange.shade700,
                size: 18,
              ),
            ),
            // Marquee content - properly clipped
            Expanded(
              child: ClipRect(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  physics: const NeverScrollableScrollPhysics(),
                  child: Row(
                    children: [
                      _buildMarqueeItem(),
                      const SizedBox(width: 60),
                      _buildMarqueeItem(),
                      const SizedBox(width: 60),
                      _buildMarqueeItem(),
                      const SizedBox(width: 60),
                    ],
                  ),
                ),
              ),
            ),
            // Right tap indicator
            Container(
              width: 32,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.orange.shade200,
              ),
              child: Icon(
                Icons.touch_app,
                color: Colors.orange.shade700,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarqueeItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.orange,
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Quick expense',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Add your expenses and selling price to see your profit.',
            style: TextStyle(
              fontSize: 12,
              color: Colors.brown.shade700,
            ),
          ),
        ],
      ),
    );
  }
}
