import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/tabs/batch_feed_tab.dart';
import 'package:agriflock360/features/farmer/batch/tabs/batch_overview.dart';
import 'package:agriflock360/features/farmer/batch/tabs/batch_products_tab.dart';
import 'package:agriflock360/features/farmer/batch/tabs/batch_vaccinations_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchDetailsScreen extends StatefulWidget {
  final BatchModel batch;
  final String farmId;

  const BatchDetailsScreen({super.key, required this.batch, required this.farmId});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/logos/Logo_0725.png',
              fit: BoxFit.cover,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.green,
                  child: const Icon(
                    Icons.image,
                    size: 100,
                    color: Colors.white54,
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            const Text('Batch Details'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.grey.shade700),
            onPressed: () {
              context.push('/batches/edit', extra: {
                'batch': widget.batch,
                'farmId': widget.farmId,
                'houseId': widget.batch.houseId,
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48), // Reduced height
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.grey.shade300, // Light grey for active tab
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.grey.shade800, // Darker text for active
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 11, // Smaller font
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11, // Smaller font
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: const [
                Tab(
                  height: 36, // Smaller tab height
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.dashboard, size: 16), // Smaller icon
                      SizedBox(width: 4),
                      Text('Overview'),
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.fastfood, size: 16),
                      SizedBox(width: 4),
                      Text('Feed'),
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.medical_services, size: 16),
                      SizedBox(width: 4),
                      Text('Vaccinations'),
                    ],
                  ),
                ),
                Tab(
                  height: 36,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inventory, size: 16),
                      SizedBox(width: 4),
                      Text('Products'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BatchOverview(batchId: widget.batch.id),
          BatchFeedTab(batch: widget.batch),
          BatchVaccinationsTab(batch: widget.batch),
          BatchProductsTab(batch: widget.batch),
        ],
      ),
    );
  }
}