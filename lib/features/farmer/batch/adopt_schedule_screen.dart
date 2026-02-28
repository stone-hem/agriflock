import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/widgets/custom_date_text_field.dart';
import 'package:agriflock/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock/features/farmer/batch/model/recommended_vaccination_model.dart';
import 'package:agriflock/features/farmer/batch/repo/vaccination_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class AdoptScheduleScreen extends StatefulWidget {
  final RecommendedVaccinationsResponse vaccineSchedule;
  final BatchModel batch;

  const AdoptScheduleScreen({
    super.key,
    required this.vaccineSchedule,
    required this.batch,
  });

  @override
  State<AdoptScheduleScreen> createState() => _AdoptScheduleScreenState();
}

class _AdoptScheduleScreenState extends State<AdoptScheduleScreen> {
  final _vaccinationRepository=VaccinationRepository();


  final Map<String, bool> _selectedItems = {};
  bool _enableReminders = true;
  bool _adjustForAge = true;
  bool _isLoading = false;
  final _dateController = TextEditingController();


  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _dateController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = _selectedItems.values.where((v) => v).length;

    return Scaffold(
      appBar: AppBar(
        title: Text('Select items to adopt - ${widget.batch.batchNumber}'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            TextButton(
              onPressed: selectedCount > 0 && !_isLoading ? _adoptSchedule : null,
              child: Text(
                'Adopt ($selectedCount)',
                style: TextStyle(
                  color: selectedCount > 0 && !_isLoading ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Batch Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.purple.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.calendar_month, color: Colors.purple.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Batch: ${widget.batch.batchNumber}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Batch Age: ${widget.vaccineSchedule.meta.batchAgeDays} days',
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
              ),
            ),
            const SizedBox(height: 24),

            // Start Date Selection
            CustomDateTextField(
              label: 'Schedule Start Date',
              icon: Icons.calendar_today,
              required: true,
              minYear: DateTime.now().year - 1,
              maxYear: DateTime.now().year,
              returnFormat: DateReturnFormat.isoString,
              controller: _dateController,
            ),
            const SizedBox(height: 24),

            // Options
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Adjust for current flock age'),
                    subtitle: Text(
                      'Skip vaccinations that should have already been done',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    value: _adjustForAge,
                    onChanged: _isLoading ? null : (value) {
                      setState(() {
                        _adjustForAge = value;
                      });
                    },
                  ),
                  Divider(height: 1, color: Colors.grey.shade200),
                  SwitchListTile(
                    title: const Text('Enable reminders'),
                    subtitle: Text(
                      'Get notifications 24 hours before each vaccination',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                    value: _enableReminders,
                    onChanged: _isLoading ? null : (value) {
                      setState(() {
                        _enableReminders = value;
                      });
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Schedule Items
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Vaccination Items (${widget.vaccineSchedule.data.length})',
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Row(
                  children: [
                    TextButton(
                      onPressed: _isLoading ? null : _selectAll,
                      child: const Text('All'),
                    ),
                    TextButton(
                      onPressed: _isLoading ? null : _deselectAll,
                      child: const Text('Deselect'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...widget.vaccineSchedule.data.map((vaccine) => _buildScheduleItem(vaccine)),

            const SizedBox(height: 24),

            // Summary Card
            Card(
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
                        Icon(Icons.check_circle, color: Colors.green.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          'Summary',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Selected items', '$selectedCount/${widget.vaccineSchedule.data.length}'),
                    _buildSummaryRow(
                      'Start date',
                      _dateController.text.isEmpty
                          ? 'Not selected'
                          : _dateController.text,
                    ),
                    _buildSummaryRow('Reminders', _enableReminders ? 'Enabled' : 'Disabled'),
                    _buildSummaryRow('Age adjustment', _adjustForAge ? 'Yes' : 'No'),
                    _buildSummaryRow('Batch age', '${widget.vaccineSchedule.meta.batchAgeDays} days'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScheduleItem(RecommendedVaccination vaccine) {
    final isSelected = _selectedItems[vaccine.vaccineName] ?? false;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: _isLoading ? null : () {
          setState(() {
            _selectedItems[vaccine.vaccineName] = !isSelected;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? Colors.purple.withOpacity(0.05) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.purple : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? Colors.purple : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? Colors.purple : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 16, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vaccine.vaccineName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (vaccine.targetDisease != null && vaccine.targetDisease!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        vaccine.targetDisease!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Day ${vaccine.recommendedAgeMin}-${vaccine.recommendedAgeMax}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vaccine.administrationMethod,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (vaccine.dosage.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(
                            Icons.medication,
                            size: 14,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            vaccine.dosage,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (vaccine.description != null && vaccine.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        vaccine.description!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
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

  void _selectAll() {
    setState(() {
      for (var vaccine in widget.vaccineSchedule.data) {
        _selectedItems[vaccine.vaccineName] = true;
      }
    });
  }

  void _deselectAll() {
    setState(() {
      for (var vaccine in widget.vaccineSchedule.data) {
        _selectedItems[vaccine.vaccineName] = false;
      }
    });
  }


  void _adoptSchedule() {
    final selectedCount = _selectedItems.values.where((v) => v).length;

    if (_dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a start date'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }



    // Get selected vaccines
    final selectedVaccines = widget.vaccineSchedule.data
        .where((vaccine) => _selectedItems[vaccine.vaccineName] == true)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Adoption'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('You are about to adopt $selectedCount vaccination schedule(s).'),
            const SizedBox(height: 12),
            Text(
              'This will create scheduled vaccinations starting from ${_dateController.text}.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            if (_adjustForAge) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.orange.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Past-due vaccinations will be skipped',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade900,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (selectedCount > 0) ...[
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 150),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected vaccines:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      ...selectedVaccines.take(5).map((vaccine) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          '• ${vaccine.vaccineName}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                        ),
                      )),
                      if (selectedVaccines.length > 5)
                        Text(
                          '... and ${selectedVaccines.length - 5} more',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmAdoption(selectedVaccines);
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Adopt'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAdoption(List<RecommendedVaccination> selectedVaccines) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Extract vaccine catalog IDs from selected vaccines
      final vaccineCatalogIds = selectedVaccines
          .where((vaccine) => vaccine.id.isNotEmpty)
          .map((vaccine) => vaccine.id)
          .toList();

      if (vaccineCatalogIds.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No valid vaccine IDs found'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Call the repository
      final result = await _vaccinationRepository.adoptRecommendedVaccinations(
        widget.batch.id,
        {
          'vaccineCatalogIds': vaccineCatalogIds,
          'scheduledDate': DateTime.parse(_dateController.text).toUtc().toIso8601String(),
          'skipExisting': _adjustForAge,
        },
      );

      switch(result) {
        case Success():
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Successfully adopted ${selectedVaccines.length} vaccination schedule(s)'),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navigate back
          if (context.mounted) {
            context.pop();
          }
        case Failure<dynamic>(message:final error):
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
      }

      setState(() {
        _isLoading = false;
      });

    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}