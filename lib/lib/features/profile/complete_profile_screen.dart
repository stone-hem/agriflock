import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<ProfileStep> _profileSteps = [
    ProfileStep(
      title: 'Personal Information',
      subtitle: 'Tell us more about yourself',
      icon: Icons.person_outline,
      color: Colors.blue,
      fields: [
        ProfileField(
          label: 'Full Name',
          hint: 'Enter your full name',
          type: FieldType.text,
        ),
        ProfileField(
          label: 'Phone Number',
          hint: 'Enter your phone number',
          type: FieldType.phone,
        ),
        ProfileField(
          label: 'Date of Birth',
          hint: 'Select your date of birth',
          type: FieldType.date,
        ),
      ],
    ),
    ProfileStep(
      title: 'Farm Details',
      subtitle: 'Information about your farming operation',
      icon: Icons.agriculture_outlined,
      color: Colors.green,
      fields: [
        ProfileField(
          label: 'Farm Name',
          hint: 'Enter your farm name',
          type: FieldType.text,
        ),
        ProfileField(
          label: 'Farm Size',
          hint: 'Enter farm size in acres',
          type: FieldType.number,
        ),
        ProfileField(
          label: 'Years of Experience',
          hint: 'Years in poultry farming',
          type: FieldType.number,
        ),
      ],
    ),
    ProfileStep(
      title: 'Production Details',
      subtitle: 'Your poultry production information',
      icon: Icons.eco_outlined,
      color: Colors.orange,
      fields: [
        ProfileField(
          label: 'Primary Poultry Type',
          hint: 'e.g., Broilers, Layers, etc.',
          type: FieldType.text,
        ),
        ProfileField(
          label: 'Average Flock Size',
          hint: 'Number of birds per batch',
          type: FieldType.number,
        ),
        ProfileField(
          label: 'Annual Production',
          hint: 'Total birds per year',
          type: FieldType.number,
        ),
      ],
    ),
    ProfileStep(
      title: 'Business Information',
      subtitle: 'Your commercial farming details',
      icon: Icons.business_center_outlined,
      color: Colors.purple,
      fields: [
        ProfileField(
          label: 'Business Name',
          hint: 'Registered business name',
          type: FieldType.text,
        ),
        ProfileField(
          label: 'Business Registration',
          hint: 'Registration number',
          type: FieldType.text,
        ),
        ProfileField(
          label: 'Target Market',
          hint: 'e.g., Local, Export, etc.',
          type: FieldType.text,
        ),
      ],
    ),
  ];

  final List<Map<String, TextEditingController>> _controllers = [];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for all fields
    for (var step in _profileSteps) {
      Map<String, TextEditingController> stepControllers = {};
      for (var field in step.fields) {
        stepControllers[field.label] = TextEditingController();
      }
      _controllers.add(stepControllers);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    // Dispose all controllers
    for (var stepControllers in _controllers) {
      for (var controller in stepControllers.values) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _profileSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeProfile();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void _completeProfile() {
    // TODO: Save profile data
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile completed successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    context.push('/complete-profile/congratulations');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Complete Your Profile'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          // Progress Indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                // Step Indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(_profileSteps.length, (index) {
                    return Expanded(
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        height: 4,
                        decoration: BoxDecoration(
                          color: index <= _currentPage
                              ? _profileSteps[index].color
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 12),
                Text(
                  'Step ${_currentPage + 1} of ${_profileSteps.length}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // PageView
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _profileSteps.length,
              onPageChanged: (page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, pageIndex) {
                final step = _profileSteps[pageIndex];
                return _buildStepPage(step, pageIndex);
              },
            ),
          ),

          // Navigation Buttons
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousPage,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  flex: _currentPage > 0 ? 1 : 2,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      _currentPage == _profileSteps.length - 1
                          ? 'Complete Profile'
                          : 'Continue',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepPage(ProfileStep step, int pageIndex) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Step Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            margin: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [step.color.withValues(alpha: 0.1), step.color.withValues(alpha: 0.05)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                Icon(
                  step.icon,
                  size: 48,
                  color: step.color,
                ),
                const SizedBox(height: 16),
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  step.subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          // Form Fields
          Column(
            children: step.fields.map((field) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      field.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildFieldInput(field, pageIndex),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFieldInput(ProfileField field, int pageIndex) {
    final controller = _controllers[pageIndex][field.label]!;

    switch (field.type) {
      case FieldType.date:
        return InkWell(
          onTap: () => _selectDate(context, controller),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.text.isEmpty ? field.hint : controller.text,
              style: TextStyle(
                color: controller.text.isEmpty ? Colors.grey.shade500 : Colors.black,
              ),
            ),
          ),
        );
      case FieldType.number:
        return TextFormField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: field.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      default:
        return TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: field.hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }
}

// Data Models
class ProfileStep {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<ProfileField> fields;

  ProfileStep({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.fields,
  });
}

class ProfileField {
  final String label;
  final String hint;
  final FieldType type;

  ProfileField({
    required this.label,
    required this.hint,
    required this.type,
  });
}

enum FieldType {
  text,
  number,
  phone,
  date,
}

// Extension to get color for current step
extension StepColor on _CompleteProfileScreenState {
  Color get stepColor => _profileSteps[_currentPage].color;
}