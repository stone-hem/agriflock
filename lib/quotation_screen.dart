import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PoultryHouseQuotationScreen extends StatefulWidget {
  const PoultryHouseQuotationScreen({super.key});

  @override
  State<PoultryHouseQuotationScreen> createState() => _PoultryHouseQuotationScreenState();
}

class _PoultryHouseQuotationScreenState extends State<PoultryHouseQuotationScreen> {
  // Color scheme
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF4CAF50);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // Bird capacity ranges
  final List<BirdCapacity> _capacityOptions = [
    BirdCapacity(
      id: '50-100',
      label: '50-100 Birds',
      minCapacity: 50,
      maxCapacity: 100,
      description: 'Small-scale backyard poultry',
      icon: Icons.eco_outlined,
    ),
    BirdCapacity(
      id: '101-300',
      label: '101-300 Birds',
      minCapacity: 101,
      maxCapacity: 300,
      description: 'Medium-scale semi-commercial',
      icon: Icons.business_outlined,
    ),
    BirdCapacity(
      id: '301-600',
      label: '301-600 Birds',
      minCapacity: 301,
      maxCapacity: 600,
      description: 'Commercial small farm',
      icon: Icons.agriculture_outlined,
    ),
    BirdCapacity(
      id: '601-1000',
      label: '601-1000 Birds',
      minCapacity: 601,
      maxCapacity: 1000,
      description: 'Large commercial operation',
      icon: Icons.factory_outlined,
    ),
  ];

  String? _selectedCapacity;
  Map<String, dynamic>? _selectedQuotation;

  // Sample quotation data for each capacity
  final Map<String, Map<String, dynamic>> _quotationsData = {
    '50-100': {
      'recommendedHouseSize': '4m x 5m (20 sqm)',
      'estimatedCost': '85,000 - 120,000 KSh',
      'constructionTime': '2-3 weeks',
      'keySpecifications': [
        'Corrugated iron roof',
        'Wire mesh walls',
        'Deep litter floor',
        'Basic ventilation',
        'Manual feeders/drinkers',
      ],
      'materials': [
        {'item': 'Timber framing', 'qty': '15 pieces', 'cost': '15,000'},
        {'item': 'Corrugated sheets', 'qty': '30 sheets', 'cost': '30,000'},
        {'item': 'Wire mesh', 'qty': '20 sqm', 'cost': '12,000'},
        {'item': 'Nails & fittings', 'qty': '1 lot', 'cost': '5,000'},
        {'item': 'Paint & treatment', 'qty': '5 liters', 'cost': '3,000'},
      ],
      'equipmentRecommendations': [
        '2 brooders (KSh 8,000)',
        '4 feeders (KSh 6,000)',
        '4 drinkers (KSh 4,000)',
        '1 weighing scale (KSh 3,000)',
      ],
      'recommendedSuppliers': [
        {'name': 'Farmers Choice Ltd', 'type': 'Equipment', 'rating': '4.5/5'},
        {'name': 'Agro Hardware Center', 'type': 'Construction', 'rating': '4.2/5'},
      ],
      'biosecurityFeatures': [
        'Foot bath at entrance',
        'Basic fencing',
        'Disinfection point',
      ],
      'estimatedMonthlyCosts': [
        'Feed: 6,000 - 8,000 KSh',
        'Medication: 1,500 - 2,000 KSh',
        'Utilities: 2,000 - 3,000 KSh',
      ],
      'profitability': {
        'breakEven': '4-5 months',
        'estimatedMonthlyProfit': '15,000 - 25,000 KSh',
        'roi': '12-15 months',
      },
    },
    '101-300': {
      'recommendedHouseSize': '6m x 8m (48 sqm)',
      'estimatedCost': '180,000 - 250,000 KSh',
      'constructionTime': '3-4 weeks',
      'keySpecifications': [
        'Corrugated iron roof',
        'Brick lower walls, mesh upper',
        'Concrete floor base',
        'Improved ventilation',
        'Semi-automated systems',
      ],
      'materials': [
        {'item': 'Bricks & cement', 'qty': '2,000 bricks', 'cost': '40,000'},
        {'item': 'Corrugated sheets', 'qty': '50 sheets', 'cost': '50,000'},
        {'item': 'Steel framing', 'qty': '30 pieces', 'cost': '30,000'},
        {'item': 'Wire mesh', 'qty': '40 sqm', 'cost': '24,000'},
        {'item': 'Ventilation fans', 'qty': '2 units', 'cost': '15,000'},
      ],
      'equipmentRecommendations': [
        '4 brooders (KSh 16,000)',
        '8 feeders (KSh 12,000)',
        '8 drinkers (KSh 8,000)',
        'Automatic lighting (KSh 10,000)',
        'Temperature monitor (KSh 8,000)',
      ],
      'recommendedSuppliers': [
        {'name': 'Poultry Masters Ltd', 'type': 'Complete Packages', 'rating': '4.7/5'},
        {'name': 'Steel Structures Co.', 'type': 'Construction', 'rating': '4.4/5'},
      ],
      'biosecurityFeatures': [
        'Double entry system',
        'Bird netting',
        'Disinfection tunnel',
        'Visitor log book',
      ],
      'estimatedMonthlyCosts': [
        'Feed: 15,000 - 20,000 KSh',
        'Medication: 3,000 - 4,000 KSh',
        'Utilities: 4,000 - 6,000 KSh',
        'Labor: 10,000 - 15,000 KSh',
      ],
      'profitability': {
        'breakEven': '5-6 months',
        'estimatedMonthlyProfit': '40,000 - 60,000 KSh',
        'roi': '10-12 months',
      },
    },
    '301-600': {
      'recommendedHouseSize': '10m x 12m (120 sqm)',
      'estimatedCost': '450,000 - 650,000 KSh',
      'constructionTime': '5-6 weeks',
      'keySpecifications': [
        'Industrial grade roofing',
        'Brick/block walls',
        'Reinforced concrete floor',
        'Automated ventilation',
        'Waste management system',
      ],
      'materials': [
        {'item': 'Concrete & blocks', 'qty': '4,000 blocks', 'cost': '80,000'},
        {'item': 'Industrial roofing', 'qty': '120 sheets', 'cost': '120,000'},
        {'item': 'Steel structure', 'qty': '50 pieces', 'cost': '75,000'},
        {'item': 'Insulation', 'qty': '120 sqm', 'cost': '60,000'},
        {'item': 'Automated systems', 'qty': '1 set', 'cost': '100,000'},
      ],
      'equipmentRecommendations': [
        '6 brooders (KSh 24,000)',
        'Auto feeders (KSh 50,000)',
        'Nipple drinkers (KSh 40,000)',
        'Climate control (KSh 80,000)',
        'Monitoring system (KSh 25,000)',
      ],
      'recommendedSuppliers': [
        {'name': 'AgroTech Solutions', 'type': 'Automated Systems', 'rating': '4.8/5'},
        {'name': 'BuildRight Contractors', 'type': 'Construction', 'rating': '4.6/5'},
        {'name': 'Chick Master Ltd', 'type': 'Equipment', 'rating': '4.5/5'},
      ],
      'biosecurityFeatures': [
        'Biosecurity zone',
        'Vehicle spray system',
        'Rodent control',
        'Air filtration',
        'Staff changing area',
      ],
      'estimatedMonthlyCosts': [
        'Feed: 40,000 - 60,000 KSh',
        'Medication: 8,000 - 12,000 KSh',
        'Utilities: 10,000 - 15,000 KSh',
        'Labor: 20,000 - 30,000 KSh',
        'Maintenance: 5,000 - 8,000 KSh',
      ],
      'profitability': {
        'breakEven': '6-8 months',
        'estimatedMonthlyProfit': '120,000 - 180,000 KSh',
        'roi': '8-10 months',
      },
    },
    '601-1000': {
      'recommendedHouseSize': '15m x 20m (300 sqm)',
      'estimatedCost': '1,200,000 - 1,800,000 KSh',
      'constructionTime': '8-10 weeks',
      'keySpecifications': [
        'Commercial poultry house',
        'Full automation',
        'Climate controlled',
        'Waste recycling',
        'Energy efficient design',
      ],
      'materials': [
        {'item': 'Industrial construction', 'qty': 'Full package', 'cost': '800,000'},
        {'item': 'Automation systems', 'qty': 'Complete set', 'cost': '400,000'},
        {'item': 'Climate control', 'qty': 'Full system', 'cost': '250,000'},
        {'item': 'Waste management', 'qty': 'Biogas system', 'cost': '150,000'},
        {'item': 'Solar backup', 'qty': '5kW system', 'cost': '200,000'},
      ],
      'equipmentRecommendations': [
        'Tunnel ventilation (KSh 150,000)',
        'Full automation (KSh 300,000)',
        'Computer monitoring (KSh 80,000)',
        'Feed storage silo (KSh 120,000)',
        'Egg collection system (KSh 75,000)',
      ],
      'recommendedSuppliers': [
        {'name': 'Big Dutchman Kenya', 'type': 'Full Automation', 'rating': '4.9/5'},
        {'name': 'Poultry Pro Africa', 'type': 'Turnkey Solutions', 'rating': '4.7/5'},
        {'name': 'Green Energy Farms', 'type': 'Sustainable Systems', 'rating': '4.6/5'},
      ],
      'biosecurityFeatures': [
        'Full biosecurity protocol',
        'Air shower entry',
        'Water treatment',
        'Pest control system',
        'ISO standards compliance',
      ],
      'estimatedMonthlyCosts': [
        'Feed: 120,000 - 180,000 KSh',
        'Medication: 25,000 - 40,000 KSh',
        'Utilities: 30,000 - 45,000 KSh',
        'Labor: 40,000 - 60,000 KSh',
        'Maintenance: 15,000 - 25,000 KSh',
      ],
      'profitability': {
        'breakEven': '8-12 months',
        'estimatedMonthlyProfit': '300,000 - 500,000 KSh',
        'roi': '18-24 months',
      },
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.white,
            elevation: 1,
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
            floating: true,
            actions: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
                onPressed: () => context.push('/notifications'),
              ),
            ],
          ),
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
                        const Text(
                          'Poultry House Quotation',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.home_work, color: primaryColor, size: 32),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Text(
                                'Get Instant House Quotation',
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
                          'Select your desired bird capacity to see detailed house specifications, cost estimates, and recommended suppliers.',
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
                const SizedBox(height: 24),

                // Capacity Selection
                Text(
                  'Select Bird Capacity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Choose your target bird population range:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),

                // Capacity Options Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: _capacityOptions.length,
                  itemBuilder: (context, index) {
                    final capacity = _capacityOptions[index];
                    return _buildCapacityCard(capacity);
                  },
                ),
                const SizedBox(height: 32),

                // Quotation Display
                if (_selectedQuotation != null) ...[
                  _buildQuotationSection(),
                  const SizedBox(height: 40),
                ] else if (_selectedCapacity != null) ...[
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

  Widget _buildCapacityCard(BirdCapacity capacity) {
    final isSelected = _selectedCapacity == capacity.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCapacity = capacity.id;
          // Simulate loading delay
          Future.delayed(const Duration(milliseconds: 500), () {
            setState(() {
              _selectedQuotation = _quotationsData[capacity.id];
            });
          });
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(16),
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
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  capacity.icon,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                capacity.label,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? primaryColor : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                capacity.description,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? primaryColor.withOpacity(0.8) : Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuotationSection() {
    if (_selectedQuotation == null) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Quotation Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: primaryColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.description, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Detailed Quotation & Recommendations',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Quick Overview
        _buildInfoCard(
          title: 'Quick Overview',
          icon: Icons.dashboard,
          color: primaryColor,
          children: [
            _buildOverviewItem('Recommended House Size', _selectedQuotation!['recommendedHouseSize']),
            _buildOverviewItem('Estimated Cost Range', _selectedQuotation!['estimatedCost']),
            _buildOverviewItem('Construction Time', _selectedQuotation!['constructionTime']),
          ],
        ),
        const SizedBox(height: 20),

        // Key Specifications
        _buildInfoCard(
          title: 'Key Specifications',
          icon: Icons.list_alt,
          color: secondaryColor,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (_selectedQuotation!['keySpecifications'] as List)
                  .map((spec) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.check_circle, color: secondaryColor, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(spec)),
                  ],
                ),
              ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Materials & Costs
        _buildInfoCard(
          title: 'Materials & Estimated Costs',
          icon: Icons.construction,
          color: accentColor,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                dataRowMaxHeight: 40,
                headingRowHeight: 40,
                columns: const [
                  DataColumn(label: Text('Material')),
                  DataColumn(label: Text('Quantity')),
                  DataColumn(label: Text('Estimated Cost (KSh)')),
                ],
                rows: (_selectedQuotation!['materials'] as List)
                    .map((material) => DataRow(cells: [
                  DataCell(Text(material['item'])),
                  DataCell(Text(material['qty'])),
                  DataCell(Text(material['cost'])),
                ]))
                    .toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Equipment Recommendations
        _buildInfoCard(
          title: 'Equipment Recommendations',
          icon: Icons.build,
          color: Colors.purple,
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: (_selectedQuotation!['equipmentRecommendations'] as List)
                  .map((equipment) => Chip(
                label: Text(equipment),
                backgroundColor: Colors.purple.withOpacity(0.1),
                labelStyle: TextStyle(color: Colors.purple.shade800),
              ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Recommended Suppliers
        _buildInfoCard(
          title: 'Recommended Suppliers',
          icon: Icons.store,
          color: Colors.blue,
          children: [
            Column(
              children: (_selectedQuotation!['recommendedSuppliers'] as List)
                  .map((supplier) => ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business, size: 20, color: Colors.blue),
                ),
                title: Text(supplier['name']),
                subtitle: Text(supplier['type']),
                trailing: Chip(
                  label: Text(supplier['rating']),
                  backgroundColor: Colors.blue.withOpacity(0.1),
                ),
              ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Biosecurity Features
        _buildInfoCard(
          title: 'Biosecurity Features',
          icon: Icons.security,
          color: Colors.teal,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: (_selectedQuotation!['biosecurityFeatures'] as List)
                  .map((feature) => Chip(
                label: Text(feature),
                backgroundColor: Colors.teal.withOpacity(0.1),
                avatar: Icon(Icons.check, size: 16, color: Colors.teal),
              ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Monthly Cost Estimates
        _buildInfoCard(
          title: 'Estimated Monthly Costs',
          icon: Icons.attach_money,
          color: Colors.orange,
          children: [
            Column(
              children: (_selectedQuotation!['estimatedMonthlyCosts'] as List)
                  .map((cost) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.circle, size: 8, color: Colors.orange),
                    const SizedBox(width: 12),
                    Expanded(child: Text(cost)),
                  ],
                ),
              ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Profitability Analysis
        _buildInfoCard(
          title: 'Profitability Analysis',
          icon: Icons.trending_up,
          color: Colors.green,
          children: [
            _buildProfitabilityItem('Break-even Period', _selectedQuotation!['profitability']['breakEven']),
            _buildProfitabilityItem('Estimated Monthly Profit', _selectedQuotation!['profitability']['estimatedMonthlyProfit']),
            _buildProfitabilityItem('ROI Period', _selectedQuotation!['profitability']['roi']),
          ],
        ),
        const SizedBox(height: 32),
      ],
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
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
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

  Widget _buildOverviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfitabilityItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}

class BirdCapacity {
  final String id;
  final String label;
  final int minCapacity;
  final int maxCapacity;
  final String description;
  final IconData icon;

  BirdCapacity({
    required this.id,
    required this.label,
    required this.minCapacity,
    required this.maxCapacity,
    required this.description,
    required this.icon,
  });
}