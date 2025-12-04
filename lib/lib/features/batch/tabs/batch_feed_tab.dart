import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchFeedTab extends StatelessWidget {
  final Map<String, dynamic> batch;

  const BatchFeedTab({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Feed Summary Cards
            Row(
              children: [
                Expanded(
                  child: _FeedMetricCard(
                    value: '25kg',
                    label: 'Daily Consumption',
                    color: Colors.orange,
                    icon: Icons.restaurant,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeedMetricCard(
                    value: '150kg',
                    label: 'Weekly Total',
                    color: Colors.blue,
                    icon: Icons.bar_chart,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _FeedMetricCard(
                    value: '2.3kg',
                    label: 'Avg per Bird',
                    color: Colors.green,
                    icon: Icons.scale,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _FeedMetricCard(
                    value: 'Good',
                    label: 'FCR',
                    color: Colors.purple,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Feedings & Recommended Schedule Tabs
            Expanded(
              child: DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: TabBar(
                        isScrollable: true,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.all(6),
                        tabAlignment: .start,
                        dividerColor: Colors.transparent,
                        indicator: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF9800), Color(0xFFF57C00)], // Orange gradient for feed
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.orange.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        indicatorSize: TabBarIndicatorSize.tab,
                        labelColor: Colors.white,
                        unselectedLabelColor: Colors.grey.shade600,
                        labelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                        splashFactory: NoSplash.splashFactory,
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        tabs: [
                          _buildTabWithIcon(Icons.history, 'Recent Feedings'),
                          _buildTabWithIcon(Icons.schedule, 'Recommended Schedule'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: TabBarView(
                        children: [
                          // Recent Feedings Tab
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ListView(
                                  children: [
                                    _FeedingRecordItem(
                                      date: 'Today, 8:30 AM',
                                      amount: '25kg',
                                      type: 'Morning Feeding',
                                      efficiency: '92%',
                                    ),
                                    _FeedingRecordItem(
                                      date: 'Today, 3:00 PM',
                                      amount: '22kg',
                                      type: 'Afternoon Feeding',
                                      efficiency: '88%',
                                    ),
                                    _FeedingRecordItem(
                                      date: 'Yesterday, 8:45 AM',
                                      amount: '24kg',
                                      type: 'Morning Feeding',
                                      efficiency: '90%',
                                    ),
                                    _FeedingRecordItem(
                                      date: 'Yesterday, 3:15 PM',
                                      amount: '23kg',
                                      type: 'Afternoon Feeding',
                                      efficiency: '87%',
                                    ),
                                    _FeedingRecordItem(
                                      date: 'Dec 10, 8:30 AM',
                                      amount: '24kg',
                                      type: 'Morning Feeding',
                                      efficiency: '89%',
                                    ),
                                    _FeedingRecordItem(
                                      date: 'Dec 10, 3:00 PM',
                                      amount: '21kg',
                                      type: 'Afternoon Feeding',
                                      efficiency: '85%',
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // Recommended Schedule Tab
                          ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.blue.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Standard feeding schedule for poultry (Broilers)',
                                          style: TextStyle(
                                            color: Colors.blue.shade900,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              _RecommendedFeedingItem(
                                stage: 'Starter (Day 1-10)',
                                feedType: 'Pre-starter Crumble',
                                amount: '20g per bird/day',
                                frequency: 'Ad libitum (Free choice)',
                                protein: '22-24% CP',
                              ),
                              _RecommendedFeedingItem(
                                stage: 'Grower (Day 11-24)',
                                feedType: 'Grower Pellet',
                                amount: '100g per bird/day',
                                frequency: '2-3 times daily',
                                protein: '20-22% CP',
                              ),
                              _RecommendedFeedingItem(
                                stage: 'Finisher (Day 25-42)',
                                feedType: 'Finisher Pellet',
                                amount: '150g per bird/day',
                                frequency: '2-3 times daily',
                                protein: '18-20% CP',
                              ),
                              _RecommendedFeedingItem(
                                stage: 'Pre-lay (Week 18-21)',
                                feedType: 'Developer Feed',
                                amount: '110g per bird/day',
                                frequency: '2 times daily',
                                protein: '16-17% CP',
                                calcium: '2.5%',
                              ),
                              _RecommendedFeedingItem(
                                stage: 'Laying (Week 22+)',
                                feedType: 'Layer Mash',
                                amount: '120g per bird/day',
                                frequency: 'Morning & Evening',
                                protein: '16-18% CP',
                                calcium: '3.5-4.0%',
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 16, bottom: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.green.shade200),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.lightbulb_outline, color: Colors.green.shade700, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Feeding Tips',
                                              style: TextStyle(
                                                color: Colors.green.shade900,
                                                fontSize: 13,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              '• Provide fresh water at all times\n• Clean feeders regularly\n• Avoid sudden feed changes\n• Monitor feed consumption daily',
                                              style: TextStyle(
                                                color: Colors.green.shade800,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/batches/feed');
        },
        icon: const Icon(Icons.add),
        label: const Text('Log Feeding'),
        backgroundColor: Colors.orange,
      ),
    );
  }

  Widget _buildTabWithIcon(IconData icon, String label) {
    return Tab(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _FeedMetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _FeedMetricCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeedingRecordItem extends StatelessWidget {
  final String date;
  final String amount;
  final String type;
  final String efficiency;

  const _FeedingRecordItem({
    required this.date,
    required this.amount,
    required this.type,
    required this.efficiency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.restaurant, size: 18, color: Colors.orange),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  type,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  amount,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  efficiency,
                  style: TextStyle(
                    color: Colors.green.shade800,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RecommendedFeedingItem extends StatelessWidget {
  final String stage;
  final String feedType;
  final String amount;
  final String frequency;
  final String protein;
  final String? calcium;

  const _RecommendedFeedingItem({
    required this.stage,
    required this.feedType,
    required this.amount,
    required this.frequency,
    required this.protein,
    this.calcium,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant_menu, size: 18, color: Colors.orange),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      stage,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feedType,
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _FeedInfoRow(
                  icon: Icons.scale,
                  label: 'Amount',
                  value: amount,
                ),
                const SizedBox(height: 6),
                _FeedInfoRow(
                  icon: Icons.schedule,
                  label: 'Frequency',
                  value: frequency,
                ),
                const SizedBox(height: 6),
                _FeedInfoRow(
                  icon: Icons.health_and_safety_outlined,
                  label: 'Protein',
                  value: protein,
                ),
                if (calcium != null) ...[
                  const SizedBox(height: 6),
                  _FeedInfoRow(
                    icon: Icons.science,
                    label: 'Calcium',
                    value: calcium!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FeedInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}