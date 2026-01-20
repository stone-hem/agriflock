import 'package:agriflock360/features/farmer/vet/models/my_order_list_item.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:math' as math;

class MyOrderTrackingScreen extends StatefulWidget {
  final MyOrderListItem order;

  const MyOrderTrackingScreen({super.key, required this.order});

  @override
  State<MyOrderTrackingScreen> createState() => _MyOrderTrackingScreenState();
}

class _MyOrderTrackingScreenState extends State<MyOrderTrackingScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    try {
      // Parse farmer location
      final farmerLocation = widget.order.parsedFarmerLocation;
      final vetLocation = widget.order.parsedVetLocation;

      if (farmerLocation != null && vetLocation != null) {
        // FIXED: Coordinates were swapped - vet should get vetLocation, farmer should get farmerLocation
        final vetLat = vetLocation['latitude'];
        final vetLng = vetLocation['longitude'];
        final farmerLat = farmerLocation['latitude'];
        final farmerLng = farmerLocation['longitude'];

        if (vetLat == null || vetLng == null || farmerLat == null || farmerLng == null) {
          print('Error: Missing coordinate values');
          return;
        }

        // Vet marker
        final vetMarker = Marker(
          markerId: const MarkerId('vet_location'),
          position: LatLng(
            (vetLat as num).toDouble(),
            (vetLng as num).toDouble(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: InfoWindow(
            title: 'Vet Location',
            snippet: widget.order.vetAddress ?? 'Vet Location',
          ),
        );

        // Farmer marker
        final farmerMarker = Marker(
          markerId: const MarkerId('farmer_location'),
          position: LatLng(
            (farmerLat as num).toDouble(),
            (farmerLng as num).toDouble(),
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          infoWindow: InfoWindow(
            title: 'Your Farm',
            snippet: widget.order.farmerAddress ?? 'Farm Location',
          ),
        );

        // Polyline between vet and farmer
        final polyline = Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 4,
          points: [
            LatLng(
              (vetLat as num).toDouble(),
              (vetLng as num).toDouble(),
            ),
            LatLng(
              (farmerLat as num).toDouble(),
              (farmerLng as num).toDouble(),
            ),
          ],
        );

        if (mounted) {
          setState(() {
            _markers.clear();
            _markers.add(vetMarker);
            _markers.add(farmerMarker);
            _polylines.clear();
            _polylines.add(polyline);
          });
        }
      }
    } catch (e) {
      print('Error initializing map: $e');
      debugPrint('Full error stack: ${e.toString()}');
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    try {
      _mapController = controller;
      _isMapReady = true;

      final farmerLocation = widget.order.parsedFarmerLocation;
      final vetLocation = widget.order.parsedVetLocation;

      if (farmerLocation != null && vetLocation != null) {
        final vetLat = vetLocation['latitude'];
        final vetLng = vetLocation['longitude'];
        final farmerLat = farmerLocation['latitude'];
        final farmerLng = farmerLocation['longitude'];

        if (vetLat != null && vetLng != null && farmerLat != null && farmerLng != null) {
          final vetLatDouble = (vetLat as num).toDouble();
          final vetLngDouble = (vetLng as num).toDouble();
          final farmerLatDouble = (farmerLat as num).toDouble();
          final farmerLngDouble = (farmerLng as num).toDouble();

          // Calculate bounds with proper min/max
          final minLat = math.min(farmerLatDouble, vetLatDouble);
          final maxLat = math.max(farmerLatDouble, vetLatDouble);
          final minLng = math.min(farmerLngDouble, vetLngDouble);
          final maxLng = math.max(farmerLngDouble, vetLngDouble);

          // Add padding to bounds
          final padding = 0.01;

          // Delay the camera animation to ensure map is fully ready
          await Future.delayed(const Duration(milliseconds: 500));

          if (mounted && _mapController != null) {
            await _mapController!.animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: LatLng(minLat - padding, minLng - padding),
                  northeast: LatLng(maxLat + padding, maxLng + padding),
                ),
                50, // padding
              ),
            );
          }
        }
      }
    } catch (e) {
      print('Error in onMapCreated: $e');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'REVIEWED':
        return Colors.blue;
      case 'SCHEDULED':
        return Colors.purple;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to get status text
  String _getStatusText(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Pending Review';
      case 'REVIEWED':
        return 'Reviewed';
      case 'SCHEDULED':
        return 'Scheduled';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Helper to get first service name
  String _getFirstServiceName() {
    if (widget.order.services.isNotEmpty) {
      return widget.order.services.first.name;
    } else if (widget.order.serviceCosts.isNotEmpty) {
      return widget.order.serviceCosts.first.serviceName;
    }
    return 'Vet Service';
  }

  // Helper to get vet specialization
  String _getVetSpecialization() {
    if (widget.order.vetSpecialization.isNotEmpty) {
      return widget.order.vetSpecialization.first.replaceAll('_', ' ');
    }
    return 'General Veterinarian';
  }

  // Helper to get house and batch info
  String _getHouseInfo() {
    if (widget.order.houses.isNotEmpty) {
      final house = widget.order.houses.first;
      return house.name;
    }
    return 'No House Info';
  }

  String _getBatchInfo() {
    if (widget.order.batches.isNotEmpty) {
      final batch = widget.order.batches.first;
      return batch.name;
    }
    return 'No Batch Info';
  }

  Widget _buildOrderStatusCard() {
    final statusColor = _getStatusColor(widget.order.status);
    final statusText = _getStatusText(widget.order.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Order Status',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeline() {
    final isPending = widget.order.status.toUpperCase() == 'PENDING';
    final isReviewed = widget.order.reviewedAt != null;
    final isScheduled = widget.order.scheduledAt != null;
    final isCompleted = widget.order.status.toUpperCase() == 'COMPLETED';
    final isCancelled = widget.order.status.toUpperCase() == 'CANCELLED';

    final steps = [
      _buildTimelineStep(
        'Order Placed',
        'Your request was submitted',
        true,
        Icons.check_circle,
        widget.order.submittedAt,
      ),
      _buildTimelineStep(
        'Vet Reviewed',
        'Vet reviewed your request',
        isReviewed || isScheduled || isCompleted,
        Icons.check_circle,
        widget.order.reviewedAt,
      ),
      _buildTimelineStep(
        'Scheduled',
        'Visit date confirmed',
        isScheduled || isCompleted,
        Icons.calendar_today,
        widget.order.scheduledAt,
      ),
      _buildTimelineStep(
        'Completed',
        'Service has been completed',
        isCompleted && !isCancelled,
        Icons.done_all,
        widget.order.completedAt,
      ),
    ];

    return Column(children: steps);
  }

  Widget _buildTimelineStep(String title, String description, bool isCompleted, IconData icon, DateTime? date) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.grey.shade300,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.white : Colors.grey,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (date != null)
                  Text(
                    '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalInfo() {
    final scheduledAt = widget.order.scheduledAt;

    if (scheduledAt == null) {
      return const SizedBox();
    }

    // Safely handle preferredTime string
    String timeString = 'Time TBD';
    try {
      if (widget.order.preferredTime.isNotEmpty) {
        timeString = widget.order.preferredTime.length >= 5
            ? widget.order.preferredTime.substring(0, 5)
            : widget.order.preferredTime;
      }
    } catch (e) {
      print('Error formatting time: $e');
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.blue.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.blue.shade600, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Scheduled Date',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${widget.order.preferredDate.year}-${widget.order.preferredDate.month.toString().padLeft(2, '0')}-${widget.order.preferredDate.day.toString().padLeft(2, '0')} at $timeString',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get screen height to calculate map height
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = kToolbarHeight + MediaQuery.of(context).padding.top;
    final mapHeight = (screenHeight - appBarHeight) * 0.45;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text('Order ${widget.order.orderNumber}'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Map Section with fixed height
          SizedBox(
            height: mapHeight,
            child: GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: const CameraPosition(
                target: LatLng(-1.2921, 36.8219), // Nairobi coordinates as fallback
                zoom: 12,
              ),
              markers: _markers,
              polylines: _polylines,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
            ),
          ),

          // Scrollable Order Info Section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Drag handle indicator
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Vet Info
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          child: const Icon(Icons.pets, color: Colors.blue),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.order.vetName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                _getVetSpecialization(),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.call, color: Colors.green.shade600),
                          onPressed: () {
                            // TODO: Implement call functionality
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Services Info
                    if (widget.order.services.isNotEmpty || widget.order.serviceCosts.isNotEmpty)
                      Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Services',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              ..._buildServicesList(),
                            ],
                          ),
                        ),
                      ),
                    if (widget.order.services.isNotEmpty || widget.order.serviceCosts.isNotEmpty)
                      const SizedBox(height: 16),

                    // Farm Info
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Farm Details',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.home_work, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    _getHouseInfo(),
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Batch: ${_getBatchInfo()}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.pets, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Total Birds: ${widget.order.birdsCount}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (widget.order.birdTypeName != null) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.category, size: 16, color: Colors.grey.shade600),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Bird Type: ${widget.order.birdTypeName}',
                                      style: TextStyle(
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Arrival Info
                    _buildArrivalInfo(),
                    const SizedBox(height: 16),

                    // Order Status
                    _buildOrderStatusCard(),
                    const SizedBox(height: 16),

                    // Cost Summary
                    Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.shade300),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cost Summary',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildCostRow('Service Fee', widget.order.serviceFee),
                            _buildCostRow('Mileage Fee', widget.order.mileageFee),
                            _buildCostRow('Distance', widget.order.distanceKm, isDistance: true),
                            if (widget.order.prioritySurcharge > 0)
                              _buildCostRow('Priority Surcharge', widget.order.prioritySurcharge),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  'KES ${widget.order.totalEstimatedCost.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  widget.order.isPaid ? Icons.check_circle : Icons.pending,
                                  color: widget.order.isPaid ? Colors.green : Colors.orange,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.order.isPaid ? 'Payment Completed' : 'Payment Pending',
                                  style: TextStyle(
                                    color: widget.order.isPaid ? Colors.green : Colors.orange,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              // TODO: Implement message functionality
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            icon: const Icon(Icons.message),
                            label: const Text('Message Vet'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              _initializeMap(); // Refresh map
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Refresh Location'),
                          ),
                        ),
                      ],
                    ),

                    // Bottom padding for better scrolling experience
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildServicesList() {
    final widgets = <Widget>[];

    // Add services
    for (final service in widget.order.services) {
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                service.name,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              Text(
                'KES ${service.cost.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Add service costs (if different from services)
    for (final serviceCost in widget.order.serviceCosts) {
      // Check if this service is already in the services list
      final isDuplicate = widget.order.services.any((s) => s.id == serviceCost.serviceId);
      if (!isDuplicate) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  serviceCost.serviceName,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  'KES ${serviceCost.cost.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _buildCostRow(String label, double amount, {bool isDistance = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          Text(
            isDistance
                ? '${amount.toStringAsFixed(2)} km'
                : 'KES ${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}