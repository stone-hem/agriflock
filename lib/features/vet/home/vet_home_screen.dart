import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/vet_unverified_banner.dart';
import 'package:agriflock360/features/vet/home/models/dashboard_stats_model.dart';
import 'package:agriflock360/features/vet/home/repo/dashboard_stats_repo.dart';
import 'package:agriflock360/features/vet/home/widgets/vet_dashboard_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/features/vet/schedules/repo/visit_repo.dart';

class VetHomeScreen extends StatefulWidget {
  const VetHomeScreen({super.key});

  @override
  State<VetHomeScreen> createState() => _VetHomeScreenState();
}

class _VetHomeScreenState extends State<VetHomeScreen> {
  final VetDashboardRepository _dashboardRepository = VetDashboardRepository();
  final VisitsRepository _visitsRepository = VisitsRepository();

  VetDashboardStats? _dashboardStats;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _errorMessage = '';
  String? _errorCond;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    if (!_isRefreshing) {
      setState(() {
        _isLoading = true;
      });
    }

    final result = await _dashboardRepository.getDashboardStats();

    if (result case Failure(:final cond, :final message)) {
      setState(() {
        _errorCond = cond;
        _errorMessage = message;
        _isLoading = false;
        _isRefreshing = false;
      });
      return;
    }

