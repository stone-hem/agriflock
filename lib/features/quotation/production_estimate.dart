import 'package:flutter/material.dart';

class ProductionEstimateScreen extends StatefulWidget {
  const ProductionEstimateScreen({super.key});

  @override
  State<ProductionEstimateScreen> createState() => _ProductionEstimateScreenState();
}

class _ProductionEstimateScreenState extends State<ProductionEstimateScreen> {
  // Color scheme
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // Breed types
  final List<BreedType> _breedTypes = [
    BreedType(
      id: 'broiler',
      name: 'Broiler',
      description: 'Fast-growing meat birds (ready in 6-8 weeks)',
      icon: Icons.restaurant,
      color: Colors.red.shade400,
    ),
    BreedType(
      id: 'layer',
      name: 'Layer',
      description: 'Egg-laying hens (start laying at 18-20 weeks)',
      icon: Icons.egg,
      color: Colors.orange.shade400,
    ),
    BreedType(
      id: 'kienyeji',
      name: 'Improved Kienyeji',
      description: 'Dual-purpose local breed (meat & eggs)',
      icon: Icons.nature,
      color: Colors.green.shade400,
    ),
  ];

  // Production capacities
  final List<ProductionCapacity> _capacityOptions = [
    ProductionCapacity(id: '50', label: '50 Birds', value: 50, icon: Icons.agriculture),
    ProductionCapacity(id: '100', label: '100 Birds', value: 100, icon: Icons.business),
    ProductionCapacity(id: '200', label: '200 Birds', value: 200, icon: Icons.home_work),
    ProductionCapacity(id: '250', label: '250 Birds', value: 250, icon: Icons.factory),
    ProductionCapacity(id: '300', label: '300 Birds', value: 300, icon: Icons.warehouse),
    ProductionCapacity(id: '500', label: '500 Birds', value: 500, icon: Icons.domain),
    ProductionCapacity(id: '750', label: '750 Birds', value: 750, icon: Icons.apartment),
    ProductionCapacity(id: '1000', label: '1,000 Birds', value: 1000, icon: Icons.factory),
    ProductionCapacity(id: '2000', label: '2,000 Birds', value: 2000, icon: Icons.factory_outlined),
  ];

  // Data for each breed type (arrays have different lengths)
  final Map<String, Map<String, dynamic>> _productionData = {
    'broiler': {
      'costPerBird': [450, 425, 363, 404, 405, 396, 394, 391, 394], // 9 items
      'feedMedCost': [22520, 42530, 72520, 101100, 121610, 197950, 295410, 390600, 788600],
      'equipmentCost': [6400, 8800, 10700, 12300, 14700, 38600, 46400, 54200, 138600],
      'adminFee': 2000,
      'initialBudget': [30920, 53330, 85220, 115400, 138310, 238550, 343810, 446800, 929200],
      'sellingPricePerBird': 430,
      'productionCycle': '6-8 weeks',
      'mortalityRate': '5%',
      'feedConversionRatio': '1.8:1',
      'materials': [
        'Starter crumbs (0-3 weeks)',
        'Finisher pellets (3-8 weeks)',
        'Essential vaccines (Newcastle, Gumboro)',
        'Medication and supplements',
        'Brooding equipment',
      ],
    },
    'layer': {
      'costPerBird': [1123, 1013, 990, 1013, 1008, 993, 997, 995, 988, 1055], // 10 items
      'feedMedCost': [56150, 101250, 198000, 253150, 302500, 496550, 747800, 995450, 1482250, 2109250],
      'equipmentCost': [7600, 7600, 10000, 12300, 13500, 32600, 40400, 48200, 62000, 77600],
      'adminFee': 2000,
      'initialBudget': [63750, 108850, 208000, 265450, 316000, 529150, 788200, 1043650, 1544250, 2186850],
      'sellingPricePerBird': 700,
      'sellingPricePerEgg': 15,
      'productionCycle': '72 weeks',
      'mortalityRate': '8%',
      'peakProduction': '85-90%',
      'eggProduction': '280-320 eggs/year',
      'materials': [
        'Chick mash (0-8 weeks)',
        'Growers mash (9-18 weeks)',
        'Layers mash (19+ weeks)',
        'Complete vaccination program',
        'Layer nesting boxes',
      ],
    },
    'kienyeji': {
      'costPerBird': [454, 432, 394, 396, 410, 389, 388, 391, 320, 317], // 10 items
      'feedMedCost': [22680, 43150, 78800, 99100, 122850, 194600, 291050, 390900, 479850, 634600],
      'equipmentCost': [7600, 7600, 10000, 12300, 13500, 32600, 40400, 48200, 62000, 77600],
      'adminFee': 2000,
      'initialBudget': [30280, 50750, 88800, 111400, 136350, 227200, 331450, 439100, 541850, 712200],
      'sellingPricePerBird': 700,
      'productionCycle': '5-6 months',
      'mortalityRate': '10-15%',
      'dualPurpose': 'Meat and eggs',
      'marketDemand': 'High for local markets',
      'materials': [
        'Chick & Duck mash',
        'Kienyeji mash',
        'Traditional vaccines',
        'Herbal supplements',
        'Local breed-specific equipment',
      ],
    },
  };

