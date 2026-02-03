import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:flutter/material.dart';

class ReportBatchSelectionView extends StatelessWidget {
  final List<BatchListItem> batches;
  final BatchListItem? selectedBatch;
  final bool isLoading;
  final Function(BatchListItem) onBatchSelected;

  const ReportBatchSelectionView({
    super.key,
    required this.batches,
    this.selectedBatch,
    required this.isLoading,
    required this.onBatchSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Batch',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a batch to view its report',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          if (batches.isEmpty)
            _buildEmptyState()
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
                  child: _buildBatchCard(batch, isSelected),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Icon(Icons.inventory_2, size: 48, color: Colors.blue.shade600),
          const SizedBox(height: 12),
          Text(
            'No batches available',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Create a batch first to generate reports',
            style: TextStyle(
              color: Colors.blue.shade700,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(BatchListItem batch, bool isSelected) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getBatchTypeColor(batch.birdType).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _getBatchTypeIcon(batch.birdType),
              size: 24,
              color: _getBatchTypeColor(batch.birdType),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.batchName,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.blue : Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip(
                      Icons.pets,
                      '${batch.birdsAlive} birds',
                    ),
                    const SizedBox(width: 8),
                    _buildInfoChip(
                      Icons.calendar_today,
                      '${batch.age} days',
                    ),
                  ],
                ),
                if (batch.houseName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      batch.houseName!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey.shade400,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Color _getBatchTypeColor(String birdType) {
    switch (birdType.toLowerCase()) {
      case 'broiler':
        return Colors.orange;
      case 'layer':
        return Colors.blue;
      case 'kienyeji':
        return Colors.brown;
      default:
        return Colors.green;
    }
  }

  IconData _getBatchTypeIcon(String birdType) {
    switch (birdType.toLowerCase()) {
      case 'broiler':
        return Icons.restaurant;
      case 'layer':
        return Icons.egg;
      case 'kienyeji':
        return Icons.eco;
      default:
        return Icons.pets;
    }
  }
}
