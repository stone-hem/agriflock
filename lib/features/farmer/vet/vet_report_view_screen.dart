import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/features/farmer/vet/models/vet_report_model.dart';
import 'package:agriflock/features/farmer/vet/repo/vet_report_repository.dart';
import 'package:flutter/material.dart';

class VetReportViewScreen extends StatefulWidget {
  final String orderId;

  const VetReportViewScreen({super.key, required this.orderId});

  @override
  State<VetReportViewScreen> createState() => _VetReportViewScreenState();
}

class _VetReportViewScreenState extends State<VetReportViewScreen> {
  final _repo = VetReportRepository();
  List<VetReport> _reports = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _isLoading = true; _error = null; });
    final result = await _repo.getVetReportsByOrderId(widget.orderId);
    if (!mounted) return;
    result.when(
      success: (data) => setState(() { _reports = data; _isLoading = false; }),
      failure: (msg, _, __) => setState(() { _error = msg; _isLoading = false; }),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vet Report'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _reports.isEmpty
                  ? _buildEmpty()
                  : RefreshIndicator(
                      onRefresh: _load,
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _reports.length,
                        itemBuilder: (_, i) => _VetReportCard(report: _reports[i]),
                      ),
                    ),
    );
  }

  Widget _buildError() => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 56, color: Colors.red.shade300),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center,
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

  Widget _buildEmpty() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 56, color: Colors.grey.shade300),
            const SizedBox(height: 12),
            Text('No vet report found for this order',
                style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
}

class _VetReportCard extends StatelessWidget {
  final VetReport report;

  const _VetReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(report.visitNumber,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Text(report.visitDateFormatted,
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                    ],
                  ),
                ),
                _StatusBadge(status: report.status),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Vet info ──
                _InfoRow(
                  icon: Icons.medical_services_outlined,
                  label: 'Vet',
                  value:
                      '${report.officer.name}${report.officer.educationLevel.isNotEmpty ? ' (${report.officer.educationLevel})' : ''}',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.work_outline,
                  label: 'Experience',
                  value: '${report.officer.yearsOfExperience} years',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  icon: Icons.local_hospital_outlined,
                  label: 'Visit Type',
                  value: report.visitType,
                ),
                const Divider(height: 24),

                // ── Farmer Complaints ──
                if (report.farmerComplaints.isNotEmpty) ...[
                  _SectionTitle('Farmer Complaints'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: report.farmerComplaints
                        .map((c) => _Chip(label: c, color: Colors.orange))
                        .toList(),
                  ),
                  const Divider(height: 24),
                ],

                // ── Observations ──
                if (report.observations.isNotEmpty) ...[
                  _SectionTitle('Observations'),
                  const SizedBox(height: 8),
                  ...report.observations.entries.map((e) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(e.key,
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontSize: 13)),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: e.value == 'Abnormal'
                                    ? Colors.red.shade50
                                    : Colors.green.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: e.value == 'Abnormal'
                                      ? Colors.red.shade200
                                      : Colors.green.shade200,
                                ),
                              ),
                              child: Text(
                                e.value,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: e.value == 'Abnormal'
                                      ? Colors.red.shade700
                                      : Colors.green.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )),
                  if (report.abnormalFindingsNotes != null &&
                      report.abnormalFindingsNotes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text('Notes: ${report.abnormalFindingsNotes}',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                            fontStyle: FontStyle.italic)),
                  ],
                  const Divider(height: 24),
                ],

                // ── Suspected Issues ──
                if (report.suspectedIssues.isNotEmpty) ...[
                  _SectionTitle('Suspected Issues'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: report.suspectedIssues
                        .map((s) => _Chip(label: s, color: Colors.red))
                        .toList(),
                  ),
                  const Divider(height: 24),
                ],

                // ── Actions Taken ──
                if (report.actionsTaken.isNotEmpty) ...[
                  _SectionTitle('Actions Taken'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: report.actionsTaken
                        .map((a) => _Chip(label: a, color: Colors.blue))
                        .toList(),
                  ),
                  const Divider(height: 24),
                ],

                // ── Recommendations ──
                if ((report.recommendation1 != null &&
                        report.recommendation1!.isNotEmpty) ||
                    (report.recommendation2 != null &&
                        report.recommendation2!.isNotEmpty)) ...[
                  _SectionTitle('Recommendations'),
                  const SizedBox(height: 8),
                  if (report.recommendation1 != null &&
                      report.recommendation1!.isNotEmpty)
                    _BulletText(report.recommendation1!),
                  if (report.recommendation2 != null &&
                      report.recommendation2!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _BulletText(report.recommendation2!),
                  ],
                  const Divider(height: 24),
                ],

                // ── Follow-up ──
                if (report.followUpDate != null ||
                    (report.followUpNotes != null &&
                        report.followUpNotes!.isNotEmpty)) ...[
                  _SectionTitle('Follow-up'),
                  const SizedBox(height: 8),
                  if (report.followUpDate != null)
                    _InfoRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Date',
                      value: report.followUpDate!,
                    ),
                  if (report.followUpNotes != null &&
                      report.followUpNotes!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _InfoRow(
                      icon: Icons.notes_outlined,
                      label: 'Notes',
                      value: report.followUpNotes!,
                    ),
                  ],
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(title,
      style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: Colors.grey.shade800,
          letterSpacing: 0.3));
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 15, color: Colors.grey.shade500),
          const SizedBox(width: 8),
          Text('$label: ',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600)),
          Expanded(
            child: Text(value,
                style:
                    TextStyle(fontSize: 13, color: Colors.grey.shade800)),
          ),
        ],
      );
}

class _Chip extends StatelessWidget {
  final String label;
  final Color color;
  const _Chip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500)),
      );
}

class _BulletText extends StatelessWidget {
  final String text;
  const _BulletText(this.text);

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ', style: TextStyle(color: Colors.green.shade700)),
          Expanded(
            child: Text(text,
                style: TextStyle(
                    fontSize: 13, color: Colors.grey.shade700)),
          ),
        ],
      );
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status,
        style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: color),
      ),
    );
  }
}
