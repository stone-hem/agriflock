import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/expense/model/expense_category.dart';
import 'package:flutter/material.dart';

class ItemSelectionView extends StatefulWidget {
  final InventoryCategory category;
  final CategoryItem? selectedItem;
  final Function(CategoryItem) onItemSelected;
  final Function(String customName)? onCustomItemSelected;
  final String? customOtherName;
  final VoidCallback onBack;

  const ItemSelectionView({
    super.key,
    required this.category,
    this.selectedItem,
    required this.onItemSelected,
    this.onCustomItemSelected,
    this.customOtherName,
    required this.onBack,
  });

  @override
  State<ItemSelectionView> createState() => _ItemSelectionViewState();
}

class _ItemSelectionViewState extends State<ItemSelectionView> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _customNameController = TextEditingController();
  bool _showCustomInput = false;
  bool _isCustomSelected = false;

  bool get _isOthersCategory {
    return widget.category.name.toLowerCase() == 'others' ||
        widget.category.name.toLowerCase() == 'other';
  }

  List<CategoryItem> get _filteredItems {
    if (_searchQuery.isEmpty) {
      return widget.category.categoryItems;
    }
    return widget.category.categoryItems.where((item) {
      return item.categoryItemName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    if (widget.customOtherName != null && widget.customOtherName!.isNotEmpty) {
      _customNameController.text = widget.customOtherName!;
      _isCustomSelected = true;
      _showCustomInput = true;
    }
  }

  IconData _getItemIcon(String itemName) {
    final lowerName = itemName.toLowerCase();
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

  Color _getCategoryColor() {
    final lowerName = widget.category.name.toLowerCase();
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
    final items = _filteredItems;
    final categoryColor = _getCategoryColor();

    return Column(
      children: [
        // Category info banner
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
                widget.category.name,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: categoryColor,
                ),
              ),
              if (widget.category.description.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    widget.category.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select specific item',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: Icon(Icons.search, color: Colors.grey.shade400),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                            _searchQuery = '';
                          });
                        },
                      )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Other / Add Custom Item option — shown for ALL categories
                if (widget.onCustomItemSelected != null) ...[
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _showCustomInput = true;
                        _isCustomSelected = true;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: _isCustomSelected ? categoryColor.withOpacity(0.1) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _isCustomSelected ? categoryColor : Colors.green.shade300,
                          width: _isCustomSelected ? 2 : 1,
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
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.add,
                              size: 24,
                              color: Colors.green.shade700,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Other',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.green.shade700,
                                  ),
                                ),
                                Text(
                                  _isOthersCategory
                                      ? 'Enter a custom expense name'
                                      : 'Add another item not listed above',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (_isCustomSelected)
                            Icon(
                              Icons.check_circle,
                              color: categoryColor,
                            ),
                        ],
                      ),
                    ),
                  ),

                  // Custom name input field
                  if (_showCustomInput)
                    Container(
                      padding: const EdgeInsets.all(16),
                      margin: const EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _isOthersCategory ? 'Custom Item Name' : 'Item Name',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ReusableInput(
                            controller: _customNameController,
                            hintText: 'Enter item name',
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                final customName = _customNameController.text.trim();
                                if (customName.isNotEmpty) {
                                  widget.onCustomItemSelected!(customName);
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: const Text('Continue'),
                            ),
                          ),
                        ],
                      ),
                    ),

                  if (items.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'Or select existing',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                    ),
                ],

                if (items.isEmpty && !_isOthersCategory)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No items found',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else if (items.isNotEmpty)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final isSelected = widget.selectedItem?.id == item.id && !_isCustomSelected;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            _isCustomSelected = false;
                            _showCustomInput = false;
                          });
                          widget.onItemSelected(item);
                        },
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
                                  color: categoryColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  _getItemIcon(item.categoryItemName),
                                  size: 24,
                                  color: categoryColor,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.categoryItemName,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? categoryColor
                                            : Colors.grey.shade800,
                                      ),
                                    ),
                                    if (item.description.isNotEmpty)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4),
                                        child: Text(
                                          item.description,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    // if (item.components != null && item.components is List && (item.components as List).isNotEmpty)
                                    //   Padding(
                                    //     padding: const EdgeInsets.only(top: 6),
                                    //     child: Wrap(
                                    //       spacing: 6,
                                    //       runSpacing: 6,
                                    //       children: (item.components as List).take(3).map<Widget>((component) {
                                    //         return Container(
                                    //           padding: const EdgeInsets.symmetric(
                                    //             horizontal: 8,
                                    //             vertical: 3,
                                    //           ),
                                    //           decoration: BoxDecoration(
                                    //             color: categoryColor.withOpacity(0.1),
                                    //             borderRadius: BorderRadius.circular(6),
                                    //             border: Border.all(
                                    //               color: categoryColor.withOpacity(0.3),
                                    //             ),
                                    //           ),
                                    //           child: Text(
                                    //             component.toString(),
                                    //             style: TextStyle(
                                    //               fontSize: 10,
                                    //               color: categoryColor,
                                    //               fontWeight: FontWeight.w500,
                                    //             ),
                                    //           ),
                                    //         );
                                    //       }).toList(),
                                    //     ),
                                    //   ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  color: categoryColor,
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

  @override
  void dispose() {
    _searchController.dispose();
    _customNameController.dispose();
    super.dispose();
  }
}