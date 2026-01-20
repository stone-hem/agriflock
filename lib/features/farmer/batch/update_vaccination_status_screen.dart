import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/date_util.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_model.dart';
import 'package:agriflock360/features/farmer/batch/model/vaccination_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/vaccination_repo.dart';

class UpdateVaccinationStatusScreen extends StatefulWidget {
  final BatchModel batch;
  final Vaccination vaccination;

  const UpdateVaccinationStatusScreen({
    super.key,
    required this.batch,
    required this.vaccination,
  });

  @override
  State<UpdateVaccinationStatusScreen> createState() => _UpdateVaccinationStatusScreenState();
}

class _UpdateVaccinationStatusScreenState extends State<UpdateVaccinationStatusScreen> {
  final _repository = VaccinationRepository();
  final _notesController = TextEditingController();
  final _administeredByController = TextEditingController();
  final _rescheduleReasonController = TextEditingController();

  String? _selectedOutcome;
  DateTime? _actualDate;
  TimeOfDay? _actualTime;
  String? _selectedFailureReason;
  String? _selectedCancellationReason;
  DateTime? _newScheduledDate;
  TimeOfDay? _newScheduledTime;
  bool _rescheduleAfterFailure = true;
  int? _birdsVaccinated;

  bool _isSubmitting = false;

  final List<String> _outcomes = ['Done', 'Failed', 'Canceled', 'Rescheduled'];

  final List<String> _failureReasons = [
    'animal_unavailable',
    'vaccine_spoiled',
    'administration_error',
    'weather_conditions',
    'equipment_failure',
    'adverse_reaction',
    'other'
  ];

  final Map<String, String> _failureReasonDisplay = {
    'animal_unavailable': 'Animal unavailable',
    'vaccine_spoiled': 'Vaccine spoiled',
    'administration_error': 'Administration error',
    'weather_conditions': 'Weather conditions',
    'equipment_failure': 'Equipment failure',
    'adverse_reaction': 'Adverse reaction',
    'other': 'Other'
  };

  final List<String> _cancellationReasons = [
    'vaccine_no_longer_needed',
    'animal_sold',
    'animal_died',
    'vet_instruction_changed',
    'other'
  ];

  final Map<String, String> _cancellationReasonDisplay = {
    'vaccine_no_longer_needed': 'Vaccine no longer needed',
    'animal_sold': 'Animal sold',
    'animal_died': 'Animal died',
    'vet_instruction_changed': 'Vet instruction changed',
    'other': 'Other'
  };

