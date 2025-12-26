import 'package:agriflock360/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';

class LocationPickerStep extends StatefulWidget {
  final String? selectedAddress;
  final double? latitude;
  final double? longitude;
  final Function(String address, double lat, double lng) onLocationSelected;
  final Color primaryColor;

  const LocationPickerStep({
    super.key,
    this.selectedAddress,
    this.latitude,
    this.longitude,
    required this.onLocationSelected,
    this.primaryColor = Colors.green,
  });

  @override
  State<LocationPickerStep> createState() => _LocationPickerStepState();
}

class _LocationPickerStepState extends State<LocationPickerStep> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  String? _selectedAddress;
  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    // Initialize controller and focus node ONCE
    _controller = TextEditingController(text: widget.selectedAddress ?? '');
    _focusNode = FocusNode();

    _selectedAddress = widget.selectedAddress;
    _latitude = widget.latitude;
    _longitude = widget.longitude;

    // Listen to focus changes
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    // This helps prevent focus issues with other text fields
    if (!_focusNode.hasFocus) {
      // When focus is lost, ensure the field is properly unfocused
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(LocationPickerStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if the parent widget's values changed
    if (widget.selectedAddress != oldWidget.selectedAddress &&
        widget.selectedAddress != _selectedAddress) {
      _controller.text = widget.selectedAddress ?? '';
      _selectedAddress = widget.selectedAddress;
      _latitude = widget.latitude;
      _longitude = widget.longitude;
    }
  }

  @override
  void dispose() {
    // Properly dispose focus node and controller
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleLocationSelected(Prediction prediction) {
    final address = prediction.description ?? '';
    final lat = double.tryParse(prediction.lat ?? '0');
    final lng = double.tryParse(prediction.lng ?? '0');

    if (address.isNotEmpty && lat != null && lng != null) {
      setState(() {
        _selectedAddress = address;
        _latitude = lat;
        _longitude = lng;
      });

      // Notify parent widget
      widget.onLocationSelected(address, lat, lng);

      // CRITICAL: Unfocus this field immediately after selection
      _focusNode.unfocus();

      // Extra safety: request focus removal from the entire scope
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          FocusScope.of(context).unfocus();
        }
      });
    }
  }

  void _clearLocation() {
    setState(() {
      _controller.clear();
      _selectedAddress = null;
      _latitude = null;
      _longitude = null;
    });

    // Unfocus when clearing
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Your Location',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Search and select your farm or practice location',
          style: TextStyle(
            fontSize: 16,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 40),

        // Google Places Autocomplete TextField
        Focus(
          // Wrap in Focus widget for better focus control
          onFocusChange: (hasFocus) {
            if (!hasFocus) {
              // Additional handling when focus is lost
              setState(() {});
            }
          },
          child: GooglePlaceAutoCompleteTextField(
            textEditingController: _controller,
            googleAPIKey: AppConstants.googleApiKey,
            focusNode: _focusNode, // Explicitly provide focus node
            inputDecoration: InputDecoration(
              hintText: 'Search for your location',
              labelText: 'Location',
              prefixIcon: Icon(
                Icons.location_on,
                color: widget.primaryColor,
              ),
              suffixIcon: _controller.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearLocation,
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: widget.primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
            debounceTime: 800,
            countries: const ["ke"],
            isLatLngRequired: true,
            getPlaceDetailWithLatLng: _handleLocationSelected,
            itemClick: (Prediction prediction) {
              _controller.text = prediction.description ?? "";
              _controller.selection = TextSelection.fromPosition(
                TextPosition(offset: prediction.description?.length ?? 0),
              );
            },
            seperatedBuilder: const Divider(),
            itemBuilder: (context, index, Prediction prediction) {
              return Container(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: widget.primaryColor,
                    ),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        prediction.description ?? "",
                        style: const TextStyle(
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            isCrossBtnShown: true,
          ),
        ),

        const SizedBox(height: 30),

        // Selected Location Display
        if (_selectedAddress != null && _latitude != null && _longitude != null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: widget.primaryColor.withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: widget.primaryColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Location Selected',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedAddress!,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),

        const SizedBox(height: 20),

        // Info Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Start typing to search for your location. Select from the dropdown suggestions to set your exact location.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade900,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}