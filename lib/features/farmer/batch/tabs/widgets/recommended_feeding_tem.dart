import 'package:flutter/material.dart';

class RecommendedFeedingItem extends StatelessWidget {
  final String stage;
  final String feedType;
  final String amount;
  final String frequency;
  final String protein;
  final List<String> feedingTimes;
  final String? notes;
  final bool isCurrent;

  const RecommendedFeedingItem({super.key, required this.stage, required this.feedType, required this.amount, required this.frequency, required this.protein, required this.feedingTimes, this.notes, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrent ? Colors.green.shade300 : Colors.grey.shade200,
          width: isCurrent ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (isCurrent ? Colors.green : Colors.orange).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu,
                  size: 18,
                  color: isCurrent ? Colors.green : Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          stage,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (isCurrent) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'CURRENT',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      feedType,
                      style: TextStyle(
                        color: (isCurrent ? Colors.green : Colors.orange).shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Feeding times
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: feedingTimes
                .map((time) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.blue.shade800,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ))
                .toList(),
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                _FeedInfoRow(
                  icon: Icons.scale,
                  label: 'Amount',
                  value: amount,
                ),
                const SizedBox(height: 6),
                _FeedInfoRow(
                  icon: Icons.schedule,
                  label: 'Frequency',
                  value: frequency,
                ),
                const SizedBox(height: 6),
                _FeedInfoRow(
                  icon: Icons.health_and_safety_outlined,
                  label: 'Protein',
                  value: protein,
                ),
                if (notes != null) ...[
                  const SizedBox(height: 6),
                  _FeedInfoRow(
                    icon: Icons.note,
                    label: 'Notes',
                    value: notes!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FeedInfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _FeedInfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade600),
        const SizedBox(width: 6),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      ],
    );
  }
}
