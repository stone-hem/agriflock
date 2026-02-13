import 'package:agriflock360/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/tabs/batch_expenditures_tab.dart';
import 'package:agriflock360/features/farmer/batch/tabs/batch_feed_tab.dart';
import 'package:agriflock360/features/farmer/batch/tabs/batch_overview.dart';
import 'package:agriflock360/features/farmer/batch/tabs/batch_products_tab.dart';
import 'package:agriflock360/features/farmer/batch/tabs/batch_vaccinations_tab.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchDetailsScreen extends StatefulWidget {
  final BatchModel batch;
  final FarmModel farm;

  const BatchDetailsScreen({super.key, required this.batch, required this.farm});

  @override
  State<BatchDetailsScreen> createState() => _BatchDetailsScreenState();
}

class _BatchDetailsScreenState extends State<BatchDetailsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            Text(widget.batch.batchName),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.only(left: 12, right: 12),
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              indicatorSize: TabBarIndicatorSize.label,
              indicator: BoxDecoration(
                color: Colors.green.shade50, // Light green background
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.green, // Green border for active
                  width: 1.5,
                ),
              ),
              labelColor: Colors.green.shade700,
              labelPadding: const EdgeInsets.symmetric(horizontal: 4),
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: [
                _buildTab(Icons.dashboard, 'Overview', false),
                _buildTab(Icons.fastfood, 'Feeding', false),
                _buildTab(Icons.medical_services, 'Vaccinations', false),
                _buildTab(Icons.inventory, 'Products', false),
                _buildTab(Icons.account_balance_wallet, 'Expenditures', false),

              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const ExpenseMarqueeBannerCompact(),
      body: TabBarView(
        controller: _tabController,
        children: [
          BatchOverview(batchId: widget.batch.id),
          BatchFeedTab(batch: widget.batch),
          BatchVaccinationsTab(batch: widget.batch),
          BatchProductsTab(batch: widget.batch),
          BatchExpendituresTab(batch: widget.batch),

        ],
      ),
    );
  }

  Widget _buildTab(IconData icon, String label, bool isActive) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300, // Grey border for inactive
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 4),
          Text(label),
        ],
      ),
    );
  }
}