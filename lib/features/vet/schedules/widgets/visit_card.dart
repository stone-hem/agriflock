import 'package:agriflock360/features/vet/schedules/models/visit_model.dart';
import 'package:agriflock360/features/vet/schedules/repo/visit_repo.dart';
import 'package:agriflock360/features/vet/schedules/widgets/cards/pending_payments_visit_card.dart';
import 'package:agriflock360/features/vet/schedules/widgets/cards/pending_visit_card.dart';
import 'package:agriflock360/features/vet/schedules/widgets/cards/scheduled_visit_card.dart';
import 'package:agriflock360/features/vet/schedules/widgets/cards/in_progress_visit_card.dart';
import 'package:agriflock360/features/vet/schedules/widgets/cards/completed_visit_card.dart';
import 'package:flutter/material.dart';

class VisitCard extends StatelessWidget {
  final Visit visit;
  final VisitsRepository repository;
  final VoidCallback onActionCompleted;
  final void Function(String targetStatus)? onStatusChanged;

  const VisitCard({
    super.key,
    required this.visit,
    required this.repository,
    required this.onActionCompleted,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Determine which card type to show based on visit status
    switch (visit.status.toLowerCase()) {
      case 'pending':
        return PendingVisitCard(
          visit: visit,
          repository: repository,
          onActionCompleted: onActionCompleted,
          onStatusChanged: onStatusChanged,
        );

      case 'scheduled':
      case 'accepted':
        return ScheduledVisitCard(
          visit: visit,
          repository: repository,
          onActionCompleted: onActionCompleted,
          onStatusChanged: onStatusChanged,
        );

      case 'in_progress':
        return InProgressVisitCard(
          visit: visit,
          repository: repository,
          onActionCompleted: onActionCompleted,
          onStatusChanged: onStatusChanged,
        );


      case 'payment_pending':
        return PendingPaymentsVisitCard(
          visit: visit,
          repository: repository,
          onActionCompleted: onActionCompleted,
          onStatusChanged: onStatusChanged,
        );

      case 'completed':
      case 'declined':
      case 'cancelled':
        return CompletedVisitCard(visit: visit);

      default:
        return PendingVisitCard(
          visit: visit,
          repository: repository,
          onActionCompleted: onActionCompleted,
          onStatusChanged: onStatusChanged,
        );
    }
  }
}