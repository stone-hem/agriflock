import 'package:agriflock360/features/farmer/vet/models/vet_farmer_model.dart';
import 'package:agriflock360/features/farmer/vet/repo/vet_farmer_repository.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:agriflock360/core/utils/result.dart';

class BrowseVetsScreen extends StatefulWidget {
  const BrowseVetsScreen({super.key});

  @override
  State<BrowseVetsScreen> createState() => _BrowseVetsScreenState();
}

class _BrowseVetsScreenState extends State<BrowseVetsScreen> {
  final VetFarmerRepository _vetRepository = VetFarmerRepository();
  final TextEditingController _searchController = TextEditingController();

  // State variables
  bool _isLoadingAllVets = false;
  bool _isLoadingRecommended = false;
  bool _hasAllVetsError = false;
  bool _hasRecommendedError = false;
  String? _allVetsErrorMessage;
  String? _recommendedErrorMessage;

  List<VetFarmer> _allVets = [];
  List<VetFarmerRecommendation> _recommendedVets = [];
  List<VetFarmer> _filteredVets = [];

  // Filter variables
  String? _selectedOfficerType;
  String? _selectedRegion;
  String? _selectedStatus;
  int _currentPage = 1;
  final int _limit = 10;
  int _totalVets = 0;


  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterVets);
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    // Load both data sources independently
    await Future.wait([
      _loadRecommendedVets(),
      _loadAllVets(),
    ]);
  }

  Future<void> _loadRecommendedVets() async {
    setState(() {
      _isLoadingRecommended = true;
      _hasRecommendedError = false;
      _recommendedErrorMessage = null;
    });

    try {
      final result = await _vetRepository.getRecommendedVetFarmers();

      switch (result) {
        case Success<List<VetFarmerRecommendation>>(data: final data):
          setState(() {
            _recommendedVets = data;
            _isLoadingRecommended = false;
          });
          break;
        case Failure(message: final error, :final statusCode, :final response):
          setState(() {
            _hasRecommendedError = true;
            _recommendedErrorMessage = error;
            _isLoadingRecommended = false;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _hasRecommendedError = true;
        _recommendedErrorMessage = e.toString();
        _isLoadingRecommended = false;
      });
    }
  }

  Future<void> _loadAllVets() async {
    setState(() {
      _isLoadingAllVets = true;
      _hasAllVetsError = false;
      _allVetsErrorMessage = null;
    });

    try {
      final result = await _vetRepository.getVetFarmers(
        officerType: _selectedOfficerType,
        region: _selectedRegion,
        status: _selectedStatus,
        isVerified: true,
        page: _currentPage,
        limit: _limit,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      );

      switch (result) {
        case Success<VetFarmerListResponse>(data: final data):
          setState(() {
            _allVets = data.data;
            _filteredVets = data.data;
            _totalVets = data.total;
            _isLoadingAllVets = false;
          });
          break;
        case Failure(message: final error, :final statusCode, :final response):
          setState(() {
            _hasAllVetsError = true;
            _allVetsErrorMessage = error;
            _isLoadingAllVets = false;
          });
          break;
      }
    } catch (e) {
      setState(() {
        _hasAllVetsError = true;
        _allVetsErrorMessage = e.toString();
        _isLoadingAllVets = false;
      });
    }
  }

  Future<void> _refreshData() async {
    // Reset to first page on refresh
    _currentPage = 1;

    // Refresh both data sources independently
    await Future.wait([
      _vetRepository.refreshRecommendedVetFarmers().then((result) {
        switch (result) {
          case Success<List<VetFarmerRecommendation>>(data: final data):
            setState(() {
              _recommendedVets = data;
              _hasRecommendedError = false;
            });
            break;
          case Failure(message: final error):
            setState(() {
              _hasRecommendedError = true;
              _recommendedErrorMessage = error;
            });
            break;
        }
      }),
      _vetRepository.refreshVetFarmers(
        officerType: _selectedOfficerType,
        region: _selectedRegion,
        status: _selectedStatus,
        isVerified: true,
        page: _currentPage,
        limit: _limit,
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
      ).then((result) {
        switch (result) {
          case Success<VetFarmerListResponse>(data: final data):
            setState(() {
              _allVets = data.data;
              _filteredVets = data.data;
              _totalVets = data.total;
              _hasAllVetsError = false;
            });
            break;
          case Failure(message: final error):
            setState(() {
              _hasAllVetsError = true;
              _allVetsErrorMessage = error;
            });
            break;
        }
      }),
    ]);
  }

  void _filterVets() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _filteredVets = _allVets;
      } else {
        _filteredVets = _allVets.where((vet) {
          return vet.name.toLowerCase().contains(query) ||
              vet.educationLevel.toLowerCase().contains(query) ||
              (vet.region?.toLowerCase().contains(query) ?? false) ||
              (vet.specializations != null &&
                  vet.specializations.toString().toLowerCase().contains(query));
        }).toList();
      }
    });
  }

  void _navigateToVetDetails(String id) {
    context.push('/vet-details', extra: id);
  }


  Widget _buildLoadingIndicator() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildErrorState({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
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
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVetCard(VetFarmer vet) {
    final rating = double.tryParse(vet.averageRating) ?? 0.0;
    final yearsExp = vet.yearsOfExperience;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _navigateToVetDetails(vet.id),
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
                  color: Colors.green.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Icon(
                    Icons.pets,
                    color: Colors.green,
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
                        Expanded(
                          child: Text(
                            vet.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
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
                              color: vet.isAvailable ? Colors.green : Colors.red,
                            ),
                          ),
                          child: Text(
                            vet.isAvailable?'Available':'Unavailable',
                            style: TextStyle(
                              color: vet.isAvailable ? Colors.green : Colors.red,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      vet.educationLevel,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.work,
                          color: Colors.grey.shade500,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$yearsExp years experience',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.location_on,
                          color: Colors.grey.shade500,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${vet.region}, ${vet.location!.address}',
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
                              rating.toStringAsFixed(1),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.group,
                              color: Colors.blue.shade600,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${vet.totalAppraisals} reviews',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade700,
                              ),
                            ),
                          ],
                        ),
                        if (vet.isVerified)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.verified,
                                  color: Colors.green,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
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

  Widget _buildChipsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, size: 18, color: Colors.grey.shade700),
              const SizedBox(width: 8),
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/my-vet-orders');
                  },
                  icon: const Icon(Icons.list_alt, size: 18),
                  label: const Text('My Orders'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.push('/my-completed-orders');
                  },
                  icon: const Icon(Icons.check_circle, size: 18),
                  label: const Text('Completed'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green.shade700,
                    side: BorderSide(color: Colors.green.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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


  bool get _isLoading => _isLoadingAllVets || _isLoadingRecommended;
  bool get _hasError => _hasAllVetsError && _hasRecommendedError;
  bool get _hasAnyData => _allVets.isNotEmpty || _recommendedVets.isNotEmpty;

  Widget _buildHorizontalRecommendedVetCard(VetFarmerRecommendation vet) {
    final rating = double.tryParse(vet.averageRating) ?? 0.0;

    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 12),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: Colors.amber.shade200, width: 1.5),
        ),
        child: InkWell(
          onTap: () => _navigateToVetDetails(vet.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: vet.faceSelfieUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                vet.faceSelfieUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.pets,
                                  color: Colors.green,
                                  size: 24,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.pets,
                              color: Colors.green,
                              size: 24,
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  vet.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (vet.isVerified)
                                Icon(
                                  Icons.verified,
                                  color: Colors.green,
                                  size: 16,
                                ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            vet.educationLevel,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 11,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey.shade500, size: 14),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        vet.location.address?.formattedAddress ?? 'Location not specified',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
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
                        Icon(Icons.star, color: Colors.amber.shade700, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${vet.yearsOfExperience}y exp',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.amber.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Recommended',
                        style: TextStyle(
                          color: Colors.amber,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Quick Actions Section - At the bottom
              _buildChipsSection(),
              const SizedBox(height: 10),

              // Loading state
              if (_isLoading && !_hasAnyData)
                _buildLoadingIndicator(),

              // Error state for both data sources
              if (_hasError && !_hasAnyData)
                _buildErrorState(
                  message: _allVetsErrorMessage ?? 'Failed to load data',
                  onRetry: _loadAllData,
                ),

              // Content when data is loaded
              if (!_isLoading || _hasAnyData) ...[
                // Recommended Section - Horizontal Scroll (Priority: show vets first)
                if (_recommendedVets.isNotEmpty &&
                    _searchController.text.isEmpty &&
                    !_hasRecommendedError) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Recommended Vets',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_recommendedVets.length} nearby',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Top-rated veterinarians in your area',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 155,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _recommendedVets.length,
                      itemBuilder: (context, index) {
                        return _buildHorizontalRecommendedVetCard(_recommendedVets[index]);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Error for recommended section only
                if (_hasRecommendedError && _recommendedVets.isEmpty && _searchController.text.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Failed to load recommendations',
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

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
                              hintText: 'Search by name, education, or specialization...',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.symmetric(vertical: 14),
                            ),
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        if (_searchController.text.isNotEmpty)
                          IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            onPressed: () {
                              _searchController.clear();
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      FilterChip(
                        label: const Text('Active'),
                        selected: _selectedStatus == 'active',
                        onSelected: (selected) {
                          setState(() {
                            _selectedStatus = selected ? 'active' : null;
                          });
                          _loadAllVets();
                        },
                        backgroundColor: Colors.blue.shade50,
                        selectedColor: Colors.blue,
                        labelStyle: TextStyle(
                          color: _selectedStatus == 'active' ? Colors.white : Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      FilterChip(
                        label: const Text('Vet Officer'),
                        selected: _selectedOfficerType == 'vet',
                        onSelected: (selected) {
                          setState(() {
                            _selectedOfficerType = selected ? 'vet' : null;
                          });
                          _loadAllVets();
                        },
                        backgroundColor: Colors.purple.shade50,
                        selectedColor: Colors.purple,
                        labelStyle: TextStyle(
                          color: _selectedOfficerType == 'vet' ? Colors.white : Colors.purple,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: 8),
                      if (_isLoadingAllVets)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // All Vets Section
                if (_hasAllVetsError && _allVets.isEmpty)
                  _buildErrorState(
                    message: _allVetsErrorMessage ?? 'Failed to load veterinarians',
                    onRetry: _loadAllVets,
                  )
                else if (_isLoadingAllVets && _allVets.isEmpty)
                  _buildLoadingIndicator()
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _searchController.text.isEmpty ? 'All Veterinary Officers' : 'Search Results',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_totalVets > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                '$_totalVets total',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (_filteredVets.isEmpty && !_isLoadingAllVets)
                        _buildEmptyState(
                          icon: Icons.search_off,
                          title: 'No veterinarians found',
                          message: _searchController.text.isEmpty
                              ? 'No veterinarians available at the moment'
                              : 'Try adjusting your search terms or filters',
                        )
                      else
                        ..._filteredVets.map(_buildVetCard),
                    ],
                  ),


                const SizedBox(height: 20),
              ],
            ],
          ),
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