import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/farmer/vet/models/vet_report_model.dart';
import 'package:agriflock/features/farmer/vet/repo/vet_report_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Reusable tab that lists vet reports fetched from /visit-reports/my.
/// Pass [batchId] to filter only reports associated with that batch.
class VetReportsTab extends StatefulWidget {
  /// If non-null, only reports whose batchId or order.batchDetails contain
  /// this batchId are shown.
  final String? batchId;

  const VetReportsTab({super.key, this.batchId});

  @override
  State<VetReportsTab> createState() => _VetReportsTabState();
}

class _VetReportsTabState extends State<VetReportsTab>
    with AutomaticKeepAliveClientMixin {
  final _repo = VetReportRepository();
  List<VetReport> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool refresh = false}) async {
    if (!refresh) setState(() { _isLoading = true; _error = null; });
    final result = await _repo.getMyVetReports();
    if (!mounted) return;
    result.when(
      success: (data) {
        final filtered = widget.batchId == null
            ? data
            : data.where((r) {
                if (r.batchId == widget.batchId) return true;
                return r.order?.batchDetails
                        .any((b) => b.batchId == widget.batchId) ??
                    false;
              }).toList();
        setState(() {
          _reports = filtered;
          _isLoading = false;
          _error = null;
        });
      },
      failure: (msg, _, __) =>
          setState(() { _error = msg; _isLoading = false; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(_error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _load,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_reports.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined,
                size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text(
              widget.batchId != null
                  ? 'No vet reports found for this batch'
                  : 'No vet reports yet',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _load(refresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _reports.length,
        itemBuilder: (_, i) => _VetReportListCard(report: _reports[i]),
      ),
    );
  }
}

class _VetReportListCard extends StatelessWidget {
  final VetReport report;

  const _VetReportListCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        report.visitNumber,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        report.officer.name,
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _StatusBadge(status: report.status),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 5),
                Text(
                  report.visitDateFormatted,
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
                const SizedBox(width: 12),
                Icon(Icons.local_hospital_outlined,
                    size: 13, color: Colors.grey.shade500),
                const SizedBox(width: 5),
                Text(
                  report.visitType,
                  style:
                      TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
            if (report.farmerComplaints.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Complaints: ${report.farmerComplaints.take(2).join(', ')}${report.farmerComplaints.length > 2 ? '…' : ''}',
                style: TextStyle(color: Colors.grey.shade700, fontSize: 12),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => context.push(
                  '/vet-report-view',
                  extra: {'orderId': report.orderId},
                ),
                icon: const Icon(Icons.visibility_outlined, size: 16),
                label: const Text('View Report'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade700,
                  side: BorderSide(color: Colors.green.shade300),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status.toUpperCase()) {
      case 'SUBMITTED':
        color = Colors.blue;
        break;
      case 'REVIEWED':
        color = Colors.green;
        break;
      default:
        color = Colors.orange;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }
}
