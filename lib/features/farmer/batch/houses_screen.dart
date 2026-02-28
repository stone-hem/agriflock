import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/utils/date_util.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/utils/toast_util.dart';
import 'package:agriflock/core/widgets/expense/expense_marquee_banner.dart';
import 'package:agriflock/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock/features/farmer/batch/widgets/add_edit_house_dialog.dart';
import 'package:agriflock/features/farmer/batch/widgets/batches_bottom_sheet.dart';
import 'package:agriflock/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';

class HousesScreen extends StatefulWidget {
  final FarmModel farm;
  const HousesScreen({super.key, required this.farm});

  @override
  State<HousesScreen> createState() => _HousesScreenState();
}

class _HousesScreenState extends State<HousesScreen> {
  final _repository = BatchHouseRepository();
  List<House> _houses = [];
  bool _isLoading = true;
  final ScrollController _scrollController = ScrollController();
  bool _showFab = true;

  @override
  void initState() {
    super.initState();
    _loadData();

    // Listen to scroll to hide/show FAB
    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection == ScrollDirection.forward) {
        if (!_showFab) {
          setState(() => _showFab = true);
        }
      } else if (_scrollController.position.userScrollDirection == ScrollDirection.reverse) {
        if (_showFab) {
          setState(() => _showFab = false);
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _repository.getAllHouses(widget.farm.id);

      switch(result){
        case Success<List<House>>(data: final houses):
          setState(() {
            _houses = houses;
          });
        case Failure(message: final error):
          ApiErrorHandler.handle(error);
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showAddHouseDialog(BuildContext context) {
    AddEditHouseDialog.show(
      context: context,
      farm: widget.farm,
      onSuccess: _loadData,
    );
  }

  void _showEditHouseDialog(BuildContext context, House house) {
    AddEditHouseDialog.show(
      context: context,
      farm: widget.farm,
      house: house,
      onSuccess: _loadData,
    );
  }

  void _confirmDeleteHouse(BuildContext context, House house) {
    if (house.batches.isNotEmpty) {
      ToastUtil.showError('Cannot delete house with active batches');
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete House'),
        content: Text('Are you sure you want to delete "${house.houseName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await _repository.deleteHouse(widget.farm.id, house.id!);
                ToastUtil.showSuccess('House deleted successfully');
                _loadData();
              } catch (e) {
                ApiErrorHandler.handle(e);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showBatchesBottomSheet(BuildContext context, House house) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BatchesBottomSheet(
        house: house,
        farm: widget.farm,
        onDataChanged: _loadData,
      ),
    );
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
      ),
      bottomNavigationBar: const ExpenseMarqueeBannerCompact(),
      floatingActionButton: _showFab
          ? FloatingActionButton.extended(
        onPressed: () => _showAddHouseDialog(context),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
        elevation: 4,
        icon: const Icon(Icons.add),
        label: const Text('Add House'),
      )
          : null,
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                '${widget.farm.farmName} Houses',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              widget.farm.location ?? widget.farm.description ?? 'Manage your poultry houses and batches',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            _buildChipsSection(),
            const SizedBox(height: 18),
            // Loading State
            if (_isLoading)
              Container(
                height: 200,
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              )

            // Empty State
            else if (_houses.isEmpty)
              Container(
                padding: const EdgeInsets.all(40),
                margin: const EdgeInsets.only(top: 40),
                child: Column(
                  children: [
                    Icon(Icons.warehouse_outlined, size: 80, color: Colors.grey.shade300),
                    const SizedBox(height: 20),
                    Text(
                      'No Houses Yet',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Add your first house to start managing batches',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey.shade500),
                    ),
                  ],
                ),
              )

            // Houses List (full width cards)
            else
              Column(
                children: _houses.map((house) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _HouseCard(
                      house: house,
                      onViewBatches: () => _showBatchesBottomSheet(context, house),
                      onEdit: () => _showEditHouseDialog(context, house),
                      onDelete: () => _confirmDeleteHouse(context, house),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 80), // Extra space for FAB
          ],
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
                    context.push('/batches/my-completed-batches',extra: widget.farm);
                  },
                  icon: const Icon(Icons.agriculture, size: 18),
                  label: const Text('My Completed/Removed Batches'),
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


}

class _HouseCard extends StatelessWidget {
  final House house;
  final VoidCallback onViewBatches;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _HouseCard({
    required this.house,
    required this.onViewBatches,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // House Header
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.warehouse,
                    color: Colors.teal,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'House ${house.houseName}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${house.batches.length} batch${house.batches.length != 1 ? 'es' : ''}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                // Utilization indicator - Simplified
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getUtilizationColor(house.utilization).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${house.utilization.toStringAsFixed(0)}%',
                    style: TextStyle(
                      color: _getUtilizationColor(house.utilization),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // House Stats Grid - Reorganized to prevent overflow
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  // Top row - Main capacity stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CompactStatItem(
                        icon: Icons.pets,
                        label: 'Max Capacity',
                        value: '${house.capacity}',
                        unit: 'birds',
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _CompactStatItem(
                        icon: Icons.group,
                        label: 'Current',
                        value: '${house.currentBirds}',
                        unit: 'birds',
                      ),
                      Container(
                        height: 30,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _CompactStatItem(
                        icon: Icons.trending_up,
                        label: 'Remaining',
                        value: '${house.capacity - house.currentBirds}',
                        unit: 'birds',
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Additional info row - Expandable for future details
                  _AdditionalInfoRow(house: house),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Buttons - Fixed to single line with flexible text
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: BorderSide(color: Colors.blue.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Edit',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.delete, size: 20),
                        SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            'Delete',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: onViewBatches,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.agriculture, size: 20),
                  SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'View / Add batch',
                      style: TextStyle(fontWeight: FontWeight.w500),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Color _getUtilizationColor(double utilization) {
    if (utilization > 80) return Colors.red;
    if (utilization > 50) return Colors.orange;
    return Colors.green;
  }
}

class _CompactStatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;

  const _CompactStatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 14, color: Colors.teal),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Text(
            unit,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _AdditionalInfoRow extends StatelessWidget {
  final House house;

  const _AdditionalInfoRow({required this.house});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Add your additional details here
        // Example placeholder:
        if(house.updatedAt!=null)
        _InfoChip(
          icon: Icons.date_range,
          text: DateUtil.toShortDateWithDay(house.updatedAt!),
        ),
        if(house.createdAt!=null)
        _InfoChip(
          icon: Icons.date_range,
          text: DateUtil.toShortDateWithDay(house.createdAt!),
        ),
        // Add more chips as needed
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

