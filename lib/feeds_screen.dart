// lib/feeds/feeds_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FeedsHomeScreen extends StatelessWidget {
  const FeedsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('2 low stock alerts'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feeding Management',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Track feed distribution and inventory',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),

            Expanded(
              child: ListView(
                children: [
                  _FeedListTile(
                    icon: Icons.note_add,
                    title: 'Log Feeding',
                    subtitle: 'Record distribution',
                    color: Colors.orange,
                    onTap: () => context.push('/feeds/log'),
                  ),
                  _FeedListTile(
                    icon: Icons.bar_chart,
                    title: 'Feeding Records',
                    subtitle: 'View history & stats',
                    color: Colors.blue,
                    onTap: () => context.push('/feeds/records'),
                  ),
                  _FeedListTile(
                    icon: Icons.inventory_2,
                    title: 'Feed Inventory',
                    subtitle: 'Stock levels',
                    color: Colors.purple,
                    onTap: () => context.push('/feeds/inventory'),
                    badge: '2 Low',
                  ),
                  _FeedListTile(
                    icon: Icons.science,
                    title: 'Feed Formula',
                    subtitle: 'Manage ratios',
                    color: Colors.teal,
                    onTap: () => context.push('/feeds/formula'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/feeds/log'),
        icon: const Icon(Icons.add),
        label: const Text('Log Feeding'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class _FeedListTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
  final String? badge;

  const _FeedListTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icon Circle
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 22, color: color),
              ),
              const SizedBox(width: 16),

              // Text Section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Badge (optional)
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(width: 8),

              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }
}
