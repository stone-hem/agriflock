import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
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
                    batch.batchName,
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
                '${batch.currentCount} birds • Day ${batch.ageInDays}',
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
              : categories.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.category_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No categories available',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          )
              : SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'What are you using?',
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

                // Category grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.1,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
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
                            if (category.categoryItems.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  '${category.categoryItems.length} items',
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
            ),
          ),
        ),
      ],
    );
  }
}