import 'package:agriflock360/features/batch/tabs/batch_feed_tab.dart';
import 'package:agriflock360/features/batch/tabs/batch_overview.dart';
import 'package:agriflock360/features/batch/tabs/batch_products_tab.dart';
import 'package:agriflock360/features/batch/tabs/batch_vaccinations_tab.dart';
import 'package:flutter/material.dart';

class BatchDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> batch;

  const BatchDetailsScreen({super.key, required this.batch});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen> {
  int _selectedIndex = 0;

  final List<_TabInfo> _tabs = [
    _TabInfo(icon: Icons.dashboard, label: 'Overview'),
    _TabInfo(icon: Icons.fastfood, label: 'Feed'),
    _TabInfo(icon: Icons.medical_services, label: 'Vaccinations'),
    _TabInfo(icon: Icons.inventory, label: 'Products'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Batch Details'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey.shade700),
            onPressed: () {
              // Navigate to edit screen
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(_tabs.length, (index) {
                  final tab = _tabs[index];
                  final isSelected = _selectedIndex == index;

                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _ChipTab(
                      icon: tab.icon,
                      label: tab.label,
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          BatchOverview(batch: widget.batch),
          BatchFeedTab(batch: widget.batch),
          BatchVaccinationsTab(batch: widget.batch),
          BatchProductsTab(batch: widget.batch),
        ],
      ),
    );
  }
}

class _TabInfo {
  final IconData icon;
  final String label;

  _TabInfo({required this.icon, required this.label});
}

class _ChipTab extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChipTab({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
            colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade300,
            width: 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey.shade700,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade700,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}