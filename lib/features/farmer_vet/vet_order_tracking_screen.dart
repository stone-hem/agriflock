import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:agriflock360/features/farmer_vet/models/vet_order.dart';

class VetOrderTrackingScreen extends StatefulWidget {
  final VetOrder order;

  const VetOrderTrackingScreen({super.key, required this.order});

  @override
  State<VetOrderTrackingScreen> createState() => _VetOrderTrackingScreenState();
}

class _VetOrderTrackingScreenState extends State<VetOrderTrackingScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  void _initializeMap() {
    // Vet marker
    final vetMarker = Marker(
      markerId: const MarkerId('vet_location'),
      position: LatLng(
        widget.order.vetLocation.latitude,
        widget.order.vetLocation.longitude,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      infoWindow: InfoWindow(
        title: 'Vet Location',
        snippet: widget.order.vetLocation.address,
      ),
    );

    // Farmer marker
    final farmerMarker = Marker(
      markerId: const MarkerId('farmer_location'),
      position: LatLng(
        widget.order.farmerLocation.latitude,
        widget.order.farmerLocation.longitude,
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: 'Your Farm',
        snippet: widget.order.farmerLocation.address,
      ),
    );

    // Polyline between vet and farmer
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      color: Colors.blue,
      width: 4,
      points: [
        LatLng(
          widget.order.vetLocation.latitude,
          widget.order.vetLocation.longitude,
        ),
        LatLng(
          widget.order.farmerLocation.latitude,
          widget.order.farmerLocation.longitude,
        ),
      ],
    );

    setState(() {
      _markers.add(vetMarker);
      _markers.add(farmerMarker);
      _polylines.add(polyline);
    });
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;

    // Fit bounds to show both markers
    await _mapController.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(
            widget.order.vetLocation.latitude - 0.01,
            widget.order.vetLocation.longitude - 0.01,
          ),
          northeast: LatLng(
            widget.order.vetLocation.latitude + 0.01,
            widget.order.vetLocation.longitude + 0.01,
          ),
        ),
        50, // padding
      ),
    );
  }

  Widget _buildOrderStatusCard() {
    final statusColors = {
      OrderStatus.pending: Colors.orange,
      OrderStatus.confirmed: Colors.blue,
      OrderStatus.enRoute: Colors.purple,
      OrderStatus.arrived: Colors.green,
      OrderStatus.inService: Colors.indigo,
      OrderStatus.completed: Colors.grey,
      OrderStatus.cancelled: Colors.red,
    };

    final statusTexts = {
      OrderStatus.pending: 'Pending',
      OrderStatus.confirmed: 'Confirmed',
      OrderStatus.enRoute: 'En Route',
      OrderStatus.arrived: 'Arrived',
      OrderStatus.inService: 'In Service',
      OrderStatus.completed: 'Completed',
      OrderStatus.cancelled: 'Cancelled',
    };

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: statusColors[widget.order.status]!),
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
                    color: statusColors[widget.order.status]!.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColors[widget.order.status]!),
                  ),
                  child: Text(
                    statusTexts[widget.order.status]!,
                    style: TextStyle(
                      color: statusColors[widget.order.status],
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
    final steps = [
      _buildTimelineStep(
        'Order Placed',
        'Your request was submitted',
        true,
        Icons.check_circle,
      ),
      _buildTimelineStep(
        'Vet Confirmed',
        'Dr. ${widget.order.vetName.split(' ').last} accepted',
        widget.order.status.index >= OrderStatus.confirmed.index,
        Icons.check_circle,
      ),
      _buildTimelineStep(
        'En Route',
        'Vet is on the way to your farm',
        widget.order.status.index >= OrderStatus.enRoute.index,
        Icons.directions_car,
      ),
      _buildTimelineStep(
        'Arrived',
        'Vet has arrived at your location',
        widget.order.status.index >= OrderStatus.arrived.index,
        Icons.location_on,
      ),
      _buildTimelineStep(
        'In Service',
        'Vet is providing service',
        widget.order.status.index >= OrderStatus.inService.index,
        Icons.medical_services,
      ),
      _buildTimelineStep(
        'Completed',
        'Service has been completed',
        widget.order.status.index >= OrderStatus.completed.index,
        Icons.done_all,
      ),
    ];

    return Column(children: steps);
  }

  Widget _buildTimelineStep(String title, String description, bool isCompleted, IconData icon) {
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArrivalInfo() {
    final now = DateTime.now();
    final difference = widget.order.estimatedArrivalTime.difference(now);
    final isVetEnRoute = widget.order.status == OrderStatus.enRoute;

    if (!isVetEnRoute || difference.inMinutes <= 0) {
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
            Icon(Icons.timer, color: Colors.blue.shade600, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Estimated Arrival',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    '${difference.inMinutes} minutes remaining',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                'Today at 10 Pm',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
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
    final mapHeight = (screenHeight - appBarHeight) * 0.45; // 45% of remaining screen

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Order Tracking'),
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
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  widget.order.vetLocation.latitude,
                  widget.order.vetLocation.longitude,
                ),
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

                    // Arrival Info
                    _buildArrivalInfo(),
                    const SizedBox(height: 16),

                    // Order Status
                    _buildOrderStatusCard(),
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
                              // TODO: Implement refresh location
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
}