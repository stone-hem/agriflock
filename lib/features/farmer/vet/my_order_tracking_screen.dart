import 'package:agriflock360/features/farmer/vet/models/my_order_list_item.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MyOrderTrackingScreen extends StatefulWidget {
  final MyOrderListItem order;

  const MyOrderTrackingScreen({super.key, required this.order});

  @override
  State<MyOrderTrackingScreen> createState() => _MyOrderTrackingScreenState();
}

class _MyOrderTrackingScreenState extends State<MyOrderTrackingScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    // Parse farmer location
    final farmerLocation = widget.order.parsedFarmerLocation;
    final vetLocation = widget.order.parsedVetLocation;

    if (farmerLocation != null && vetLocation != null) {
      // Vet marker
      final vetMarker = Marker(
        markerId: const MarkerId('vet_location'),
        position: LatLng(
          vetLocation['latitude'] as double,
          vetLocation['longitude'] as double,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'Vet Location',
          snippet: vetLocation['address'] as String? ?? 'Vet Location',
        ),
      );

      // Farmer marker
      final farmerMarker = Marker(
        markerId: const MarkerId('farmer_location'),
        position: LatLng(
          farmerLocation['latitude'] as double,
          farmerLocation['longitude'] as double,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: InfoWindow(
          title: 'Your Farm',
          snippet: farmerLocation['address'] as String? ?? 'Farm Location',
        ),
      );

      // Polyline between vet and farmer
      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        color: Colors.blue,
        width: 4,
        points: [
          LatLng(
            vetLocation['latitude'] as double,
            vetLocation['longitude'] as double,
          ),
          LatLng(
            farmerLocation['latitude'] as double,
            farmerLocation['longitude'] as double,
          ),
        ],
      );

      setState(() {
        _markers.add(vetMarker);
        _markers.add(farmerMarker);
        _polylines.add(polyline);
      });
    }
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    final farmerLocation = widget.order.parsedFarmerLocation;
    final vetLocation = widget.order.parsedVetLocation;

    if (farmerLocation != null && vetLocation != null) {
      // Fit bounds to show both markers
      await _mapController.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(
              min(farmerLocation['latitude'] as double, vetLocation['latitude'] as double) - 0.01,
              min(farmerLocation['longitude'] as double, vetLocation['longitude'] as double) - 0.01,
            ),
            northeast: LatLng(
              max(farmerLocation['latitude'] as double, vetLocation['latitude'] as double) + 0.01,
              max(farmerLocation['longitude'] as double, vetLocation['longitude'] as double) + 0.01,
            ),
          ),
          50, // padding
        ),
      );
    }
  }

  // Helper method to get status color
  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'SCHEDULED':
        return Colors.blue;
      case 'EN_ROUTE':
        return Colors.purple;
      case 'IN_PROGRESS':
        return Colors.indigo;
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
        return 'Pending';
      case 'SCHEDULED':
        return 'Scheduled';
      case 'EN_ROUTE':
        return 'En Route';
      case 'IN_PROGRESS':
        return 'In Progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
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
        'Vet Confirmed',
        'Vet accepted your request',
        isScheduled || isCompleted,
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
        'In Progress',
        'Service is being provided',
        isCompleted,
        Icons.medical_services,
        widget.order.completedAt,
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
                    '${scheduledAt.day}/${scheduledAt.month}/${scheduledAt.year} at ${widget.order.preferredTime}',
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
                                widget.order.serviceType,
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
                                Icon(Icons.location_on, size: 16, color: Colors.grey.shade600),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    widget.order.houseName,
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
                                    'Batch: ${widget.order.batchName}',
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
                                    'Birds: ${widget.order.birdCount}',
                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
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
                            _buildCostRow('Consultation', widget.order.consultationFee),
                            _buildCostRow('Service Fee', widget.order.serviceFee),
                            _buildCostRow('Mileage Fee', widget.order.mileageFee),
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

  Widget _buildCostRow(String label, double amount) {
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
            'KES ${amount.toStringAsFixed(2)}',
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

// Helper function for min/max
double min(double a, double b) => a < b ? a : b;
double max(double a, double b) => a > b ? a : b;