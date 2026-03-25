import 'package:agriflock/core/utils/format_util.dart';
import 'package:agriflock/features/farmer/expense/model/expense_category.dart';
import 'package:flutter/material.dart';

enum UsageChoice { storeIt, useNow, pastRecord }

/// Returns true for items that cannot meaningfully be counted in quantity
/// (e.g. services, generic equipment categories, utilities).
bool isNonQuantifiableItem(CategoryItem item) {
  if (item.id == 'custom') return false;
  if (item.categoryItemPackagingOptions != null &&
      item.categoryItemPackagingOptions!.isNotEmpty) return false;
  final unit = item.categoryItemUnit.toLowerCase().trim();
  return unit == 'service' || unit == 'category' || unit == 'set' || unit == '0.5 acre';
}

class UsageChoiceView extends StatelessWidget {
  final CategoryItem item;
  final double quantity;
  final double totalPrice;
  final Function(UsageChoice choice) onChoice;
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
    final nonQuantifiable = isNonQuantifiableItem(item);

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
                    if (!nonQuantifiable)
                      Text(
                        '${quantity.toStringAsFixed(0)} units',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                      ),
                    Text(
                      'KES ${FormatUtil.formatAmount(totalPrice)}',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
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
          _buildOption(
            context: context,
            onTap: () => onChoice(UsageChoice.storeIt),
            borderColor: Colors.blue.shade200,
            iconColor: Colors.blue.shade700,
            iconBgColor: Colors.blue.shade50,
            icon: Icons.inventory,
            title: isSubmitting ? 'Saving to store...' : 'PUT IN STORE',
            bulletBg: Colors.blue.shade50,
            bullets: const [
              '→ Adds to inventory',
              '→ Records expense only',
              '→ Use later for any batch',
            ],
            bulletColor: Colors.blue.shade700,
            showLoader: isSubmitting,
          ),
          const SizedBox(height: 10),

          // Option 2: Used it now
          _buildOption(
            context: context,
            onTap: () => onChoice(UsageChoice.useNow),
            borderColor: Colors.green.shade200,
            iconColor: Theme.of(context).primaryColor,
            iconBgColor: Colors.green.shade50,
            icon: Icons.now_widgets_outlined,
            title: 'USED IMMEDIATELY',
            bulletBg: Colors.green.shade50,
            bullets: const [
              '→ Adds to batch cost',
              '→ Records usage activity',
              '→ Updates schedules if applicable',
            ],
            bulletColor: Colors.green.shade700,
          ),
          const SizedBox(height: 10),

          // Option 3: Past record (used before batch was created)
          _buildOption(
            context: context,
            onTap: () => onChoice(UsageChoice.pastRecord),
            borderColor: Colors.amber.shade300,
            iconColor: Colors.amber.shade800,
            iconBgColor: Colors.amber.shade50,
            icon: Icons.history_edu,
            title: 'RECORDED AS PAST USE',
            bulletBg: Colors.amber.shade50,
            bullets: const [
              '→ Used before this batch started',
              '→ Links to an existing batch',
              '→ Marked as pre-batch expense',
            ],
            bulletColor: Colors.amber.shade800,
          ),
        ],
      ),
    );
  }

  Widget _buildOption({
    required BuildContext context,
    required VoidCallback onTap,
    required Color borderColor,
    required Color iconColor,
    required Color iconBgColor,
    required IconData icon,
    required String title,
    required Color bulletBg,
    required List<String> bullets,
    required Color bulletColor,
    bool showLoader = false,
  }) {
    return IgnorePointer(
      ignoring: isSubmitting,
      child: Opacity(
        opacity: isSubmitting ? 0.6 : 1.0,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor, width: 2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (showLoader)
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
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: bulletBg,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < bullets.length; i++) ...[
                        if (i > 0) const SizedBox(height: 3),
                        Text(
                          bullets[i],
                          style: TextStyle(
                            fontSize: 13,
                            color: bulletColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
