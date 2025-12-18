import 'package:agriflock360/core/widgets/reusable_input.dart';
import 'package:agriflock360/features/farmer_vet/models/vet_officer.dart';
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

  void _navigateToVetDetails(VetOfficer vet) {
    context.push('/vet-details', extra: vet);
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