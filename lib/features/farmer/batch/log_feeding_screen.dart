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
  final _notesController = TextEditingController();
  final _mortalityTodayController = TextEditingController();
  final _currentWeightController = TextEditingController();
  final _selectedDateController = TextEditingController();

  TimeOfDay _selectedTime = TimeOfDay.now();

  // State
  FeedingRecommendationsResponse? _recommendations;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _error;
  DateTime _selectedFeedingDate = DateTime.now();
  String? _selectedFeedType;

  // List of available feed types
  final List<String> _feedTypes = [
    'Starter Mash',
    'Grower Mash',
    'Finisher Mash',
    'Layer Mash',
    'Broiler Starter',
    'Broiler Finisher',
    'Custom Feed'
  ];

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
            _isLoading = false;
          });
      }


    } finally  {
      if (mounted && _isLoading) {
        setState(() {
          _isLoading = false;
        });
      }
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
              _buildRecommendationsDisplay(),
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
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsDisplay() {
    final currentRec = _recommendations?.currentRecommendation;
    final allRecs = _recommendations?.allRecommendations;

    // Check if there are any recommendations
    final hasCurrentRec = currentRec != null &&
        (currentRec.stageName != null && currentRec.stageName!.isNotEmpty);

    final hasAllRecs = allRecs != null && allRecs.isNotEmpty;

    if (!hasCurrentRec && !hasAllRecs) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange.shade100),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade600),
                const SizedBox(width: 8),
                Text(
                  'No Recommendations Available',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'No feeding recommendations found for ${_recommendations!.batchInfo.ageDays} days old birds.',
              style: TextStyle(
                color: Colors.orange.shade700,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (hasCurrentRec) _buildCurrentRecommendationCard(),
        if (hasAllRecs) ...[
          const SizedBox(height: 16),
          _buildAllRecommendationsCard(),
        ],
      ],
    );
  }

  Widget _buildCurrentRecommendationCard() {
    final currentRec = _recommendations!.currentRecommendation!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Text(
                  'Current Stage Recommendation',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Stage Name
            if (currentRec.stageName.isNotEmpty)
              _buildRecommendationRow(
                label: 'Stage',
                value: currentRec.stageName,
                icon: Icons.flag,
                color: Colors.blue,
              ),

            // Feed Type
            if (currentRec.feedType.isNotEmpty)
              _buildRecommendationRow(
                label: 'Recommended Feed',
                value: currentRec.feedType!,
                icon: Icons.restaurant,
                color: Colors.green,
              ),

            // Protein Percentage
            _buildRecommendationRow(
              label: 'Protein Content',
              value: '${currentRec.proteinPercentage}% CP',
              icon: Icons.bar_chart,
              color: Colors.purple,
            ),

            // Daily Feed Required
            if (currentRec.dailyFeedRequiredKg != null)
              _buildRecommendationRow(
                label: 'Daily Feed Required',
                value: '${currentRec.dailyFeedRequiredKg!.toStringAsFixed(2)} kg',
                icon: Icons.scale,
                color: Colors.orange,
              ),

            // Feeding Times
            if (currentRec.feedingTimes.slots.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 18, color: Colors.red.shade600),
                      const SizedBox(width: 8),
                      Text(
                        'Feeding Times:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: currentRec.feedingTimes!.slots!
                        .map((time) => Chip(
                      label: Text(
                        time,
                        style: const TextStyle(fontSize: 12, color: Colors.white),
                      ),
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    ))
                        .toList(),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAllRecommendationsCard() {
    final allRecs = _recommendations!.allRecommendations!;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.list_alt, color: Colors.green.shade600),
                const SizedBox(width: 8),
                Text(
                  'All Stage Recommendations',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...allRecs.map((rec) {
              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Stage Name
                        if (rec.stageName.isNotEmpty)
                          Text(
                            rec.stageName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),

                        // Age Range
                          Text(
                            'Age: ${rec.ageStart} - ${rec.ageEnd} days',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                          ),

                        const SizedBox(height: 4),

                        // Feed Type
                        if (rec.feedType.isNotEmpty)
                          Text(
                            'Feed: ${rec.feedType}',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 13,
                            ),
                          ),

                        // Protein Percentage
                        Text(
                          'Protein: ${rec.proteinPercentage}%',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (rec != allRecs.last) const SizedBox(height: 8),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationRow({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
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
          ),
        ],
      ),
    );
  }

  Widget _buildFeedingInformationSection() {
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

        // Feed Type Select
        Text(
          'Feed Type',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedFeedType,
            onChanged: (value) {
              setState(() {
                _selectedFeedType = value;
              });
            },
            items: [
              const DropdownMenuItem<String>(
                value: null,
                child: Text(
                  'Select feed type',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              ..._feedTypes.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ],
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              hintText: 'Choose feed type',
              prefixIcon: const Icon(Icons.restaurant),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select feed type';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 20),
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
          hintText: 'Enter feed quantity in kg',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter feed quantity';
            }
            if (double.tryParse(value) == null) {
              return 'Please enter a valid number';
            }
            return null;
          },
          labelText: 'Quantity in Kgs',
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
          'feed_type': _selectedFeedType,
          'quantity': double.parse(_quantityController.text),
          'fed_at': _selectedFeedingTime.toIso8601String(),
          'notes': _notesController.text,
          'mortality_today': _mortalityTodayController.text.isEmpty ? null : int.parse(_mortalityTodayController.text),
          'current_total_weight': _currentWeightController.text.isEmpty ? null : double.parse(_currentWeightController.text),
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
    _notesController.dispose();
    _mortalityTodayController.dispose();
    _currentWeightController.dispose();
    super.dispose();
  }
}