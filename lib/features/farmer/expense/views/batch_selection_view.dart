import 'package:agriflock/core/widgets/reusable_input.dart';
import 'package:agriflock/core/utils/age_util.dart';
import 'package:agriflock/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock/features/farmer/expense/views/usage_choice_view.dart';
import 'package:agriflock/features/farmer/farm/models/farm_model.dart';
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
  final Function(double? usedQuantity) onSave;
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
  final TextEditingController _usedQuantityController = TextEditingController();
  bool _didNotUseAll = false;

  String get _unit => widget.item.categoryItemUnit.isNotEmpty
      ? widget.item.categoryItemUnit
      : 'units';

  bool get _isNonQuantifiable => isNonQuantifiableItem(widget.item);

  String _formatQty(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
  }

  Color _getCategoryColor() {
    final lowerName = widget.category.name.toLowerCase();
    if (lowerName.contains('feed')) return Colors.orange;
    if (lowerName.contains('vaccine')) return Colors.blue;
    if (lowerName.contains('medication') || lowerName.contains('medicine')) {
      return Colors.red;
    }
    return Colors.green;
  }

  void _handleSave() {
    if (widget.selectedBatch == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a batch')),
      );
      return;
    }

    // Non-quantifiable items (services, etc.) always count as fully used
    if (_isNonQuantifiable) {
      widget.onSave(null);
      return;
    }

    if (_didNotUseAll) {
      if (!_formKey.currentState!.validate()) return;
      final usedQty = double.tryParse(_usedQuantityController.text);
      widget.onSave(usedQty);
    } else {
      // All used — don't send used_quantity
      widget.onSave(null);
    }
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
            color: categoryColor.withValues(alpha: 0.1),
            border: Border(
              bottom: BorderSide(color: categoryColor.withValues(alpha: 0.2)),
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
                '${_formatQty(widget.quantity)} $_unit purchased',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
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
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  if (widget.farm != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Farm: ${widget.farm!.farmName}',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade600),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Batch list
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
                          Icon(Icons.info_outline,
                              color: Colors.orange.shade700),
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
                                    color:
                                        categoryColor.withValues(alpha: 0.15),
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
                                        batch.birdType!.name,
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
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 8,
                                  children: [
                                    _buildBatchInfo(Icons.pets,
                                        '${batch.currentCount} birds',
                                        Colors.blue),
                                    _buildBatchInfo(Icons.calendar_today,
                                        AgeUtil.formatAge(batch.ageInDays), Colors.orange),
                                    if (batch.farm != null)
                                      _buildBatchInfo(Icons.agriculture,
                                          batch.farm!.farmName, Colors.green),
                                    if (batch.house != null)
                                      _buildBatchInfo(Icons.home,
                                          batch.house!.name, Colors.purple),
                                  ],
                                ),
                                if (batch.birdType != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: categoryColor.withValues(
                                            alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        batch.batchNumber,
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
                    }),

                  const SizedBox(height: 8),

                  // ── Usage section (hidden for non-quantifiable items) ──────
                  if (!_isNonQuantifiable) ...[
                  const Text(
                    'How much was used?',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // "All used" summary card
                  if (!_didNotUseAll)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check_circle_outline,
                                color: Colors.green.shade700, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'All ${_formatQty(widget.quantity)} units used',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'The full purchased amount will be recorded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                  // "Didn't use all?" row
                  if (!_didNotUseAll) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => setState(() => _didNotUseAll = true),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: Colors.grey.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined,
                                size: 18, color: Colors.grey.shade500),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Didn't use all of it? Tap to specify amount",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ),
                            Icon(Icons.chevron_right,
                                size: 18, color: Colors.grey.shade400),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Partial quantity input (visible only when "didn't use all")
                  if (_didNotUseAll) ...[
                    ReusableInput(
                      topLabel: 'Amount Used ($_unit)',
                      icon: Icons.output,
                      controller: _usedQuantityController,
                      hintText: 'Enter amount used',
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter amount used';
                        }
                        final v = double.tryParse(value);
                        if (v == null || v <= 0) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () {
                        _usedQuantityController.clear();
                        setState(() => _didNotUseAll = false);
                      },
                      child: Row(
                        children: [
                          Icon(Icons.undo,
                              size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 6),
                          Text(
                            'Actually, all was used',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  ], // end if (!_isNonQuantifiable)

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
          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _usedQuantityController.dispose();
    super.dispose();
  }
}
