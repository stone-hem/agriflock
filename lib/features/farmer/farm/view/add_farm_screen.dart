// lib/farms/screens/add_farm_screen.dart

import 'dart:io';
import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/core/widgets/location_picker_step.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:agriflock360/features/farmer/farm/repositories/farm_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AddFarmScreen extends StatefulWidget {
  const AddFarmScreen({super.key});

  @override
  State<AddFarmScreen> createState() => _AddFarmScreenState();
}

class _AddFarmScreenState extends State<AddFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _farmRepository = FarmRepository();

  // Location data
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  // Farm photo
  File? _farmPhotoFile;

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
              // Farm Photo Upload
              PhotoUpload(
                file: _farmPhotoFile,
                onFileSelected: (File? file) {
                  setState(() {
                    _farmPhotoFile = file;
                  });
                },
                title: 'Farm Photo (Optional)',
                description: 'Upload a photo of your farm',
                primaryColor: Colors.green,
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

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare farm data according to API requirements
      final farmData = {
        "farm_name": _nameController.text.trim(),
        "location": _selectedAddress,
        "total_area": 0.0,
        "farm_type": "poultry",
        "description": _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      };

      // Add GPS coordinates if location is selected
      if (_selectedAddress != null && _latitude != null && _longitude != null) {
        farmData["location"] = {
          "address": {
            "formatted_address": _selectedAddress,
          },
          "latitude": _latitude,
          "longitude": _longitude,
        };
      }

      // Create farm using repository
      await _farmRepository.createFarm(farmData, photoFile: _farmPhotoFile);

      // Success
      ToastUtil.showSuccess(
          'Farm "${_nameController.text}" created successfully!');

      // Pop the screen with success result
      if (context.mounted) {
        context.pop();
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}