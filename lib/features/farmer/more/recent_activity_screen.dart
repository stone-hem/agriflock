// lib/activity/recent_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecentActivityScreen extends StatelessWidget {
  const RecentActivityScreen({super.key});

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
            const Text('Recent Activity'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(context),
            const SizedBox(height: 24),

            // Activity List
            _buildActivityList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.lightGreen.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Farm Activity',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'All recent farm activities',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Track everything happening on your farm',
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      children: [
        // Today Section
        _buildDateSection('Today'),
        _ActivityItem(
          icon: Icons.egg,
          title: 'Egg Collection - Flock A',
          subtitle: '87 eggs recorded in morning collection',
          time: '2 hours ago',
          color: Colors.orange,
        ),
        _ActivityItem(
          icon: Icons.restaurant,
          title: 'Morning Feeding',
          subtitle: '25kg feed distributed across all flocks',
          time: '4 hours ago',
          color: Colors.green,
        ),
        _ActivityItem(
          icon: Icons.cleaning_services,
          title: 'Coop Cleaning',
          subtitle: 'Flock B coop cleaned and sanitized',
          time: '6 hours ago',
          color: Colors.blue,
        ),

        // Yesterday Section
        _buildDateSection('Yesterday'),
        _ActivityItem(
          icon: Icons.medical_services,
          title: 'Health Check',
          subtitle: 'Routine health inspection completed for Flock A',
          time: 'Yesterday, 10:30 AM',
          color: Colors.blue,
        ),
        _ActivityItem(
          icon: Icons.egg,
          title: 'Egg Collection',
          subtitle: '92 eggs recorded in total',
          time: 'Yesterday, 8:15 AM',
          color: Colors.orange,
        ),
        _ActivityItem(
          icon: Icons.water_drop,
          title: 'Water System Check',
          subtitle: 'Automatic waterers inspected and cleaned',
          time: 'Yesterday, 9:00 AM',
          color: Colors.cyan,
        ),
        _ActivityItem(
          icon: Icons.shopping_cart,
          title: 'Feed Delivery',
          subtitle: '200kg of layer feed delivered',
          time: 'Yesterday, 2:30 PM',
          color: Colors.purple,
        ),

        // This Week Section
        _buildDateSection('This Week'),
        _ActivityItem(
          icon: Icons.analytics,
          title: 'Weekly Production Report',
          subtitle: 'Production analysis completed',
          time: '2 days ago',
          color: Colors.indigo,
        ),
        _ActivityItem(
          icon: Icons.vaccines,
          title: 'Vaccination',
          subtitle: 'Flock C vaccinated against Newcastle disease',
          time: '3 days ago',
          color: Colors.red,
        ),
        _ActivityItem(
          icon: Icons.construction,
          title: 'Equipment Maintenance',
          subtitle: 'Feeding system serviced and calibrated',
          time: '4 days ago',
          color: Colors.brown,
        ),
      ],
    );
  }

  Widget _buildDateSection(String date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Text(
        date,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade700,
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
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                time,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Completed',
                  style: TextStyle(
                    color: Colors.green.shade700,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
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