  @override
  void initState() {
    super.initState();
    // Initialize birds vaccinated with current batch count
    _birdsVaccinated = widget.batch.birdsAlive;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Update Status'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: _isSubmitting ? null : () => context.pop(),
        ),
        actions: [
          _isSubmitting
              ? Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.green,
              ),
            ),
          )
              : TextButton(
            onPressed: _canSubmit() ? _submitStatus : null,
            child: Text(
              'Submit',
              style: TextStyle(
                color: _canSubmit() ? Colors.green : Colors.grey,
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
            // Vaccination Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(
                  color: widget.vaccination.isOverdue ? Colors.red.shade200 : Colors.blue.shade200,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          widget.vaccination.isOverdue ? Icons.warning : Icons.medical_services,
                          color: widget.vaccination.isOverdue ? Colors.red.shade600 : Colors.blue.shade600,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.vaccination.vaccineName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                widget.vaccination.isOverdue
                                    ? 'Overdue: ${widget.vaccination.scheduledDate}'
                                    : 'Scheduled: ${DateUtil.toDateWithDay(widget.vaccination.scheduledDate)}',
                                style: TextStyle(
                                  color: widget.vaccination.isOverdue ? Colors.red.shade700 : Colors.grey.shade600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (widget.vaccination.isOverdue) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, size: 16, color: Colors.red.shade700),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'This vaccination is overdue. Please update the status.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.red.shade700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Outcome Selection
            Text(
              'Select Outcome',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),

            // Outcome Options
            ..._outcomes.map((outcome) => _buildOutcomeCard(outcome)),

            const SizedBox(height: 24),

            // Dynamic Fields Based on Selection
            if (_selectedOutcome == 'Done') _buildDoneFields(),
            if (_selectedOutcome == 'Failed') _buildFailedFields(),
            if (_selectedOutcome == 'Canceled') _buildCanceledFields(),
            if (_selectedOutcome == 'Rescheduled') _buildRescheduledFields(),
          ],
        ),
      ),
    );
  }

  Widget _buildOutcomeCard(String outcome) {
    final isSelected = _selectedOutcome == outcome;
    Color color;
    IconData icon;

    switch (outcome) {
      case 'Done':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'Failed':
        color = Colors.orange;
        icon = Icons.error;
        break;
      case 'Canceled':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'Rescheduled':
        color = Colors.blue;
        icon = Icons.schedule;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedOutcome = outcome;
          });
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  outcome,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check, color: color),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDoneFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Completion Details',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        // Actual Date
        Text('Actual Date', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectActualDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  _actualDate == null
                      ? 'Select actual date (default: today)'
                      : '${_actualDate!.day}/${_actualDate!.month}/${_actualDate!.year}',
                  style: TextStyle(
                    color: _actualDate == null
                        ? Colors.grey.shade600
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Actual Time
        Text('Actual Time (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectActualTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  _actualTime == null
                      ? 'Select actual time'
                      : _actualTime!.format(context),
                  style: TextStyle(
                    color: _actualTime == null
                        ? Colors.grey.shade600
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Birds Vaccinated
        Text('Birds Vaccinated', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ReusableInput(
          initialValue: _birdsVaccinated?.toString() ?? '',
          keyboardType: TextInputType.number,
          hintText: 'Enter number of birds vaccinated',
          suffixIcon: Icon(Icons.agriculture, color: Colors.grey.shade600),
          onChanged: (value) {
            setState(() {
              _birdsVaccinated = int.tryParse(value) ?? 0;
            });
          },
        ),
        const SizedBox(height: 16),

        // Administered By
        Text('Administered By (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ReusableInput(
          controller: _administeredByController,
          hintText: 'Name of person who administered',
        ),
        const SizedBox(height: 16),

        // Notes
        Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ReusableInput(
          controller: _notesController,
          maxLines: 3,
          hintText: 'Reaction, batch number, observations...',
        ),
      ],
    );
  }

  Widget _buildFailedFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Failure Details',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        // Failure Reason
        Text('Failure Reason', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ReusableDropdown<String>(
          value: _selectedFailureReason,
          hintText: 'Select failure reason',
          items: _failureReasons.map((String reason) {
            return DropdownMenuItem<String>(
              value: reason,
              child: Text(_failureReasonDisplay[reason] ?? reason),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedFailureReason = newValue;
            });
          },
        ),
        const SizedBox(height: 16),

        // Reschedule Option
        SwitchListTile(
          title: Text('Reschedule after failure',
              style: TextStyle(fontWeight: FontWeight.w500)),
          subtitle: Text('Schedule a new date for this vaccination'),
          value: _rescheduleAfterFailure,
          activeThumbColor: Colors.orange,
          onChanged: (value) {
            setState(() {
              _rescheduleAfterFailure = value;
            });
          },
        ),

        if (_rescheduleAfterFailure) ...[
          const SizedBox(height: 16),
          // New Date
          Text('New Scheduled Date', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectNewScheduledDate,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_today, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Text(
                    _newScheduledDate == null
                        ? 'Select new date (default: 14 days from now)'
                        : '${_newScheduledDate!.day}/${_newScheduledDate!.month}/${_newScheduledDate!.year}',
                    style: TextStyle(
                      color: _newScheduledDate == null
                          ? Colors.grey.shade600
                          : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // New Time
          Text('New Scheduled Time (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          InkWell(
            onTap: _selectNewScheduledTime,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.access_time, color: Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Text(
                    _newScheduledTime == null
                        ? 'Select new time (default: 09:00)'
                        : _newScheduledTime!.format(context),
                    style: TextStyle(
                      color: _newScheduledTime == null
                          ? Colors.grey.shade600
                          : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],

        const SizedBox(height: 16),

        // Notes
        Text('Additional Notes (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ReusableInput(
          controller: _notesController,
          maxLines: 3,
          hintText: 'Provide additional details...',
        ),
      ],
    );
  }

  Widget _buildCanceledFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cancellation Details',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        // Cancellation Reason
        Text('Cancellation Reason', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ReusableDropdown<String>(
          value: _selectedCancellationReason,
          hintText: 'Select cancellation reason',
          items: _cancellationReasons.map((String reason) {
            return DropdownMenuItem<String>(
              value: reason,
              child: Text(_cancellationReasonDisplay[reason] ?? reason),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCancellationReason = newValue;
            });
          },
        ),
        const SizedBox(height: 16),

        // Notes
        Text('Additional Notes (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ReusableInput(
          controller: _notesController,
          maxLines: 3,
          hintText: 'Provide additional details...',
        ),
        const SizedBox(height: 16),

        // Warning
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.red.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.warning, color: Colors.red.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'This will stop all reminders for this vaccination.',
                    style: TextStyle(fontSize: 14, color: Colors.red.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRescheduledFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reschedule Details',
          style: Theme.of(context).textTheme.titleMedium!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 12),

        // New Date
        Text('New Scheduled Date', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectNewScheduledDate,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  _newScheduledDate == null
                      ? 'Select new date'
                      : '${_newScheduledDate!.day}/${_newScheduledDate!.month}/${_newScheduledDate!.year}',
                  style: TextStyle(
                    color: _newScheduledDate == null
                        ? Colors.grey.shade600
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // New Time
        Text('New Scheduled Time (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectNewScheduledTime,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade400),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.access_time, color: Colors.grey.shade600),
                const SizedBox(width: 12),
                Text(
                  _newScheduledTime == null
                      ? 'Select new time (default: 09:00)'
                      : _newScheduledTime!.format(context),
                  style: TextStyle(
                    color: _newScheduledTime == null
                        ? Colors.grey.shade600
                        : Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Reschedule Reason
        Text('Reschedule Reason (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ReusableInput(
          controller: _rescheduleReasonController,
          maxLines: 2,
          hintText: 'Why are you rescheduling?',
        ),
        const SizedBox(height: 16),

        // Additional Notes
        Text('Additional Notes (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        ReusableInput(
          controller: _notesController,
          maxLines: 2,
          hintText: 'Any additional notes...',
        ),
      ],
    );
  }

  bool _canSubmit() {
    if (_selectedOutcome == null || _isSubmitting) return false;

    switch (_selectedOutcome) {
      case 'Failed':
        return _selectedFailureReason != null;
      case 'Rescheduled':
        return _newScheduledDate != null;
      case 'Canceled':
        return _selectedCancellationReason != null;
      default:
        return true;
    }
  }

  Future<void> _selectActualDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _actualDate = picked;
      });
    }
  }

  Future<void> _selectActualTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _actualTime = picked;
      });
    }
  }

  Future<void> _selectNewScheduledDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(Duration(days: _selectedOutcome == 'Failed' ? 14 : 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _newScheduledDate = picked;
      });
    }
  }

  Future<void> _selectNewScheduledTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: 9, minute: 0), // Default to 09:00
    );
    if (picked != null) {
      setState(() {
        _newScheduledTime = picked;
      });
    }
  }

  Future<void> _submitStatus() async {
    try {
      setState(() {
        _isSubmitting = true;
      });

      // Prepare the request based on selected outcome
      final request = _prepareUpdateRequest();

      // Call the API
      final result = await _repository.updateVaccinationStatus(
        widget.batch.id,
        widget.vaccination.id,
        request,
      );

      switch (result) {
        case Success<Vaccination>(data: final data):
        // Show success message
          _showSuccessMessage();

          // Navigate back with success indicator
          if (mounted) {
            context.pop(true);
          }

        case Failure<Vaccination>(message: final e, statusCode: final statusCode):
          _showErrorMessage('$e (Status: $statusCode)');
      }
    } catch (e) {
      _showErrorMessage(e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  UpdateVaccinationStatusRequest _prepareUpdateRequest() {
    final status = _getStatusFromOutcome();

    switch (_selectedOutcome) {
      case 'Done':
        final actualDate = _actualDate != null
            ? DateUtil.toISO8601(_actualDate!)
            : DateUtil.toISO8601(DateTime.now());

        final actualTime = _actualTime != null
            ? '${_actualTime!.hour.toString().padLeft(2, '0')}:${_actualTime!.minute.toString().padLeft(2, '0')}'
            : null;

        return UpdateVaccinationStatusRequest(
          status: status,
          actualDate: actualDate,
          actualTime: actualTime,
          birdsVaccinated: _birdsVaccinated ?? widget.batch.birdsAlive,
          administeredBy: _administeredByController.text.isNotEmpty
              ? _administeredByController.text
              : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

      case 'Failed':
      // Prepare new scheduled date (default 14 days from now)
        DateTime newDate;
        if (_newScheduledDate != null) {
          newDate = _newScheduledDate!;
        } else {
          newDate = DateTime.now().add(const Duration(days: 14));
        }

        final newScheduledDate = _rescheduleAfterFailure
            ? DateUtil.toISO8601(newDate)
            : null;

        final newScheduledTime = _rescheduleAfterFailure && _newScheduledTime != null
            ? '${_newScheduledTime!.hour.toString().padLeft(2, '0')}:${_newScheduledTime!.minute.toString().padLeft(2, '0')}'
            : _rescheduleAfterFailure
            ? '09:00' // Default time
            : null;

        return UpdateVaccinationStatusRequest(
          status: status,
          failureReason: _selectedFailureReason,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
          rescheduleAfterFailure: _rescheduleAfterFailure,
          newScheduledDate: newScheduledDate,
          newScheduledTime: newScheduledTime,
        );

      case 'Canceled':
        return UpdateVaccinationStatusRequest(
          status: status,
          cancellationReason: _selectedCancellationReason,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

      case 'Rescheduled':
        final newDate = _newScheduledDate ??
            DateTime.now().add(const Duration(days: 1));
        final newScheduledDate = DateUtil.toISO8601(newDate);

        final newScheduledTime = _newScheduledTime != null
            ? '${_newScheduledTime!.hour.toString().padLeft(2, '0')}:${_newScheduledTime!.minute.toString().padLeft(2, '0')}'
            : '09:00';

        return UpdateVaccinationStatusRequest(
          status: 'scheduled', // When rescheduling, status goes back to scheduled
          newScheduledDate: newScheduledDate,
          newScheduledTime: newScheduledTime,
          rescheduleReason: _rescheduleReasonController.text.isNotEmpty
              ? _rescheduleReasonController.text
              : null,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

      default:
        throw Exception('Invalid outcome selected');
    }
  }

  String _getStatusFromOutcome() {
    switch (_selectedOutcome) {
      case 'Done':
        return 'completed';
      case 'Failed':
        return 'failed';
      case 'Canceled':
        return 'cancelled';
      case 'Rescheduled':
        return 'scheduled';
      default:
        throw Exception('Invalid outcome');
    }
  }

  void _showSuccessMessage() {
    String message = '';
    Color color = Colors.green;

    switch (_selectedOutcome) {
      case 'Done':
        message = 'Vaccination marked as completed';
        break;
      case 'Failed':
        message = 'Vaccination marked as failed';
        color = Colors.orange;
        break;
      case 'Canceled':
        message = 'Vaccination cancelled';
        color = Colors.red;
        break;
      case 'Rescheduled':
        message = 'Vaccination rescheduled';
        color = Colors.blue;
        break;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showErrorMessage(String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Failed to update vaccination: $error'),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _administeredByController.dispose();
    _rescheduleReasonController.dispose();
    super.dispose();
  }
}