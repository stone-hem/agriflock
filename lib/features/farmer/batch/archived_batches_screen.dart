import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/utils/toast_util.dart';
import 'package:agriflock/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ArchivedBatchesScreen extends StatefulWidget {
  final FarmModel farm;
  const ArchivedBatchesScreen({super.key, required this.farm});

  @override
  State<ArchivedBatchesScreen> createState() => _ArchivedBatchesScreenState();
}

class _ArchivedBatchesScreenState extends State<ArchivedBatchesScreen> {
  final _repository = BatchMgtRepository();
  List<BatchListItem> _archivedBatches = [];
  Pagination? _pagination;
  bool _isLoading = true;
  bool _isRestoring = false;
  bool _isDeleting = false;
  int _currentPage = 1;
  final int _limit = 20;
  String? _selectedBatchId;

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
      final response = await _repository.getBatches(
        farmId:widget.farm.id,
        page: page,
        limit: _limit,
        currentStatus: 'archived',
      );

      switch(response) {
        case Success<BatchListResponse>(data: final response):
          setState(() {
            _archivedBatches = response.batches;
            _pagination = response.pagination;
            _currentPage = page;
            _isLoading = false;
          });
        case Failure<BatchListResponse>(message: final message):
          ApiErrorHandler.handle(message);
          setState(() {
            _isLoading = false;
          });
      }

    } catch (e) {
      ApiErrorHandler.handle(e);
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _restoreBatch(String batchId) async {
    setState(() {
      _isRestoring = true;
      _selectedBatchId = batchId;
    });

    try {
      final result = await _repository.deleteArchivedBatch(
        widget.farm.id,
        batchId,
      );

      switch(result) {
        case Success<void>():
          ToastUtil.showSuccess('Batch restored successfully');
          _loadData(); // Refresh the list
        case Failure<void>():
          ApiErrorHandler.handle('Failed to restore batch');
      }

    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      setState(() {
        _isRestoring = false;
        _selectedBatchId = null;
      });
    }
  }

  Future<void> _deleteBatch(String batchId) async {
    setState(() {
      _isDeleting = true;
      _selectedBatchId = batchId;
    });

    try {
      final result = await _repository.deleteArchivedBatch(widget.farm.id, batchId);

      switch(result) {
        case Success<void>():
          ToastUtil.showSuccess('Batch deleted successfully');
          _loadData(); // Refresh the list
          case Failure<void>():
          ApiErrorHandler.handle('Failed to delete batch');
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      setState(() {
        _isDeleting = false;
        _selectedBatchId = null;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Batches'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => _loadData(page: 1),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Header
            _buildHeader(),
            const SizedBox(height: 16),

            // Loading Indicator
            if (_isLoading) _buildLoadingIndicator(),

            // Empty State
            if (!_isLoading && _archivedBatches.isEmpty)
              _buildEmptyState(),

            // Archived Batches List
            if (_archivedBatches.isNotEmpty)
              ..._archivedBatches.map((batch) => _buildBatchCard(batch)),

            // Pagination Controls
            if (_archivedBatches.isNotEmpty && _pagination != null)
              _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Archived Batches',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Farm: ${widget.farm.farmName}',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.shade100),
          ),
          child: Text(
            'Archived batches are hidden from the main view but can be restored or deleted.',
            style: TextStyle(
              color: Colors.orange.shade800,
              fontSize: 13,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Archived Batches',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Archived batches will appear here when you archive them.',
            style: TextStyle(color: Colors.grey.shade500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(BatchListItem batch) {
    final isRestoring = _isRestoring && _selectedBatchId == batch.id;
    final isDeleting = _isDeleting && _selectedBatchId == batch.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with batch name and status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        batch.batchNumber,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (batch.birdType != null)
                        Text(
                          batch.birdType!.name,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Text(
                    'Archived',
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

            // Batch Details
            _buildDetailRow('Total Birds', '${batch.initialCount}'),
            _buildDetailRow('Current Count', '${batch.currentCount}'),
            _buildDetailRow('Mortality', '${batch.totalMortality}'),
            _buildDetailRow('Mortality Rate', '${batch.mortalityRate.toStringAsFixed(2)}%'),
            _buildDetailRow('Age', '${batch.ageInDays} days'),

            _buildDetailRow(
              'Archived on',
              '${batch.updatedAt.day}/${batch.updatedAt.month}/${batch.updatedAt.year}',
            ),

            const SizedBox(height: 16),

            // Status Info
            if (batch.currentStatus == 'completed')
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade100),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: Colors.green.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This batch was completed before being archived',
                        style: TextStyle(
                          color: Colors.green.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 16),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isRestoring ? null : () => _confirmRestore(batch),
                    icon: isRestoring
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.restore, size: 18),
                    label: Text(isRestoring ? 'Restoring...' : 'Restore'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isDeleting ? null : () => _confirmDelete(batch),
                    icon: isDeleting
                        ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                        : const Icon(Icons.delete_forever, size: 18),
                    label: Text(isDeleting ? 'Deleting...' : 'Delete'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),


          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Previous Button
            IconButton(
              onPressed: _currentPage > 1
                  ? () => _loadData(page: _currentPage - 1)
                  : null,
              icon: const Icon(Icons.chevron_left),
              color: _currentPage > 1 ? Colors.orange : Colors.grey.shade400,
            ),

            // Page Info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                'Page $_currentPage of ${_pagination!.totalPages}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Next Button
            IconButton(
              onPressed: _currentPage < _pagination!.totalPages
                  ? () => _loadData(page: _currentPage + 1)
                  : null,
              icon: const Icon(Icons.chevron_right),
              color: _currentPage < _pagination!.totalPages
                  ? Colors.orange
                  : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  void _confirmRestore(BatchListItem batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restore Batch'),
        content: Text(
          'Are you sure you want to restore "${batch.batchNumber}" to active batches?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _restoreBatch(batch.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BatchListItem batch) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Batch'),
        content: Text(
          'Are you sure you want to permanently delete "${batch.batchNumber}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBatch(batch.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

}