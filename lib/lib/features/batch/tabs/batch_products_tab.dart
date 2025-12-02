import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchProductsTab extends StatelessWidget {
  final Map<String, dynamic> batch;

  const BatchProductsTab({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    // Mock data - replace with real data from provider/API later
    final List<Map<String, dynamic>> recentCollections = [
      {
        'type': 'Eggs',
        'quantity': 245,
        'date': 'Today, 7:30 AM',
        'icon': Icons.egg,
        'color': Colors.orange,
      },
      {
        'type': 'Eggs',
        'quantity': 238,
        'date': 'Yesterday',
        'icon': Icons.egg,
        'color': Colors.orange,
      },
      {
        'type': 'Meat (Sold)',
        'quantity': 12,
        'unit': 'birds',
        'date': '2 days ago',
        'icon': Icons.kebab_dining,
        'color': Colors.red.shade600,
      },
    ];

    final totalEggs = 4832;
    final avgDailyEggs = 241;
    final totalMeatSold = 47; // birds

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Summary Metrics
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    value: '$totalEggs',
                    label: 'Total Eggs',
                    color: Colors.orange,
                    icon: Icons.egg,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _MetricCard(
                    value: '$avgDailyEggs',
                    label: 'Avg Daily Eggs',
                    color: Colors.amber.shade700,
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    value: '$totalMeatSold',
                    label: 'Birds Sold',
                    color: Colors.red.shade600,
                    icon: Icons.kebab_dining,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(), // placeholder if needed later
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Recent Collections
            _buildSection(
              title: 'Recent Collections',
              context: context,
              children: recentCollections.map((item) {
                return _ActivityItem(
                  icon: item['icon'],
                  title: '${item['type']} Collection',
                  subtitle:
                  '${item['quantity']} ${item['unit'] ?? 'eggs'} collected',
                  time: item['date'],
                  color: item['color'],
                );
              }).toList(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/batches/${batch['id']}/record-product');
        },
        backgroundColor: Colors.green,
        icon: const Icon(Icons.add),
        label: const Text('Record Product'),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
    required BuildContext context,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => context.push('/activity'),
              child: const Text('View all'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

// Reusable widgets (same as in BatchDetailsScreen)
class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _MetricCard({
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
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;

  const _ActivityItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
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
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
          Text(time,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
        ],
      ),
    );
  }
}