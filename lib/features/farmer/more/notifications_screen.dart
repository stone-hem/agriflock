import 'package:agriflock360/core/notifications/notification_model.dart';
import 'package:agriflock360/core/notifications/notification_repository.dart';
import 'package:agriflock360/core/notifications/notification_service.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Shared notifications screen for both farmer and vet users.
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repo = NotificationRepository();
  final _service = NotificationService.instance;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAndSeed();
  }

  Future<void> _fetchAndSeed() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final result = await _repo.fetchNotifications();
    if (!mounted) return;

    switch (result) {
      case Success<List<AppNotification>>(data: final list):
        _service.seedNotifications(list);
      case Failure(message: final msg):
        setState(() => _errorMessage = msg);
    }

    setState(() => _isLoading = false);
  }

  Future<void> _markAllAsRead() async {
    await _service.markAllAsRead();
  }

  Future<void> _markAsRead(String id) async {
    await _service.markAsRead(id);
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  Color _typeColor(String type) {
    switch (type.toLowerCase()) {
      case 'error':
      case 'critical':
        return Colors.red.shade600;
      case 'warning':
        return Colors.orange.shade600;
      case 'success':
        return Colors.green.shade600;
      default:
        return Colors.blue.shade600;
    }
  }

  IconData _typeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'error':
      case 'critical':
        return Icons.error_outline;
      case 'warning':
        return Icons.warning_amber_outlined;
      case 'success':
        return Icons.check_circle_outline;
      default:
        return Icons.notifications_outlined;
    }
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays == 1) return 'Yesterday';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]}';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              width: 30,
              height: 30,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.green,
                child:
                    const Icon(Icons.image, size: 30, color: Colors.white54),
              ),
            ),
            const SizedBox(width: 8),
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
            onPressed: _markAllAsRead,
            child: Text(
              'Mark all read',
              style: TextStyle(color: Colors.green.shade700, fontSize: 13),
            ),
          ),
        ],
      ),
      body: StreamBuilder<List<AppNotification>>(
        stream: _service.notificationsStream,
        initialData: _service.notifications,
        builder: (context, snapshot) {
          final notifications = snapshot.data ?? _service.notifications;
          return RefreshIndicator(
            onRefresh: _fetchAndSeed,
            color: Colors.green,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 16),
                        _buildStats(notifications),
                        const SizedBox(height: 8),
                        if (_errorMessage != null)
                          _buildError(),
                        if (_isLoading && notifications.isEmpty)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Colors.green),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                if (!_isLoading || notifications.isNotEmpty)
                  notifications.isEmpty
                      ? SliverFillRemaining(
                          child: _buildEmpty(),
                        )
                      : SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (ctx, i) => _NotificationTile(
                                notification: notifications[i],
                                typeColor: _typeColor(notifications[i].type),
                                typeIcon: _typeIcon(notifications[i].type),
                                timeLabel: _formatTime(
                                    notifications[i].createdAt),
                                onTap: () =>
                                    _markAsRead(notifications[i].id),
                              ),
                              childCount: notifications.length,
                            ),
                          ),
                        ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.lightGreen.shade50],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alerts & Updates',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w400,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            'Stay updated in real-time',
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.green.shade800,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats(List<AppNotification> notifications) {
    final total = notifications.length;
    final unread = notifications.where((n) => !n.isRead).length;
    final critical = notifications
        .where((n) =>
            n.type.toLowerCase() == 'error' ||
            n.type.toLowerCase() == 'critical')
        .length;

    return Row(
      children: [
        Expanded(
          child: _StatCard(
              value: '$total',
              label: 'Total',
              bg: Colors.blue.shade100,
              fg: Colors.blue.shade800),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
              value: '$unread',
              label: 'Unread',
              bg: Colors.orange.shade100,
              fg: Colors.orange.shade800),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _StatCard(
              value: '$critical',
              label: 'Critical',
              bg: Colors.red.shade100,
              fg: Colors.red.shade800),
        ),
      ],
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade600),
            const SizedBox(width: 8),
            Expanded(
              child: Text(_errorMessage!,
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13)),
            ),
            TextButton(
              onPressed: _fetchAndSeed,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.notifications_none,
              size: 72, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text('No notifications yet',
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600)),
          const SizedBox(height: 8),
          Text("You're all caught up!",
              style:
                  TextStyle(fontSize: 13, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

// ── Notification tile ─────────────────────────────────────────────────────────

class _NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final Color typeColor;
  final IconData typeIcon;
  final String timeLabel;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.typeColor,
    required this.typeIcon,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;

    return GestureDetector(
      onTap: isUnread ? onTap : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? typeColor.withOpacity(0.04) : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isUnread
                ? typeColor.withOpacity(0.35)
                : Colors.grey.shade200,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Unread dot
            Padding(
              padding: const EdgeInsets.only(top: 6, right: 8),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isUnread ? typeColor : Colors.transparent,
                  shape: BoxShape.circle,
                ),
              ),
            ),

            // Icon
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: typeColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(typeIcon, size: 20, color: typeColor),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color:
                          isUnread ? typeColor : Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.body,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 11, color: Colors.grey.shade400),
                      const SizedBox(width: 3),
                      Text(timeLabel,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey.shade400)),
                      const Spacer(),
                      _TypeBadge(type: notification.type, color: typeColor),
                      if (isUnread) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: onTap,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: typeColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: typeColor.withOpacity(0.3)),
                            ),
                            child: Text('Mark read',
                                style: TextStyle(
                                    fontSize: 10,
                                    color: typeColor,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  final String type;
  final Color color;
  const _TypeBadge({required this.type, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        type[0].toUpperCase() + type.substring(1),
        style:
            TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color bg;
  final Color fg;
  const _StatCard(
      {required this.value,
      required this.label,
      required this.bg,
      required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall!
                  .copyWith(fontWeight: FontWeight.bold, color: fg)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: fg.withOpacity(0.8),
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
