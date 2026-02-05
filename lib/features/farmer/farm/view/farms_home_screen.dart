import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock360/features/farmer/batch/widgets/add_edit_house_dialog.dart';
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
  bool _isLoading = false;
  bool _hasError = false;
  String? _errorMessage;

  FarmsResponse? _farmsResponse;

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

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final result = await _farmRepository.getAllFarmsWithStats();

      switch (result) {
        case Success<FarmsResponse>(data: final data):
          setState(() {
            _farmsResponse = data;
            _isLoading = false;
          });
          break;
        case Failure(message: final error, :final statusCode, :final response):
          setState(() {
            _hasError = true;
            _errorMessage = error;
            _isLoading = false;
          });
          // Optionally handle the error using ApiErrorHandler
          // ApiErrorHandler.handle(error);
          break;
      }
    } finally {
      // Ensure loading state is reset even if there's an unexpected error
      if (_isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _refreshData() {
    _loadData();
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
      bottomNavigationBar: const ExpenseMarqueeBannerCompact(),
      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
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
        label: Row(
      children: [
      Text('Add Farm'),
      const Icon(Icons.add),
      ],
    ),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: () async {
          await _loadData();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          child: CustomScrollView(
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
                    _buildChipsSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
              _buildFarmsListSection(),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildChipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push(AppRoutes.farmsInventory);
                  },
                  icon: const Icon(Icons.agriculture, size: 18),
                  label: const Text('View My inventory'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }




  Widget _buildFarmsListSection() {
    if (_isLoading) {
      return _buildLoadingList();
    }

    if (_hasError) {
      return _buildErrorList(_errorMessage ?? 'An error occurred');
    }

    if (_farmsResponse == null || _farmsResponse!.farms.isEmpty) {
      return _buildEmptyList();
    }

    return _buildFarmsList(_farmsResponse!.farms);
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
              error.length > 100 ? '${error.substring(0, 100)}...' : error,
              style: TextStyle(color: Colors.grey.shade600),
              textAlign: TextAlign.center,
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
                height: 100,
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
                    const SizedBox(height: 2),
                    if (farm.description != null)
                      SizedBox(
                        width: 150,
                        child: Text(
                          farm.description!,
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
                        if (farm.batchCount != null)
                          _FarmStat(
                            icon: Icons.egg_outlined,
                            value: '${farm.batchCount}',
                            label: 'Batches',
                          ),
                      ],
                    ),

                    // Instead of the ElevatedButton.icon, use this:
                    FilledButton.icon(
                      onPressed: () {
                        AddEditHouseDialog.show(
                          context: context,
                          farm: farm,
                          onSuccess: onEdited,
                        );
                      },
                      icon: Icon(Icons.add_home, size: 18),

                      label: Text('Add House'),
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
                    value: 'view_batches',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('View Houses'),
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
      final result = await FarmRepository().deleteFarm(farm.id);

      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      switch (result) {
        case Success<void>():
          ToastUtil.showSuccess('Farm "${farm.farmName}" deleted successfully!');
          onDeleted();
          break;
        case Failure(message: final error, :final statusCode, :final response):
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to delete: $error')),
            );
          }
          break;
      }
    } catch (e) {
      // Close loading dialog
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Handle unexpected errors
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unexpected error: $e')),
        );
      }
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