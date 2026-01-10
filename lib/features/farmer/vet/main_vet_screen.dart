import 'package:agriflock360/features/farmer/vet/tabs/browse_vets_tab.dart';
import 'package:agriflock360/features/farmer/vet/tabs/completed_orders_tab.dart';
import 'package:agriflock360/features/farmer/vet/tabs/track_orders_tab.dart';
import 'package:flutter/material.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_officer.dart';
import 'package:agriflock360/features/farmer/vet/models/vet_order.dart';

class MainVetScreen extends StatefulWidget {
  const MainVetScreen({super.key});

  @override
  State<MainVetScreen> createState() => _MainVetScreenState();
}

class _MainVetScreenState extends State<MainVetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<VetOfficer> _allVets = [];
  List<VetOrder> _vetOrders = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
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
        latitude: -1.286389,
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
        estimatedArrivalTime: now.add(const Duration(hours: 25)), isPaid: true, userRating: 5, userComment: 'Noting',
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
        estimatedArrivalTime: now.add(const Duration(minutes: 45)), isPaid: true, userRating: 3, userComment: '',
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
        estimatedArrivalTime: now.add(const Duration(days: 3, hours: 1)), isPaid: true, userRating: 5, userComment: 'yey',
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
        isPaid: false,
        userRating: 0,
        userComment: '',
      ),
      VetOrder(
        id: 'ORD005',
        vetId: '2',
        vetName: 'Dr. Michael Chen',
        serviceType: 'Disease Diagnosis',
        priority: 'Urgent',
        scheduledDate: now.subtract(const Duration(days: 2)),
        scheduledTime: const TimeOfDay(hour: 15, minute: 30),
        status: OrderStatus.completed,
        totalCost: 11200,
        consultationFee: 5000,
        serviceFee: 3500,
        mileageFee: 1500,
        prioritySurcharge: 1200,
        houseName: 'Main Poultry House',
        batchName: 'Batch 128 - Layers',
        reason: 'Suspected Newcastle disease',
        notes: 'Samples collected for lab testing',
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
        estimatedArrivalTime: now.subtract(const Duration(days: 2, hours: 2)),
        serviceCompletedDate: now.subtract(const Duration(days: 2)),
        isPaid: true,
        userRating: 5,
        userComment: 'Excellent service! Quick diagnosis and helpful advice.',
      ),
      VetOrder(
        id: 'ORD006',
        vetId: '3',
        vetName: 'Dr. Maria Rodriguez',
        serviceType: 'Preventive Medicine',
        priority: 'Normal',
        scheduledDate: now.subtract(const Duration(days: 7)),
        scheduledTime: const TimeOfDay(hour: 13, minute: 0),
        status: OrderStatus.completed,
        totalCost: 9700,
        consultationFee: 5000,
        serviceFee: 2000,
        mileageFee: 2000,
        prioritySurcharge: 700,
        houseName: 'Secondary Poultry House',
        batchName: 'Batch 129 - Broilers',
        reason: 'Seasonal preventive treatment',
        notes: 'Applied deworming and vitamin supplements',
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
        estimatedArrivalTime: now.subtract(const Duration(days: 7, hours: 1)),
        serviceCompletedDate: now.subtract(const Duration(days: 7)),
        isPaid: true,
        userRating: 4,
        userComment: 'Good service but a bit late for the appointment.',
      ),
    ];
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
            Tab(
              icon: Icon(Icons.history),
              text: 'Completed',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          BrowseVetsTab(),
          TrackOrdersTab(
            vetOrders: _vetOrders,
          ),
          CompletedOrdersTab(
            vetOrders: _vetOrders,
            onOrderUpdated: (updatedOrder) {
              setState(() {
                final index = _vetOrders.indexWhere((order) => order.id == updatedOrder.id);
                if (index != -1) {
                  _vetOrders[index] = updatedOrder;
                }
              });
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}