import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActiveBatchesTab extends StatefulWidget {
  final FarmModel farm;
  const ActiveBatchesTab({super.key, required this.farm});

  @override
  State<ActiveBatchesTab> createState() => _ActiveBatchesTabState();
}

class _ActiveBatchesTabState extends State<ActiveBatchesTab> {
  final Map<String, bool> _expandedHouses = {};
  final _repository = BatchHouseRepository();

  List<House> _houses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
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
            _isLoading = false;
          });;
        case Failure(message: final error):
          ApiErrorHandler.handle(error);
          return;
      }

    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Header
          Text(
            '${widget.farm.farmName} Batches & Houses',
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            widget.farm.location ?? widget.farm.description ?? 'Track and monitor all your poultry batches',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 18),

          // Action Grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.1,
            children: [
              _ActionCard(
                icon: Icons.group_add,
                title: 'Add New Batch',
                subtitle: 'Start a new batch',
                color: Colors.green,
                onTap: () => _navigateToAddBatch(),
              ),
              _ActionCard(
                icon: Icons.warehouse,
                title: 'Add New House',
                subtitle: 'Create new house',
                color: Colors.teal,
                onTap: () => _showAddHouseDialog(context),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Houses Section
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade100,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Houses Header
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Houses & Batches',
                        style: Theme.of(context).textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(Icons.warehouse, color: Colors.green.shade700, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '${_getAllBatches().length} Active',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Houses List
                if (_isLoading)
                  const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (_houses.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.warehouse_outlined, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No houses yet',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first house to start managing batches',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                else
                  _buildHousesList(),
                const SizedBox(height: 20),
              ],
            ),
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHousesList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _houses.length,
      itemBuilder: (context, index) {
        final house = _houses[index];
        return _HouseCard(
          house: house,
          farmId: widget.farm.id,
          isExpanded: _expandedHouses[house.id] ?? false,
          onExpand: () {
            setState(() {
              _expandedHouses[house.id!] = !(_expandedHouses[house.id] ?? false);
            });
          },
          onEdit: () => _showEditHouseDialog(context, house),
          onDelete: () => _confirmDeleteHouse(context, house),
          onRefresh: _loadData,
        );
      },
    );
  }

  List<BatchModel> _getAllBatches() {
    final List<BatchModel> allBatches = [];
    for (var house in _houses) {
      allBatches.addAll(house.batches);
    }
    return allBatches;
  }

  void _navigateToAddBatch() async {
    final result = await context.push('/batches/add', extra: {
      'farmId': widget.farm.id,
      'houses': _houses,
    });

    if (result == true) {
      _loadData();
    }
  }

  void _showAddHouseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => _AddEditHouseDialog(
        farmId: widget.farm.id,
        onSuccess: _loadData,
      ),
    );
  }

  void _showEditHouseDialog(BuildContext context, House house) {
    showDialog(
      context: context,
      builder: (context) => _AddEditHouseDialog(
        farmId: widget.farm.id,
        house: house,
        onSuccess: _loadData,
      ),
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
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: FittedBox(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 24, color: color),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HouseCard extends StatelessWidget {
  final House house;
  final String farmId;
  final bool isExpanded;
  final VoidCallback onExpand;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onRefresh;

  const _HouseCard({
    required this.house,
    required this.farmId,
    required this.isExpanded,
    required this.onExpand,
    required this.onEdit,
    required this.onDelete,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // House Header
          ListTile(
            title: Text(
              house.houseName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Capacity: ${house.capacity} birds • Current: ${house.currentBirds} birds',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${house.batches.length} batch${house.batches.length == 1 ? '' : 'es'}',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: house.utilization / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    house.utilization > 80
                        ? Colors.red
                        : house.utilization > 50
                        ? Colors.orange
                        : Colors.green,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 4),
                Text(
                  '${house.utilization.toStringAsFixed(1)}% utilized',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                  onSelected: (value) {
                    if (value == 'edit') {
                      onEdit();
                    } else if (value == 'delete') {
                      onDelete();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 18),
                          SizedBox(width: 8),
                          Text('Edit House'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 18, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete House', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: onExpand,
                ),
              ],
            ),
          ),

          // Expandable Content
          if (isExpanded) ...[
            Divider(color: Colors.grey.shade200, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (house.batches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_off,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No batches in this house',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () async {
                              final result = await context.push('/batches/add', extra: {
                                'farmId': farmId,
                                'houseId': house.id,
                              });
                              if (result == true) onRefresh();
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: BorderSide(color: Colors.green.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Batch to this House'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...house.batches
                        .map((batch) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MiniBatchCard(
                        batch: batch,
                        farmId: farmId,
                        onRefresh: onRefresh,
                      ),
                    ))
                        .toList(),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final result = await context.push('/batches/add', extra: {
                              'farmId': farmId,
                              'houseId': house.id,
                            });
                            if (result == true) onRefresh();
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: BorderSide(color: Colors.green.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Batch'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniBatchCard extends StatelessWidget {
  final BatchModel batch;
  final String farmId;
  final VoidCallback onRefresh;

  const _MiniBatchCard({
    required this.batch,
    required this.farmId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: InkWell(
        onTap: () async {
          final result = await context.push('/batches/details', extra: {
            'batch': batch,
            'farmId': farmId,
          });
          if (result == true) onRefresh();
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.pets,
                  color: Colors.green.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      batch.batchName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${batch.breed} • ${batch.birdsAlive} birds • ${batch.age} days',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: Colors.grey.shade400),
            ],
          ),
        ),
      ),
    );
  }
}

// Add/Edit House Dialog
class _AddEditHouseDialog extends StatefulWidget {
  final String farmId;
  final House? house;
  final VoidCallback onSuccess;

  const _AddEditHouseDialog({
    required this.farmId,
    this.house,
    required this.onSuccess,
  });

  @override
  State<_AddEditHouseDialog> createState() => _AddEditHouseDialogState();
}

class _AddEditHouseDialogState extends State<_AddEditHouseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _capacityController;
  late TextEditingController _descriptionController;
  final _repository = BatchHouseRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.house?.houseName ?? '');
    _capacityController = TextEditingController(text: widget.house?.capacity.toString() ?? '');
    _descriptionController = TextEditingController(text: widget.house?.description ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.house == null ? 'Add New House' : 'Edit House'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'House Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter house name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _capacityController,
                decoration: InputDecoration(
                  labelText: 'Capacity',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixText: 'birds',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter capacity';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _saveHouse,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(widget.house == null ? 'Add House' : 'Update'),
        ),
      ],
    );
  }

  Future<void> _saveHouse() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final houseData = {
        'name': _nameController.text.trim(),
        'capacity': int.parse(_capacityController.text.trim()),
        'description': _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      };

      if (widget.house == null) {
        await _repository.createHouse(widget.farmId, houseData);
        ToastUtil.showSuccess('House created successfully');
      } else {
        await _repository.updateHouse(widget.farmId, widget.house!.id!, houseData);
        ToastUtil.showSuccess('House updated successfully');
      }

      if (context.mounted) {
        Navigator.pop(context);
        widget.onSuccess();
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}