  String? _selectedBreed;
  int? _selectedCapacity;
  Map<String, dynamic>? _selectedEstimate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header Card
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: primaryColor.withOpacity(0.2)),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.assessment, color: primaryColor, size: 32),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Production Cost Estimator',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select your breed type and flock size to get detailed production cost estimates, profitability analysis, and equipment requirements.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Breed Selection
                Text(
                  'Select Breed Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose the type of poultry you want to raise:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),

                // Breed Type Cards
                SizedBox(
                  height: 170,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _breedTypes.length,
                    itemBuilder: (context, index) {
                      final breed = _breedTypes[index];
                      return _buildBreedCard(breed);
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Capacity Selection
                Text(
                  'Select Flock Size',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose your target number of birds:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),

                // Capacity Grid - Only show capacities that have data for selected breed
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _getAvailableCapacities().length,
                  itemBuilder: (context, index) {
                    final capacity = _getAvailableCapacities()[index];
                    return _buildCapacityCard(capacity);
                  },
                ),
                const SizedBox(height: 32),

                // Estimate Display
                if (_selectedEstimate != null) ...[
                  _buildEstimateSection(),
                  const SizedBox(height: 40),
                ] else if (_selectedBreed != null && _selectedCapacity != null) ...[
                  const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                  const SizedBox(height: 40),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  // Get capacities that have data for the selected breed
  List<ProductionCapacity> _getAvailableCapacities() {
    if (_selectedBreed == null) return _capacityOptions;

    final data = _productionData[_selectedBreed]!;
    final costPerBirdList = (data['costPerBird'] as List);

    // Return only capacities that have corresponding data
    return _capacityOptions
        .where((capacity) => _capacityOptions.indexOf(capacity) < costPerBirdList.length)
        .toList();
  }

  Widget _buildBreedCard(BreedType breed) {
    final isSelected = _selectedBreed == breed.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBreed = breed.id;
          _selectedEstimate = null;
          _selectedCapacity = null;
        });
      },
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 12),
        child: Card(
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: isSelected ? breed.color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          color: isSelected ? breed.color.withOpacity(0.1) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: breed.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(breed.icon, color: breed.color, size: 24),
                ),
                const SizedBox(height: 8),
                Text(
                  breed.name,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: breed.color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  breed.description,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCapacityCard(ProductionCapacity capacity) {
    final isSelected = _selectedCapacity == capacity.value;

    return GestureDetector(
      onTap: () {
        if (_selectedBreed != null) {
          setState(() {
            _selectedCapacity = capacity.value;
            // Simulate loading delay
            Future.delayed(const Duration(milliseconds: 300), () {
              setState(() {
                _selectedEstimate = _calculateEstimate(capacity.value);
              });
            });
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: primaryColor.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                capacity.icon,
                color: isSelected ? primaryColor : Colors.grey.shade700,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                capacity.label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? primaryColor : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 2),
              Text(
                '${capacity.value} birds',
                style: TextStyle(
                  fontSize: 10,
                  color: isSelected ? primaryColor.withOpacity(0.8) : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, dynamic> _calculateEstimate(int capacity) {
    if (_selectedBreed == null) return {};

    final data = _productionData[_selectedBreed]!;

    // Find which capacity option matches the selected value
    final capacityIndex = _capacityOptions.indexWhere((c) => c.value == capacity);

    if (capacityIndex == -1) return {};

    // Since different breeds have different data array lengths,
    // we need to check if this capacity has data
    final costPerBirdList = (data['costPerBird'] as List);
    if (capacityIndex >= costPerBirdList.length) {
      // This capacity doesn't have data for this breed
      return _getFallbackEstimate(capacity, data);
    }

    // We have data for this capacity
    final feedMedCost = (data['feedMedCost'] as List)[capacityIndex] as int;
    final equipmentCost = (data['equipmentCost'] as List)[capacityIndex] as int;
    final costPerBird = costPerBirdList[capacityIndex] as int;
    final initialBudget = (data['initialBudget'] as List)[capacityIndex] as int;
    final adminFee = data['adminFee'] as int;

    // Calculate sales revenue
    double salesRevenue;
    if (_selectedBreed == 'layer') {
      // For layers, calculate egg revenue
      final sellingPricePerEgg = (data['sellingPricePerEgg'] ?? 15) as int;
      const annualEggs = 300; // Conservative estimate
      salesRevenue = (capacity * annualEggs * sellingPricePerEgg).toDouble();
    } else {
      final sellingPricePerBird = (data['sellingPricePerBird'] ?? 430) as int;
      salesRevenue = (capacity * sellingPricePerBird).toDouble();
    }

    final netProfit = salesRevenue - initialBudget;
    final roiMonths = _calculateROI(netProfit, initialBudget.toDouble());

    return {
      'breed': _selectedBreed,
      'capacity': capacity,
      'feedMedCost': feedMedCost,
      'equipmentCost': equipmentCost,
      'costPerBird': costPerBird,
      'initialBudget': initialBudget,
      'adminFee': adminFee,
      'salesRevenue': salesRevenue.toInt(),
      'netProfit': netProfit.toInt(),
      'roiMonths': roiMonths,
      'productionCycle': data['productionCycle'],
      'mortalityRate': data['mortalityRate'],
      'materials': data['materials'],
      if (_selectedBreed == 'layer') 'eggProduction': data['eggProduction'],
      if (_selectedBreed == 'layer') 'peakProduction': data['peakProduction'],
      if (_selectedBreed == 'layer') 'sellingPricePerEgg': data['sellingPricePerEgg'],
      if (_selectedBreed == 'kienyeji') 'dualPurpose': data['dualPurpose'],
      if (_selectedBreed == 'kienyeji') 'marketDemand': data['marketDemand'],
      if (_selectedBreed == 'broiler') 'feedConversionRatio': data['feedConversionRatio'],
    };
  }

  // Fallback estimate when no specific data exists for a capacity
  Map<String, dynamic> _getFallbackEstimate(int capacity, Map<String, dynamic> data) {
    final costPerBirdList = (data['costPerBird'] as List);
    final lastIndex = costPerBirdList.length - 1;

    // Use the last available data point and scale it
    final lastFeedMedCost = (data['feedMedCost'] as List)[lastIndex] as int;
    final lastEquipmentCost = (data['equipmentCost'] as List)[lastIndex] as int;
    final lastCostPerBird = costPerBirdList[lastIndex] as int;
    final lastInitialBudget = (data['initialBudget'] as List)[lastIndex] as int;
    final adminFee = data['adminFee'] as int;

    // Get the last capacity value that has data
    final lastCapacityValue = _capacityOptions[lastIndex].value;

    // Scale factors based on capacity ratio
    final scaleFactor = capacity / lastCapacityValue;

    final scaledFeedMedCost = (lastFeedMedCost * scaleFactor).toInt();
    final scaledEquipmentCost = (lastEquipmentCost * scaleFactor).toInt();
    final scaledInitialBudget = (lastInitialBudget * scaleFactor).toInt();

    // Calculate sales revenue
    double salesRevenue;
    if (_selectedBreed == 'layer') {
      final sellingPricePerEgg = (data['sellingPricePerEgg'] ?? 15) as int;
      const annualEggs = 300;
      salesRevenue = (capacity * annualEggs * sellingPricePerEgg).toDouble();
    } else {
      final sellingPricePerBird = (data['sellingPricePerBird'] ?? 430) as int;
      salesRevenue = (capacity * sellingPricePerBird).toDouble();
    }

    final netProfit = salesRevenue - scaledInitialBudget;
    final roiMonths = _calculateROI(netProfit, scaledInitialBudget.toDouble());

    return {
      'breed': _selectedBreed,
      'capacity': capacity,
      'feedMedCost': scaledFeedMedCost,
      'equipmentCost': scaledEquipmentCost,
      'costPerBird': lastCostPerBird,
      'initialBudget': scaledInitialBudget,
      'adminFee': adminFee,
      'salesRevenue': salesRevenue.toInt(),
      'netProfit': netProfit.toInt(),
      'roiMonths': roiMonths,
      'productionCycle': data['productionCycle'],
      'mortalityRate': data['mortalityRate'],
      'materials': data['materials'],
      if (_selectedBreed == 'layer') 'eggProduction': data['eggProduction'],
      if (_selectedBreed == 'layer') 'peakProduction': data['peakProduction'],
      if (_selectedBreed == 'layer') 'sellingPricePerEgg': data['sellingPricePerEgg'],
      if (_selectedBreed == 'kienyeji') 'dualPurpose': data['dualPurpose'],
      if (_selectedBreed == 'kienyeji') 'marketDemand': data['marketDemand'],
      if (_selectedBreed == 'broiler') 'feedConversionRatio': data['feedConversionRatio'],
      'isEstimated': true, // Flag to indicate this is an estimated value
    };
  }

  int _calculateROI(double netProfit, double initialBudget) {
    if (initialBudget <= 0) return 0;
    final monthlyProfit = netProfit / 12;
    if (monthlyProfit <= 0) return 99;
    return (initialBudget / monthlyProfit).ceil();
  }

  Widget _buildEstimateSection() {
    if (_selectedEstimate == null) return Container();

    final breed = _selectedBreed!;
    final capacity = _selectedCapacity!;
    final estimate = _selectedEstimate!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Estimate Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: _breedTypes.firstWhere((b) => b.id == breed).color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.assessment_outlined, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${breed.toUpperCase()} PRODUCTION ESTIMATE',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$capacity birds | ${estimate['productionCycle']} cycle',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                    if (estimate['isEstimated'] == true)
                      Text(
                        'Based on estimated calculations',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Summary
        _buildInfoCard(
          title: 'Quick Summary',
          icon: Icons.summarize,
          color: primaryColor,
          children: [
            _buildSummaryItem('Total Birds', '$capacity'),
            _buildSummaryItem('Cost per Bird', 'KSh ${estimate['costPerBird']}'),
            _buildSummaryItem('Production Cycle', '${estimate['productionCycle']}'),
            _buildSummaryItem('Mortality Rate', '${estimate['mortalityRate']}'),
            if (breed == 'layer') ...[
              _buildSummaryItem('Egg Production', estimate['eggProduction'] ?? '280-320/year'),
              _buildSummaryItem('Peak Production', estimate['peakProduction'] ?? '85-90%'),
            ],
            if (breed == 'kienyeji') ...[
              _buildSummaryItem('Type', estimate['dualPurpose'] ?? 'Dual Purpose'),
              _buildSummaryItem('Market Demand', estimate['marketDemand'] ?? 'High'),
            ],
            if (breed == 'broiler')
              _buildSummaryItem('Feed Conversion', estimate['feedConversionRatio'] ?? '1.8:1'),
          ],
        ),
        const SizedBox(height: 20),

        // Cost Breakdown
        _buildCostBreakdown(estimate),
        const SizedBox(height: 20),

        // Equipment Requirements
        _buildInfoCard(
          title: 'Equipment Requirements',
          icon: Icons.build,
          color: Colors.blue,
          children: [
            Column(
              children: [
                _buildEquipmentItem('Feeders & Drinkers', 'KSh ${estimate['equipmentCost']}'),
                _buildEquipmentItem('Brooding Equipment', 'Included'),
                _buildEquipmentItem('Vaccination Tools', 'Included'),
                _buildEquipmentItem('Administrative Fee', 'KSh ${estimate['adminFee']}'),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Required Materials
        _buildInfoCard(
          title: 'Required Materials & Supplies',
          icon: Icons.inventory,
          color: Colors.purple,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (estimate['materials'] as List)
                  .map<Widget>((material) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: Colors.purple, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(material)),
                  ],
                ),
              ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Financial Projection
        _buildInfoCard(
          title: 'Financial Projection',
          icon: Icons.trending_up,
          color: Colors.green,
          children: [
            Column(
              children: [
                _buildFinancialItem('Initial Investment', 'KSh ${estimate['initialBudget']}'),
                _buildFinancialItem('Feed & Medication', 'KSh ${estimate['feedMedCost']}'),
                _buildFinancialItem('Equipment & Admin', 'KSh ${estimate['equipmentCost'] + estimate['adminFee']}'),
                const Divider(height: 20),
                _buildFinancialItem('Total Estimated Cost', 'KSh ${estimate['initialBudget']}', isTotal: true),
                _buildFinancialItem('Projected Revenue', 'KSh ${estimate['salesRevenue']}'),
                const Divider(height: 20),
                _buildFinancialItem(
                  'Estimated Net Profit',
                  'KSh ${estimate['netProfit']}',
                  isProfit: true,
                ),
                _buildFinancialItem(
                  'ROI Period',
                  '${estimate['roiMonths']} months',
                  isROI: true,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Recommendations
        _buildInfoCard(
          title: 'Recommendations',
          icon: Icons.lightbulb_outline,
          color: Colors.orange,
          children: [
            _buildRecommendationItem(
              'Start with good quality day-old chicks from reputable hatcheries.',
            ),
            _buildRecommendationItem(
              'Follow vaccination schedule strictly to prevent disease outbreaks.',
            ),
            _buildRecommendationItem(
              'Monitor feed quality and ensure clean water is always available.',
            ),
            _buildRecommendationItem(
              'Keep accurate records of all expenses and production data.',
            ),
            if (breed == 'broiler')
              _buildRecommendationItem(
                'Maintain proper temperature and ventilation in brooding area.',
              ),
            if (breed == 'layer')
              _buildRecommendationItem(
                'Provide adequate lighting (16 hours/day) for optimal egg production.',
              ),
            if (breed == 'kienyeji')
              _buildRecommendationItem(
                'Allow some free-range time for natural foraging behavior.',
              ),
          ],
        ),
        const SizedBox(height: 20),

        // Note
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Note',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '• Administrative fee is Ksh. 1,000 for subsequent production cycles\n'
                    '• Other fees such as transport may apply\n'
                    '• Prices are estimates and may vary based on location and market conditions\n'
                    '• Mortality rates and production figures are industry averages\n'
                    '• For capacities without specific data, estimates are calculated based on available data',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCostBreakdown(Map<String, dynamic> estimate) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: primaryColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.attach_money, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'COST BREAKDOWN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                _buildCostItem('Feed & Medication Cost', 'KSh ${estimate['feedMedCost']}'),
                _buildCostItem('Equipment Cost', 'KSh ${estimate['equipmentCost']}'),
                _buildCostItem('Administrative Fee', 'KSh ${estimate['adminFee']}'),
                const Divider(height: 20),
                _buildCostItem(
                  'TOTAL INITIAL INVESTMENT',
                  'KSh ${estimate['initialBudget']}',
                  isTotal: true,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Icon(Icons.info_outline, size: 16, color: primaryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Cost per Bird: KSh ${estimate['costPerBird']}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_selectedBreed == 'broiler') const SizedBox(height: 4),
                  if (_selectedBreed == 'broiler')
                    Text(
                      'Includes: Day-old chicks, feed, vaccines, medication, utilities',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  if (estimate['isEstimated'] == true) const SizedBox(height: 4),
                  if (estimate['isEstimated'] == true)
                    Text(
                      'Note: Costs are estimated based on available data',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange.shade700,
                        fontStyle: FontStyle.italic,
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

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: color.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCostItem(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.4,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? primaryColor : Colors.grey.shade700,
                fontSize: isTotal ? 15 : 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? primaryColor : Colors.green.shade700,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 14),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialItem(String label, String value,
      {bool isTotal = false, bool isProfit = false, bool isROI = false}) {
    Color textColor = Colors.black;
    if (isTotal) textColor = primaryColor;
    if (isProfit) textColor = value.startsWith('-') ? Colors.red : Colors.green;
    if (isROI) textColor = Colors.blue;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal || isProfit ? FontWeight.bold : FontWeight.normal,
              color: textColor,
              fontSize: isTotal ? 15 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal || isProfit ? FontWeight.bold : FontWeight.normal,
              color: textColor,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, size: 16, color: Colors.green),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class BreedType {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;

  BreedType({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });
}

class ProductionCapacity {
  final String id;
  final String label;
  final int value;
  final IconData icon;

  ProductionCapacity({
    required this.id,
    required this.label,
    required this.value,
    required this.icon,
  });
}