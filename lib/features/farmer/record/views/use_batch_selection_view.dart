import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';

class UseBatchSelectionView extends StatelessWidget {
  final FarmModel? farm;
  final List<BatchListItem> batches;
  final BatchListItem? selectedBatch;
  final bool isLoadingBatches;
  final Function(BatchListItem) onBatchSelected;

  const UseBatchSelectionView({
    super.key,
    this.farm,
    required this.batches,
    this.selectedBatch,
    required this.isLoadingBatches,
    required this.onBatchSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Which batch?',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (farm != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Farm: ${farm!.farmName}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            'Select the batch to apply this record to',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Batch list
          if (isLoadingBatches)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: CircularProgressIndicator(),
              ),
            )
          else if (batches.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.orange.shade700),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      farm != null
                          ? 'No active batches in this farm'
                          : 'No active batches available',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: batches.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final batch = batches[index];
                final isSelected = selectedBatch?.id == batch.id;

                return GestureDetector(
                  onTap: () => onBatchSelected(batch),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.green
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                      boxShadow: [
                        if (isSelected)
                          BoxShadow(
                            color: Colors.green.withOpacity(0.2),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey.shade400,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                batch.batchName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: isSelected
                                      ? Colors.green
                                      : Colors.grey.shade800,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Batch info
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: [
                            _buildBatchInfo(
                              Icons.pets,
                              '${batch.currentCount} birds',
                              Colors.blue,
                            ),
                            _buildBatchInfo(
                              Icons.calendar_today,
                              'Day ${batch.ageInDays}',
                              Colors.orange,
                            ),
                            if (batch.farm != null)
                              _buildBatchInfo(
                                Icons.agriculture,
                                batch.farm!.farmName,
                                Colors.green,
                              ),
                            if (batch.house != null)
                              _buildBatchInfo(
                                Icons.home,
                                batch.house!.name,
                                Colors.purple,
                              ),
                          ],
                        ),

                        if (batch.birdType != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                batch.birdType!.name,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBatchInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}