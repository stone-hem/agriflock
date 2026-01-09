import 'dart:convert';
import 'dart:io';
import 'package:agriflock360/app_routes.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/core/widgets/location_picker_step.dart';
import 'package:agriflock360/core/widgets/photo_upload.dart';
import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:agriflock360/features/farmer/farm/repositories/farm_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditFarmScreen extends StatefulWidget {
  final FarmModel farm;

  const EditFarmScreen({
    super.key,
    required this.farm,
  });

  @override
  State<EditFarmScreen> createState() => _EditFarmScreenState();
}

class _EditFarmScreenState extends State<EditFarmScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
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
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.farm.farmName);
    _descriptionController =
        TextEditingController(text: widget.farm.description ?? '');

    // Initialize location data
    _selectedAddress = widget.farm.location;
    _latitude = widget.farm.gpsCoordinates?.latitude;
    _longitude = widget.farm.gpsCoordinates?.longitude;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Edit Farm'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _updateFarm,
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
              'Update',
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
                title: 'Farm Photo',
                description: widget.farm.imageUrl != null
                    ? 'Current photo will be replaced if you upload a new one'
                    : 'Upload a photo of your farm',
                primaryColor: Colors.green,
              ),

              // Show existing photo if available
              if (widget.farm.imageUrl != null && _farmPhotoFile == null) ...[
                const SizedBox(height: 12),
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(widget.farm.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ],
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

            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updateFarm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare farm data
      final farmData = {
        "farm_name": _nameController.text.trim(),
        "location": _selectedAddress,
        "description": _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
      };

      // Add GPS coordinates if location is selected
      if (_selectedAddress != null && _latitude != null && _longitude != null) {
        farmData["location"] = jsonEncode({
          "address": {
            "formatted_address": _selectedAddress,
          },
          "latitude": _latitude,
          "longitude": _longitude,
        });

      }

      // Update farm using repository
      final res=await _farmRepository.updateFarm(
        widget.farm.id,
        farmData,
        photoFile: _farmPhotoFile,
      );


      switch(res) {
        case Success<bool>():
        // Success
          ToastUtil.showSuccess(
              'Farm  updated successfully!');

          // Pop the screen with success result
          if (context.mounted) {
            context.pushReplacement(AppRoutes.farms);
          }
        case Failure<bool>(response:final response):
          ApiErrorHandler.handle(response);
      }


    }  finally {
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

