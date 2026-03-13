import 'package:agriflock/features/vet/schedules/models/visit_model.dart';
import 'package:agriflock/features/vet/schedules/repo/visit_repo.dart';
import 'package:agriflock/features/vet/schedules/widgets/visit_details_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class InProgressVisitCard extends StatelessWidget {
  final Visit visit;
  final VisitsRepository repository;
  final VoidCallback onActionCompleted;
  final void Function(String targetStatus)? onStatusChanged;

  const InProgressVisitCard({
    super.key,
    required this.visit,
    required this.repository,
    required this.onActionCompleted,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
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
                        visit.farmerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        visit.farmerLocation.address,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 12, color: Colors.grey.shade600),
                          const SizedBox(width: 4),
                          Text(
                            visit.farmerPhone,
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
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'In Progress',
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
                VisitDetailsSection(
                  visit: visit,
                  accentColor: Colors.purple,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await context.push<bool>(
                        '/vet-visit-form',
                        extra: {
                          'orderId': visit.id,
                          'farmerId': visit.farmerId,
                          'autoComplete': true,
                        },
                      );
                      if (result == true) {
                        onActionCompleted();
                        onStatusChanged?.call(VisitStatus.paymentPending.value);
                      }
                    },
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: const Text(
                      'Complete Visit',
                      style: TextStyle(fontSize: 16),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
