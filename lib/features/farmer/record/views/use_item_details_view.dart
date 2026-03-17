import 'package:agriflock/core/utils/age_util.dart';
import 'package:agriflock/core/utils/feed_format_util.dart';
import 'package:agriflock/core/widgets/custom_date_text_field.dart';
import 'package:agriflock/core/widgets/reusable_dropdown.dart';
import 'package:agriflock/core/widgets/reusable_input.dart';
import 'package:agriflock/core/widgets/reusable_time_input.dart';
import 'package:agriflock/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock/features/farmer/expense/model/expense_category.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UseItemDetailsView extends StatefulWidget {
  final BatchListItem batch;
  final InventoryCategory category;
  final CategoryItem? selectedItem;
  final double? quantity;
  final String? methodOfAdministration;
  final String? notes;
  final DateTime selectedDate;
  final double? dosesUsed;
  final Function(CategoryItem) onItemSelected;
  final VoidCallback onItemCleared;
  final Function({
  required double quantity,
  String? methodOfAdministration,
  String? notes,
  required DateTime selectedDate,
  double? dosesUsed,
  bool usedFromStore,
  double? price,
  }) onSave;
  final VoidCallback onBack;
  final bool isSubmitting;

  const UseItemDetailsView({
    super.key,
    required this.batch,
    required this.category,
    this.selectedItem,
    this.quantity,
    this.methodOfAdministration,
    this.notes,
    required this.selectedDate,
    this.dosesUsed,
    required this.onItemSelected,
    required this.onItemCleared,
    required this.onSave,
    required this.onBack,
    required this.isSubmitting,
  });

  @override
  State<UseItemDetailsView> createState() => _UseItemDetailsViewState();
}

