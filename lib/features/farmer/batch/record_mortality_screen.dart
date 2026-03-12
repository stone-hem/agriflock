import 'package:agriflock/core/utils/api_error_handler.dart';
import 'package:agriflock/core/utils/refresh_bus.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/utils/toast_util.dart';
import 'package:agriflock/core/widgets/reusable_dropdown.dart';
import 'package:agriflock/core/widgets/reusable_input.dart';
import 'package:agriflock/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock/features/farmer/batch/repo/batch_mgt_repo.dart';
import 'package:agriflock/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RecordMortalityScreen extends StatefulWidget {
  final FarmModel? farm;
  final BatchListItem? batch;

  const RecordMortalityScreen({
    super.key,
    this.farm,
    this.batch,
  });

  @override
  State<RecordMortalityScreen> createState() => _RecordMortalityScreenState();
}

class _RecordMortalityScreenState extends State<RecordMortalityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _batchMgtRepository = BatchMgtRepository();

  final TextEditingController _countController = TextEditingController();
  final TextEditingController _otherReasonController = TextEditingController();

  List<BatchListItem> _batches = [];
  BatchListItem? _selectedBatch;
  bool _isLoadingBatches = true;
  bool _isSubmitting = false;

  // Multi-select reasons
  final Set<String> _selectedReasons = {};

  static const List<String> _mortalityReasons = [
    'Temperature (heat/cold)',
    'Wet litter',
    'Overcrowding',
    'Disease related e.g. Coccidiosis, NCD etc.',
    'Predator attack e.g. snake etc.',
    'Cannibalism',
    'Sudden death',
    'Starvation / lack of feed',
    'Poor quality feed',
    'Lack of water',
    'Aflatoxin poisoning',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.batch != null) {
      _selectedBatch = widget.batch;
      _isLoadingBatches = false;
    } else {
      _loadBatches();
    }
  }

  Future<void> _loadBatches() async {
    setState(() => _isLoadingBatches = true);
    try {
      final result = await _batchMgtRepository.getBatches(
        farmId: widget.farm?.id,
        currentStatus: 'active',
      );
      switch (result) {
        case Success<BatchListResponse>(data: final response):
          setState(() {
            _batches = response.batches;
            _isLoadingBatches = false;
          });
        case Failure(message: final error):
          setState(() => _isLoadingBatches = false);
          ApiErrorHandler.handle(error);
      }
    } catch (e) {
      setState(() => _isLoadingBatches = false);
      ToastUtil.showError('Failed to load batches: $e');
    }
  }

  Future<void> _submitMortality() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBatch == null) {
      ToastUtil.showError('Please select a batch');
      return;
    }

    if (_selectedReasons.isEmpty) {
      ToastUtil.showError('Please select at least one reason');
      return;
    }

    // Build the reasons list — replace 'Other' with the custom text
    final List<String> reasons = _selectedReasons.map((r) {
      if (r == 'Other') {
        final custom = _otherReasonController.text.trim();
        return custom.isNotEmpty ? custom : 'Other';
      }
      return r;
    }).toList();

    if (_selectedReasons.contains('Other') &&
        _otherReasonController.text.trim().isEmpty) {
      ToastUtil.showError('Please specify the "Other" reason');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final result = await _batchMgtRepository.recordMortality(
        batchId: _selectedBatch!.id,
        changeAmount: int.parse(_countController.text),
        reasons: reasons,
      );

      switch (result) {
        case Success():
          ToastUtil.showSuccess('Mortality recorded successfully');
          RefreshBus.instance.fire(RefreshEvent.recordCreated);
          if (mounted) context.pop(true);
        case Failure(message: final error):
          ApiErrorHandler.handle(error);
      }
    } catch (e) {
      ToastUtil.showError('Failed to record mortality: $e');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Mortality'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Mortality info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.red.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.warning_amber_rounded,
                          color: Colors.red.shade700, size: 24),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Record Bird Mortality',
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red.shade700)),
                          const SizedBox(height: 4),
                          Text(
                              'Track bird losses to maintain accurate flock records',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.red.shade600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),



              // Batch Selection
              if (widget.batch == null) ...[
                Text('Select Batch',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700)),
                const SizedBox(height: 8),
                if (_isLoadingBatches)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Row(
                      children: [
                        const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2)),
                        const SizedBox(width: 12),
                        Text('Loading batches...',
                            style:
                                TextStyle(color: Colors.grey.shade600)),
                      ],
                    ),
                  )
                else if (_batches.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200)),
                    child: Text('No active batches found',
                        style: TextStyle(color: Colors.orange.shade700)),
                  )
                else
                  ReusableDropdown<BatchListItem>(
                    value: _selectedBatch,
                    hintText: 'Choose a batch',
                    icon: Icons.pets,
                    items: _batches.map((batch) {
                      return DropdownMenuItem<BatchListItem>(
                        value: batch,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(batch.batchNumber,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600)),
                            Text(
                                '${batch.currentCount} birds | ${batch.ageInDays} days old',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) =>
                        setState(() => _selectedBatch = value),
                    validator: (value) =>
                        value == null ? 'Please select a batch' : null,
                  ),
                const SizedBox(height: 20),
              ] else ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200)),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            shape: BoxShape.circle),
                        child: Icon(Icons.pets,
                            color: Colors.orange.shade700, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.batch!.batchNumber,
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '${widget.batch!.currentCount} birds | ${widget.batch!.ageInDays} days old',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Mortality Count
              ReusableInput(
                topLabel: 'Number of Deaths *',
                icon: Icons.numbers,
                controller: _countController,
                hintText: 'Enter number of birds',
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of deaths';
                  }
                  final count = int.tryParse(value);
                  if (count == null || count <= 0) {
                    return 'Please enter a valid number';
                  }
                  if (_selectedBatch != null &&
                      count > _selectedBatch!.currentCount) {
                    return 'Cannot exceed current bird count (${_selectedBatch!.currentCount})';
                  }
                  return null;
                },
              ),
              if (_selectedBatch != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4, left: 4),
                  child: Text(
                    'Current flock size: ${_selectedBatch!.currentCount} birds',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              const SizedBox(height: 24),

              // Reasons — multi-select checkboxes
              Text('Reason(s) for Mortality *',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade700)),
              const SizedBox(height: 4),
              Text('Select all that apply',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: _mortalityReasons.map((reason) {
                    final isLast =
                        reason == _mortalityReasons.last;
                    return Column(
                      children: [
                        CheckboxListTile(
                          value: _selectedReasons.contains(reason),
                          onChanged: (checked) {
                            setState(() {
                              if (checked == true) {
                                _selectedReasons.add(reason);
                              } else {
                                _selectedReasons.remove(reason);
                              }
                            });
                          },
                          title: Text(reason,
                              style: const TextStyle(fontSize: 14)),
                          controlAffinity:
                              ListTileControlAffinity.leading,
                          activeColor: Colors.red.shade600,
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 0),
                          dense: true,
                        ),
                        if (!isLast)
                          Divider(
                              height: 1,
                              indent: 12,
                              endIndent: 12,
                              color: Colors.grey.shade100),
                      ],
                    );
                  }).toList(),
                ),
              ),

              // Custom "Other" input
              if (_selectedReasons.contains('Other')) ...[
                const SizedBox(height: 16),
                ReusableInput(
                  topLabel: 'Specify "Other" reason *',
                  icon: Icons.edit_note,
                  controller: _otherReasonController,
                  hintText: 'Enter specific reason',
                  maxLines: 2,
                  validator: (value) {
                    if (_selectedReasons.contains('Other') &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please specify the reason';
                    }
                    return null;
                  },
                ),
              ],

              const SizedBox(height: 32),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitMortality,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white))
                      : const Text('Record Mortality',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Text('Cancel',
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey.shade600)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _countController.dispose();
    _otherReasonController.dispose();
    super.dispose();
  }
}
