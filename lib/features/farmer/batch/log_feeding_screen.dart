import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/feeding_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/feeding_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LogFeedingScreen extends StatefulWidget {
  final String batchId;

  const LogFeedingScreen({super.key, required this.batchId});

  @override
  State<LogFeedingScreen> createState() => _LogFeedingScreenState();
}

class _LogFeedingScreenState extends State<LogFeedingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _feedingRepository = FeedingRepository();

  // Controllers
  final _quantityController = TextEditingController();
  final _costController = TextEditingController();
  final _supplierController = TextEditingController();
  final _notesController = TextEditingController();
  final _birdsAliveBeforeController = TextEditingController();
  final _mortalityTodayController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _expectedWeightController = TextEditingController();
  final _selectedDateController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();


  // State
  FeedingRecommendationsResponse? _recommendations;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  DateTime _selectedFeedingDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final res = await _feedingRepository.getFeedingRecommendations(widget.batchId);

      switch(res) {
        case Success<FeedingRecommendationsResponse>(data: final data):
          setState(() {
            _recommendations = data;
            _isLoading = false;
          });
        case Failure<FeedingRecommendationsResponse>(message: final e):
          setState(() {
            _error = e.toString();
          });
      }


    } finally  {
      setState(() {
        _isLoading = false;
      });
    }
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
            const Text('Log Feeding'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _logFeeding,
            child: _isSaving
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text(
              'Save Log',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRecommendations,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBatchInfoCard(),
              const SizedBox(height: 24),
              _buildFeedingTimesCard(),
              const SizedBox(height: 24),
              _buildFeedingInformationSection(),
              const SizedBox(height: 32),
              _buildBirdsInformationSection(),
              const SizedBox(height: 32),
              _buildSummaryCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBatchInfoCard() {
    final batchInfo = _recommendations!.batchInfo;
    final currentRec = _recommendations!.currentRecommendation;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.pets, color: Colors.green.shade600),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Batch Info',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '${batchInfo.birdType} • ${batchInfo.currentCount} birds • ${batchInfo.ageDays} days old',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current Stage: ${currentRec.stageName}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.green.shade800,
                    ),
                  ),
                  Text(
                    'Recommended: ${currentRec.feedType} (${currentRec.proteinPercentage}% CP)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedingTimesCard() {
    final feedingTimes = _recommendations!.currentRecommendation.feedingTimes.slots;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recommended Feeding Times:',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: feedingTimes
                .map((time) => Chip(
              label: Text(
                time,
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.blue,
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingInformationSection() {
    final currentRec = _recommendations!.currentRecommendation;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Feeding Information',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),

        // Feeding Time
        Text(
          'Feeding Time',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        // Date & Time

        CustomDateTextField(
          label: 'Date & Time',
          hintText: 'Select date',
          icon: Icons.calendar_today,
          required: true,
          minYear: DateTime.now().year - 1,
          returnFormat: DateReturnFormat.dateTime,
          initialDate: DateTime.now(),
          maxYear: DateTime.now().year,
          controller: _selectedDateController,
          onChanged: (value) {
            if (value != null) {
              _selectedFeedingDate = value;
            }
          },
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _selectTime,
          child: _dateTimeTile(
            icon: Icons.access_time,
            label: 'Time',
            value: _selectedTime.format(context),
          ),
        ),

        const SizedBox(height: 20),

        ReusableInput(
          controller: _quantityController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          hintText: 'Recommended: ${currentRec.dailyFeedRequiredKg?.toStringAsFixed(2) ?? "N/A"} kg',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter feed quantity';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          }, labelText: 'Quantity in Kgs',
        ),
        const SizedBox(height: 20),

        ReusableInput(
          controller: _costController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          hintText: 'e.g., 2.50',
          labelText: 'Feed Cost per kg',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter feed cost';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),

        ReusableInput(
          controller: _supplierController,
          hintText: 'e.g., Agrimart Ltd. (Optional)',
          labelText: 'Feed Supplier(Optional)',
        ),
        const SizedBox(height: 20),
        ReusableInput(
          labelText: 'Notes (Optional)',
          controller: _notesController,
          maxLines: 3,
          hintText: 'Any observations or special notes...',
        ),
      ],
    );
  }

  Widget _buildBirdsInformationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Birds Information (Optional)',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 16),

        ReusableInput(
          controller: _birdsAliveBeforeController,
          keyboardType: TextInputType.number,
          hintText: 'Current: ${_recommendations!.batchInfo.currentCount}',
          labelText: 'Birds Alive Before Feeding',
        ),
        const SizedBox(height: 20),

        ReusableInput(
          controller: _mortalityTodayController,
          keyboardType: TextInputType.number,
          labelText: 'Mortality Today',
          hintText: 'e.g., 0',
        ),
        const SizedBox(height: 20),

        // Current Total Weight
        ReusableInput(
          controller: _currentWeightController,
          keyboardType: const TextInputType.numberWithOptions(
            decimal: true,
            signed: false,
          ),
          hintText: 'e.g., 310',
          labelText: 'Current Average Weight (kg)',
        ),
        const SizedBox(height: 20),
        // ReusableInput(
        //   controller: _expectedWeightController,
        //   keyboardType: TextInputType.number,
        //   hintText: 'e.g., 330',
        //   labelText: 'Expected Weight (kg)',
        // ),
      ],
    );
  }

  Widget _dateTimeTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Feeding Log Information',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This log will help you:\n'
                  '• Track feed consumption\n'
                  '• Monitor bird health and mortality\n'
                  '• Calculate feed conversion ratio\n'
                  '• Generate performance reports\n'
                  '• Plan future feeding schedules',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _logFeeding() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      DateTime _selectedFeedingTime=DateTime(
        _selectedFeedingDate.year,
        _selectedFeedingDate.month,
        _selectedFeedingDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      try {
        final request= {
          'feed_type': 'somthing',
          'quantity': double.parse(_quantityController.text),
          'cost': double.parse(_costController.text),
          'supplier': _supplierController.text,
          'fed_at': _selectedFeedingTime.toIso8601String(),
          'notes': _notesController.text,
          'birds_alive_before': _birdsAliveBeforeController.text.isEmpty ? null : int.parse(_birdsAliveBeforeController.text),
          'mortality_today': _mortalityTodayController.text.isEmpty ? null : int.parse(_mortalityTodayController.text),
          'current_total_weight': _currentWeightController.text.isEmpty ? null : double.parse(_currentWeightController.text),
          'expected_weight':_currentWeightController.text.isEmpty ? null : double.parse(_expectedWeightController.text)
        };

        final res=await _feedingRepository.createFeedingRecord(widget.batchId, request);

        switch (res) {
          case Success():
            ToastUtil.showSuccess('Feeding logged successfully!');
            context.pop(true);
          case Failure<dynamic>(response:final response):
            ApiErrorHandler.handle(response);
        }


      } finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _costController.dispose();
    _supplierController.dispose();
    _notesController.dispose();
    _birdsAliveBeforeController.dispose();
    _mortalityTodayController.dispose();
    _currentWeightController.dispose();
    _expectedWeightController.dispose();
    super.dispose();
  }
}