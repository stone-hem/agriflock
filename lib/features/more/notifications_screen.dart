// lib/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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
              width: 30,
              height: 30,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 30,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const Text('Notifications'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Mark all as read functionality
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('All notifications marked as read'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(
              'Mark all as read',
              style: TextStyle(
                color: Colors.green.shade700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(context),
            const SizedBox(height: 24),

            // Notification Stats
            _buildNotificationStats(),
            const SizedBox(height: 24),

            // Notifications List
            _buildNotificationsList(),
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
            'Farm Alerts',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Stay updated with farm notifications',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.green.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Important alerts and reminders for your farm',
            style: TextStyle(
              color: Colors.green.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStats() {
    return Row(
      children: [
        Expanded(
          child: _NotificationStatCard(
            value: '12',
            label: 'Total Alerts',
            color: Colors.blue.shade100,
            textColor: Colors.blue.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NotificationStatCard(
            value: '3',
            label: 'Unread',
            color: Colors.orange.shade100,
            textColor: Colors.orange.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _NotificationStatCard(
            value: '2',
            label: 'Critical',
            color: Colors.red.shade100,
            textColor: Colors.red.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationsList() {
    return Column(
      children: [
        // Critical Alerts
        _buildNotificationSection('Critical Alerts', Icons.warning_amber),
        _NotificationItem(
          icon: Icons.inventory_2,
          title: 'Low Stock Alert',
          subtitle: 'Layer feed running low. Only 25kg remaining',
          time: 'Just now',
          color: Colors.red,
          isUnread: true,
          priority: 'High',
        ),
        _NotificationItem(
          icon: Icons.medical_services,
          title: 'Health Warning',
          subtitle: 'Unusual behavior detected in Flock B',
          time: '30 mins ago',
          color: Colors.red,
          isUnread: true,
          priority: 'High',
        ),

        // Regular Notifications
        _buildNotificationSection('Today', Icons.today),
        _NotificationItem(
          icon: Icons.egg,
          title: 'Egg Production Update',
          subtitle: 'Today\'s collection completed: 87 eggs',
          time: '2 hours ago',
          color: Colors.orange,
          isUnread: false,
          priority: 'Normal',
        ),
        _NotificationItem(
          icon: Icons.restaurant,
          title: 'Feeding Reminder',
          subtitle: 'Evening feeding due in 1 hour',
          time: '3 hours ago',
          color: Colors.green,
          isUnread: false,
          priority: 'Normal',
        ),

        // Yesterday
        _buildNotificationSection('Yesterday', Icons.history),
        _NotificationItem(
          icon: Icons.shopping_cart,
          title: 'Order Shipped',
          subtitle: 'Your feed order has been shipped',
          time: 'Yesterday, 4:30 PM',
          color: Colors.purple,
          isUnread: false,
          priority: 'Normal',
        ),
        _NotificationItem(
          icon: Icons.analytics,
          title: 'Weekly Report Ready',
          subtitle: 'Your farm performance report is available',
          time: 'Yesterday, 2:15 PM',
          color: Colors.indigo,
          isUnread: false,
          priority: 'Normal',
        ),
        _NotificationItem(
          icon: Icons.vaccines,
          title: 'Vaccination Due',
          subtitle: 'Flock A vaccination due in 3 days',
          time: 'Yesterday, 10:00 AM',
          color: Colors.blue,
          isUnread: false,
          priority: 'Normal',
        ),
      ],
    );
  }

  Widget _buildNotificationSection(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationStatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _NotificationStatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
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
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String time;
  final Color color;
  final bool isUnread;
  final String priority;

  const _NotificationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.color,
    required this.isUnread,
    required this.priority,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isUnread ? color.withOpacity(0.3) : Colors.grey.shade200,
          width: isUnread ? 2 : 1,
        ),
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
          // Unread indicator
          if (isUnread)
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
              ),
            )
          else
            const SizedBox(width: 8),
          const SizedBox(width: 8),

          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: isUnread ? color : Colors.grey.shade800,
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

          // Time and Priority
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
                  color: _getPriorityColor(priority).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _getPriorityColor(priority).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  priority,
                  style: TextStyle(
                    color: _getPriorityColor(priority),
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

  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'normal':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}