import 'package:agriflock360/features/farmer_vet/models/vet_officer.dart';
import 'package:agriflock360/features/farmer_vet/models/vet_order.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainVetScreen extends StatefulWidget {
  const MainVetScreen({super.key});

  @override
  State<MainVetScreen> createState() => _MainVetScreenState();
}

class _MainVetScreenState extends State<MainVetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  // Sample data
  List<VetOfficer> _allVets = [];
  List<VetOfficer> _filteredVets = [];
  List<VetOfficer> _recommendedVets = [];
  List<VetOrder> _vetOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _initializeData();
    _searchController.addListener(_filterVets);
  }

  void _initializeData() {
    // Initialize vets
    _allVets = [
      VetOfficer(
        id: '1',
        name: 'Dr. Sarah Johnson',
        specialization: 'Poultry Specialist',
        experience: '12 years',
        rating: 4.9,
        distance: '2.5 km',
        phone: '+1 234-567-8901',
        email: 'sarah.j@vetcare.com',
        clinic: 'Green Valley Veterinary Clinic',
        address: '123 Farm Road, Agricultural Zone',
        latitude: -1.286389, // Nairobi coordinates
        longitude: 36.817223,
        isAvailable: true,
        consultationFee: '\$75',
        emergencyService: true,
        languages: ['English', 'Spanish'],
        services: ['Vaccination', 'Health Check', 'Emergency Care', 'Consultation'],
        avatarColor: Colors.blue,
      ),
      VetOfficer(
        id: '2',
        name: 'Dr. Michael Chen',
        specialization: 'Avian Diseases Expert',
        experience: '8 years',
        rating: 4.8,
        distance: '5.2 km',
        phone: '+1 234-567-8902',
        email: 'm.chen@aviancare.com',
        clinic: 'Avian Health Center',
        address: '456 Poultry Lane, Farm District',
        latitude: -1.300000,
        longitude: 36.783333,
        isAvailable: true,
        consultationFee: '\$85',
        emergencyService: true,
        languages: ['English', 'Mandarin'],
        services: ['Disease Diagnosis', 'Treatment Plans', 'Biosecurity', 'Training'],
        avatarColor: Colors.green,
      ),
      VetOfficer(
        id: '3',
        name: 'Dr. Maria Rodriguez',
        specialization: 'Livestock Veterinarian',
        experience: '15 years',
        rating: 4.7,
        distance: '8.1 km',
        phone: '+1 234-567-8903',
        email: 'm.rodriguez@farmvet.com',
        clinic: 'Farm Animal Clinic',
        address: '789 Ranch Street, Rural Area',
        latitude: -1.250000,
        longitude: 36.850000,
        isAvailable: false,
        consultationFee: '\$95',
        emergencyService: false,
        languages: ['English', 'Spanish', 'Portuguese'],
        services: ['Livestock Care', 'Herd Health', 'Preventive Medicine', 'Surgery'],
        avatarColor: Colors.orange,
      ),
    ];

    // Initialize orders
    final now = DateTime.now();
    _vetOrders = [
      VetOrder(
        id: 'ORD001',
        vetId: '1',
        vetName: 'Dr. Sarah Johnson',
        serviceType: 'Vaccination Service',
        priority: 'Normal',
        scheduledDate: now.add(const Duration(days: 1)),
        scheduledTime: const TimeOfDay(hour: 10, minute: 30),
        status: OrderStatus.confirmed,
        totalCost: 12500,
        consultationFee: 5000,
        serviceFee: 3500,
        mileageFee: 1200,
        prioritySurcharge: 0,
        houseName: 'Main Poultry House',
        batchName: 'Batch 123 - Broilers',
        reason: 'Annual vaccination program',
        notes: 'Please bring avian flu vaccines',
        vetLocation: VetLocation(
          latitude: -1.286389,
          longitude: 36.817223,
          address: '123 Farm Road, Agricultural Zone',
        ),
        farmerLocation: FarmerLocation(
          latitude: -1.2921,
          longitude: 36.8219,
          address: 'My Farm, Kiambu Road',
        ),
        estimatedArrivalTime: now.add(const Duration(hours: 25)),
      ),
      VetOrder(
        id: 'ORD002',
        vetId: '2',
        vetName: 'Dr. Michael Chen',
        serviceType: 'Emergency Visit',
        priority: 'Emergency',
        scheduledDate: now,
        scheduledTime: const TimeOfDay(hour: 14, minute: 0),
        status: OrderStatus.enRoute,
        totalCost: 18200,
        consultationFee: 5000,
        serviceFee: 8000,
        mileageFee: 1500,
        prioritySurcharge: 3700,
        houseName: 'Secondary Poultry House',
        batchName: 'Batch 124 - Layers',
        reason: 'Sudden mortality in layers',
        notes: 'Birds showing respiratory symptoms',
        vetLocation: VetLocation(
          latitude: -1.300000,
          longitude: 36.783333,
          address: '456 Poultry Lane, Farm District',
        ),
        farmerLocation: FarmerLocation(
          latitude: -1.2921,
          longitude: 36.8219,
          address: 'My Farm, Kiambu Road',
        ),
        estimatedArrivalTime: now.add(const Duration(minutes: 45)),
      ),
      VetOrder(
        id: 'ORD003',
        vetId: '3',
        vetName: 'Dr. Maria Rodriguez',
        serviceType: 'Routine Check-up',
        priority: 'Urgent',
        scheduledDate: now.add(const Duration(days: 3)),
        scheduledTime: const TimeOfDay(hour: 9, minute: 0),
        status: OrderStatus.pending,
        totalCost: 9600,
        consultationFee: 5000,
        serviceFee: 2000,
        mileageFee: 2000,
        prioritySurcharge: 600,
        houseName: 'Main Poultry House',
        batchName: 'Batch 125 - Broilers',
        reason: 'Monthly health check',
        notes: 'Focus on weight gain monitoring',
        vetLocation: VetLocation(
          latitude: -1.250000,
          longitude: 36.850000,
          address: '789 Ranch Street, Rural Area',
        ),
        farmerLocation: FarmerLocation(
          latitude: -1.2921,
          longitude: 36.8219,
          address: 'My Farm, Kiambu Road',
        ),
        estimatedArrivalTime: now.add(const Duration(days: 3, hours: 1)),
      ),
      VetOrder(
        id: 'ORD004',
        vetId: '1',
        vetName: 'Dr. Sarah Johnson',
        serviceType: 'Consultation',
        priority: 'Normal',
        scheduledDate: now.subtract(const Duration(days: 5)),
        scheduledTime: const TimeOfDay(hour: 11, minute: 0),
        status: OrderStatus.completed,
        totalCost: 8500,
        consultationFee: 5000,
        serviceFee: 1500,
        mileageFee: 1200,
        prioritySurcharge: 0,
        houseName: 'Quarantine House',
        batchName: 'Batch 127 - Recovery',
        reason: 'Follow-up on treatment progress',
        notes: 'All birds recovered well',
        vetLocation: VetLocation(
          latitude: -1.286389,
          longitude: 36.817223,
          address: '123 Farm Road, Agricultural Zone',
        ),
        farmerLocation: FarmerLocation(
          latitude: -1.2921,
          longitude: 36.8219,
          address: 'My Farm, Kiambu Road',
        ),
        estimatedArrivalTime: now.subtract(const Duration(days: 5, hours: 1)),
        serviceCompletedDate: now.subtract(const Duration(days: 5)),
      ),
    ];

    _recommendedVets = _allVets.where((vet) => vet.rating >= 4.7).toList();
    _filteredVets = _allVets;
  }

  void _filterVets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredVets = _allVets;
      } else {
        _filteredVets = _allVets.where((vet) {
          return vet.name.toLowerCase().contains(query) ||
              vet.specialization.toLowerCase().contains(query) ||
              vet.clinic.toLowerCase().contains(query) ||
              vet.services.any((service) => service.toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  void _navigateToVetDetails(VetOfficer vet) {
    context.push('/vet-details', extra: vet);
  }

  void _navigateToOrderForm(VetOfficer vet) {
    context.push('/vet-order-details', extra: vet);
  }

  void _navigateToOrderTracking(VetOrder order) {
    context.push('/vet-order-tracking', extra: order);
  }

  // Tab 1: Browse Vets
  Widget _buildBrowseVetsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  Icon(Icons.medical_services, color: Colors.green.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Professional Veterinary Services',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Book appointments, emergency visits, or consultations with certified veterinarians',
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

          // Search Bar
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  const Icon(Icons.search, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search by name, specialization, or service...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Available Now'),
                  selected: false,
                  onSelected: (selected) {},
                  backgroundColor: Colors.green.shade50,
                  selectedColor: Colors.green,
                  labelStyle: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Emergency Service'),
                  selected: false,
                  onSelected: (selected) {},
                  backgroundColor: Colors.red.shade50,
                  selectedColor: Colors.red,
                  labelStyle: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Top Rated'),
                  selected: false,
                  onSelected: (selected) {},
                  backgroundColor: Colors.amber.shade50,
                  selectedColor: Colors.amber,
                  labelStyle: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Nearby'),
                  selected: false,
                  onSelected: (selected) {},
                  backgroundColor: Colors.blue.shade50,
                  selectedColor: Colors.blue,
                  labelStyle: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Recommended Section
          if (_recommendedVets.isNotEmpty && _searchController.text.isEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recommended Vets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_recommendedVets.length} available',
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Top-rated veterinarians in your area',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ..._recommendedVets.map(_buildVetCard),
                const SizedBox(height: 24),
              ],
            ),

          // All Vets Section
          Text(
            _searchController.text.isEmpty ? 'All Veterinary Officers' : 'Search Results',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_filteredVets.length} vets found',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          if (_filteredVets.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No veterinarians found matching your search',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else
            ..._filteredVets.map(_buildVetCard),
        ],
      ),
    );
  }

  // Tab 2: Track Orders
  Widget _buildTrackOrdersTab() {
    final activeOrders = _vetOrders.where((order) => order.status != OrderStatus.completed).toList();
    final completedOrders = _vetOrders.where((order) => order.status == OrderStatus.completed).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
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
                  Icon(Icons.track_changes, color: Colors.blue.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Track Your Vet Orders',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Monitor your veterinary service requests and track vet locations',
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

          // Active Orders Section
          Text(
            'Active Orders',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${activeOrders.length} ongoing service${activeOrders.length == 1 ? '' : 's'}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          if (activeOrders.isEmpty)
            _buildEmptyState(
              icon: Icons.schedule,
              title: 'No Active Orders',
              message: 'You don\'t have any active veterinary service requests',
            )
          else
            ...activeOrders.map(_buildOrderCard),

          const SizedBox(height: 32),

          // Completed Orders Section
          Text(
            'Completed Orders',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${completedOrders.length} past service${completedOrders.length == 1 ? '' : 's'}',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),

          if (completedOrders.isEmpty)
            _buildEmptyState(
              icon: Icons.history,
              title: 'No Completed Orders',
              message: 'Your completed veterinary services will appear here',
            )
          else
            ...completedOrders.map(_buildOrderCard),

          const SizedBox(height: 32),

          // Order Status Legend
          Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Order Status Legend',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusLegendItem('Pending', Colors.orange, 'Waiting for vet confirmation'),
                  _buildStatusLegendItem('Confirmed', Colors.blue, 'Vet has accepted your request'),
                  _buildStatusLegendItem('En Route', Colors.purple, 'Vet is on the way to your farm'),
                  _buildStatusLegendItem('Arrived', Colors.green, 'Vet has arrived at your location'),
                  _buildStatusLegendItem('In Service', Colors.indigo, 'Vet is providing service'),
                  _buildStatusLegendItem('Completed', Colors.grey, 'Service has been completed'),
                  _buildStatusLegendItem('Cancelled', Colors.red, 'Order was cancelled'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(VetOrder order) {
    final timeUntilArrival = order.estimatedArrivalTime.difference(DateTime.now());
    final isWithinTrackingWindow = timeUntilArrival.inHours <= 1 && timeUntilArrival.inMinutes > 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToOrderTracking(order),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.vetName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          order.serviceType,
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(order.status),
                      ),
                    ),
                    child: Text(
                      _getStatusText(order.status),
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Order Details
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    order.scheduledDate.toIso8601String(),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Text(
                    order.scheduledTime.format(context),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Row(
                children: [
                  Icon(Icons.home_work, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${order.houseName} • ${order.batchName}',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tracking Info
              if (isWithinTrackingWindow && order.status == OrderStatus.enRoute)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.location_on, color: Colors.blue.shade600, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Vet is on the way!',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            Text(
                              'Estimated arrival: ${timeUntilArrival.inMinutes} minutes',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.track_changes, color: Colors.blue.shade600),
                        onPressed: () => _navigateToOrderTracking(order),
                      ),
                    ],
                  ),
                ),

              // Action Buttons
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement call functionality
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: BorderSide(color: Colors.grey.shade400),
                      ),
                      child: const Text('Contact Vet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _navigateToOrderTracking(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Track Order'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVetCard(VetOfficer vet) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToVetDetails(vet),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Vet Avatar
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: vet.avatarColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    color: vet.avatarColor,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Vet Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          vet.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: vet.isAvailable
                                ? Colors.green.withOpacity(0.1)
                                : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: vet.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          child: Text(
                            vet.isAvailable ? 'Available' : 'Busy',
                            style: TextStyle(
                              color: vet.isAvailable
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vet.specialization,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.medical_services,
                          color: Colors.grey.shade500,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            vet.clinic,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 12,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber.shade700,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vet.rating.toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.monetization_on,
                              color: Colors.green.shade600,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vet.consultationFee,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.green.shade700,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: Colors.grey.shade500,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              vet.distance,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: vet.services.take(3).map((service) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            service,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusLegendItem(String status, Color color, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
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

  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.enRoute:
        return Colors.purple;
      case OrderStatus.arrived:
        return Colors.green;
      case OrderStatus.inService:
        return Colors.indigo;
      case OrderStatus.completed:
        return Colors.grey;
      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.enRoute:
        return 'En Route';
      case OrderStatus.arrived:
        return 'Arrived';
      case OrderStatus.inService:
        return 'In Service';
      case OrderStatus.completed:
        return 'Completed';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
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
            const Text('Agriflock 360'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.green,
          labelColor: Colors.green,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(
              icon: Icon(Icons.search),
              text: 'Find Vets',
            ),
            Tab(
              icon: Icon(Icons.track_changes),
              text: 'Track Orders',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildBrowseVetsTab(),
          _buildTrackOrdersTab(),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}