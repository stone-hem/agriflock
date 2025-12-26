// lib/features/farmer/farm/view/farms_home_screen.dart

import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/farm/repositories/farm_repository.dart';
import 'package:agriflock360/features/farmer/farm/view/edit_farm_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FarmsHomeScreen extends StatefulWidget {
  const FarmsHomeScreen({super.key});

  @override
  State<FarmsHomeScreen> createState() => _FarmsHomeScreenState();
}

class _FarmsHomeScreenState extends State<FarmsHomeScreen> {
  final ScrollController _scrollController = ScrollController();
  final _farmRepository = FarmRepository();

  bool _showFab = true;

  // Combined future for farms and stats
  late Future<FarmsResponse> _farmsResponseFuture;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Listen to scroll events to hide/show FAB
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && _showFab) {
        setState(() {
          _showFab = false;
        });
      } else if (_scrollController.offset <= 100 && !_showFab) {
        setState(() {
          _showFab = true;
        });
      }
    });
  }

  void _loadData() {
    // Load farms and stats in a single API call
    _farmsResponseFuture = _farmRepository.getAllFarmsWithStats();
  }

  void _refreshData() {
    setState(() {
      _loadData();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
            icon: Icon(Icons.notifications_outlined,
                color: Colors.grey.shade700),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      floatingActionButton: _showFab
          ? FloatingActionButton(
        onPressed: () async {
          final result = await context.push('/farms/add');
          if (result == true) {
            _refreshData();
          }
        },
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
          // Wait for future to complete
          await _farmsResponseFuture;
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: FutureBuilder<FarmsResponse>(
            future: _farmsResponseFuture,
            builder: (context, snapshot) {
              // Show loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select a Farm to continue',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage multiple farm locations and their Batches',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildStatsLoading(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    _buildLoadingList(),
                  ],
                );
              }

              // Show error state
              if (snapshot.hasError) {
                return CustomScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select a Farm to continue',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall!
                                .copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Manage multiple farm locations and their Batches',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 24),
                          _buildStatsError(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                    _buildErrorList(snapshot.error.toString()),
                  ],
                );
              }

              // Show data
              final farmsResponse = snapshot.data!;
              final farms = farmsResponse.farms;
              final stats = farmsResponse.statistics;

              return CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select a Farm to continue',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall!
                              .copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Manage multiple farm locations and their Batches',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _buildStatsOverview(stats),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                  farms.isEmpty ? _buildEmptyList() : _buildFarmsList(farms),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsError() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'Failed to load statistics',
        style: TextStyle(color: Colors.red.shade700),
      ),
    );
  }

  Widget _buildStatsOverview(FarmStatistics stats) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '${stats.totalFarms}',
            label: 'Total Farms',
            color: Colors.blue.shade100,
            textColor: Colors.blue.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '${stats.totalBirds}',
            label: 'Total Birds',
            color: Colors.green.shade100,
            textColor: Colors.green.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '${stats.totalActiveBatches}',
            label: 'Active Batches',
            color: Colors.orange.shade100,
            textColor: Colors.orange.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingList() {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Container(
              height: 120,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 16,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          height: 14,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        childCount: 3,
      ),
    );
  }

  Widget _buildErrorList(String error) {
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text(
              'Failed to load farms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please try again',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshData,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyList() {
    return SliverToBoxAdapter(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Icon(Icons.agriculture_outlined,
                size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'No farms yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first farm to get started',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () async {
                final result = await context.push('/farms/add');
                if (result == true) {
                  _refreshData();
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Add Farm'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFarmsList(List<FarmModel> farms) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return _FarmCard(
            farm: farms[index],
            onDeleted: _refreshData,
            onEdited: _refreshData,
          );
        },
        childCount: farms.length,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  final FarmModel farm;
  final VoidCallback onDeleted;
  final VoidCallback onEdited;

  const _FarmCard({
    required this.farm,
    required this.onDeleted,
    required this.onEdited,
  });

  @override
  Widget build(BuildContext context) {
    // Default image if none provided
    final imageUrl = farm.imageUrl ??
        'https://upload.wikimedia.org/wikipedia/commons/8/84/Male_and_female_chicken_sitting_together.jpg';

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => context.push('/batches', extra: farm),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Farm Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Farm Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.farmName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (farm.location != null)
                      SizedBox(
                        width: 150,
                        child: Text(
                          farm.location!,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (farm.totalBirds != null)
                          _FarmStat(
                            icon: Icons.groups_outlined,
                            value: '${farm.totalBirds}',
                            label: 'Birds',
                          ),
                        const SizedBox(width: 2),
                        if (farm.activeBatches != null)
                          _FarmStat(
                            icon: Icons.egg_outlined,
                            value: '${farm.activeBatches}',
                            label: 'Batches',
                          ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                onSelected: (value) {
                  _handleMenuAction(value, context);
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Edit Farm'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'inventory',
                    child: Row(
                      children: [
                        Icon(Icons.inventory, size: 20),
                        SizedBox(width: 8),
                        Text('View Farm Inventory'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'view_batches',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('View Batches'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline,
                            size: 20, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete Farm',
                            style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context) {
    switch (value) {
      case 'edit':
        _navigateToEdit(context);
        break;
      case 'inventory':
        context.push(AppRoutes.farmsInventory);
        break;
      case 'view_batches':
        context.push(AppRoutes.batches, extra: farm);
        break;
      case 'delete':
        _showDeleteDialog(context);
        break;
    }
  }

  Future<void> _navigateToEdit(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditFarmScreen(farm: farm),
      ),
    );

    if (result == true) {
      onEdited();
    }
  }

  Future<void> _showDeleteDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Farm'),
          content: Text(
            'Are you sure you want to delete "${farm.farmName}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await _deleteFarm(context);
    }
  }

  Future<void> _deleteFarm(BuildContext context) async {
    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      final farmRepository = FarmRepository();
      await farmRepository.deleteFarm(farm.id);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      ToastUtil.showSuccess('Farm "${farm.farmName}" deleted successfully!');
      onDeleted();
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }
      ApiErrorHandler.handle(e);
    }
  }
}

class _FarmStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _FarmStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green.shade600),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}