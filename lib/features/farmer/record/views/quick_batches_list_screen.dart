import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickBatchesListScreen extends StatefulWidget {
  const QuickBatchesListScreen({super.key});

  @override
  State<QuickBatchesListScreen> createState() => _QuickBatchesListScreenState();
}

class _QuickBatchesListScreenState extends State<QuickBatchesListScreen> {
  final _batchMgtRepository = BatchMgtRepository();

  List<BatchListItem> _batches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadBatches();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Batches'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
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
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no active batches at the moment',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchCard(BatchListItem batch) {
    return GestureDetector(
      onTap: () {
        context.push('/batches/details', extra: {
          'batch': batch,
          'farm': batch.farm,
        });
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
                Expanded(
                  child: Text(
                    batch.batchName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
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
                  _buildBatchInfo(
                    Icons.home,
                    batch.house!.name,
                    Colors.purple,
                  ),
              ],
            ),
            if (batch.birdType != null)
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
                    batch.birdType!.name,
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
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
