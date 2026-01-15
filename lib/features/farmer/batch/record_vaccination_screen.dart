import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/custom_date_text_field.dart';
import 'package:agriflock360/core/widgets/reusable_dropdown.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer/batch/model/vaccination_model.dart';
import 'package:agriflock360/features/farmer/batch/repo/vaccination_repo.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VaccinationRecordScreen extends StatefulWidget {
  final String batchId;

  const VaccinationRecordScreen({super.key, required this.batchId});

  @override
  State<VaccinationRecordScreen> createState() => _VaccinationRecordScreenState();
}

class _VaccinationRecordScreenState extends State<VaccinationRecordScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _scheduleFormKey= GlobalKey<FormState>();
  final _quickRecordFormKey= GlobalKey<FormState>();
  final _repository = VaccinationRepository();

  // Common controllers
  final _vaccineNameController = TextEditingController();
  final _dosageController = TextEditingController();
  final _birdsVaccinatedController = TextEditingController();
  final _costController = TextEditingController();
  final _notesController = TextEditingController();
  final _scheduledDateController = TextEditingController();
  final _completedDateController = TextEditingController();


  // Common dropdowns
  String? _selectedVaccineType;
  String? _selectedAdministration;

  // Tab-specific controllers
  DateTime _scheduledDate = DateTime.now();
  TimeOfDay _scheduledTime = TimeOfDay.now();

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
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _vaccineNameController.dispose();
    _dosageController.dispose();
    _birdsVaccinatedController.dispose();
    _costController.dispose();
    _notesController.dispose();
    _scheduledDateController.dispose();
    _completedDateController.dispose();
    super.dispose();
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
            const SizedBox(width: 12),
            const Text('Vaccination Record'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TabBar(
              controller: _tabController,
              indicatorSize: TabBarIndicatorSize.tab,
              indicator: BoxDecoration(
                color: Colors.green, // Light grey for active tab
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white, //  for active
              unselectedLabelColor: Colors.grey.shade600,
              labelStyle: const TextStyle(
                fontSize: 11, // Smaller font
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 11, // Smaller font
                fontWeight: FontWeight.w500,
                letterSpacing: 0.1,
              ),
              dividerColor: Colors.transparent,
              splashFactory: NoSplash.splashFactory,
              overlayColor: WidgetStateProperty.all(Colors.transparent),
              tabs: [
                Tab(
                  height: 36, // Smaller tab height
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today, size: 16),
                      SizedBox(width: 4),
                      Text('Schedule'),
                    ],
                  ),
                ),
                Tab(
                  height: 36, // Smaller tab height
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, size: 16),
                      SizedBox(width: 4),
                      Text('Quick Record'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Schedule Tab
                _buildScheduleTab(),
                // Quick Record Tab
                _buildQuickRecordTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _scheduleFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.blue.shade200),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.schedule, color: Colors.blue.shade600),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Schedule Vaccination',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            'Plan a future vaccination for your batch',
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
              labelText: 'Vaccine Name',
              hintText: 'e.g., Newcastle Disease Vaccine',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vaccine name';
                }
                return null;
              },
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
            ReusableDropdown<String>(
              value: _selectedVaccineType,
              labelText: 'Vaccine Type',
              hintText: 'Select vaccine type',
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
            ReusableDropdown<String>(
              value: _selectedAdministration,
              hintText: 'Select administration method',
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
              }, labelText: 'Method',
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

            CustomDateTextField(
              label: 'Scheduled Date',
              hintText: 'Select date',
              icon: Icons.calendar_today,
              required: true,
              minYear: DateTime.now().year - 1,
              returnFormat: DateReturnFormat.dateTime,
              initialDate: DateTime.now(),
              maxYear: DateTime.now().year,
              controller: _scheduledDateController,
              onChanged: (value) {
                if (value != null) {
                  _scheduledDate = value;
                }
              },
            ),
            const SizedBox(height: 20),

            // Scheduled Time
            Text(
              'Scheduled Time',
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 8),
            InkWell(
              onTap: () => _selectTime(context, true),
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
                      _scheduledTime.format(context),
                      style: TextStyle(color: Colors.grey.shade800),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            ReusableInput(
              controller: _costController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              labelText: 'Estimated Cost - Optional',
              hintText: 'e.g., 150.00',
            ),
            const SizedBox(height: 20),

            ReusableInput(
              controller: _notesController,
              maxLines: 3,
              labelText: 'Notes (Optional)',
              hintText: 'Special instructions, batch number...',
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitSchedule,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.schedule, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Schedule Vaccination',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

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
                            'Scheduled Vaccination',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This will create a scheduled vaccination that will appear in your upcoming tasks. You can mark it as completed later.',
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
    );
  }

  Widget _buildQuickRecordTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _quickRecordFormKey,
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
                    Icon(Icons.check_circle, color: Colors.green.shade600),
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
              labelText: 'Vaccine Name',
              hintText: 'e.g., Newcastle Disease Vaccine',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter vaccine name';
                }
                return null;
              },
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
            ReusableDropdown<String>(
              value: _selectedVaccineType,
              hintText: 'Select vaccine type',
              labelText: 'Vaccine Type',
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
            ReusableDropdown<String>(
              value: _selectedAdministration,
              hintText: 'Select administration method',
              labelText: 'Method',
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
              labelText: 'Number of Birds Vaccinated',
              hintText: 'e.g., 450',
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter number of birds';
                }
                if (int.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            // Completion Date
            CustomDateTextField(
              label: 'Completion Date',
              hintText: 'Select date',
              icon: Icons.calendar_today,
              required: true,
              minYear: DateTime.now().year - 1,
              returnFormat: DateReturnFormat.dateTime,
              initialDate: DateTime.now(),
              maxYear: DateTime.now().year,
              controller: _completedDateController,
              onChanged: (value) {
                if (value != null) {
                  _completionDate = value;
                }
              },
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
              onTap: () => _selectTime(context, false),
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
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: false,
              ),
              labelText: 'Total Cost - Optional',
              hintText: 'e.g., 150.00',
            ),
            const SizedBox(height: 20),

            ReusableInput(
              controller: _notesController,
              maxLines: 3,
              labelText: 'Notes (Optional)',
              hintText: 'Batch number, reactions, observations...',
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _submitQuickRecord,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Save Vaccination Record',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Info Card
            Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.green.shade100),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: Colors.green.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Record',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This will create a completed vaccination record. If there is a vaccination protocol, the next dose will be automatically scheduled.',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.green.shade800,
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
    );
  }

  Future<void> _selectTime(BuildContext context, bool isSchedule) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: isSchedule ? _scheduledTime : _completionTime,
    );
    if (picked != null) {
      setState(() {
        if (isSchedule) {
          _scheduledTime = picked;
        } else {
          _completionTime = picked;
        }
      });
    }
  }

  Future<void> _submitSchedule() async {
    if (_scheduleFormKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {

        final request = VaccinationScheduleRequest(
          vaccineName: _vaccineNameController.text,
          vaccineType: _selectedVaccineType!,
          scheduledDate: _scheduledDate,
          scheduleTime: '${_scheduledTime.hour}:${_scheduledTime.minute}',
          dosage: _dosageController.text,
          administrationMethod: _selectedAdministration!,
          cost: _costController.text.isEmpty ? 0 : double.parse(_costController.text),
          notes: _notesController.text.isEmpty ? null : _notesController.text,
          source: 'manual',
        );

       final res= await _repository.scheduleVaccination(widget.batchId, request);
       switch(res) {
         case Success():
           if (mounted) {
             ToastUtil.showSuccess('Vaccination scheduled successfully');
             _clearForm();
             context.pop(true);
           }
         case Failure(response:final response):
           ApiErrorHandler.handle(response);
       }

      }  finally {
        if (mounted) {
          setState(() {
            _isSaving = false;
          });
        }
      }
    }
  }

  Future<void> _submitQuickRecord() async {
    if (_quickRecordFormKey.currentState!.validate()) {
      setState(() {
        _isSaving = true;
      });

      try {

        final request = QuickDoneVaccinationRequest(
          vaccineName: _vaccineNameController.text,
          vaccineType: _selectedVaccineType!,
          dosage: _dosageController.text,
          administrationMethod: _selectedAdministration!,
          birdsVaccinated: int.parse(_birdsVaccinatedController.text),
          completedDate: _completionDate,
          completedTime: '${_completionTime.hour}:${_completionTime.minute}',
          cost: _costController.text.isEmpty ? 0 : double.parse(_costController.text),
          notes: _notesController.text.isEmpty ? null : _notesController.text,
        );

        final res=await _repository.quickDoneVaccination(widget.batchId, request);

        switch(res) {
          case Success():
            if (mounted) {
             ToastUtil.showSuccess('Vaccination recorded successfully');
              _clearForm();
             context.pop(true);
            }
          case Failure(response:final response):
            ApiErrorHandler.handle(response);
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

  void _clearForm() {
    _vaccineNameController.clear();
    _dosageController.clear();
    _birdsVaccinatedController.clear();
    _costController.clear();
    _notesController.clear();
    setState(() {
      _selectedVaccineType = null;
      _selectedAdministration = null;
      _scheduledDate = DateTime.now();
      _scheduledTime = TimeOfDay.now();
      _completionDate = DateTime.now();
      _completionTime = TimeOfDay.now();
    });
  }
}