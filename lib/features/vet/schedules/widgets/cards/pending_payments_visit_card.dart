import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/features/vet/schedules/models/visit_model.dart';
import 'package:agriflock360/features/vet/schedules/repo/visit_repo.dart';
import 'package:agriflock360/features/vet/schedules/widgets/visit_details_section.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PendingPaymentsVisitCard extends StatelessWidget {
  final Visit visit;
  final VisitsRepository repository;
  final VoidCallback onActionCompleted;
  final void Function(String targetStatus)? onStatusChanged;

  const PendingPaymentsVisitCard({
    super.key,
    required this.visit,
    required this.repository,
    required this.onActionCompleted,
    this.onStatusChanged,
  });

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

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
          // Header with pending payments styling
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
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
                        visit.farmerLocation,
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
                    color: primaryColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.payment,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pending Payments',
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
                // Comprehensive visit details
                VisitDetailsSection(
                  visit: visit,
                  accentColor: primaryColor,
                ),

                const SizedBox(height: 16),

                // Payment Summary Section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.receipt_long, size: 16, color: primaryColor),
                          const SizedBox(width: 8),
                          Text(
                            'Payment Summary',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Service Fee
                      _buildPaymentRow(
                        'Service Fee',
                        visit.serviceFee,
                        primaryColor,
                      ),
                      const SizedBox(height: 8),

                      // Mileage Fee
                      _buildPaymentRow(
                        'Mileage Fee (${visit.distanceKm.toStringAsFixed(1)} km)',
                        visit.mileageFee,
                        primaryColor,
                      ),
                      const SizedBox(height: 8),

                      // Priority Surcharge (if applicable)
                      if (visit.prioritySurcharge > 0) ...[
                        _buildPaymentRow(
                          'Priority Surcharge',
                          visit.prioritySurcharge,
                          primaryColor,
                        ),
                        const SizedBox(height: 8),
                      ],

                      const Divider(height: 16),

                      // Total
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          Text(
                            'KES ${visit.totalEstimatedCost.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Action Buttons
                Row(
                  children: [

                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Process payment
                          _processPayment(context);
                        },
                        icon: const Icon(Icons.payment),
                        label: const Text('Process Payment'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Schedule info
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      'Scheduled for ${visit.preferredDate} at ${_formatTime(visit.preferredTime)}',
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

  Widget _buildPaymentRow(String label, double amount, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade700,
          ),
        ),
        Text(
          'KES ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade900,
          ),
        ),
      ],
    );
  }

  Future<void> _processPayment(BuildContext context) async {
    // Show payment processing dialog or navigate to payment screen
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: const Text('This will open payment processing.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Handle payment processing
              // After successful payment, update status to completed
              // and call onActionCompleted()
            },
            child: const Text('Process'),
          ),
        ],
      ),
    );
  }
}