import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetSchedulesScreen extends StatefulWidget {
  const VetSchedulesScreen({super.key});

  @override
  State<VetSchedulesScreen> createState() => _VetSchedulesScreenState();
}

class _VetSchedulesScreenState extends State<VetSchedulesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

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
            const SizedBox(width: 8),
            const Text('Visit Requests'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(Icons.filter_list, color: Colors.grey.shade700),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.blue.shade700,
          unselectedLabelColor: Colors.grey.shade600,
          indicatorColor: Colors.blue.shade700,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'In Progress'),
            Tab(text: 'Completed'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildPendingRequests(),
          _buildInProgressRequests(),
          _buildCompletedRequests(),
        ],
      ),
    );
  }

  Widget _buildPendingRequests() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRequestStats(pending: 5, inProgress: 3, completed: 12),
        const SizedBox(height: 20),
        _PendingRequestCard(
          farmerName: 'John Peterson',
          farmName: 'Green Valley Farm',
          requestDate: 'Dec 21, 2023',
          requestTime: '2 hours ago',
          visitType: 'Regular Checkup',
          birdsCount: '1,240',
          urgency: 'Normal',
          description: 'Routine health checkup for the flock. Some birds showing mild respiratory symptoms.',
          onAccept: () => _showAcceptDialog(context, 'John Peterson', 'Green Valley Farm'),
          onReject: () => _showRejectDialog(context, 'John Peterson'),
        ),
        _PendingRequestCard(
          farmerName: 'Maria Rodriguez',
          farmName: 'Sunrise Poultry',
          requestDate: 'Dec 21, 2023',
          requestTime: '5 hours ago',
          visitType: 'Vaccination',
          birdsCount: '890',
          urgency: 'Normal',
          description: 'Need vaccination for new batch of chicks.',
          onAccept: () => _showAcceptDialog(context, 'Maria Rodriguez', 'Sunrise Poultry'),
          onReject: () => _showRejectDialog(context, 'Maria Rodriguez'),
        ),
        _PendingRequestCard(
          farmerName: 'Robert Chen',
          farmName: 'Happy Hens Farm',
          requestDate: 'Dec 20, 2023',
          requestTime: '1 day ago',
          visitType: 'Emergency Visit',
          birdsCount: '2,150',
          urgency: 'High',
          description: 'Sudden increase in mortality rate. Multiple birds showing severe symptoms. Need immediate attention.',
          onAccept: () => _showAcceptDialog(context, 'Robert Chen', 'Happy Hens Farm'),
          onReject: () => _showRejectDialog(context, 'Robert Chen'),
        ),
      ],
    );
  }

  Widget _buildInProgressRequests() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRequestStats(pending: 5, inProgress: 3, completed: 12),
        const SizedBox(height: 20),
        _InProgressRequestCard(
          farmerName: 'David Wilson',
          farmName: 'Wilson Farms',
          visitType: 'Health Inspection',
          birdsCount: '1,500',
          acceptedDate: 'Dec 20, 2023',
          scheduledDate: 'Dec 22, 2023',
          scheduledTime: '10:00 AM',
          onComplete: () => context.push('/vet/payment/service'),
          onCancel: () => _showCancelDialog(context, 'David Wilson'),
        ),
        _InProgressRequestCard(
          farmerName: 'Sarah Miller',
          farmName: 'Miller Poultry',
          visitType: 'Follow-up Visit',
          birdsCount: '750',
          acceptedDate: 'Dec 19, 2023',
          scheduledDate: 'Dec 23, 2023',
          scheduledTime: '2:30 PM',
          onComplete: () => context.push('/vet/payment/service'),
          onCancel: () => _showCancelDialog(context, 'Sarah Miller'),
        ),
        _InProgressRequestCard(
          farmerName: 'James Brown',
          farmName: 'Brown\'s Farm',
          visitType: 'New Farm Setup',
          birdsCount: '3,200',
          acceptedDate: 'Dec 18, 2023',
          scheduledDate: 'Dec 24, 2023',
          scheduledTime: '11:00 AM',
          onComplete: () => context.push('/vet/payment/service'),
          onCancel: () => _showCancelDialog(context, 'James Brown'),
        ),
      ],
    );
  }

  Widget _buildCompletedRequests() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildRequestStats(pending: 5, inProgress: 3, completed: 12),
        const SizedBox(height: 20),
        _CompletedRequestCard(
          farmerName: 'Michael Anderson',
          farmName: 'Anderson Poultry',
          visitType: 'Vaccination',
          birdsCount: '1,100',
          completedDate: 'Dec 19, 2023',
          status: 'Completed',
          notes: 'Successfully vaccinated all birds. Follow-up scheduled for next month.',
        ),
        _CompletedRequestCard(
          farmerName: 'Emily Davis',
          farmName: 'Sunrise Farm',
          visitType: 'Emergency Treatment',
          birdsCount: '2,000',
          completedDate: 'Dec 18, 2023',
          status: 'Completed',
          notes: 'Treated respiratory infection. Prescribed medication for 7 days.',
        ),
        _CompletedRequestCard(
          farmerName: 'Thomas White',
          farmName: 'White Ranch',
          visitType: 'Regular Checkup',
          birdsCount: '850',
          completedDate: 'Dec 15, 2023',
          status: 'Cancelled',
          notes: 'Cancelled by vet - Farmer rescheduled to next week.',
        ),
      ],
    );
  }

  Widget _buildRequestStats({required int pending, required int inProgress, required int completed}) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: pending.toString(),
            label: 'Pending',
            color: Colors.orange.shade100,
            textColor: Colors.orange.shade800,
            icon: Icons.pending_actions,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: inProgress.toString(),
            label: 'In Progress',
            color: Colors.blue.shade100,
            textColor: Colors.blue.shade800,
            icon: Icons.work_outline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: completed.toString(),
            label: 'Completed',
            color: Colors.green.shade100,
            textColor: Colors.green.shade800,
            icon: Icons.check_circle_outline,
          ),
        ),
      ],
    );
  }

  void _showAcceptDialog(BuildContext context, String farmerName, String farmName) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Accept Visit Request'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Farmer: $farmerName',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                'Farm: $farmName',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (Optional)',
                  hintText: 'Add any additional notes',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // Handle accept logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request accepted successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Accept'),
          ),
        ],
      ),
    );
  }

  void _showRejectDialog(BuildContext context, String farmerName) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Visit Request'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to reject the request from $farmerName?',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for rejection',
                hintText: 'Please provide a reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
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
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              // Handle reject logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Request rejected')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }


  void _showCancelDialog(BuildContext context, String farmerName) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Visit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Cancel scheduled visit for $farmerName?',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason for cancellation',
                hintText: 'Please provide a reason',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Back'),
          ),
          ElevatedButton(
            onPressed: () {
              if (reasonController.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please provide a reason')),
                );
                return;
              }
              // Handle cancel logic here
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Visit cancelled')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Cancel Visit'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
    required this.icon,
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
        children: [
          Icon(icon, color: textColor, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  final String farmerName;
  final String farmName;
  final String requestDate;
  final String requestTime;
  final String visitType;
  final String birdsCount;
  final String urgency;
  final String description;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _PendingRequestCard({
    required this.farmerName,
    required this.farmName,
    required this.requestDate,
    required this.requestTime,
    required this.visitType,
    required this.birdsCount,
    required this.urgency,
    required this.description,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final isHighUrgency = urgency == 'High';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isHighUrgency ? Colors.red.shade300 : Colors.grey.shade200,
          width: isHighUrgency ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isHighUrgency ? Colors.red.shade50 : Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        farmName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isHighUrgency ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    urgency,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      visitType,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Icon(Icons.pets, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '$birdsCount birds',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Requested $requestTime',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onReject,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onAccept,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Accept'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InProgressRequestCard extends StatelessWidget {
  final String farmerName;
  final String farmName;
  final String visitType;
  final String birdsCount;
  final String acceptedDate;
  final String scheduledDate;
  final String scheduledTime;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const _InProgressRequestCard({
    required this.farmerName,
    required this.farmName,
    required this.visitType,
    required this.birdsCount,
    required this.acceptedDate,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        farmName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Scheduled',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      visitType,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Icon(Icons.pets, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '$birdsCount birds',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, size: 18, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Scheduled Visit',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '$scheduledDate at $scheduledTime',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Accepted on $acceptedDate',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onCancel,
                        icon: const Icon(Icons.cancel_outlined, size: 18),
                        label: const Text('Cancel'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onComplete,
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Complete'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
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
    );
  }
}

class _CompletedRequestCard extends StatelessWidget {
  final String farmerName;
  final String farmName;
  final String visitType;
  final String birdsCount;
  final String completedDate;
  final String status;
  final String notes;

  const _CompletedRequestCard({
    required this.farmerName,
    required this.farmName,
    required this.visitType,
    required this.birdsCount,
    required this.completedDate,
    required this.status,
    required this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = status == 'Completed';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.shade50 : Colors.red.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        farmerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        farmName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isCompleted ? Icons.check_circle : Icons.cancel,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.medical_services, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      visitType,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Icon(Icons.pets, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '$birdsCount birds',
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes:',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notes,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      isCompleted ? Icons.check_circle_outline : Icons.cancel_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${isCompleted ? 'Completed' : 'Cancelled'} on $completedDate',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}