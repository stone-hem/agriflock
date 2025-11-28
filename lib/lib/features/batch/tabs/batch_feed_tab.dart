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


            // Recent Feedings
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Feedings',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
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
                      ],
                    ),
                  ),
                ],
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