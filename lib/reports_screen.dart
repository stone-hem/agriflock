// lib/reports/reports_screen.dart
import 'package:flutter/material.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const Text('Agriflock 360'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey.shade700),
            onPressed: () {
              // Show date range picker
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Farm Analytics',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track your farm performance and insights',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),

            // Stats Grid
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _ReportMetricCard(
                  title: 'Total Eggs',
                  value: '2,840',
                  subtitle: 'This Month',
                  change: '+12%',
                  color: Colors.purple,
                  icon: Icons.egg,
                  isPositive: true,
                ),
                _ReportMetricCard(
                  title: 'Feed Efficiency',
                  value: '1.68',
                  subtitle: 'FCR Ratio',
                  change: '-5%',
                  color: Colors.orange,
                  icon: Icons.rice_bowl,
                  isPositive: true,
                ),
                _ReportMetricCard(
                  title: 'Mortality Rate',
                  value: '2.1%',
                  subtitle: 'Overall',
                  change: '-0.8%',
                  color: Colors.red,
                  icon: Icons.monitor_heart,
                  isPositive: true,
                ),
                _ReportMetricCard(
                  title: 'Avg. Weight',
                  value: '2.3kg',
                  subtitle: 'Per Bird',
                  change: '+0.2kg',
                  color: Colors.blue,
                  icon: Icons.monitor_weight,
                  isPositive: true,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Performance Chart
            Card(
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
                      'Performance Overview',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart, size: 48, color: Colors.grey.shade400),
                            const SizedBox(height: 8),
                            Text(
                              'Production Trends',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Chart will be integrated here',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _ReportMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final String change;
  final Color color;
  final IconData icon;
  final bool isPositive;

  const _ReportMetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.change,
    required this.color,
    required this.icon,
    required this.isPositive,
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 16, color: color),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isPositive ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPositive ? Icons.trending_up : Icons.trending_down,
                        size: 12,
                        color: isPositive ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        change,
                        style: TextStyle(
                          color: isPositive ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}