    result.when(
      success: (stats) {
        setState(() {
          _dashboardStats = stats;
          _isLoading = false;
          _isRefreshing = false;
          _errorMessage = '';
          _errorCond = null;
        });
      },
      failure: (_, __, ___) {},
    );
  }

  Future<void> _onRefresh() async {
    setState(() {
      _isRefreshing = true;
    });
    await _loadDashboardData();
  }

  void _handleAppointmentAction(VisitDashboard appointment, String action) async {
    Result? result;

    // Since VisitRepository uses Visit model, we need to convert VisitDashboard to Visit
    // or update the repository to handle both. For now, we'll use the visit ID directly.

    switch (action) {
      case 'accept':
        result = await _visitsRepository.acceptVisit(visitId: appointment.id);
        break;
      case 'reject':
        result = await _visitsRepository.rejectVisit(
          visitId: appointment.id,
          body: {'reason': 'Rejected from dashboard'},
        );
        break;
      case 'start':
        result = await _visitsRepository.startVisit(
          visitId: appointment.id,
          body: {},
        );
        break;
      case 'complete':
        result = await _visitsRepository.completeVisit(
          visitId: appointment.id,
          body: {},
        );
        break;
      case 'cancel':
        result = await _visitsRepository.cancelVisit(
          visitId: appointment.id,
          body: {'reason': 'Cancelled from dashboard'},
        );
        break;
    }

    if (result != null && mounted) {
      result.when(
        success: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Appointment ${action}ed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          // Refresh dashboard data
          _onRefresh();
        },
        failure: (message, response, statusCode) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to $action appointment: $message'),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    }
  }

  void _showAcceptDialog(VisitDashboard appointment) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Appointment'),
        content: Text('Accept appointment with ${appointment.farmerName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _handleAppointmentAction(appointment, 'accept');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(VisitDashboard appointment) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Appointment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Reject appointment with ${appointment.farmerName}?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (optional)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.isNotEmpty) {
                // You can pass the reason to the API if needed
              }
              Navigator.pop(context);
              _handleAppointmentAction(appointment, 'reject');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time24) {
    if (time24.isEmpty) return '';
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour12:${minute.padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && !_isRefreshing) {
      return const VetDashboardSkeleton();
    }

    if (_errorMessage.isNotEmpty && _dashboardStats == null) {
      return Scaffold(
        body: _errorCond == 'unverified_vet'
            ? VetUnverifiedBanner(onRefresh: _loadDashboardData)
            : Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        _errorMessage,
                        style: TextStyle(color: Colors.grey.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _loadDashboardData,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ),
      );
    }

    return Scaffold(
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
            const SizedBox(width: 8),
            const Text('Agriflock 360 - Vet'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
            onPressed: () => context.push('/vet/notifications'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              _buildWelcomeSection(context),
              const SizedBox(height: 32),

              // Stats Overview
              _buildStatsOverview(),
              const SizedBox(height: 32),

              // Today's Appointments
              _buildTodaysAppointments(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final totalAppointments = _dashboardStats?.activeAppointments.length ?? 0;
    final appointmentText = totalAppointments == 1
        ? 'You have 1 appointment today'
        : 'You have $totalAppointments appointments today';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.lightBlue.shade50],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good Morning, Dr. Smith',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            appointmentText,
            style: TextStyle(
              color: Colors.blue.shade600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${_dashboardStats?.todayVisits ?? 0}',
            label: 'Today\'s Visits',
            color: Colors.blue.shade100,
            textColor: Colors.blue.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '${_dashboardStats?.weekVisits ?? 0}',
            label: 'This Week',
            color: Colors.purple.shade100,
            textColor: Colors.purple.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '${_dashboardStats?.pendingReports ?? 0}',
            label: 'Pending Reports',
            color: Colors.orange.shade100,
            textColor: Colors.orange.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildTodaysAppointments(BuildContext context) {
    final appointments = _dashboardStats?.activeAppointments ?? [];

    if (appointments.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Today\'s Appointments',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 48,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 16),
                Text(
                  'No appointments for today',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Appointments',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),
        ...appointments.map((appointment) => _AppointmentItem(
          appointment: appointment,
          onAccept: () => _showAcceptDialog(appointment),
          onReject: () => _showRejectDialog(appointment),
          onStart: () => _handleAppointmentAction(appointment, 'start'),
          onComplete: () => _handleAppointmentAction(appointment, 'complete'),
          onCancel: () => _handleAppointmentAction(appointment, 'cancel'),
        )).toList(),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _StatCard({
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

class _AppointmentItem extends StatelessWidget {
  final VisitDashboard appointment;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final VoidCallback? onStart;
  final VoidCallback? onComplete;
  final VoidCallback? onCancel;

  const _AppointmentItem({
    required this.appointment,
    this.onAccept,
    this.onReject,
    this.onStart,
    this.onComplete,
    this.onCancel,
  });

  String _formatTime(String time24) {
    if (time24.isEmpty) return '';
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour12:${minute.padLeft(2, '0')} $period';
    } catch (e) {
      return time24;
    }
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String displayText;

    switch (status.toUpperCase()) {
      case 'PENDING':
        backgroundColor = Colors.orange.withOpacity(0.1);
        textColor = Colors.orange;
        displayText = 'Pending';
        break;
      case 'IN_PROGRESS':
        backgroundColor = Colors.blue.withOpacity(0.1);
        textColor = Colors.blue;
        displayText = 'In Progress';
        break;
      default:
        backgroundColor = Colors.grey.withOpacity(0.1);
        textColor = Colors.grey;
        displayText = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        displayText,
        style: TextStyle(
          color: textColor,
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    final status = appointment.status.toUpperCase();

    if (status == 'PENDING') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: onReject,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Decline'),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              onPressed: onAccept,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Accept'),
            ),
          ),
        ],
      );
    } else if (status == 'IN_PROGRESS') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.cancel_outlined, size: 18),
              label: const Text('Cancel'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onComplete,
              icon: const Icon(Icons.check_circle, size: 18),
              label: const Text('Complete'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      );
    } else {
      return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayTime = appointment.displayTime;
    final timeString = _formatTime(displayTime);

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
                  color: appointment.statusColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person, size: 18, color: appointment.statusColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      appointment.farmerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      appointment.farmName,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.pets, size: 12, color: Colors.grey.shade500),
                        const SizedBox(width: 4),
                        Text(
                          '${appointment.birdCount} birds',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(appointment.status),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Service: ${appointment.serviceType}',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          _buildActionButtons(),
        ],
      ),
    );
  }
}