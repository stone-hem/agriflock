import 'package:agriflock360/features/farmer/batch/model/scheduled_vaccination.dart';
import 'package:agriflock360/features/farmer/batch/model/vaccination_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/vaccination_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class UpdateVaccinationStatusScreen extends StatefulWidget {
  final String batchId;
  final VaccinationSchedule vaccination;

  const UpdateVaccinationStatusScreen({
    super.key,
    required this.batchId, required this.vaccination,
  });

  @override
  State<UpdateVaccinationStatusScreen> createState() => _UpdateVaccinationStatusScreenState();
}

class _UpdateVaccinationStatusScreenState extends State<UpdateVaccinationStatusScreen> {
  final _repository = VaccinationRepository();
  final _notesController = TextEditingController();

  String? _selectedOutcome;
  DateTime? _actualDate;
  TimeOfDay? _actualTime;
  String? _selectedFailureReason;
  String? _selectedCancellationReason;
  DateTime? _newScheduledDate;
  TimeOfDay? _newScheduledTime;

  bool _isSubmitting = false;

  final List<String> _outcomes = ['Done', 'Failed', 'Canceled', 'Rescheduled'];

  final List<String> _failureReasons = [
    'Animal unavailable',
    'Vaccine spoiled',
    'Administration error',
    'Weather conditions',
    'Equipment failure',
    'Other'
  ];

  final List<String> _cancellationReasons = [
    'Vaccine no longer needed',
    'Animal sold',
    'Animal died',
    'Vet instruction changed',
    'Other'
  ];

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
                                    : 'Scheduled: ${widget.vaccination.scheduledDate}',
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

        // Notes
        Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Reaction, batch number, observations...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
        DropdownButtonFormField<String>(
          value: _selectedFailureReason,
          decoration: InputDecoration(
            hintText: 'Select failure reason',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: _failureReasons.map((String reason) {
            return DropdownMenuItem<String>(
              value: reason,
              child: Text(reason),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedFailureReason = newValue;
            });
          },
        ),
        const SizedBox(height: 16),

        // Notes
        Text('Additional Notes (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Provide additional details...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Reschedule Prompt
        Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.orange.shade200),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(Icons.schedule, color: Colors.orange.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Would you like to reschedule this vaccination?',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
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
        DropdownButtonFormField<String>(
          value: _selectedCancellationReason,
          decoration: InputDecoration(
            hintText: 'Select cancellation reason',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          items: _cancellationReasons.map((String reason) {
            return DropdownMenuItem<String>(
              value: reason,
              child: Text(reason),
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
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Provide additional details...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
                      ? 'Select new time'
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

        // Reason
        Text('Reason (Optional)', style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextField(
          controller: _notesController,
          maxLines: 2,
          decoration: InputDecoration(
            hintText: 'Why are you rescheduling?',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
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
      initialDate: DateTime.now().add(const Duration(days: 1)),
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
      initialTime: TimeOfDay.now(),
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
      await _repository.updateVaccinationStatus(
        widget.batchId,
        widget.vaccination.id,
        request,
      );

      // Show success message
      _showSuccessMessage();

      // Navigate back with success indicator
      if (mounted) {
        context.pop(true);
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
        final actualDateTime = _actualDate != null
            ? DateTime(
          _actualDate!.year,
          _actualDate!.month,
          _actualDate!.day,
          _actualTime?.hour ?? 0,
          _actualTime?.minute ?? 0,
        )
            : DateTime.now();

        return UpdateVaccinationStatusRequest(
          status: status,
          completedDate: actualDateTime,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

      case 'Failed':
        return UpdateVaccinationStatusRequest(
          status: status,
          failureReason: _selectedFailureReason,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

      case 'Canceled':
        return UpdateVaccinationStatusRequest(
          status: status,
          cancellationReason: _selectedCancellationReason,
          notes: _notesController.text.isNotEmpty ? _notesController.text : null,
        );

      case 'Rescheduled':
        final newDateTime = _newScheduledDate != null
            ? DateTime(
          _newScheduledDate!.year,
          _newScheduledDate!.month,
          _newScheduledDate!.day,
          _newScheduledTime?.hour ?? 0,
          _newScheduledTime?.minute ?? 0,
        )
            : DateTime.now().add(const Duration(days: 1));

        return UpdateVaccinationStatusRequest(
          status: 'scheduled', // When rescheduling, status goes back to scheduled
          scheduledDate: newDateTime,
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
        return 'canceled';
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
        message = 'Vaccination canceled';
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
    super.dispose();
  }
}