class _UseItemDetailsViewState extends State<UseItemDetailsView> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dosesController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();

  String _searchQuery = '';
  String? _selectedMethodOfAdministration;
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _usedFromStore = true;

  // Packaging options

  String get _dateLabel {
    final name = widget.category.name.toLowerCase();
    if (name.contains('vacc')) return 'Date Vaccinated';
    if (name.contains('medic') || name.contains('medicine')) return 'Date Medicated';
    return 'Date Fed';
  }

  String get _timeLabel {
    final name = widget.category.name.toLowerCase();
    if (name.contains('vacc')) return 'Actual Time Vaccinated';
    if (name.contains('medic') || name.contains('medicine')) return 'Actual Time Medicated';
    return 'Actual Time Fed';
  }

  @override
  void initState() {
    super.initState();

    if (widget.quantity != null) {
      _quantityController.text = widget.quantity.toString();
    }
    if (widget.dosesUsed != null) {
      _dosesController.text = widget.dosesUsed.toString();
    }
    if (widget.notes != null) {
      _notesController.text = widget.notes!;
    }
    if (widget.methodOfAdministration != null) {
      _selectedMethodOfAdministration = widget.methodOfAdministration;
    }

  }


  @override
  void didUpdateWidget(UseItemDetailsView oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  /// Returns the recommended quantity already converted to the field's unit
  /// (kg for feeds, doses for vaccines). Returns null if not available.
  double? _recommendedQtyInFieldUnit(CategoryItem item) {
    final rec = item.recommendedQuantity;
    if (rec == null) return null;

    final qtyPerBird = (rec['quantity_per_bird_per_day'] as num?)?.toDouble();
    if (qtyPerBird == null) return null;

    final numBirds = widget.batch.currentCount;
    final total = qtyPerBird * numBirds;

    // qtyPerBird comes in grams from API; convert to kgs for feed categories
    if (_getUnitDisplay().toLowerCase() == 'kgs') {
      return total / 1000;
    }
    return total;
  }

  String _formatQty(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    // up to 3 decimal places, strip trailing zeros
    return value.toStringAsFixed(3).replaceAll(RegExp(r'\.?0+$'), '');
  }

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

  String _getUnitDisplay() {
    return widget.category.name.toLowerCase().contains('feed')
        ? 'kgs'
        : 'units';
  }

  List<CategoryItem> get _filteredItems {
    // First filter to only items that can be used from store
    final usableItems = widget.category.categoryItems.where((item) => item.useFromStore).toList();

    if (_searchQuery.isEmpty) {
      return usableItems;
    }
    return usableItems.where((item) {
      return item.categoryItemName.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _handleSave() {
    if (widget.selectedItem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an item')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_usedFromStore) {
      if (_priceController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter the purchase price')),
        );
        return;
      }
      final rawPrice = _priceController.text.replaceAll(',', '');
      if (double.tryParse(rawPrice) == null || double.parse(rawPrice) <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter a valid price')),
        );
        return;
      }
    }

    final quantity = double.parse(_quantityController.text);
    final dosesUsed = _isVaccineOrMedicine && _dosesController.text.isNotEmpty
        ? double.tryParse(_dosesController.text)
        : null;
    final price = !_usedFromStore
        ? double.tryParse(_priceController.text.replaceAll(',', ''))
        : null;

    // Parse date from controller (ISO format from CustomDateTextField)
    DateTime selectedDate = DateTime.now();
    if (_dateController.text.isNotEmpty) {
      try {
        selectedDate = DateTime.parse(_dateController.text);
      } catch (e) {
        // Fallback to current date if parsing fails
        selectedDate = DateTime.now();
      }
    }

    // Combine date + time into a single DateTime
    final combinedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    widget.onSave(
      quantity: quantity,
      methodOfAdministration: _selectedMethodOfAdministration,
      notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      selectedDate: combinedDateTime,
      dosesUsed: dosesUsed,
      usedFromStore: _usedFromStore,
      price: price,
    );
  }

  @override
  Widget build(BuildContext context) {
    final categoryColor = _getCategoryColor();
    final items = _filteredItems;

    return Column(
      children: [
        // Batch and category banner
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
              Row(
                children: [
                  Icon(Icons.pets, color: categoryColor, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.batch.birdType?.name ?? widget.batch.batchNumber,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: categoryColor,
                          ),
                        ),
                        if (widget.batch.birdType != null)
                          Text(
                            widget.batch.batchNumber,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${widget.batch.currentCount} birds',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                AgeUtil.formatAge(widget.batch.ageInDays),
                style: TextStyle(
                  fontSize: 13,
                  color: categoryColor,
                ),
              ),
              Row(
                children: [
                  Text(
                    widget.category.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: categoryColor,
                    ),
                  ),
                  const SizedBox(width: 5),
                ],
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Item selection section
                  if (widget.selectedItem == null) ...[
                    const Text(
                      'Select item',
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

                    // Items list
                    if (items.isEmpty)
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
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final item = items[index];

                          return GestureDetector(
                            onTap: () => widget.onItemSelected(item),
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: item.isSuggestedForAge
                                      ? const Color(0xFF2E7D32).withOpacity(0.3)
                                      : Colors.grey.shade200,
                                  width: item.isSuggestedForAge ? 1.5 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 2),
                                  ),
                                  if (item.isSuggestedForAge)
                                    BoxShadow(
                                      color: const Color(0xFF2E7D32).withOpacity(0.1),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                ],
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Icon with suggestion indicator
                                  Stack(
                                    clipBehavior: Clip.none,
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
                                      if (item.isSuggestedForAge)
                                        Positioned(
                                          top: -4,
                                          right: -4,
                                          child: Container(
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2E7D32),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.white, width: 1.5),
                                            ),
                                            child: const Icon(
                                              Icons.thumb_up,
                                              size: 10,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // Title and suggested chip
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.categoryItemName,
                                                style: TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade800,
                                                ),
                                              ),
                                            ),
                                            if (item.isSuggestedForAge)
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFF2E7D32).withOpacity(0.1),
                                                  borderRadius: BorderRadius.circular(16),
                                                  border: Border.all(
                                                    color: const Color(0xFF2E7D32).withOpacity(0.3),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.thumb_up,
                                                      size: 12,
                                                      color: Color(0xFF2E7D32),
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      'Suggested',
                                                      style: TextStyle(
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.w600,
                                                        color: const Color(0xFF2E7D32),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        // Quantity in store
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade50,
                                            borderRadius: BorderRadius.circular(16),
                                            border: Border.all(color: Colors.grey.shade200),
                                          ),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.inventory_2,
                                                size: 12,
                                                color: Colors.grey.shade600,
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                'In Store: ${FeedFormatUtil.formatQuantity(item.quantityInStore, item.categoryItemUnit)}',
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        // Description
                                        if (item.description != null)
                                          Text(
                                            item.description!,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.grey.shade600,
                                              height: 1.4,
                                            ),
                                          ),
                                        // Suggestion context chip (if suggested)
                                        if (item.isSuggestedForAge && item.suggestionContext != null && item.suggestionContext!.isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF2E7D32).withOpacity(0.05),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(
                                                color: const Color(0xFF2E7D32).withOpacity(0.2),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.info_outline,
                                                  size: 12,
                                                  color: const Color(0xFF2E7D32).withOpacity(0.7),
                                                ),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    item.suggestionContext!,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      fontWeight: FontWeight.w500,
                                                      color: const Color(0xFF2E7D32).withOpacity(0.8),
                                                    ),
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  // Arrow icon
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Icon(
                                      Icons.chevron_right,
                                      size: 20,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ] else ...[
                    // Selected item display and details
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: categoryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: categoryColor.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _getItemIcon(widget.selectedItem!.categoryItemName),
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
                                  widget.selectedItem!.categoryItemName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: categoryColor,
                                  ),
                                ),
                                if (widget.selectedItem!.description != null)
                                  Text(
                                    widget.selectedItem!.description!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            color: categoryColor,
                            tooltip: 'Change item',
                            onPressed: widget.onItemCleared,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),


                    // Source choice
                    const Text(
                      'Where is this coming from?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _usedFromStore = true),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _usedFromStore ? Colors.green.shade50 : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _usedFromStore ? Colors.green : Colors.grey.shade200,
                                  width: _usedFromStore ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: _usedFromStore ? Colors.green.withOpacity(0.15) : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.inventory_2_rounded,
                                      size: 26,
                                      color: _usedFromStore ? Colors.green : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'From Store',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: _usedFromStore ? Colors.green.shade700 : Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Deduct from stored inventory',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: _usedFromStore ? Colors.green.shade600 : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _usedFromStore = false),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: !_usedFromStore ? Colors.orange.shade50 : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: !_usedFromStore ? Colors.orange : Colors.grey.shade200,
                                  width: !_usedFromStore ? 2 : 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.04),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: !_usedFromStore ? Colors.orange.withOpacity(0.15) : Colors.grey.shade100,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.shopping_cart_rounded,
                                      size: 26,
                                      color: !_usedFromStore ? Colors.orange : Colors.grey.shade500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'New Purchase',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: !_usedFromStore ? Colors.orange.shade700 : Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Bought & used now',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: !_usedFromStore ? Colors.orange.shade600 : Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'How much did you use?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // In-store availability badge
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue.shade100),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.inventory_2, size: 14, color: Colors.blue.shade700),
                          const SizedBox(width: 6),
                          Text(
                            'In Store: ${FeedFormatUtil.formatQuantity(widget.selectedItem!.quantityInStore, widget.selectedItem!.categoryItemUnit)}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ReusableInput(
                      topLabel: 'Quantity Used (${_getUnitDisplay()})',
                      icon: Icons.inventory_2,
                      controller: _quantityController,
                      hintText: 'Enter quantity in ${_getUnitDisplay()}',
                      keyboardType: const TextInputType.numberWithOptions(decimal: true,signed: false),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'^\d+\.?\d{0,2}'),
                        ),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter quantity';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        if (double.parse(value) <= 0) {
                          return 'Quantity must be greater than 0';
                        }
                        return null;
                      },
                    ),

                    // Feed recommendation banner
                    if (!_isVaccineOrMedicine && widget.selectedItem != null) ...[
                      Builder(builder: (context) {
                        final item = widget.selectedItem!;
                        final rec = item.recommendedQuantity;
                        if (rec == null) return const SizedBox.shrink();

                        final qtyPerBird = (rec['quantity_per_bird_per_day'] as num?)?.toDouble();
                        final timesPerDay = (rec['times_per_day'] as num?)?.toInt();
                        final unit = (rec['unit'] as String?) ?? item.categoryItemUnit;
                        if (qtyPerBird == null) return const SizedBox.shrink();

                        final recQty = _recommendedQtyInFieldUnit(item)!;
                        final fieldUnit = _getUnitDisplay();


                        return GestureDetector(
                          onTap: () => setState(
                            () => _quantityController.text = _formatQty(recQty),
                          ),
                          child: Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.green.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.lightbulb_outline,
                                    color: Colors.green.shade700, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.green.shade800),
                                      children: [
                                        const TextSpan(
                                          text: 'Recommended feeds per day: ',
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                        TextSpan(
                                          text: '${_formatQty(recQty)} $fieldUnit'
                                              '(${timesPerDay != null ? ' $timesPerDay×/day' : ''})',
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Use',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                    const SizedBox(height: 16),

                    // Price field (only when fresh purchase)
                    if (!_usedFromStore) ...[
                      ReusableInput(
                        topLabel: 'Total Purchase Price',
                        icon: Icons.payments_rounded,
                        controller: _priceController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: false),
                        inputFormatters: [_ThousandsFormatter()],
                        hintText: 'Enter total amount paid',
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Method of administration (for vaccines/medicines)
                    if (_isVaccineOrMedicine) ...[
                      const Text(
                        'Method of Administration',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ReusableDropdown<String>(
                          value: _selectedMethodOfAdministration,
                          icon: Icons.medication_liquid,
                          topLabel: 'Select method of administration',
                          hintText: 'Select method',
                          items: [
                            'Drinking water',
                            'Injection',
                            'Spray',
                            'Eye drop',
                            'Oral',
                          ].map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(method),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() => _selectedMethodOfAdministration = value);
                          },
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Doses used
                      ReusableInput(
                        topLabel: 'Doses/Amount Used (Optional)',
                        icon: Icons.medical_information,
                        controller: _dosesController,
                        hintText: '0',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null && value.isNotEmpty) {
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Amount must be greater than 0';
                            }
                          }
                          return null;
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.lightbulb_outline,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Recommended: ${widget.batch.currentCount} doses (1 per bird)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Date selection
                    CustomDateTextField(
                      label: _dateLabel,
                      icon: Icons.calendar_today,
                      required: true,
                      initialDate: DateTime.now(),
                      minYear: DateTime.now().year - 1,
                      maxYear: DateTime.now().year,
                      returnFormat: DateReturnFormat.isoString,
                      controller: _dateController,
                    ),
                    const SizedBox(height: 16),

                    // Time selection
                    ReusableTimeInput(
                      topLabel: _timeLabel,
                      icon: Icons.access_time,
                      onTimeChanged: (time) {
                        setState(() => _selectedTime = time);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Notes
                    ReusableInput(
                      topLabel: 'Notes (Optional)',
                      icon: Icons.note,
                      controller: _notesController,
                      hintText: 'Add any additional notes...',
                      maxLines: 3,
                    ),
                    const SizedBox(height: 32),

                    // Save button
                    SizedBox(
                      width: double.infinity,
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
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _dosesController.dispose();
    _notesController.dispose();
    _searchController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    super.dispose();
  }
}

class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final stripped = newValue.text.replaceAll(',', '');
    if (stripped.isEmpty) return newValue.copyWith(text: '');

    final parts = stripped.split('.');
    final intPart = parts[0];
    final decPart = parts.length > 1
        ? '.${parts[1].substring(0, parts[1].length.clamp(0, 2))}'
        : '';

    final buffer = StringBuffer();
    for (int i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }

    final formatted = '${buffer.toString()}$decPart';
    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}