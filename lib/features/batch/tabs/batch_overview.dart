import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchOverview extends StatelessWidget {
  final Map<String, dynamic> batch;

  const BatchOverview({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header Card
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: Colors.green,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              batch['name'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              batch['breed'],
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Key Metrics
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '${batch['quantity']}',
                  label: 'Total Birds',
                  color: Colors.blue.shade100,
                  icon: Icons.agriculture, textColor: Colors.blue.shade800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  value: '${batch['age']}',
                  label: 'Days Old',
                  color: Colors.orange.shade100,
                  icon: Icons.calendar_today, textColor: Colors.orange.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  value: '${batch['mortality']}',
                  label: 'Mortality',
                  color: Colors.red.shade100,
                  icon: Icons.flag, textColor: Colors.red.shade800,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  value: '${(batch['quantity'] - batch['mortality'])}',
                  label: 'Live Birds',
                  color: Colors.green.shade100,
                  icon: Icons.verified_user, textColor: Colors.green.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Recent Activity
          _buildSection(
            title: 'Recent Activity',
            context: context,
            children: [
              _ActivityItem(
                icon: Icons.restaurant,
                title: 'Morning Feeding',
                subtitle: '25kg feed distributed',
                time: 'Today, 8:30 AM',
                color: Colors.green,
              ),
              _ActivityItem(
                icon: Icons.egg,
                title: 'Egg Collection',
                subtitle: '45 eggs collected',
                time: 'Today, 7:00 AM',
                color: Colors.orange,
              ),
              _ActivityItem(
                icon: Icons.monitor_weight,
                title: 'Weight Check',
                subtitle: 'Average: 2.3kg per bird',
                time: 'Yesterday',
                color: Colors.blue,
              ),
            ],
          ),
        ],
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
            TextButton(onPressed: ()=>context.push('/activity'), child: Text('View all'))
          ],
        ),
        const SizedBox(height: 16),
        ...children,
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;
  final IconData? icon; // Optional icon
  final Color? iconColor; // Optional icon color
  final double iconSize; // Icon size
  final bool showIconOnTop; // Whether to show icon above or beside value
  final MainAxisAlignment iconAlignment; // Icon alignment when beside value

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    this.icon,
    this.iconColor,
    this.iconSize = 24,
    this.showIconOnTop = false,
    this.iconAlignment = MainAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null && showIconOnTop) ...[
            Icon(
              icon,
              color: iconColor ?? textColor,
              size: iconSize,
            ),
            const SizedBox(height: 8),
          ],

          // Value row with optional icon
          Row(
            mainAxisAlignment: iconAlignment,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null && !showIconOnTop) ...[
                Icon(
                  icon,
                  color: iconColor ?? textColor,
                  size: iconSize,
                ),
                const SizedBox(width: 8),
              ],

              Expanded(
                child: Text(
                  value,
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Label
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
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
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  subtitle,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

