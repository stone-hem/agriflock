import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/batch/tabs/active_batches_tab.dart';
import 'package:agriflock360/features/farmer/batch/tabs/archived_batches_tab.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchesScreen extends StatefulWidget {
  final FarmModel farm;
  const BatchesScreen({super.key, required this.farm});

  @override
  State<BatchesScreen> createState() => _BatchesScreenState();
}

class _BatchesScreenState extends State<BatchesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
            const Text('Agriflock 360'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
            onPressed: () => context.push('/notifications'),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey.shade600,
          tabs: const [
            Tab(
              icon: Icon(Icons.warehouse),
              text: 'Active Houses & Batches',
            ),
            Tab(
              icon: Icon(Icons.archive),
              text: 'Archived Batches',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          ActiveBatchesTab(farm: widget.farm),
          ArchivedBatchesTab(farm: widget.farm),
        ],
      ),
    );
  }
}