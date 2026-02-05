import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A scrolling marquee banner that promotes quick expense recording.
/// This widget displays a continuously scrolling text that links to the
/// record-expenditure screen.
class ExpenseMarqueeBanner extends StatefulWidget {
  final String buttonText;
  final String description;
  final Color backgroundColor;
  final Color textColor;
  final Color accentColor;
  final double height;

  const ExpenseMarqueeBanner({
    super.key,
    this.buttonText = 'Quick expense',
    this.description = 'Add your expenses and selling price to see your profit.',
    this.backgroundColor = const Color(0xFFFFF8E1), // Light amber
    this.textColor = const Color(0xFF795548), // Brown
    this.accentColor = const Color(0xFFFF9800), // Orange
    this.height = 40,
  });

  @override
  State<ExpenseMarqueeBanner> createState() => _ExpenseMarqueeBannerState();
}

class _ExpenseMarqueeBannerState extends State<ExpenseMarqueeBanner>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _scrollPosition = 0;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..addListener(_updateScroll);

    // Start scrolling after widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startScrolling();
    });
  }

  void _startScrolling() {
    if (_isDisposed) return;
    _animationController.repeat();
  }

  void _updateScroll() {
    if (_isDisposed || !_scrollController.hasClients) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll > 0) {
      _scrollPosition = _animationController.value * maxScroll;
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollPosition % (maxScroll + 100));
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final marqueeText = '${widget.buttonText} - ${widget.description}';

    return GestureDetector(
      onTap: () => context.push('/record-expenditure'),
      child: Container(
        height: widget.height,
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          border: Border(
            top: BorderSide(color: widget.accentColor.withOpacity(0.3)),
            bottom: BorderSide(color: widget.accentColor.withOpacity(0.3)),
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: widget.height,
              color: widget.accentColor.withOpacity(0.2),
              child: Icon(
                Icons.receipt_long,
                color: widget.accentColor,
                size: 20,
              ),
            ),
            // Marquee text
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const NeverScrollableScrollPhysics(),
                child: Row(
                  children: [
                    _buildMarqueeContent(marqueeText),
                    const SizedBox(width: 50),
                    _buildMarqueeContent(marqueeText),
                    const SizedBox(width: 50),
                    _buildMarqueeContent(marqueeText),
                  ],
                ),
              ),
            ),
            // Arrow indicator
            Container(
              width: 36,
              height: widget.height,
              color: widget.accentColor.withOpacity(0.1),
              child: Icon(
                Icons.arrow_forward_ios,
                color: widget.accentColor,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMarqueeContent(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: widget.accentColor,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              widget.buttonText,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            widget.description,
            style: TextStyle(
              fontSize: 13,
              color: widget.textColor,
            ),
          ),
        ],
      ),
    );
  }
}

/// A compact version of the expense banner for use at the bottom of screens.
class ExpenseMarqueeBannerCompact extends StatefulWidget {
  const ExpenseMarqueeBannerCompact({super.key});

  @override
  State<ExpenseMarqueeBannerCompact> createState() => _ExpenseMarqueeBannerCompactState();
}

class _ExpenseMarqueeBannerCompactState extends State<ExpenseMarqueeBannerCompact>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    )..repeat();

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: const Offset(-1.0, 0.0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.linear,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
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
        child: ClipRect(
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Icon(
                  Icons.trending_up,
                  color: Colors.orange.shade700,
                  size: 18,
                ),
              ),
              Expanded(
                child: SlideTransition(
                  position: _offsetAnimation,
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
                      const SizedBox(width: 40),
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
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Icon(
                  Icons.touch_app,
                  color: Colors.orange.shade700,
                  size: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
