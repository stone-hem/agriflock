import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';

class BatchSelectionView extends StatefulWidget {
  final FarmModel? farm;
  final List<BatchListItem> batches;
  final BatchListItem? selectedBatch;
  final bool isLoadingBatches;
  final CategoryItem item;
  final InventoryCategory category;
  final double quantity;
  final Function(BatchListItem?) onBatchSelected;
  final Function() onSave;
  final VoidCallback onBack;
  final bool isSubmitting;

  const BatchSelectionView({
    super.key,
    this.farm,
    required this.batches,
    this.selectedBatch,
    required this.isLoadingBatches,
    required this.item,
    required this.category,
    required this.quantity,
    required this.onBatchSelected,
    required this.onSave,
    required this.onBack,
    required this.isSubmitting,
  });

  @override
  State<BatchSelectionView> createState() => _BatchSelectionViewState();
}

class _BatchSelectionViewState extends State<BatchSelectionView> {
  final _formKey = GlobalKey<FormState>();

  bool get _isVaccineOrMedicine {
    final categoryLower = widget.category.name.toLowerCase();
    return categoryLower.contains('vaccine') ||
        categoryLower.contains('medicine') ||
        categoryLower.contains('medication');
  }

  Color _getCategoryColor() {
    final lowerName = widget.category.name.toLowerCase();
    if (lowerName.contains('feed')) {
      return Colors.orange;
    } else if (lowerName.contains('vaccine')) {
      return Colors.blue;
    } else if (lowerName.contains('medication') || lowerName.contains('medicine')) {
      return Colors.red;
    } else {
      return Colors.green;
    }
  }

  void _handleSave() {
    if (widget.selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a batch')),
      );
      return;
    }


    widget.onSave();
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return Column(
      children: [
        // Item banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: categoryColor.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: categoryColor.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Using: ${widget.item.categoryItemName}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
              Text(
                '${widget.quantity.toStringAsFixed(0)} units available',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Which batch did you use it on?',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.farm != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Farm: ${widget.farm!.farmName}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Batch selection
                  if (widget.isLoadingBatches)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (widget.batches.isEmpty)
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
                              widget.farm != null
                                  ? 'No active batches in this farm'
                                  : 'No active batches available',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...widget.batches.map((batch) {
                      final isSelected = widget.selectedBatch?.id == batch.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => widget.onBatchSelected(batch),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? categoryColor
                                    : Colors.grey.shade200,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: [
                                if (isSelected)
                                  BoxShadow(
                                    color: categoryColor.withOpacity(0.2),
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
                                          ? categoryColor
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
                                              ? categoryColor
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
                                        color: categoryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        batch.birdType!.name,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: categoryColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),



                  const SizedBox(height: 32),

                  // Save button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: widget.isSubmitting ? null : _handleSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: widget.isSubmitting
                          ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text(
                        'Save Record',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
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

  @override
  void dispose() {
    super.dispose();
  }
}