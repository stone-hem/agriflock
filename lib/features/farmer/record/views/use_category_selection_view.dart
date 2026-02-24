import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:agriflock360/features/farmer/record/views/record_weight_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UseCategorySelectionView extends StatelessWidget {
  final List<InventoryCategory> categories;
  final bool isLoading;
  final InventoryCategory? selectedCategory;
  final BatchListItem batch;
  final Function(InventoryCategory) onCategorySelected;
  final VoidCallback onBack;

  const UseCategorySelectionView({
    super.key,
    required this.categories,
    required this.isLoading,
    this.selectedCategory,
    required this.batch,
    required this.onCategorySelected,
    required this.onBack,
  });

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('feed')) {
      return Icons.fastfood;
    } else if (lowerName.contains('vaccine')) {
      return Icons.vaccines;
    } else if (lowerName.contains('medication') || lowerName.contains('medicine')) {
      return Icons.medical_services;
    } else if (lowerName.contains('equipment')) {
      return Icons.build;
    } else if (lowerName.contains('service')) {
      return Icons.room_service;
    } else {
      return Icons.category;
    }
  }

  Color _getCategoryColor(String categoryName) {
    final lowerName = categoryName.toLowerCase();
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

  // Filter categories to only show those with useFromStore true
  List<InventoryCategory> get _filteredCategories {
    return categories
        .where((cat) => cat.useFromStore && cat.categoryItems.any((item) => item.useFromStore))
        .toList();
  }

  // Get count of items that can be used from store
  int _getUsableItemsCount(InventoryCategory category) {
    return category.categoryItems.where((item) => item.useFromStore).length;
  }

  @override
  Widget build(BuildContext context) {
    final filteredCategories = _filteredCategories;

    return Column(
      children: [
        // Batch info banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            border: Border(
              bottom: BorderSide(
                color: Colors.green.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.pets, color: Colors.green, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    batch.batchNumber,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                '${batch.currentCount} birds •  ${batch.ageInDays} days old  /  '
                    '${((batch.ageInDays / 7) % 1 > 0.5)
                    ? (batch.ageInDays / 7).ceil()
                    : (batch.ageInDays / 7).floor()} weeks',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),


            ],
          ),
        ),

        Expanded(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What are you recording?',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Select a category to continue',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 24),

                // Special action cards
                _buildSpecialActionCard(
                  context: context,
                  icon: Icons.warning_amber_rounded,
                  title: 'Record Mortality',
                  subtitle: 'Log bird losses for this batch',
                  color: Colors.red,
                  onTap: () {
                    context.push('/record-mortality', extra: {
                      'batch': batch,
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildSpecialActionCard(
                  context: context,
                  icon: Icons.monitor_weight,
                  title: 'Record Weight',
                  subtitle: 'Log weight sampling data',
                  color: Colors.indigo,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => RecordWeightScreen(batch: batch),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 12),
                _buildSpecialActionCard(
                  context: context,
                  icon: Icons.egg,
                  title: 'Record Product',
                  subtitle: 'Log eggs or other products',
                  color: Colors.amber.shade700,
                  onTap: () {
                    context.push('/batches/${batch.id}/record-product');
                  },
                ),

                if (filteredCategories.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  Text(
                    'Use from store',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Category grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.1, maxCrossAxisExtent: 250,
                    ),
                    itemCount: filteredCategories.length,
                    itemBuilder: (context, index) {
                      final category = filteredCategories[index];
                      final color = _getCategoryColor(category.name);
                      final icon = _getCategoryIcon(category.name);
                      final isSelected = selectedCategory?.id == category.id;

                      return GestureDetector(
                        onTap: () => onCategorySelected(category),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: isSelected ? color : Colors.grey.shade200,
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: color.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  icon,
                                  size: 32,
                                  color: color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(
                                  category.name,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                    color: isSelected ? color : Colors.grey.shade800,
                                  ),
                                ),
                              ),
                              if (_getUsableItemsCount(category) > 0)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    '${_getUsableItemsCount(category)} items',
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade500,
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
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSpecialActionCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
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
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 24, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
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
      ),
    );
  }
}
