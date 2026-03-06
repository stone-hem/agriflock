import 'package:agriflock/core/utils/date_util.dart';
import 'package:agriflock/features/vet/schedules/models/visit_model.dart';
import 'package:agriflock/features/vet/schedules/repo/visit_repo.dart';
import 'package:agriflock/features/vet/schedules/widgets/visit_details_section.dart';
import 'package:flutter/material.dart';

class ScheduledVisitCard extends StatefulWidget {
  final Visit visit;
  final VisitsRepository repository;
  final VoidCallback onActionCompleted;
  final void Function(String targetStatus)? onStatusChanged;

  const ScheduledVisitCard({
    super.key,
    required this.visit,
    required this.repository,
    required this.onActionCompleted,
    this.onStatusChanged,
  });

  @override
  State<ScheduledVisitCard> createState() => _ScheduledVisitCardState();
}

class _ScheduledVisitCardState extends State<ScheduledVisitCard> {
  bool _isProcessing = false;

  String _formatTime(String time24) {
    try {
      final parts = time24.split(':');
      final hour = int.parse(parts[0]);
      final minute = parts[1];
      final period = hour >= 12 ? 'PM' : 'AM';
      final hour12 = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      return '$hour12:$minute $period';
    } catch (e) {
      return time24;
    }
  }

  Future<void> _startVisit() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final result = await widget.repository.startVisit(
      visitId: widget.visit.id,
      body: {
        'notes': 'Visit started',
      },
    );

    if (mounted) {
      result.when(
        success: (data) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visit started successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onActionCompleted();
          widget.onStatusChanged?.call(VisitStatus.inProgress.value);
          setState(() => _isProcessing = false);
        },
        failure: (message, _, __) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
          setState(() => _isProcessing = false);
        },
      );
    }
  }

  void _showStartVisitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Start Visit'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you ready to start the visit for ${widget.visit.farmerName}?',
                style: TextStyle(color: Colors.grey.shade700),
              ),
              const SizedBox(height: 12),
              Text(
                'Scheduled for:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '${widget.visit.preferredDate} at ${_formatTime(widget.visit.preferredTime)}',
                style: TextStyle(color: Colors.blue.shade700),
              ),
              const SizedBox(height: 12),
              Text(
                'Location: ${widget.visit.farmerLocation}',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Not Yet'),
          ),
          ElevatedButton(
            onPressed: _isProcessing ? null : () {
              Navigator.pop(context);
              _startVisit();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: _isProcessing
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
                : const Text('Start Visit'),
          ),
        ],
      ),
    );
  }

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
                        widget.visit.farmerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.visit.farmerLocation.address,
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
                // Comprehensive visit details
                VisitDetailsSection(
                  visit: widget.visit,
                  accentColor: Colors.blue,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green.shade700),
                    const SizedBox(width: 4),
                    Text(
                      'Earnings: KES ${widget.visit.officerEarnings.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                if (widget.visit.scheduledAt != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        'Accepted on ${DateUtil.toFullDateTime(widget.visit.scheduledAt!)}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 16),
                Builder(
                  builder: (context) {
                    final scheduledDate = DateTime.tryParse(widget.visit.preferredDate);
                    final isToday = scheduledDate != null && DateUtil.isToday(scheduledDate);
                    return Tooltip(
                      message: isToday
                          ? ''
                          : 'You can only start the visit on the scheduled day (${widget.visit.preferredDate})',
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: (_isProcessing || !isToday) ? null : _showStartVisitDialog,
                          icon: const Icon(Icons.play_arrow, size: 18),
                          label: _isProcessing
                              ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                              : Text(isToday ? 'Start Visit' : 'Visit on ${widget.visit.preferredDate}'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey.shade300,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}