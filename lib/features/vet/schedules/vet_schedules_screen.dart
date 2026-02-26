import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/alert_button.dart';
import 'package:agriflock360/core/widgets/vet_unverified_banner.dart';
import 'package:agriflock360/features/vet/schedules/models/visit_stats.dart';
import 'package:agriflock360/features/vet/schedules/repo/visit_repo.dart';
import 'package:agriflock360/features/vet/schedules/widgets/status_chip.dart';
import 'package:agriflock360/features/vet/schedules/widgets/visits_list_view.dart';
import 'package:flutter/material.dart';
import 'package:agriflock360/features/vet/schedules/models/visit_model.dart';

class VetSchedulesScreen extends StatefulWidget {
  const VetSchedulesScreen({super.key});

  @override
  State<VetSchedulesScreen> createState() => _VetSchedulesScreenState();
}

class _VetSchedulesScreenState extends State<VetSchedulesScreen> {
  final VisitsRepository _repository = VisitsRepository();

  VisitStats? _visitStats;
  bool _isLoadingStats = false;
  String? _statsCond;
  String _selectedStatus = VisitStatus.pending.value;

  @override
  void initState() {
    super.initState();
    _loadVisitStats();
  }

  Future<void> _loadVisitStats() async {
    setState(() => _isLoadingStats = true);

    final result = await _repository.getVisitStats();

    if (!mounted) return;

    if (result case Failure(:final cond, :final message)) {
      setState(() {
        _statsCond = cond;
        _isLoadingStats = false;
      });
      if (cond != 'unverified_vet') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
      return;
    }

    result.when(
      success: (stats) {
        setState(() {
          _visitStats = stats;
          _statsCond = null;
          _isLoadingStats = false;
        });
      },
      failure: (_, _, _) {},
    );
  }

  void _onStatusChanged(String status) {
    setState(() {
      _selectedStatus = status;
    });
  }

  void _onVisitMovedToStatus(String targetStatus) {
    setState(() {
      _selectedStatus = targetStatus;
    });
    _loadVisitStats();
  }

  @override
  Widget build(BuildContext context) {
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
                  width: 40,
                  height: 40,
                  color: Colors.green,
                  child: const Icon(Icons.image, size: 24, color: Colors.white54),
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
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: AlertsButton(),
          ),
        ],
      ),
      body: _statsCond == 'unverified_vet'
          ? VetUnverifiedBanner(onRefresh: _loadVisitStats)
          : Column(
        children: [
          // Total visits counter
          if (_visitStats != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, size: 15, color: Colors.grey.shade600),
                  const SizedBox(width: 6),
                  Text(
                    'Total Visits: ${_visitStats!.total}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

          // Status chips section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: Colors.white,
            child: _isLoadingStats
                ? const Center(
              child: SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
                : SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  StatusChip(
                    label: 'Pending',
                    count: _visitStats?.pending ?? 0,
                    status: VisitStatus.pending.value,
                    color: Colors.orange,
                    isSelected: _selectedStatus == VisitStatus.pending.value,
                    onTap: _onStatusChanged,
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: 'Accepted',
                    count: _visitStats?.accepted ?? 0,
                    status: VisitStatus.accepted.value,
                    color: Colors.blue,
                    isSelected: _selectedStatus == VisitStatus.accepted.value,
                    onTap: _onStatusChanged,
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: 'In Progress',
                    count: _visitStats?.inProgress ?? 0,
                    status: VisitStatus.inProgress.value,
                    color: Colors.purple,
                    isSelected: _selectedStatus == VisitStatus.inProgress.value,
                    onTap: _onStatusChanged,
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: 'Pending Payments',
                    count: _visitStats?.pendingPayments ?? 0,
                    status: VisitStatus.pendingPayments.value,
                    color: Theme.of(context).primaryColor,
                    isSelected: _selectedStatus == VisitStatus.pendingPayments.value,
                    onTap: _onStatusChanged,
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: 'Completed',
                    count: _visitStats?.completed ?? 0,
                    status: VisitStatus.completed.value,
                    color: Colors.green,
                    isSelected: _selectedStatus == VisitStatus.completed.value,
                    onTap: _onStatusChanged,
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: 'Declined',
                    count: _visitStats?.declined ?? 0,
                    status: VisitStatus.declined.value,
                    color: Colors.red.shade400,
                    isSelected: _selectedStatus == VisitStatus.declined.value,
                    onTap: _onStatusChanged,
                  ),
                  const SizedBox(width: 8),
                  StatusChip(
                    label: 'Cancelled',
                    count: _visitStats?.cancelled ?? 0,
                    status: VisitStatus.cancelled.value,
                    color: Colors.grey,
                    isSelected: _selectedStatus == VisitStatus.cancelled.value,
                    onTap: _onStatusChanged,
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1),

          // Visits list based on selected status
          Expanded(
            child: VisitsListView(
              key: ValueKey(_selectedStatus),
              status: _selectedStatus,
              repository: _repository,
              onVisitUpdated: _loadVisitStats,
              onStatusChanged: _onVisitMovedToStatus,
            ),
          ),
        ],
      ),
    );
  }
}