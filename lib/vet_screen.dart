// vet_order_screen.dart
import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VetScreen extends StatefulWidget {
  const VetScreen({super.key});

  @override
  State<VetScreen> createState() => _VetScreenState();
}

class _VetScreenState extends State<VetScreen> {
  final _searchController = TextEditingController();
  List<VetOfficer> _allVets = [];
  List<VetOfficer> _filteredVets = [];
  List<VetOfficer> _recommendedVets = [];

  @override
  void initState() {
    super.initState();
    _initializeVets();
    _searchController.addListener(_filterVets);
  }

  void _initializeVets() {
    // Sample vet data
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
        isAvailable: false,
        consultationFee: '\$95',
        emergencyService: false,
        languages: ['English', 'Spanish', 'Portuguese'],
        services: ['Livestock Care', 'Herd Health', 'Preventive Medicine', 'Surgery'],
        avatarColor: Colors.orange,
      ),
      VetOfficer(
        id: '4',
        name: 'Dr. James Wilson',
        specialization: 'Animal Health Consultant',
        experience: '10 years',
        rating: 4.6,
        distance: '3.7 km',
        phone: '+1 234-567-8904',
        email: 'j.wilson@consultvet.com',
        clinic: 'Wilson Veterinary Services',
        address: '321 Harvest Avenue, Farming Community',
        isAvailable: true,
        consultationFee: '\$65',
        emergencyService: true,
        languages: ['English'],
        services: ['Consultation', 'Farm Visits', 'Health Plans', 'Record Keeping'],
        avatarColor: Colors.purple,
      ),
      VetOfficer(
        id: '5',
        name: 'Dr. Lisa Thompson',
        specialization: 'Preventive Care Specialist',
        experience: '7 years',
        rating: 4.5,
        distance: '6.3 km',
        phone: '+1 234-567-8905',
        email: 'l.thompson@preventvet.com',
        clinic: 'Proactive Animal Health',
        address: '654 Wellness Road, Health District',
        isAvailable: true,
        consultationFee: '\$70',
        emergencyService: false,
        languages: ['English', 'French'],
        services: ['Preventive Care', 'Vaccination Programs', 'Nutrition Advice', 'Wellness Checks'],
        avatarColor: Colors.teal,
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

  void _showVetDetails(VetOfficer vet) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return VetDetailsModal(
          vet: vet,
          onOrderPressed: () {
            Navigator.pop(context);
            _navigateToOrderForm(vet);
          },
        );
      },
    );
  }

  void _navigateToOrderForm(VetOfficer vet) {
    context.push('/vet-order-details', extra: vet);
  }

  Widget _buildVetCard(VetOfficer vet) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _showVetDetails(vet),
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
      ),
      body: SingleChildScrollView(
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
              ..._filteredVets
                  .where((vet) => vet.rating >= 4.7 || _searchController.text.isNotEmpty)
                  .map(_buildVetCard),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// Vet Details Modal
class VetDetailsModal extends StatelessWidget {
  final VetOfficer vet;
  final VoidCallback onOrderPressed;

  const VetDetailsModal({
    super.key,
    required this.vet,
    required this.onOrderPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header - Wrap in Expanded or make scrollable
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: vet.avatarColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.pets,
                            color: vet.avatarColor,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    vet.name,
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
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
                                      fontSize: 12,
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
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.amber.shade700,
                                  size: 20,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  vet.rating.toString(),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  Icons.work,
                                  color: Colors.grey.shade600,
                                  size: 18,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  vet.experience,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Services Section
                  const Text(
                    'Services Offered',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: vet.services.map((service) {
                      return Chip(
                        label: Text(service),
                        backgroundColor: Colors.blue.shade50,
                        labelStyle: TextStyle(
                          color: Colors.blue.shade700,
                          fontSize: 12,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // Contact Info
                  _buildDetailItem(
                    icon: Icons.medical_services,
                    title: 'Clinic',
                    value: vet.clinic,
                  ),
                  _buildDetailItem(
                    icon: Icons.location_on,
                    title: 'Address',
                    value: vet.address,
                  ),
                  _buildDetailItem(
                    icon: Icons.location_pin,
                    title: 'Distance',
                    value: vet.distance,
                  ),
                  _buildDetailItem(
                    icon: Icons.attach_money,
                    title: 'Consultation Fee',
                    value: vet.consultationFee,
                  ),
                  _buildDetailItem(
                    icon: Icons.emergency,
                    title: 'Emergency Service',
                    value: vet.emergencyService ? 'Available' : 'Not Available',
                    color: vet.emergencyService ? Colors.green : Colors.red,
                  ),
                  _buildDetailItem(
                    icon: Icons.language,
                    title: 'Languages',
                    value: vet.languages.join(', '),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Action Buttons - Keep these at the bottom
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implement call functionality
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.blue.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.call, color: Colors.blue.shade400),
                      const SizedBox(width: 8),
                      const Text(
                        'Call Now',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: vet.isAvailable ? onOrderPressed : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Order Vet',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String value,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color ?? Colors.grey.shade600, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16,
                    color: color ?? Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Vet Order Details Screen
class VetOrderDetailsScreen extends StatefulWidget {
  final VetOfficer vet;

  const VetOrderDetailsScreen({super.key, required this.vet});

  @override
  State<VetOrderDetailsScreen> createState() => _VetOrderDetailsScreenState();
}

class _VetOrderDetailsScreenState extends State<VetOrderDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _reasonController = TextEditingController();
  final _notesController = TextEditingController();

  String? _selectedBatch;
  String? _selectedServiceType;
  String? _selectedPriority;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  final List<String> _batches = [
    'Batch 123 - Broilers (1000 birds)',
    'Batch 124 - Layers (500 birds)',
    'Batch 125 - Broilers (1500 birds)',
    'Batch 126 - Breeders (200 birds)',
  ];

  final List<String> _serviceTypes = [
    'Routine Check-up',
    'Vaccination Service',
    'Emergency Visit',
    'Disease Diagnosis',
    'Consultation',
    'Treatment',
    'Post-mortem Examination',
    'Health Certification',
  ];

  final List<String> _priorities = [
    'Normal',
    'Urgent',
    'Emergency',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Order Details'),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.grey.shade700),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _submitOrder,
            child: const Text(
              'Submit Order',
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
              // Vet Info Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: widget.vet.avatarColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.pets,
                            color: widget.vet.avatarColor,
                            size: 24,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.vet.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              widget.vet.specialization,
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_services,
                                  color: Colors.grey.shade500,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  widget.vet.clinic,
                                  style: TextStyle(
                                    color: Colors.grey.shade600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Order Details Card
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.blue.shade100),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.description, color: Colors.blue.shade600),
                          const SizedBox(width: 8),
                          const Text(
                            'Order Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Please provide details for your veterinary service request. '
                            'The veterinarian will review your order and contact you to confirm.',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Batch Selection
              Text(
                'Select Batch',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedBatch,
                decoration: InputDecoration(
                  hintText: 'Choose a batch',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _batches.map((String batch) {
                  return DropdownMenuItem<String>(
                    value: batch,
                    child: Text(batch),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedBatch = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a batch';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Service Type
              Text(
                'Service Type',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedServiceType,
                decoration: InputDecoration(
                  hintText: 'Select type of service needed',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _serviceTypes.map((String type) {
                  return DropdownMenuItem<String>(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedServiceType = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select service type';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Priority
              Text(
                'Priority Level',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                decoration: InputDecoration(
                  hintText: 'Select priority',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey.shade50,
                ),
                items: _priorities.map((String priority) {
                  Color? color;
                  if (priority == 'Emergency') {
                    color = Colors.red;
                  } else if (priority == 'Urgent') {
                    color = Colors.orange;
                  } else {
                    color = Colors.green;
                  }

                  return DropdownMenuItem<String>(
                    value: priority,
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(priority),
                      ],
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedPriority = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select priority level';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Preferred Date
              Text(
                'Preferred Date',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        _selectedDate == null
                            ? 'Select preferred date'
                            : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                        style: TextStyle(
                          color: _selectedDate == null
                              ? Colors.grey.shade600
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Preferred Time
              Text(
                'Preferred Time',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey.shade50,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time, color: Colors.grey.shade600),
                      const SizedBox(width: 12),
                      Text(
                        _selectedTime == null
                            ? 'Select preferred time'
                            : _selectedTime!.format(context),
                        style: TextStyle(
                          color: _selectedTime == null
                              ? Colors.grey.shade600
                              : Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Reason for Visit
              Text(
                'Reason for Visit',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _reasonController,
                labelText: 'Reason',
                hintText: 'Describe the reason for ordering veterinary service...',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please describe the reason for visit';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Additional Notes
              Text(
                'Additional Notes (Optional)',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              ReusableInput(
                controller: _notesController,
                labelText: 'Notes',
                hintText: 'Any additional information the vet should know...',
                maxLines: 4,
              ),
              const SizedBox(height: 32),

              // Terms and Conditions
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
                      Row(
                        children: [
                          Checkbox(
                            value: true,
                            onChanged: (value) {},
                            activeColor: Colors.green,
                          ),
                          const SizedBox(width: 8),
                          const Expanded(
                            child: Text(
                              'I agree to the terms and conditions',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By submitting this order, you agree to:\n'
                            '• Consultation fee of ${widget.vet.consultationFee}\n'
                            '• Cancellation policy (24 hours notice required)\n'
                            '• Payment terms (due upon service completion)\n'
                            '• Privacy and data protection agreement',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitOrder,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Submit Order Request',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 60)),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submitOrder() {
    if (_formKey.currentState!.validate()) {
      // Process the order
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Order submitted for ${widget.vet.name}'),
              Text('Service: $_selectedServiceType'),
              Text('Priority: $_selectedPriority'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 3),
        ),
      );

      // Navigate back to home
      context.pop();
      context.pop();
    }
  }

  @override
  void dispose() {
    _reasonController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}

// Vet Officer Model
class VetOfficer {
  final String id;
  final String name;
  final String specialization;
  final String experience;
  final double rating;
  final String distance;
  final String phone;
  final String email;
  final String clinic;
  final String address;
  final bool isAvailable;
  final String consultationFee;
  final bool emergencyService;
  final List<String> languages;
  final List<String> services;
  final Color avatarColor;

  VetOfficer({
    required this.id,
    required this.name,
    required this.specialization,
    required this.experience,
    required this.rating,
    required this.distance,
    required this.phone,
    required this.email,
    required this.clinic,
    required this.address,
    required this.isAvailable,
    required this.consultationFee,
    required this.emergencyService,
    required this.languages,
    required this.services,
    required this.avatarColor,
  });
}