import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/utils/refresh_bus.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/utils/toast_util.dart';
import 'package:agriflock/features/farmer/batch/model/batch_list_model.dart' hide House;
import 'package:agriflock/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock/features/farmer/farm/repositories/farm_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickBatchesListScreen extends StatefulWidget {
  const QuickBatchesListScreen({super.key});

  @override
  State<QuickBatchesListScreen> createState() => _QuickBatchesListScreenState();
}

class _QuickBatchesListScreenState extends State<QuickBatchesListScreen> {
  final _batchMgtRepository = BatchMgtRepository();
  final _batchHouseRepository = BatchHouseRepository();

  List<BatchListItem> _batches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
    RefreshBus.instance.addListener(_onRefreshBus);
  }

  void _onRefreshBus() {
    final event = RefreshBus.instance.lastEvent;
    if (event == RefreshEvent.batchCreated || event == RefreshEvent.batchUpdated) {
      if (mounted) _loadBatches();
    }
  }

  @override
  void dispose() {
    RefreshBus.instance.removeListener(_onRefreshBus);
    super.dispose();
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoading = true);

    try {
      final result = await _batchMgtRepository.getBatches(
        currentStatus: 'active',
      );

      switch (result) {
        case Success<BatchListResponse>(data: final response):
          setState(() {
            _batches = response.batches;
            _isLoading = false;
          });
          break;
        case Failure(message: final error):
          setState(() => _isLoading = false);
          ApiErrorHandler.handle(error);
          break;
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ToastUtil.showError('Failed to load batches: $e');
    }
  }

  Future<void> _navigateToAddBatch() async {
    // Step 1: pick a farm
    final farm = await _pickFarm();
    if (farm == null || !mounted) return;

    // Step 2: pick a house within that farm
    final house = await _pickHouse(farm);
    if (house == null || !mounted) return;

    context.push('/batches/add', extra: {'farm': farm, 'house': house});
  }

  Future<FarmModel?> _pickFarm() async {
    List<FarmModel> farms = [];
    bool loading = true;
    bool fetched = false;

    return showModalBottomSheet<FarmModel>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          if (!fetched) {
            fetched = true;
            FarmRepository().getAllFarmsWithStats().then((result) {
              switch (result) {
                case Success<FarmsResponse>(data: final response):
                  setModalState(() {
                    farms = response.farms;
                    loading = false;
                  });
                case Failure():
                  setModalState(() => loading = false);
              }
            });
          }
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (_, controller) => Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select Farm',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : farms.isEmpty
                          ? const Center(child: Text('No farms found'))
                          : ListView.builder(
                              controller: controller,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: farms.length,
                              itemBuilder: (_, i) => ListTile(
                                leading: const Icon(Icons.agriculture,
                                    color: Colors.green),
                                title: Text(farms[i].farmName),
                                subtitle: farms[i].location != null
                                    ? Text(farms[i].location!)
                                    : null,
                                onTap: () => Navigator.pop(ctx, farms[i]),
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<House?> _pickHouse(FarmModel farm) async {
    List<House> houses = [];
    bool loading = true;
    bool fetched = false;

    return showModalBottomSheet<House>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) {
          if (!fetched) {
            fetched = true;
            BatchHouseRepository().getAllHouses(farm.id).then((result) {
              switch (result) {
                case Success<List<House>>(data: final list):
                  setModalState(() {
                    houses = list;
                    loading = false;
                  });
                case Failure():
                  setModalState(() => loading = false);
              }
            });
          }
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.5,
            maxChildSize: 0.85,
            builder: (_, controller) => Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Select House – ${farm.farmName}',
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: loading
                      ? const Center(child: CircularProgressIndicator())
                      : houses.isEmpty
                          ? const Center(
                              child: Text('No houses found for this farm'))
                          : ListView.builder(
                              controller: controller,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: houses.length,
                              itemBuilder: (_, i) => ListTile(
                                leading:
                                    const Icon(Icons.home, color: Colors.teal),
                                title: Text(houses[i].houseName),
                                subtitle: Text(
                                    '${houses[i].currentBirds}/${houses[i].capacity} birds'),
                                onTap: () => Navigator.pop(ctx, houses[i]),
                              ),
                            ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _navigateToEditBatch(BatchListItem batch) async {
    final farmCopy = FarmModel(
      id: batch.farmId,
      farmName: batch.farm?.farmName ?? '',
    );
    final houseCopy = House(
      id: batch.houseId,
      houseName: batch.house?.name ?? '',
      capacity: batch.house?.maximumCapacity ?? 0,
    );
    final batchCopy = BatchModel(
      id: batch.id,
      batchNumber: batch.batchNumber,
      birdTypeId: batch.birdTypeId,
      breed: batch.breed ?? 'Not Provided',
      type: '',
      startDate: DateTime.now(),
      age: batch.ageInDays,
      initialQuantity: batch.initialCount,
      birdsAlive: batch.currentCount,
      currentWeight: batch.currentWeight ?? 0.0,
      expectedWeight: batch.expectedWeight ?? 0.0,
      feedingTime: batch.feedingTime ?? '',
      feedingSchedule: [?batch.feedingSchedule],
    );
    context.push('/batches/edit', extra: {
      'batch': batchCopy,
      'farm': farmCopy,
      'house': houseCopy,
    });
  }

  Future<void> _deleteBatch(BatchListItem batch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Batch'),
        content: const Text(
            'Are you sure you want to delete this batch? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      try {
        final res=await _batchHouseRepository.deleteBatch(batch.id);
        switch(res) {
          case Success<void>():
            ToastUtil.showSuccess('Batch deleted');
            RefreshBus.instance.fire(RefreshEvent.batchUpdated);
            _loadBatches();
          case Failure<void>():
            ToastUtil.showError('Batch not deleted');
        }

      } catch (e) {
        ApiErrorHandler.handle(e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Batches'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _navigateToAddBatch,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.teal,
              visualDensity: VisualDensity.compact,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _batches.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: _loadBatches,
              child: ListView.separated(
                padding: const EdgeInsets.all(20),
                itemCount: _batches.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final batch = _batches[index];
                  return _buildBatchCard(batch);
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No active batches',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no active batches at the moment',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(BatchListItem batch) {
    return GestureDetector(
      onTap: () {
        final FarmModel farmCopy = FarmModel(
          id: batch.farmId,
          farmName: batch.farm!.farmName,
        );
        final BatchModel batchCopy = BatchModel(
          id: batch.id,
          batchNumber: batch.batchNumber,
          birdTypeId: batch.birdTypeId,
          breed: batch.breed ?? 'Not Provided',
          type: '',
          startDate: DateTime.now(),
          age: batch.ageInDays,
          initialQuantity: batch.initialCount,
          birdsAlive: batch.currentCount,
          currentWeight: batch.currentWeight ?? 0.0,
          expectedWeight: batch.expectedWeight ?? 0.0,
          feedingTime: batch.feedingTime ?? '',
          feedingSchedule: [?batch.feedingSchedule],
        );
        context.push(
          '/batches/details',
          extra: {'batch': batchCopy, 'farm': farmCopy},
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.pets, color: Colors.green),
                ),
                const SizedBox(width: 12),
                if (batch.birdType != null)
                Expanded(
                  child: Text(
                    batch.birdType!.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => _navigateToEditBatch(batch),
                  icon: const Icon(Icons.edit, size: 18),
                  color: Colors.orange,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Edit',
                ),
                IconButton(
                  onPressed: () => _deleteBatch(batch),
                  icon: const Icon(Icons.delete, size: 18),
                  color: Colors.red,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Delete',
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                _buildBatchInfo(
                  Icons.pets,
                  '${batch.currentCount} birds',
                  Colors.blue,
                ),
                _buildBatchInfo(
                  Icons.calendar_today,
                  'Day ${batch.ageInDays}',
                  Colors.orange,
                ),
                if (batch.farm != null)
                  _buildBatchInfo(
                    Icons.agriculture,
                    batch.farm!.farmName,
                    Colors.green,
                  ),
                if (batch.house != null)
                  _buildBatchInfo(Icons.home, batch.house!.name, Colors.purple),
              ],
            ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    batch.batchNumber,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBatchInfo(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(text, style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
      ],
    );
  }
}
