import 'package:agriflock/core/utils/format_util.dart';
import 'package:agriflock/features/farmer/expense/model/expense_category.dart';
import 'package:flutter/material.dart';

class UsageChoiceView extends StatelessWidget {
  final CategoryItem item;
  final double quantity;
  final double totalPrice;
  final Function(bool useNow) onChoice;
  final VoidCallback onBack;
  final bool isSubmitting;

  const UsageChoiceView({
    super.key,
    required this.item,
    required this.quantity,
    required this.totalPrice,
    required this.onChoice,
    required this.onBack,
    this.isSubmitting = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.inventory_2, color: Colors.green, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item.categoryItemName,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${quantity.toStringAsFixed(0)} units',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    Text('KES ${FormatUtil.formatAmount(totalPrice)}',
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Question
          const Text(
            'What did you do with it?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Choose how you want to handle this purchase',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 14),

          // Option 1: Put in store
          IgnorePointer(
            ignoring: isSubmitting,
            child: Opacity(
              opacity: isSubmitting ? 0.6 : 1.0,
              child: GestureDetector(
                onTap: () => onChoice(false),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.inventory, color: Colors.blue.shade700, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              isSubmitting ? 'Saving to store...' : 'PUT IN STORE',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          if (isSubmitting)
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          else
                            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletPoint('→ Adds to inventory', Colors.blue.shade700),
                            const SizedBox(height: 3),
                            _buildBulletPoint('→ Records expense only', Colors.blue.shade700),
                            const SizedBox(height: 3),
                            _buildBulletPoint('→ Use later for any batch', Colors.blue.shade700),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),

          // Option 2: Used it now
          IgnorePointer(
            ignoring: isSubmitting,
            child: Opacity(
              opacity: isSubmitting ? 0.6 : 1.0,
              child: GestureDetector(
                onTap: () => onChoice(true),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200, width: 2),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.now_widgets_outlined,
                              color: Theme.of(context).primaryColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'USED IMMEDIATELY',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildBulletPoint('→ Adds to batch cost', Colors.green.shade700),
                            const SizedBox(height: 3),
                            _buildBulletPoint('→ Records usage activity', Colors.green.shade700),
                            const SizedBox(height: 3),
                            _buildBulletPoint('→ Updates schedules if applicable', Colors.green.shade700),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}