import 'package:agriflock360/features/batch/tabs/batch_feed_tab.dart';
import 'package:agriflock360/features/batch/tabs/batch_overview.dart';
import 'package:agriflock360/features/batch/tabs/batch_products_tab.dart';
import 'package:agriflock360/features/batch/tabs/batch_vaccinations_tab.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class BatchDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> batch;

  const BatchDetailsScreen({super.key, required this.batch});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
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
            preferredSize: const Size.fromHeight(80),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withValues(alpha: 0.1),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: TabBar(
                  padding: const EdgeInsets.all(6),
                  dividerColor: Colors.transparent,
                  isScrollable: true,
                  dragStartBehavior: DragStartBehavior.start,
                  tabAlignment: .start,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.grey.shade600,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  splashFactory: NoSplash.splashFactory,
                  overlayColor: WidgetStateProperty.all(Colors.transparent),
                  tabs: [
                    _buildTabWithIcon(Icons.dashboard, 'Overview'),
                    _buildTabWithIcon(Icons.fastfood, 'Feed'),
                    _buildTabWithIcon(Icons.medical_services, 'Vaccinations'),
                    _buildTabWithIcon(Icons.inventory, 'Products'),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            BatchOverview(batch: batch),
            BatchFeedTab(batch: batch),
            BatchVaccinationsTab(batch: batch),
            BatchProductsTab(batch: batch),
          ],
        ),
      ),
    );
  }

  Widget _buildTabWithIcon(IconData icon, String label) {
    return Tab(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 6),
          Text(label),
        ],
      ),
    );
  }
}