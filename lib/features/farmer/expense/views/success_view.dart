import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';

class SuccessView extends StatelessWidget {
  final bool useNow;
  final CategoryItem item;
  final InventoryCategory category;
  final double quantity;
  final double totalPrice;
  final DateTime selectedDate;
  final BatchListItem? batch;
  final double? dosesUsed;
  final FarmModel? farm;
  final VoidCallback onDone;

  const SuccessView({
    super.key,
    required this.useNow,
    required this.item,
    required this.category,
    required this.quantity,
    required this.totalPrice,
    required this.selectedDate,
    this.batch,
    this.dosesUsed,
    this.farm,
    required this.onDone,
  });

  Color _getCategoryColor() {
    final lowerName = category.name.toLowerCase();
    if (lowerName.contains('feed')) {
      return Colors.orange;
    } else if (lowerName.contains('vaccine')) {
      return Colors.blue;
    } else if (lowerName.contains('medication') || lowerName.contains('medicine')) {
      return Colors.red;
    } else if (lowerName.contains('equipment')) {
      return Colors.purple;
    } else if (lowerName.contains('service')) {
      return Colors.teal;
    } else {
      return Colors.green;
    }
  }

  bool get _isVaccineOrMedicine {
    final categoryLower = category.name.toLowerCase();
    return categoryLower.contains('vaccine') ||
        categoryLower.contains('medicine') ||
        categoryLower.contains('medication');
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Success icon
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green.shade600,
            ),
          ),
          const SizedBox(height: 24),

          // Title
          Text(
            useNow ? 'RECORDED & USED!' : 'STORED!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            useNow
                ? '${item.categoryItemName} has been recorded and applied'
                : '${item.categoryItemName} added to inventory',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 32),

          // What was updated section
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.update,
                        color: categoryColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'WHAT WAS UPDATED',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey.shade200),
                const SizedBox(height: 16),

                // Expense recorded
                _buildUpdateItem(
                  Icons.receipt,
                  'Expense recorded',
                  'KES ${totalPrice.toStringAsFixed(2)} (${DateUtil.toShortDateWithDay(selectedDate)})',
                  Colors.green,
                ),
                const SizedBox(height: 16),

                if (useNow) ...[
                  // Batch cost updated
                  if (batch != null)
                    _buildUpdateItem(
                      Icons.trending_up,
                      'Batch cost updated',
                      '${batch!.batchName} +KES ${totalPrice.toStringAsFixed(2)}',
                      Colors.blue,
                    ),
                  const SizedBox(height: 16),

                  // Activity recorded
                  _buildUpdateItem(
                    Icons.history,
                    useNow ? 'Usage recorded' : 'Inventory updated',
                    useNow
                        ? 'Activity logged for ${batch?.batchName ?? 'batch'}'
                        : '${quantity.toStringAsFixed(0)} units added to store',
                    Colors.orange,
                  ),

                  if (_isVaccineOrMedicine && batch != null) ...[
                    const SizedBox(height: 16),
                    _buildUpdateItem(
                      Icons.vaccines,
                      'Health record updated',
                      'Vaccination/medication logged',
                      Colors.purple,
                    ),
                  ],
                ] else ...[
                  // Store updated
                  _buildUpdateItem(
                    Icons.inventory,
                    'Inventory updated',
                    '${quantity.toStringAsFixed(0)} units added',
                    Colors.blue,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Details section
          if (useNow && batch != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: categoryColor.withOpacity(0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: categoryColor.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: categoryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'RECORD DETAILS',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: categoryColor,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _buildDetailRow('Batch', batch!.batchName),
                  _buildDetailRow('Birds', '${batch!.currentCount}'),
                  _buildDetailRow('Age', 'Day ${batch!.ageInDays}'),
                  if (batch!.farm != null)
                    _buildDetailRow('Farm', batch!.farm!.farmName),
                  if (batch!.house != null)
                    _buildDetailRow('House', batch!.house!.name),
                  if (dosesUsed != null)
                    _buildDetailRow('Amount Used', '${dosesUsed!.toStringAsFixed(0)} units'),
                  _buildDetailRow('Item', item.categoryItemName),
                  _buildDetailRow('Category', category.name),
                ],
              ),
            )
          else
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You can now use this ${category.name.toLowerCase()} for any batch when needed',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 32),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onDone,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: const Text(
                    'Back to Home',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: onDone,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: categoryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUpdateItem(
      IconData icon,
      String title,
      String subtitle,
      Color color,
      ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: color,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}