import 'package:agriflock360/features/vet/schedules/models/visit_model.dart';
import 'package:flutter/material.dart';

/// A shared widget that displays comprehensive visit details
/// used across all vet schedule cards (pending, scheduled, in-progress, completed).
class VisitDetailsSection extends StatelessWidget {
  final Visit visit;
  final Color accentColor;

  const VisitDetailsSection({
    super.key,
    required this.visit,
    this.accentColor = Colors.green,
  });

  static const _dayNames = [
    'Monday', 'Tuesday', 'Wednesday', 'Thursday',
    'Friday', 'Saturday', 'Sunday',
  ];

  static const _monthNames = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

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

  String _getDayOfWeek(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return _dayNames[date.weekday - 1];
    } catch (_) {
      return '';
    }
  }

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${_monthNames[date.month - 1]} ${date.day}, ${date.year}';
    } catch (_) {
      return dateStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Collect bird type info from batches
    final birdSummary = _buildBirdSummary();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bird Info Section
        if (birdSummary.isNotEmpty) ...[
          _SectionRow(
            icon: Icons.egg_outlined,
            iconColor: accentColor,
            children: [
              for (final info in birdSummary)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    info,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // Requested Services with costs
        if (visit.serviceCosts.isNotEmpty) ...[
          _SectionRow(
            icon: Icons.medical_services_outlined,
            iconColor: accentColor,
            children: [
              Text(
                'Requested Services',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 4),
              for (final service in visit.serviceCosts)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          service.serviceName,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        'KES ${service.cost.toStringAsFixed(0)}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
        ],

        // Cost Breakdown
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            children: [
              _CostRow(
                label: 'Service Cost',
                value: 'KES ${visit.serviceFee.toStringAsFixed(2)}',
              ),
              const SizedBox(height: 6),
              _CostRow(
                label: 'Transport Estimate',
                value: 'KES ${visit.mileageFee.toStringAsFixed(2)}',
                subtitle: '${visit.distanceKm.toStringAsFixed(1)} km',
              ),
              if (visit.prioritySurcharge > 0) ...[
                const SizedBox(height: 6),
                _CostRow(
                  label: 'Priority Surcharge',
                  value: 'KES ${visit.prioritySurcharge.toStringAsFixed(2)}',
                ),
              ],
              Divider(height: 16, color: Colors.grey.shade300),
              _CostRow(
                label: 'Total Estimated',
                value: 'KES ${visit.totalEstimatedCost.toStringAsFixed(2)}',
                isBold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),

        // Expected Visit Date/Time
        _SectionRow(
          icon: Icons.event_outlined,
          iconColor: accentColor,
          children: [
            Text(
              'Expected Visit',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  _getDayOfWeek(visit.preferredDate),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (_getDayOfWeek(visit.preferredDate).isNotEmpty)
                  Text(
                    '  ·  ',
                    style: TextStyle(color: Colors.grey.shade400),
                  ),
                Text(
                  _formatDate(visit.preferredDate),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'Time: ${_formatTime(visit.preferredTime)}',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build a summary of bird info from batches.
  List<String> _buildBirdSummary() {
    final lines = <String>[];

    if (visit.batches.isNotEmpty) {
      for (final batch in visit.batches) {
        lines.add('${batch.birdTypeName} – ${batch.birdsCount} birds');
      }
    } else if (visit.birdsCount > 0) {
      lines.add('${visit.birdsCount} birds');
    }

    return lines;
  }
}

/// A row with a leading icon and content children.
class _SectionRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final List<Widget> children;

  const _SectionRow({
    required this.icon,
    required this.iconColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          ),
        ),
      ],
    );
  }
}

/// A labeled cost row for the cost breakdown.
class _CostRow extends StatelessWidget {
  final String label;
  final String value;
  final String? subtitle;
  final bool isBold;

  const _CostRow({
    required this.label,
    required this.value,
    this.subtitle,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
                fontWeight: isBold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(width: 4),
              Text(
                '($subtitle)',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 11,
                ),
              ),
            ],
          ],
        ),
        Text(
          value,
          style: TextStyle(
            color: isBold ? Colors.green.shade700 : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
