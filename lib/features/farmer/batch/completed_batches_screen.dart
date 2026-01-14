import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/farmer/batch/model/archived_batch_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/archived_batch_repo.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompletedBatchesScreen extends StatefulWidget {
  final FarmModel farm;
  const CompletedBatchesScreen({super.key, required this.farm});

  @override
  State<CompletedBatchesScreen> createState() => _CompletedBatchesScreenState();
}

class _CompletedBatchesScreenState extends State<CompletedBatchesScreen> {
  final _repository = ArchivedBatchRepository();
  List<ArchivedBatchModel> _archivedBatches = [];
  ArchivedBatchPagination? _pagination;
  bool _isLoading = true;
  int _currentPage = 1;
  final int _limit = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData({int page = 1}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await _repository.getArchivedBatches(
        widget.farm.id,
        page: page,
        limit: _limit,
      );

      switch(response){

        case Success<ArchivedBatchesResponse>(data: final res):
          setState(() {
            _archivedBatches = res.batches;
            _pagination = res.pagination;
            _currentPage = page;
            _isLoading = false;
          });
        case Failure<ArchivedBatchesResponse>(message:final error):
          ApiErrorHandler.handle(error);
      }


    } finally  {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_archivedBatches.isEmpty) {
      return _buildEmptyState();
    }

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
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Header
            Text(
              'Archived Batches - ${widget.farm.farmName}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'View and manage your completed batches',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            // Archived batches list
            ..._archivedBatches.map((batch) => _ArchivedBatchCard(
              batch: batch,
              farmId: widget.farm.id,
              onRestore: () => _confirmRestore(batch),
              onDelete: () => _confirmDelete(batch),
            )).toList(),

            // Pagination Controls
            if (_pagination != null && _pagination!.totalPages > 1) ...[
              const SizedBox(height: 24),
              _buildPaginationControls(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous Button
          OutlinedButton.icon(
            onPressed: _currentPage > 1
                ? () => _loadData(page: _currentPage - 1)
                : null,
            icon: const Icon(Icons.arrow_back, size: 18),
            label: const Text('Previous'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: BorderSide(
                color: _currentPage > 1 ? Colors.green.shade300 : Colors.grey.shade300,
              ),
            ),
          ),

          // Page Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Page $_currentPage of ${_pagination!.totalPages}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.green.shade800,
              ),
            ),
          ),

          // Next Button
          OutlinedButton.icon(
            onPressed: _currentPage < _pagination!.totalPages
                ? () => _loadData(page: _currentPage + 1)
                : null,
            icon: const Icon(Icons.arrow_forward, size: 18),
            label: const Text('Next'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: BorderSide(
                color: _currentPage < _pagination!.totalPages
                    ? Colors.green.shade300
                    : Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Archived Batches',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Archived batches will appear here',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _confirmRestore(ArchivedBatchModel batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Batch'),
        content: Text(
          'Are you sure you want to restore "${batch.name}" to active batches?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _restoreBatch(batch);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  Future<void> _restoreBatch(ArchivedBatchModel batch) async {
    try {
      await _repository.restoreBatch(widget.farm.id, batch.id);
      ToastUtil.showSuccess('"${batch.name}" has been restored to active batches');
      _loadData(); // Refresh the list
    } catch (e) {
      ApiErrorHandler.handle(e);
    }
  }

  void _confirmDelete(ArchivedBatchModel batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text(
          'Are you sure you want to permanently delete "${batch.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteBatch(batch);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteBatch(ArchivedBatchModel batch) async {
    try {
      await _repository.deleteArchivedBatch(widget.farm.id, batch.id);
      ToastUtil.showSuccess('"${batch.name}" has been permanently deleted');
      _loadData(); // Refresh the list
    } catch (e) {
      ApiErrorHandler.handle(e);
    }
  }
}

class _ArchivedBatchCard extends StatelessWidget {
  final ArchivedBatchModel batch;
  final String farmId;
  final VoidCallback onRestore;
  final VoidCallback onDelete;

  const _ArchivedBatchCard({
    required this.batch,
    required this.farmId,
    required this.onRestore,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          // Navigate to view archived batch details
          context.push('/batches/archived/details', extra: {
            'batch': batch,
            'farmId': farmId,
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          batch.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        if (batch.houseName != null)
                          Text(
                            batch.houseName!,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      batch.status,
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                batch.breed,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _ArchivedStat(
                    icon: Icons.pets,
                    value: '${batch.totalBirds}',
                    label: 'Total Birds',
                  ),
                  _ArchivedStat(
                    icon: Icons.calendar_today,
                    value: '${batch.totalDays}',
                    label: 'Days',
                  ),
                  _ArchivedStat(
                    icon: Icons.show_chart,
                    value: '${batch.totalDeaths}',
                    label: 'Deaths',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Mortality Rate Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: batch.mortalityRate < 5
                      ? Colors.green.shade50
                      : batch.mortalityRate < 10
                      ? Colors.orange.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: batch.mortalityRate < 5
                        ? Colors.green.shade200
                        : batch.mortalityRate < 10
                        ? Colors.orange.shade200
                        : Colors.red.shade200,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mortality Rate',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      '${batch.mortalityRate.toStringAsFixed(2)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: batch.mortalityRate < 5
                            ? Colors.green.shade800
                            : batch.mortalityRate < 10
                            ? Colors.orange.shade800
                            : Colors.red.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Survival Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green.shade600, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Final Birds Alive: ',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${batch.finalBirdsAlive}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.green.shade800,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Start Date',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${batch.startDate.day}/${batch.startDate.month}/${batch.startDate.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_forward, size: 16, color: Colors.grey.shade400),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'End Date',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${batch.endDate.day}/${batch.endDate.month}/${batch.endDate.year}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onRestore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                        side: BorderSide(color: Colors.green.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Restore'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onDelete,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: BorderSide(color: Colors.red.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Delete'),
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
}

class _ArchivedStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ArchivedStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
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

