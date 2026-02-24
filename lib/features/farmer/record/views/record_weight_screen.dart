import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/record/repo/recording_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class RecordWeightScreen extends StatefulWidget {
  final BatchListItem batch;

  const RecordWeightScreen({
    super.key,
    required this.batch,
  });

  @override
  State<RecordWeightScreen> createState() => _RecordWeightScreenState();
}

class _RecordWeightScreenState extends State<RecordWeightScreen> {
  final _formKey = GlobalKey<FormState>();
  final _recordingRepo = RecordingRepo();


  final _averageKgsController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();

  bool _isSaving = false;

  Future<void> _saveWeightRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      DateTime sampleDate = DateTime.now();
      if (_dateController.text.isNotEmpty) {
        try {
          sampleDate = DateTime.parse(_dateController.text);
        } catch (e) {
          sampleDate = DateTime.now();
        }
      }

      final recordData = {
        'average_weight_kgs': double.parse(_averageKgsController.text),
        'sample_date': sampleDate.toUtc().toIso8601String(),
        if (_notesController.text.isNotEmpty) 'notes': _notesController.text,
      };


      final result = await _recordingRepo.recordWeight(recordData, widget.batch.id);

      switch(result) {
        case Success<dynamic>():
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Weight record saved successfully!'),
              ),
            );
            context.pop(true);
          }
        case Failure<dynamic>(message: final error):
          ApiErrorHandler.handle(error);
          break;
      }


    } catch (e) {
      // TODO: Handle error
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Record Weight'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Batch info banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.indigo.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.indigo.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.pets, color: Colors.indigo),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.batch.batchNumber,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${widget.batch.currentCount} birds  •  Day ${widget.batch.ageInDays}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              const Text(
                'Weight Sampling',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Record the weight sample for this batch',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 24),


              // Sample Date
              CustomDateTextField(
                label: 'Sample Date',
                icon: Icons.calendar_today,
                required: true,
                minYear: DateTime.now().year - 1,
                maxYear: DateTime.now().year,
                returnFormat: DateReturnFormat.isoString,
                controller: _dateController,
              ),
              const SizedBox(height: 20),

              // Sample Average Kgs
              ReusableInput(
                topLabel: 'Sample Average (Kgs)',
                icon: Icons.monitor_weight,
                controller: _averageKgsController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true,signed: false),
                hintText: 'Average weight in kgs',
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter average weight';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  if (double.parse(value) <= 0) {
                    return 'Weight must be greater than 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Notes
              ReusableInput(
                topLabel: 'Notes (Optional)',
                icon: Icons.note,
                controller: _notesController,
                maxLines: 3,
                hintText: 'Any observations about the weight sampling...',
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isSaving ? null : _saveWeightRecord,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.save),
                            SizedBox(width: 8),
                            Text(
                              'Record Weight',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
    _averageKgsController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }
}
