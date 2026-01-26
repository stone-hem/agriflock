import 'package:agriflock360/features/farmer/quotation/widgets/image_with_desc.dart';
import 'package:flutter/material.dart';

class ProductionEstimateScreen extends StatefulWidget {
  const ProductionEstimateScreen({super.key});

  @override
  State<ProductionEstimateScreen> createState() => _ProductionEstimateScreenState();
}

class _ProductionEstimateScreenState extends State<ProductionEstimateScreen> {
  // Color scheme
  static const Color primaryColor = Color(0xFF2E7D32);
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
      name: 'Improved Indigenous Kienyeji',
      description: 'Dual-purpose local breed (meat & eggs)',
      icon: Icons.nature,
      color: Colors.green.shade400,
    ),
  ];

  // BREED-SPECIFIC CAPACITY OPTIONS
  final Map<String, List<ProductionCapacity>> _breedCapacities = {
    'broiler': [
      ProductionCapacity(id: '50', label: '50 Birds', value: 50, icon: Icons.agriculture),
      ProductionCapacity(id: '100', label: '100 Birds', value: 100, icon: Icons.business),
      ProductionCapacity(id: '200', label: '200 Birds', value: 200, icon: Icons.home_work),
      ProductionCapacity(id: '250', label: '250 Birds', value: 250, icon: Icons.factory),
      ProductionCapacity(id: '300', label: '300 Birds', value: 300, icon: Icons.warehouse),
      ProductionCapacity(id: '500', label: '500 Birds', value: 500, icon: Icons.domain),
      ProductionCapacity(id: '750', label: '750 Birds', value: 750, icon: Icons.apartment),
      ProductionCapacity(id: '1000', label: '1,000 Birds', value: 1000, icon: Icons.factory),
      ProductionCapacity(id: '2000', label: '2,000 Birds', value: 2000, icon: Icons.factory_outlined),
    ],
    'layer': [
      ProductionCapacity(id: '50', label: '50 Birds', value: 50, icon: Icons.agriculture),
      ProductionCapacity(id: '100', label: '100 Birds', value: 100, icon: Icons.business),
      ProductionCapacity(id: '200', label: '200 Birds', value: 200, icon: Icons.home_work),
      ProductionCapacity(id: '250', label: '250 Birds', value: 250, icon: Icons.factory),
      ProductionCapacity(id: '300', label: '300 Birds', value: 300, icon: Icons.warehouse),
      ProductionCapacity(id: '500', label: '500 Birds', value: 500, icon: Icons.domain),
      ProductionCapacity(id: '750', label: '750 Birds', value: 750, icon: Icons.apartment),
      ProductionCapacity(id: '1000', label: '1,000 Birds', value: 1000, icon: Icons.factory),
      ProductionCapacity(id: '1500', label: '1,500 Birds', value: 1500, icon: Icons.factory),
      ProductionCapacity(id: '2000', label: '2,000 Birds', value: 2000, icon: Icons.factory_outlined),
    ],
    'kienyeji': [
      ProductionCapacity(id: '50', label: '50 Birds', value: 50, icon: Icons.agriculture),
      ProductionCapacity(id: '100', label: '100 Birds', value: 100, icon: Icons.business),
      ProductionCapacity(id: '200', label: '200 Birds', value: 200, icon: Icons.home_work),
      ProductionCapacity(id: '250', label: '250 Birds', value: 250, icon: Icons.factory),
      ProductionCapacity(id: '300', label: '300 Birds', value: 300, icon: Icons.warehouse),
      ProductionCapacity(id: '500', label: '500 Birds', value: 500, icon: Icons.domain),
      ProductionCapacity(id: '750', label: '750 Birds', value: 750, icon: Icons.apartment),
      ProductionCapacity(id: '1000', label: '1,000 Birds', value: 1000, icon: Icons.factory),
      ProductionCapacity(id: '1500', label: '1,500 Birds', value: 1500, icon: Icons.factory),
      ProductionCapacity(id: '2000', label: '2,000 Birds', value: 2000, icon: Icons.factory_outlined),
    ],
  };

  // ACCURATE PRODUCTION DATA
  final Map<String, Map<String, dynamic>> _productionData = {
    'broiler': {
      // 9 capacities
      'capacities': [50, 100, 200, 250, 300, 500, 750, 1000, 2000],
      'costPerBird': [450, 425, 363, 404, 405, 396, 394, 391, 394],
      'feedMedCost': [22520, 42530, 72520, 101100, 121610, 197950, 295410, 390600, 788600],
      'equipmentCost': [6400, 8800, 10700, 12300, 14700, 38600, 46400, 54200, 138600],
      'adminFee': 2000,
      'initialBudget': [30920, 53330, 85220, 115400, 138310, 238550, 343810, 446800, 929200],
      'sellingPricePerBird': 430,
      'productionCycle': '6-8 weeks',
      'mortalityRate': '3%',
      'feedConversionRatio': '1.8:1',
      'poultryHouseCostWithinKsm': [70252, 141011, 180973, 259787, 259787],
      'poultryHouseCostOutsideKsm': [77164, 146465, 201455, 291627, 291627],
      'poultryHouseCapacities': [50, 200, 300, 750, 1000],
      'materials': [
        'Starter crumbs (0-3 weeks)',
        'Finisher pellets (3-8 weeks)',
        'Essential vaccines (Newcastle, Gumboro)',
        'Medication and supplements',
        'Brooding equipment',
      ],
    },
    'layer': {
      // 10 capacities
      'capacities': [50, 100, 200, 250, 300, 500, 750, 1000, 1500, 2000],
      'costPerBird': [1123, 1013, 990, 1013, 1008, 993, 997, 995, 988, 1055],
      'feedMedCost': [56150, 101250, 198000, 253150, 302500, 496550, 747800, 995450, 1482250, 2109250],
      'equipmentCost': [7600, 7600, 10000, 12300, 13500, 32600, 40400, 48200, 62000, 77600],
      'adminFee': 2000,
      'initialBudget': [65750, 110850, 210000, 265450, 316000, 529150, 788200, 1043650, 1544250, 2186850],
      'sellingPricePerBird': 700,
      'sellingPricePerEgg': 15,
      'productionCycle': '72 weeks',
      'mortalityRate': '5%',
      'peakProduction': '85-90%',
      'eggProduction': '280-320 eggs/year',
      'monthlyLoss': [6043, 8929, 16571, 22329, 26429, 41871, 63657, 94414, 138500, 222643],
      'totalSales': [35000, 70000, 140000, 175000, 210000, 350000, 525000, 665000, 997500, 1330000],
      'birdsSold': [50, 100, 200, 250, 300, 500, 750, 950, 1425, 1900],
      'profitPerBird': [-423, -313, -290, -313, -308, -293, -297, -348, -340, -410],
      'materials': [
        'Chick mash (0-8 weeks)',
        'Growers mash (9-18 weeks)',
        'Layers mash (19+ weeks)',
        'Complete vaccination program',
        'Layer nesting boxes',
      ],
    },
    'kienyeji': {
      // 10 capacities
      'capacities': [50, 100, 200, 250, 300, 500, 750, 1000, 1500, 2000],
      'costPerBird': [454, 432, 394, 396, 410, 389, 388, 391, 320, 317],
      'feedMedCost': [22680, 43150, 78800, 99100, 122850, 194600, 291050, 390900, 479850, 634600],
      'equipmentCost': [7600, 7600, 10000, 12300, 13500, 32600, 40400, 48200, 62000, 77600],
      'adminFee': 2000,
      'initialBudget': [30280, 50750, 88800, 111400, 136350, 227200, 331450, 439100, 541850, 712200],
      'sellingPricePerBird': 700,
      'productionCycle': '5-6 months',
      'mortalityRate': '5%',
      'dualPurpose': 'Meat and eggs',
      'marketDemand': 'High for local markets',
      'monthlyIncome': [3520, 7671, 17486, 21686, 24900, 44400, 66843, 78314, 147900, 198686],
      'totalSales': [35000, 70000, 140000, 175000, 210000, 350000, 525000, 665000, 997500, 1330000],
      'birdsSold': [50, 100, 200, 250, 300, 500, 750, 950, 1425, 1900],
      'profitPerBird': [246, 269, 306, 304, 291, 311, 312, 289, 363, 366],
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
                // Header
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
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Select your breed type and flock size to get accurate production cost estimates.',
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

                // Capacity Grid
                if (_selectedBreed != null) ...[
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _breedCapacities[_selectedBreed]!.length,
                    itemBuilder: (context, index) {
                      final capacity = _breedCapacities[_selectedBreed]![index];
                      return _buildCapacityCard(capacity);
                    },
                  ),
                  const SizedBox(height: 32),
                ],

                // Estimate Display
                if (_selectedEstimate != null) ...[
                  _buildEstimateTables(),
                  const SizedBox(height: 40),
                ] else if (_selectedBreed != null && _selectedCapacity != null) ...[
                  const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                  const SizedBox(height: 40),
                ],

                // Disclaimer
                _buildDisclaimer(),
              ]),
            ),
          ),
        ],
      ),
    );
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
        margin: const EdgeInsets.only(right: 10),
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
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: breed.color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(breed.icon, color: breed.color, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  breed.name,
                  style: TextStyle(
                    fontSize: 14,
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
            _selectedEstimate = _getEstimateForCapacity(capacity.value);
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

  Map<String, dynamic> _getEstimateForCapacity(int capacity) {
    if (_selectedBreed == null) return {};

    final data = _productionData[_selectedBreed]!;
    final capacities = data['capacities'] as List<int>;
    final index = capacities.indexOf(capacity);

    if (index == -1) return {};

    return {
      'breed': _selectedBreed,
      'capacity': capacity,
      'costPerBird': (data['costPerBird'] as List)[index],
      'feedMedCost': (data['feedMedCost'] as List)[index],
      'equipmentCost': (data['equipmentCost'] as List)[index],
      'adminFee': data['adminFee'],
      'initialBudget': (data['initialBudget'] as List)[index],
      'productionCycle': data['productionCycle'],
      'mortalityRate': data['mortalityRate'],
      'materials': data['materials'],
      if (_selectedBreed == 'broiler') 'sellingPricePerBird': data['sellingPricePerBird'],
      if (_selectedBreed == 'broiler') 'feedConversionRatio': data['feedConversionRatio'],
      if (_selectedBreed == 'layer') 'sellingPricePerBird': data['sellingPricePerBird'],
      if (_selectedBreed == 'layer') 'sellingPricePerEgg': data['sellingPricePerEgg'],
      if (_selectedBreed == 'layer') 'peakProduction': data['peakProduction'],
      if (_selectedBreed == 'layer') 'eggProduction': data['eggProduction'],
      if (_selectedBreed == 'layer') 'monthlyLoss': (data['monthlyLoss'] as List)[index],
      if (_selectedBreed == 'layer') 'totalSales': (data['totalSales'] as List)[index],
      if (_selectedBreed == 'layer') 'birdsSold': (data['birdsSold'] as List)[index],
      if (_selectedBreed == 'layer') 'profitPerBird': (data['profitPerBird'] as List)[index],
      if (_selectedBreed == 'kienyeji') 'sellingPricePerBird': data['sellingPricePerBird'],
      if (_selectedBreed == 'kienyeji') 'dualPurpose': data['dualPurpose'],
      if (_selectedBreed == 'kienyeji') 'marketDemand': data['marketDemand'],
      if (_selectedBreed == 'kienyeji') 'monthlyIncome': (data['monthlyIncome'] as List)[index],
      if (_selectedBreed == 'kienyeji') 'totalSales': (data['totalSales'] as List)[index],
      if (_selectedBreed == 'kienyeji') 'birdsSold': (data['birdsSold'] as List)[index],
      if (_selectedBreed == 'kienyeji') 'profitPerBird': (data['profitPerBird'] as List)[index],
    };
  }

  Widget _buildEstimateTables() {
    if (_selectedEstimate == null) return Container();

    final breed = _selectedBreed!;
    final estimate = _selectedEstimate!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: _breedTypes.firstWhere((b) => b.id == breed).color,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${breed.toUpperCase()} PRODUCTION DATA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${estimate['capacity']} birds',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Basic Information Table
        _buildBasicInfoTable(estimate),
        const SizedBox(height: 20),

        // Cost Breakdown Table
        _buildCostTable(estimate),
        const SizedBox(height: 20),

        // Equipment & Admin Table
        _buildEquipmentTable(estimate),
        const SizedBox(height: 20),

        // Breed-specific tables
        if (breed == 'broiler') _buildBroilerSpecificTable(estimate),
        if (breed == 'layer') _buildLayerSpecificTable(estimate),
        if (breed == 'kienyeji') _buildKienyejiSpecificTable(estimate),
        const SizedBox(height: 20),

        // Materials Table
        _buildMaterialsTable(estimate),
        const SizedBox(height: 20),

        // Financial Summary
        _buildFinancialSummaryTable(estimate),
        const SizedBox(height: 20),

        const SizedBox(height: 10),

        ImageWithDescriptionWidget(imageAssetPath: 'assets/quotation/img_7.png', description: 'This is the first image description'),
        ImageWithDescriptionWidget(imageAssetPath: 'assets/quotation/img_8.png', description: 'This is the first image description'),
        ImageWithDescriptionWidget(imageAssetPath: 'assets/quotation/img_9.png', description: 'This is the first image description'),

        const SizedBox(height: 10),


        // Recommendations
        _buildRecommendationsTable(breed),
      ],
    );
  }

  Widget _buildBasicInfoTable(Map<String, dynamic> estimate) {
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
                Icon(Icons.info_outline, color: primaryColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  'BASIC INFORMATION',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey.shade300),
                verticalInside: BorderSide(color: Colors.grey.shade300),
              ),
              children: [
                _buildTableRow(['Breed Type', estimate['breed']!.toString().toUpperCase()]),
                _buildTableRow(['Number of Birds', '${estimate['capacity']}']),
                _buildTableRow(['Production Cycle', estimate['productionCycle']]),
                _buildTableRow(['Mortality Rate', estimate['mortalityRate']]),
                if (estimate['breed'] == 'broiler')
                  _buildTableRow(['Feed Conversion Ratio', estimate['feedConversionRatio']]),
                if (estimate['breed'] == 'layer')
                  _buildTableRow(['Egg Production', estimate['eggProduction']]),
                if (estimate['breed'] == 'layer')
                  _buildTableRow(['Peak Production', estimate['peakProduction']]),
                if (estimate['breed'] == 'kienyeji')
                  _buildTableRow(['Purpose', estimate['dualPurpose']]),
                if (estimate['breed'] == 'kienyeji')
                  _buildTableRow(['Market Demand', estimate['marketDemand']]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCostTable(Map<String, dynamic> estimate) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.blue.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.monetization_on, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Text(
                  'COST BREAKDOWN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.blue.shade50),
                  children: [
                    _buildTableCell('Item', fontWeight: FontWeight.bold),
                    _buildTableCell('Amount (KSh)', fontWeight: FontWeight.bold),
                  ],
                ),
                _buildTableRow(['Cost per Bird from hatchery', '${estimate['costPerBird']}']),
                _buildTableRow(['Feed & Medication Cost', _formatCurrency(estimate['feedMedCost'])]),
                _buildTableRow(['Equipment Cost', _formatCurrency(estimate['equipmentCost'])]),
                _buildTableRow(['Administrative Fee', _formatCurrency(estimate['adminFee'])]),
                TableRow(
                  decoration: BoxDecoration(color: Colors.blue.shade100),
                  children: [
                    _buildTableCell('TOTAL INITIAL INVESTMENT', fontWeight: FontWeight.bold),
                    _buildTableCell(_formatCurrency(estimate['initialBudget']), fontWeight: FontWeight.bold),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEquipmentTable(Map<String, dynamic> estimate) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.purple.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.build, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.7,
                  child: Text(
                    'EQUIPMENT & ADMINISTRATIVE COSTS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.purple.shade50),
                  children: [
                    _buildTableCell('Item', fontWeight: FontWeight.bold),
                    _buildTableCell('Amount (KSh)', fontWeight: FontWeight.bold),
                  ],
                ),
                _buildTableRow(['Equipment Cost', _formatCurrency(estimate['equipmentCost'])]),
                _buildTableRow(['Administrative Fee (Initial)', _formatCurrency(estimate['adminFee'])]),
                _buildTableRow(['Administrative Fee (Subsequent)', '1,000']),
                _buildTableRow(['Total Equipment & Admin', _formatCurrency(estimate['equipmentCost'] + estimate['adminFee'])]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBroilerSpecificTable(Map<String, dynamic> estimate) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.restaurant, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  'BROILER SPECIFIC DATA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.red.shade50),
                  children: [
                    _buildTableCell('Item', fontWeight: FontWeight.bold),
                    _buildTableCell('Amount (KSh)', fontWeight: FontWeight.bold),
                  ],
                ),
                _buildTableRow(['Selling Price per Bird', '${estimate['sellingPricePerBird']}']),
                _buildTableRow(['Feed Conversion Ratio', estimate['feedConversionRatio']]),
                _buildTableRow(['Total Revenue', _formatCurrency(estimate['capacity'] * estimate['sellingPricePerBird'])]),
                _buildTableRow(['Estimated Net Profit',
                  _formatCurrency((estimate['capacity'] * estimate['sellingPricePerBird']) - estimate['initialBudget'])]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayerSpecificTable(Map<String, dynamic> estimate) {
    final totalSales = estimate['totalSales'];
    final monthlyLoss = estimate['monthlyLoss'];
    final profitPerBird = estimate['profitPerBird'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.egg, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'LAYER SPECIFIC DATA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.orange.shade50),
                  children: [
                    _buildTableCell('Item', fontWeight: FontWeight.bold),
                    _buildTableCell('Amount', fontWeight: FontWeight.bold),
                  ],
                ),
                _buildTableRow(['Selling Price per Bird', '${estimate['sellingPricePerBird']}']),
                _buildTableRow(['Selling Price per Egg', '${estimate['sellingPricePerEgg']}']),
                _buildTableRow(['Birds Sold', '${estimate['birdsSold']}']),
                _buildTableRow(['Total Sales Revenue', _formatCurrency(totalSales)]),
                _buildTableRow(['Profit/Loss per Bird', '${profitPerBird.toString().replaceFirst('-', '')} (Loss)']),
                _buildTableRow(['Monthly Loss', _formatCurrency(monthlyLoss)]),
                _buildTableRow(['Total Loss', _formatCurrency(totalSales - estimate['initialBudget'])]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKienyejiSpecificTable(Map<String, dynamic> estimate) {
    final totalSales = estimate['totalSales'];
    final monthlyIncome = estimate['monthlyIncome'];
    final profitPerBird = estimate['profitPerBird'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.green.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.nature, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  'KIENYEJI SPECIFIC DATA',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.green.shade50),
                  children: [
                    _buildTableCell('Item', fontWeight: FontWeight.bold),
                    _buildTableCell('Amount', fontWeight: FontWeight.bold),
                  ],
                ),
                _buildTableRow(['Selling Price per Bird', '${estimate['sellingPricePerBird']}']),
                _buildTableRow(['Birds Sold', '${estimate['birdsSold']}']),
                _buildTableRow(['Total Sales Revenue', _formatCurrency(totalSales)]),
                _buildTableRow(['Profit per Bird', '${profitPerBird}']),
                _buildTableRow(['Monthly Income', _formatCurrency(monthlyIncome)]),
                _buildTableRow(['Total Profit', _formatCurrency(totalSales - estimate['initialBudget'])]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialsTable(Map<String, dynamic> estimate) {
    final materials = estimate['materials'] as List<String>;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.brown.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.inventory, color: Colors.brown, size: 20),
                const SizedBox(width: 8),
                SizedBox(
                  width: MediaQuery.of(context).size.width*0.7,
                  child: Text(
                    'REQUIRED MATERIALS & SUPPLIES',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(1),
              },
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey.shade300),
              ),
              children: [
                for (int i = 0; i < materials.length; i++)
                  TableRow(
                    children: [
                      _buildTableCell('${i + 1}.', textAlign: TextAlign.right),
                      _buildTableCell(materials[i]),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryTable(Map<String, dynamic> estimate) {
    final breed = estimate['breed'];
    double totalRevenue;
    double netProfit;

    if (breed == 'layer') {
      totalRevenue = (estimate['totalSales'] as num).toDouble();
    } else if (breed == 'kienyeji') {
      totalRevenue = (estimate['totalSales'] as num).toDouble();
    } else {
      totalRevenue = (estimate['capacity'] * estimate['sellingPricePerBird']).toDouble();
    }

    netProfit = totalRevenue - estimate['initialBudget'];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.teal.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.teal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'FINANCIAL SUMMARY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Table(
              columnWidths: const {
                0: FlexColumnWidth(3),
                1: FlexColumnWidth(2),
              },
              border: TableBorder.all(color: Colors.grey.shade300),
              children: [
                TableRow(
                  decoration: BoxDecoration(color: Colors.teal.shade50),
                  children: [
                    _buildTableCell('Item', fontWeight: FontWeight.bold),
                    _buildTableCell('Amount (KSh)', fontWeight: FontWeight.bold),
                  ],
                ),
                _buildTableRow(['Total Investment', _formatCurrency(estimate['initialBudget'])]),
                _buildTableRow(['Total Revenue', _formatCurrency(totalRevenue.toInt())]),
                TableRow(
                  decoration: BoxDecoration(
                    color: netProfit >= 0 ? Colors.green.shade50 : Colors.red.shade50,
                  ),
                  children: [
                    _buildTableCell(
                      'NET PROFIT/LOSS',
                      fontWeight: FontWeight.bold,
                      color: netProfit >= 0 ? Colors.green : Colors.red,
                    ),
                    _buildTableCell(
                      _formatCurrency(netProfit.toInt()),
                      fontWeight: FontWeight.bold,
                      color: netProfit >= 0 ? Colors.green : Colors.red,
                    ),
                  ],
                ),
                if (breed == 'layer') _buildTableRow(['Monthly Loss', _formatCurrency(estimate['monthlyLoss'])]),
                if (breed == 'kienyeji') _buildTableRow(['Monthly Income', _formatCurrency(estimate['monthlyIncome'])]),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsTable(String breed) {
    List<String> recommendations = [];

    if (breed == 'broiler') {
      recommendations = [
        'Start with good quality day-old chicks from reputable hatcheries.',
        'Follow vaccination schedule strictly to prevent disease outbreaks.',
        'Monitor feed quality and ensure clean water is always available.',
        'Maintain proper temperature and ventilation in brooding area.',
        'Keep accurate records of all expenses and production data.',
      ];
    } else if (breed == 'layer') {
      recommendations = [
        'Start with good quality day-old chicks from reputable hatcheries.',
        'Follow vaccination schedule strictly to prevent disease outbreaks.',
        'Monitor feed quality and ensure clean water is always available.',
        'Provide adequate lighting (16 hours/day) for optimal egg production.',
        'Keep accurate records of all expenses and production data.',
      ];
    } else if (breed == 'kienyeji') {
      recommendations = [
        'Start with good quality day-old chicks from reputable hatcheries.',
        'Follow vaccination schedule strictly to prevent disease outbreaks.',
        'Monitor feed quality and ensure clean water is always available.',
        'Allow some free-range time for natural foraging behavior.',
        'Keep accurate records of all expenses and production data.',
      ];
    }

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.amber.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb_outline, color: Colors.amber, size: 20),
                const SizedBox(width: 8),
                Text(
                  'RECOMMENDATIONS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: recommendations.map((rec) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, size: 16, color: Colors.green),
                    const SizedBox(width: 8),
                    Expanded(child: Text(rec)),
                  ],
                ),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning, color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(
                  'DISCLAIMER',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '• Administrative fee is Ksh. 1,000 for subsequent production cycles\n'
                  '• Other fees such as transport may apply\n'
                  '• Prices are estimates and may vary based on location and market conditions\n'
                  '• Mortality rates and production figures are industry averages\n'
                  '• Consult with agricultural experts for specific farm conditions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableRow(List<String> cells) {
    return TableRow(
      children: cells.map((cell) => _buildTableCell(cell)).toList(),
    );
  }

  Widget _buildTableCell(String text, {
    FontWeight fontWeight = FontWeight.normal,
    TextAlign textAlign = TextAlign.left,
    Color? color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 14,
          fontWeight: fontWeight,
          color: color,
        ),
        textAlign: textAlign,
      ),
    );
  }

  String _formatCurrency(dynamic amount) {
    final numValue = amount is int ? amount : (amount as num).toInt();
    return numValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
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