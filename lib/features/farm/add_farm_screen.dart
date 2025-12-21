import 'dart:convert';

import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/core/widgets/location_picker_step.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Add the import for ApiClient
import '../../main.dart';

class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Location data (for both farmer and vet)
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  // Loading state
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Add New Farm'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveFarm,
            child: _isLoading
                ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
              ),
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
              // Farm Image Upload
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined,
                          color: Colors.grey.shade500),
                      const SizedBox(height: 8),
                      Text(
                        'Add Farm Photo',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Farm Name
              Text(
                'Farm Name',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter farm name';
                  }
                  return null;
                },
                labelText: 'Name',
                hintText: 'Eg Main Poultry Farm',
              ),
              const SizedBox(height: 20),

              // Location Picker
              LocationPickerStep(
                selectedAddress: _selectedAddress,
                latitude: _latitude,
                longitude: _longitude,
                onLocationSelected: (String address, double lat, double lng) {
                  setState(() {
                    _selectedAddress = address;
                    _latitude = lat;
                    _longitude = lng;
                  });
                },
                primaryColor: Colors.green,
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                'Description (Optional)',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _descriptionController,
                maxLines: 3,
                labelText: 'Description',
                hintText: 'Enter a brief description of your farm',
              ),
              const SizedBox(height: 32),

              // Additional Information
              Card(
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
                        'Farm Setup',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'After creating your farm, you can:\n'
                            '• Add multiple flocks\n'
                            '• Set up IoT devices\n'
                            '• Track performance metrics\n'
                            '• Manage farm staff',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
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

  Future<void> _saveFarm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate location is selected
    if (_selectedAddress == null || _latitude == null || _longitude == null) {
      ToastUtil.showError("Please select location for your farm!");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare farm data according to API requirements
      final farmData = {
        "farm_name": _nameController.text.trim(),
        "location": _selectedAddress,
        "total_area": 0.0, // You might want to add a field for this or get it from location
        "farm_type": "poultry", // You might want to add a field for farm type selection
        "description": _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        "gps_coordinates": {
          "address": _selectedAddress,
          "latitude": _latitude,
          "longitude": _longitude,
          // Add other location details if available from your location picker
        }
      };

      // Remove null values from the request body
      farmData.removeWhere((key, value) => value == null);

      // Make API call
      final response = await apiClient.post(
        '/farms',
        body: farmData,
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        // Success
        ToastUtil.showSuccess('Farm "${_nameController.text}" created successfully!');
        // Pop the screen with success result
        if (context.mounted) {
          context.pop(true);
        }
      } else {
        // Handle API error
        final errorMessage = _parseErrorMessage(response.body);
        ToastUtil.showError('Failed to create farm: $errorMessage');
      }
    } catch (e) {
      // Handle network or other errors
      ToastUtil.showError('Error creating farm: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _parseErrorMessage(String responseBody) {
    try {
      final Map<String, dynamic> errorJson =
      Map<String, dynamic>.from(json.decode(responseBody));

      // Try to extract error message from common response formats
      if (errorJson.containsKey('message')) {
        return errorJson['message'];
      } else if (errorJson.containsKey('error')) {
        return errorJson['error'];
      } else if (errorJson.containsKey('detail')) {
        return errorJson['detail'];
      }

      return 'Unknown error occurred';
    } catch (e) {
      return 'Unable to parse error response';
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}