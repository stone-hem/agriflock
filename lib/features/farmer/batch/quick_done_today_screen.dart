import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/vaccination_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/vaccination_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class QuickDoneTodayScreen extends StatefulWidget {
  final String batchId;

  const QuickDoneTodayScreen({super.key, required this.batchId});

  @override
  State<QuickDoneTodayScreen> createState() => _QuickDoneTodayScreenState();
}

class _QuickDoneTodayScreenState extends State<QuickDoneTodayScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = VaccinationRepository();

  final _vaccineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _birdsVaccinatedController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedVaccineType;
  String? _selectedAdministration;
  DateTime _completionDate = DateTime.now();
  TimeOfDay _completionTime = TimeOfDay.now();
  bool _isSaving = false;

  final List<String> _vaccineTypes = [
    'Newcastle Disease',
    'Infectious Bronchitis',
    'Gumboro Disease',
    'Fowl Pox',
    'Marek\'s Disease',
    'Avian Influenza',
    'Salmonella',
    'Coccidiosis'
  ];

  final List<String> _administrationMethods = [
    'Drinking Water',
    'Eye Drop',
    'Injection',
    'Spray',
    'Wing Web Stab'
  ];

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
            const SizedBox(width: 12),
            const Text('Quick Record'),
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
            onPressed: _isSaving ? null : _submitRecord,
            child: _isSaving
                ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
                : const Text(
              'Save',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.green.shade200),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.flash_on, color: Colors.green.shade600),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Quick Record',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Record a vaccination that was completed today',
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
              ReusableInput(
                controller: _vaccineNameController,

                hintText: 'e.g., Newcastle Disease Vaccine',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter vaccine name';
                  }
                  return null;
                }, labelText: 'Vaccine Name',
              ),
              const SizedBox(height: 20),

              // Vaccine Type
              Text(
                'Vaccine Type',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedVaccineType,
                decoration: InputDecoration(
                  hintText: 'Select vaccine type',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _vaccineTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVaccineType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select vaccine type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Administration Method
              Text(
                'Administration Method',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedAdministration,
                decoration: InputDecoration(
                  hintText: 'Select administration method',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items: _administrationMethods.map((String method) {
                  return DropdownMenuItem<String>(
                    value: method,
                    child: Text(method),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedAdministration = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select administration method';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ReusableInput(
                controller: _dosageController,
                labelText: 'Dosage',
                hintText: 'e.g., 1ml per bird',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter dosage';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              ReusableInput(
                controller: _birdsVaccinatedController,
                keyboardType: TextInputType.number,
                hintText: 'e.g., 450',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter number of birds';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                }, labelText: 'Number of Birds Vaccinated',
              ),
              const SizedBox(height: 20),

              // Completion Date
              Text(
                'Completion Date',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectCompletionDate,
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
                        '${_completionDate.day}/${_completionDate.month}/${_completionDate.year}',
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Completion Time
              Text(
                'Completion Time',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectCompletionTime,
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
                        _completionTime.format(context),
                        style: TextStyle(color: Colors.grey.shade800),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ReusableInput(
                controller: _costController,
                keyboardType: TextInputType.number,
                hintText: 'e.g., 150.00', labelText: 'Total Cost (₵) - Optional',

              ),
              const SizedBox(height: 20),
              ReusableInput(
                controller: _notesController,
                maxLines: 3,
                labelText: 'Notes (Optional)',
                hintText: 'Batch number, reactions, observations...',
              ),
              const SizedBox(height: 24),

              // Info Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Record',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'This will create a completed vaccination record. If there is a vaccination protocol, the next dose will be automatically scheduled.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue.shade800,
                              ),
                            ),
                          ],
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

  Future<void> _selectCompletionDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _completionDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _completionDate = picked;
      });
    }
  }

  Future<void> _selectCompletionTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _completionTime,
    );
    if (picked != null) {
      setState(() {
        _completionTime = picked;
      });
    }
  }

  Future<void> _submitRecord() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {
        final completionDateTime = DateTime(
          _completionDate.year,
          _completionDate.month,
          _completionDate.day,
          _completionTime.hour,
          _completionTime.minute,
        );

        final request = QuickDoneVaccinationRequest(
          vaccineName: _vaccineNameController.text,
          vaccineType: _selectedVaccineType!,
          dosage: _dosageController.text,
          administrationMethod: _selectedAdministration!,
          birdsVaccinated: int.parse(_birdsVaccinatedController.text),
          completedDate: completionDateTime,
          cost: _costController.text.isEmpty
              ? 0
              : double.parse(_costController.text),
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        await _repository.quickDoneVaccination(widget.batchId, request);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Vaccination recorded successfully'),
                  Text('${_birdsVaccinatedController.text} birds vaccinated'),
                  const Text('Status: Completed'),
                ],
              ),
              backgroundColor: Colors.green,
            ),
          );
          context.pop(true); // Return true to indicate success
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to record vaccination: $e'),
              backgroundColor: Colors.red,
            ),
          );
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
    _vaccineNameController.dispose();
    _dosageController.dispose();
    _birdsVaccinatedController.dispose();
    _costController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}