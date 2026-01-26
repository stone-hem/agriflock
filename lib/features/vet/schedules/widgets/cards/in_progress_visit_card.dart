import 'package:agriflock360/features/vet/schedules/models/visit_model.dart';
import 'package:agriflock360/features/vet/schedules/repo/visit_repo.dart';
import 'package:flutter/material.dart';

class InProgressVisitCard extends StatefulWidget {
  final Visit visit;
  final VisitsRepository repository;
  final VoidCallback onActionCompleted;

  const InProgressVisitCard({
    super.key,
    required this.visit,
    required this.repository,
    required this.onActionCompleted,
  });

  @override
  State<InProgressVisitCard> createState() => _InProgressVisitCardState();
}

class _InProgressVisitCardState extends State<InProgressVisitCard> {
  bool _isProcessing = false;

  Future<void> _completeVisit(Map<String, dynamic> data) async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);

    final result = await widget.repository.completeVisit(
      visitId: widget.visit.id,
      body: data,
    );

    if (mounted) {
      result.when(
        success: (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Visit completed successfully'),
              backgroundColor: Colors.green,
            ),
          );
          widget.onActionCompleted();
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

  void _showCompleteDialog() {
    final diagnosisController = TextEditingController();
    final treatmentController = TextEditingController();
    final recommendationsController = TextEditingController();
    final medicationController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Complete Visit'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Complete visit for ${widget.visit.farmerName}',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: diagnosisController,
                    decoration: const InputDecoration(
                      labelText: 'Diagnosis',
                      hintText: 'Enter diagnosis',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !_isProcessing,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: treatmentController,
                    decoration: const InputDecoration(
                      labelText: 'Treatment Provided',
                      hintText: 'Enter treatment details',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !_isProcessing,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: medicationController,
                    decoration: const InputDecoration(
                      labelText: 'Medication Prescribed',
                      hintText: 'Enter medication details',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 2,
                    enabled: !_isProcessing,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: recommendationsController,
                    decoration: const InputDecoration(
                      labelText: 'Recommendations',
                      hintText: 'Enter follow-up recommendations',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    enabled: !_isProcessing,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: _isProcessing ? null : () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: _isProcessing ? null : () async {
                  if (diagnosisController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter diagnosis')),
                    );
                    return;
                  }

                  if (treatmentController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please enter treatment details')),
                    );
                    return;
                  }

                  final data = {
                    'diagnosis': diagnosisController.text.trim(),
                    'treatment': treatmentController.text.trim(),
                    'medication': medicationController.text.trim(),
                    'recommendations': recommendationsController.text.trim(),
                    'completed_at': DateTime.now().toIso8601String(),
                  };

                  Navigator.pop(context);
                  await _completeVisit(data);
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
                    : const Text('Complete'),
              ),
            ],
          );
        },
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
                        widget.visit.farmerName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.visit.farmerLocation,
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
                            widget.visit.farmerPhone,
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
                Row(
                  children: [
                    Icon(Icons.pets, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.visit.birdsCount} birds',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                    const SizedBox(width: 16),
                    Icon(Icons.home_work, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.visit.houses.length} house${widget.visit.houses.length > 1 ? 's' : ''}',
                      style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                    ),
                  ],
                ),
                if (widget.visit.serviceCosts.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.visit.serviceCosts.map((service) => Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple.shade100),
                      ),
                      child: Text(
                        service.serviceName,
                        style: TextStyle(
                          color: Colors.purple.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )).toList(),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.purple.shade100),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: Colors.purple.shade700),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Visit Started',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.visit.preferredDate,
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
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
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isProcessing ? null : _showCompleteDialog,
                    icon: const Icon(Icons.check_circle, size: 20),
                    label: _isProcessing
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
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