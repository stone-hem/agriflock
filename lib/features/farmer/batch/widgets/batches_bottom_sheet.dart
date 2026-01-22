import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';

class BatchesBottomSheet extends StatefulWidget {
  final House house;
  final FarmModel farm;
  final VoidCallback onDataChanged;

  const BatchesBottomSheet({
    super.key,
    required this.house,
    required this.farm,
    required this.onDataChanged,
  });

  @override
  State<BatchesBottomSheet> createState() => _BatchesBottomSheetState();
}

class _BatchesBottomSheetState extends State<BatchesBottomSheet> {
  final _repository = BatchHouseRepository();
  late List<BatchModel> _batches;
  bool _isLoading = false;
  bool _showAddButton = true;
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _batches = List.from(widget.house.batches);
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      setState(() {
        _scrollOffset = notification.metrics.pixels;
        // Hide button when scrolled down more than 50 pixels
        _showAddButton = _scrollOffset <= 50;
      });
    }
    return false;
  }

  Future<void> _refreshBatches() async {
    setState(() => _isLoading = true);
    try {
      final result = await _repository.getAllHouses(widget.farm.id);
      switch(result){
        case Success<List<House>>(data: final houses):
          final updatedHouse = houses.firstWhere(
                (h) => h.id == widget.house.id,
            orElse: () => widget.house,
          );
          setState(() {
            _batches = updatedHouse.batches;
          });
          widget.onDataChanged();
        case Failure(message: final error):
          ApiErrorHandler.handle(error);
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markBatchComplete(BatchModel batch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Complete'),
        content: const Text('Are you sure you want to mark this batch as complete?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Mark Complete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await _repository.completeBatch(batch.id, {
          "final_count": 945,
          "total_eggs_produced": 124500,
          "end_date": "2025-12-20",
          "reason": "End of laying cycle"
        });
        ToastUtil.showSuccess('Batch marked as complete');
        await _refreshBatches();
      } catch (e) {
        ApiErrorHandler.handle(e);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteBatch(BatchModel batch) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: const Text('Are you sure you want to delete this batch? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() => _isLoading = true);
        await _repository.deleteBatch(widget.farm.id, batch.id);
        ToastUtil.showSuccess('Batch deleted successfully');
        await _refreshBatches();
      } catch (e) {
        ApiErrorHandler.handle(e);
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _navigateToAddBatch() async {
    final result = await context.push('/batches/add', extra: {
      'farm': widget.farm,
      'house': widget.house,
    });

    if (result == true) {
      await _refreshBatches();
    }
  }

  Future<void> _navigateToEditBatch(BatchModel batch) async {
    final result = await context.push('/batches/edit', extra: {
      'batch': batch,
      'farm': widget.farm,
      'house': widget.house,
    });

    if (result == true) {
      await _refreshBatches();
    }
  }

  Future<void> _navigateToBatchDetails(BatchModel batch) async {
    final result = await context.push('/batches/details', extra: {
      'batch': batch,
      'farm': widget.farm,
    });

    if (result == true) {
      await _refreshBatches();
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            children: [
              // Draggable Handle
              Container(
                margin: const EdgeInsets.only(top: 8),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.warehouse, color: Colors.teal),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'House ${widget.house.houseName}',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${_batches.length} batches • ${widget.house.currentBirds} birds',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Add Batch Button (animated to hide on scroll)
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _showAddButton
                    ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _navigateToAddBatch,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('Add New Batch'),
                    ),
                  ),
                )
                    : const SizedBox.shrink(),
              ),

              SizedBox(height: _showAddButton ? 20 : 0),

              // Divider
              Divider(color: Colors.grey.shade200, thickness: 1),

              // Batches List Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Batches',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_isLoading)
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                  ],
                ),
              ),

              // Batches List
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _batches.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets_outlined,
                        size: 64,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No batches yet',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add your first batch to get started',
                        style: TextStyle(color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                )
                    : NotificationListener<ScrollNotification>(
                  onNotification: _onScrollNotification,
                  child: RefreshIndicator(
                    onRefresh: _refreshBatches,
                    child: ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _batches.length,
                      itemBuilder: (context, index) {
                        final batch = _batches[index];
                        return _BatchCard(
                          batch: batch,
                          onView: () => _navigateToBatchDetails(batch),
                          onEdit: () => _navigateToEditBatch(batch),
                          onComplete: () => _markBatchComplete(batch),
                          onDelete: () => _deleteBatch(batch),
                        );
                      },
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }
}

class _BatchCard extends StatelessWidget {
  final BatchModel batch;
  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onComplete;
  final VoidCallback onDelete;

  const _BatchCard({
    required this.batch,
    required this.onView,
    required this.onEdit,
    required this.onComplete,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.pets,
                    color: Colors.green,
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
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
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
              ],
            ),

            const SizedBox(height: 16),

            // Batch Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: 'Start Date',
                  value: DateUtil.toMMDDYYYY(batch.startDate),
                ),
                _StatItem(
                  label: 'Mortality',
                  value: '${batch.mortality.toStringAsFixed(1)}%',
                ),
                _StatItem(
                  label: 'Weight',
                  value: '${batch.currentWeight}kg',
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Buttons Row
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.visibility, size: 16),
                    label: const Text('View'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onEdit,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.orange,
                      side: BorderSide(color: Colors.orange.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Edit'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onComplete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.check_circle, size: 16),
                    label: Text('Complete'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: onDelete,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    icon: const Icon(Icons.delete, size: 16),
                    label: const Text('Delete'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}