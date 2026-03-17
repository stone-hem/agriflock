import 'package:agriflock/core/utils/date_util.dart';
import 'package:agriflock/features/vet/schedules/models/visit_model.dart';
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

  @override
  Widget build(BuildContext context) {
    final hasBatches = visit.batches.isNotEmpty;
    final hasBirdTypes = visit.birdTypes.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Bird Info Section ──
        if (hasBatches) ...[
          // Case 2: has batches — show each batch as a line
          _SectionRow(
            icon: Icons.egg_outlined,
            iconColor: accentColor,
            children: [
              for (final batch in visit.batches)
                Padding(
                  padding: const EdgeInsets.only(bottom: 2),
                  child: Text(
                    '${batch.birdTypeName} – ${batch.birdsCount} birds',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
            ],
          ),
        ] else if (hasBirdTypes || visit.birdsCount > 0) ...[
          // Case 1: no batches — show bird type chips + total count
          _SectionRow(
            icon: Icons.egg_outlined,
            iconColor: accentColor,
            children: [
              Text(
                '${visit.birdsCount} total birds',
                style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600),
              ),
              if (hasBirdTypes) ...[
                const SizedBox(height: 6),
                Wrap(
                  spacing: 4,
                  runSpacing: 6,
                  children: visit.birdTypes.map((bt) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accentColor.withOpacity(0.35)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.pets, size: 11, color: accentColor),
                      const SizedBox(width: 4),
                      ConstrainedBox(
                       constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width*0.65),
                        child: Text(bt.name,
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: accentColor)),
                      ),

                    ]),
                  )).toList(),
                ),
              ],
            ],
          ),
        ],
        const SizedBox(height: 10),

        // ── Mortality ──
        _SectionRow(
          icon: Icons.warning_amber_rounded,
          iconColor: (visit.mortality ?? 0) > 0 ? Colors.red.shade400 : accentColor,
          children: [
            Text(
              'Total Mortality: ${visit.mortality ?? 0} birds',
              style: TextStyle(
                color: (visit.mortality ?? 0) > 0
                    ? Colors.red.shade700
                    : Colors.grey.shade700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // ── Age ──
        _SectionRow(
          icon: Icons.calendar_month_outlined,
          iconColor: accentColor,
          children: [
            Text(
              visit.ageInDays != null
                  ? 'Age: ${visit.ageInDays} day${visit.ageInDays == 1 ? '' : 's'} old'
                  : hasBatches
                      ? 'Age: varies per batch'
                      : 'Age: not specified',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
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
                  DateUtil.toShortDateWithDay(
                    DateTime.parse(visit.preferredDate),
                  ),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Time: ${DateUtil.to12HourTime(DateTime.parse(visit.preferredDate))}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        // Requested Visit Date/Time
        _SectionRow(
          icon: Icons.event_outlined,
          iconColor: accentColor,
          children: [
            Text(
              'Date Visit Requested',
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
                  DateUtil.toShortDateWithDay(visit.submittedAt),
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  'Time: ${DateUtil.to12HourTime(visit.submittedAt)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 10,),

        // Requested Services with costs
        if (visit.serviceCosts.isNotEmpty) ...[
          _SectionRow(
            icon: Icons.medical_services_outlined,
            iconColor: accentColor,
            children: [
              Text(
                'Requested Services ',
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
        const SizedBox(height: 10),

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
                label: 'Payment Mode',
                value:
                    '${visit.paymentMode.isNotEmpty ? visit.paymentMode.replaceAll('_', ' ') : 'Not Provided'}',
              ),
              SizedBox(height: 10),
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
      ],
    );
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
                style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
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
