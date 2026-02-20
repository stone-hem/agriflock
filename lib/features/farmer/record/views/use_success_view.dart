import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';

class UseSuccessView extends StatelessWidget {
  final BatchListItem batch;
  final InventoryCategory category;
  final CategoryItem item;
  final double quantity;
  final DateTime selectedDate;
  final double? dosesUsed;
  final FarmModel? farm;
  final VoidCallback onDone;

  const UseSuccessView({
    super.key,
    required this.batch,
    required this.category,
    required this.item,
    required this.quantity,
    required this.selectedDate,
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
              color: Colors.green.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle,
              size: 80,
              color: Colors.green,
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Record Saved!',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Successfully recorded usage from store',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),

          const SizedBox(height: 32),

          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),

          const SizedBox(height: 24),

          // Summary section
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'WHAT WAS RECORDED:',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                color: Colors.grey,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Batch info
          _buildInfoCard(
            icon: Icons.pets,
            color: Colors.green,
            title: 'Batch',
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  batch.batchNumber,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${batch.currentCount} birds • Day ${batch.ageInDays}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (batch.house != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'House: ${batch.house!.name}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Item used
          _buildInfoCard(
            icon: _getItemIcon(),
            color: categoryColor,
            title: category.name,
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.categoryItemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.inventory_2, size: 14, color: categoryColor),
                    const SizedBox(width: 6),
                    Text(
                      '${quantity.toStringAsFixed(0)} units used',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Vaccination/Medicine details
          if (_isVaccineOrMedicine && dosesUsed != null)
            _buildInfoCard(
              icon: Icons.medication_liquid,
              color: Colors.purple,
              title: 'Administration',
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline,
                        size: 14,
                        color: Colors.purple,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${dosesUsed?.toStringAsFixed(0)} doses administered',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (dosesUsed! < batch.currentCount)
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline,
                            size: 14,
                            color: Colors.orange,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              'Partial administration: ${dosesUsed?.toStringAsFixed(0)}/${batch.currentCount} birds',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.withOpacity(0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.check_circle,
                            size: 14,
                            color: Colors.green,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'All birds administered',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          const SizedBox(height: 12),

          // Date
          _buildInfoCard(
            icon: Icons.calendar_today,
            color: Colors.blue,
            title: 'Date',
            content: Text(
              '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Info box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Store inventory has been updated and costs allocated to the batch',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Done button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: onDone,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Done',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color color,
    required String title,
    required Widget content,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
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
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }

  IconData _getItemIcon() {
    final lowerName = item.categoryItemName.toLowerCase();
    if (lowerName.contains('vaccine')) {
      return Icons.vaccines;
    } else if (lowerName.contains('feed')) {
      return Icons.fastfood;
    } else if (lowerName.contains('medicine') || lowerName.contains('drug')) {
      return Icons.medication;
    } else if (lowerName.contains('vitamin') || lowerName.contains('supplement')) {
      return Icons.health_and_safety;
    } else if (lowerName.contains('equipment') || lowerName.contains('tool')) {
      return Icons.build_circle;
    } else {
      return Icons.inventory_2;
    }
  }
}