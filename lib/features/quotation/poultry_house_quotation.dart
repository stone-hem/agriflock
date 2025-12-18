import 'package:agriflock360/features/quotation/widgets/market_disclaimer.dart';
import 'package:flutter/material.dart';

// Data Models
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

  // Detailed quotation data for each capacity
  final Map<String, Map<String, dynamic>> _quotationsData = {
    '50-100': {
      'recommendedHouseSize': '4m x 5m (20 sqm)',
      'estimatedCost': '26,250 - 35,000 KSh',
      'constructionTime': '1-2 weeks',
      'keySpecifications': [
        'Galvanized plate G-16 roofing',
        'Angleline 1.5" support structure',
        'Tube 1.5"x1.5" framing',
        'Wiremesh heavy gauge walls',
        'Plainsheet G-32 finishing',
      ],
      'materials': [
        {'item': 'Plate G-16', 'qty': '1 piece (2.5m x 1m)', 'cost': '4,500'},
        {'item': 'Angleline 1.5"', 'qty': '2 pieces (6m each)', 'cost': '2,000'},
        {'item': 'Tube 1.5"x1.5"', 'qty': '6 pieces (6m each)', 'cost': '3,600'},
        {'item': 'Pipe 1"', 'qty': '1 piece (6m)', 'cost': '300'},
        {'item': 'D 8 (Door hinge)', 'qty': '2 pieces', 'cost': '800'},
        {'item': 'Wiremesh heavy gauge', 'qty': '1 sheet (2m x 1m)', 'cost': '400'},
        {'item': 'Tube 3/4"', 'qty': '5 pieces (6m each)', 'cost': '3,000'},
        {'item': 'Plainsheet G-32', 'qty': '4 meters', 'cost': '1,600'},
        {'item': 'Welding rods', 'qty': '2 kg', 'cost': '400'},
        {'item': 'Fittings (nuts/bolts)', 'qty': '10 pieces', 'cost': '500'},
        {'item': 'Black paint', 'qty': '1 liter', 'cost': '300'},
        {'item': 'Pop rivets', 'qty': '5 pieces', 'cost': '150'},
        {'item': 'Flat 3/4"', 'qty': '1 piece', 'cost': '300'},
      ],
      'labor': [
        {'item': 'Construction labor', 'cost': '5,000'},
        {'item': 'Painting & branding', 'cost': '1,900'},
      ],
      'equipmentRecommendations': [
        '2 manual feeders (KSh 1,500)',
        '2 drinkers (KSh 1,000)',
        '1 brooder lamp (KSh 800)',
        '1 thermometer (KSh 500)',
      ],
      'recommendedSuppliers': [
        {'name': 'Jambo Steel Ltd', 'type': 'Steel Materials', 'rating': '4.3/5', 'location': 'Nairobi'},
        {'name': 'Farmers Choice Hardware', 'type': 'Poultry Equipment', 'rating': '4.2/5', 'location': 'Nakuru'},
      ],
      'biosecurityFeatures': [
        'Wiremesh door for ventilation',
        'Elevated floor design',
        'Easy cleaning surface',
      ],
      'estimatedMonthlyCosts': [
        'Feed: 4,000 - 6,000 KSh',
        'Medication: 800 - 1,200 KSh',
        'Utilities: 500 - 800 KSh',
      ],
      'profitability': {
        'breakEven': '3-4 months',
        'estimatedMonthlyProfit': '8,000 - 15,000 KSh',
        'roi': '6-8 months',
      },
      'materialCostSubtotal': '19,350',
      'laborCostSubtotal': '6,900',
      'grandTotal': '26,250',
    },
    '101-300': {
      'recommendedHouseSize': '6m x 8m (48 sqm)',
      'estimatedCost': '75,000 - 100,000 KSh',
      'constructionTime': '2-3 weeks',
      'keySpecifications': [
        'Plate G-16 roofing doubled',
        'Angleline 1.5" reinforced structure',
        'Tube 1.5"x1.5" double framing',
        'Wiremesh heavy gauge on all sides',
        'Additional ventilation pipes',
      ],
      'materials': [
        {'item': 'Plate G-16', 'qty': '3 pieces', 'cost': '13,500'},
        {'item': 'Angleline 1.5"', 'qty': '6 pieces', 'cost': '6,000'},
        {'item': 'Tube 1.5"x1.5"', 'qty': '12 pieces', 'cost': '7,200'},
        {'item': 'Pipe 1"', 'qty': '3 pieces', 'cost': '900'},
        {'item': 'D 8 (Door hinge)', 'qty': '4 pieces', 'cost': '1,600'},
        {'item': 'Wiremesh heavy gauge', 'qty': '3 sheets', 'cost': '1,200'},
        {'item': 'Tube 3/4"', 'qty': '10 pieces', 'cost': '6,000'},
        {'item': 'Plainsheet G-32', 'qty': '8 meters', 'cost': '3,200'},
        {'item': 'Welding rods', 'qty': '4 kg', 'cost': '800'},
        {'item': 'Fittings', 'qty': '20 pieces', 'cost': '1,000'},
        {'item': 'Black paint', 'qty': '2 liters', 'cost': '600'},
        {'item': 'Pop rivets', 'qty': '10 pieces', 'cost': '300'},
        {'item': 'Flat 3/4"', 'qty': '3 pieces', 'cost': '900'},
      ],
      'labor': [
        {'item': 'Construction labor', 'cost': '12,000'},
        {'item': 'Painting & branding', 'cost': '3,500'},
      ],
      'equipmentRecommendations': [
        '4 feeders (KSh 3,000)',
        '4 drinkers (KSh 2,000)',
        '2 brooders (KSh 3,500)',
        '2 thermometers (KSh 1,000)',
      ],
      'recommendedSuppliers': [
        {'name': 'Mabati Rolling Mills', 'type': 'Steel & Roofing', 'rating': '4.5/5', 'location': 'Nairobi'},
        {'name': 'Steel Structures Kenya', 'type': 'Construction', 'rating': '4.3/5', 'location': 'Mombasa'},
      ],
      'biosecurityFeatures': [
        'Double entry system',
        'Wiremesh windows',
        'Proper drainage',
        'Disinfection area',
      ],
      'estimatedMonthlyCosts': [
        'Feed: 12,000 - 18,000 KSh',
        'Medication: 2,500 - 3,500 KSh',
        'Utilities: 1,500 - 2,000 KSh',
        'Labor: 5,000 - 8,000 KSh',
      ],
      'profitability': {
        'breakEven': '4-5 months',
        'estimatedMonthlyProfit': '25,000 - 40,000 KSh',
        'roi': '8-10 months',
      },
      'materialCostSubtotal': '42,200',
      'laborCostSubtotal': '15,500',
      'grandTotal': '57,700',
    },
    '301-600': {
      'recommendedHouseSize': '10m x 12m (120 sqm)',
      'estimatedCost': '180,000 - 250,000 KSh',
      'constructionTime': '4-5 weeks',
      'keySpecifications': [
        'Industrial Plate G-16 roofing',
        'Reinforced Angleline structure',
        'Heavy-duty Tube framing',
        'Double wiremesh layers',
        'Professional finishing',
      ],
      'materials': [
        {'item': 'Plate G-16', 'qty': '8 pieces', 'cost': '36,000'},
        {'item': 'Angleline 1.5"', 'qty': '15 pieces', 'cost': '15,000'},
        {'item': 'Tube 1.5"x1.5"', 'qty': '25 pieces', 'cost': '15,000'},
        {'item': 'Pipe 1"', 'qty': '8 pieces', 'cost': '2,400'},
        {'item': 'D 8 (Door hinge)', 'qty': '8 pieces', 'cost': '3,200'},
        {'item': 'Wiremesh heavy gauge', 'qty': '10 sheets', 'cost': '4,000'},
        {'item': 'Tube 3/4"', 'qty': '20 pieces', 'cost': '12,000'},
        {'item': 'Plainsheet G-32', 'qty': '20 meters', 'cost': '8,000'},
        {'item': 'Welding rods', 'qty': '8 kg', 'cost': '1,600'},
        {'item': 'Fittings', 'qty': '40 pieces', 'cost': '2,000'},
        {'item': 'Black paint', 'qty': '5 liters', 'cost': '1,500'},
        {'item': 'Pop rivets', 'qty': '20 pieces', 'cost': '600'},
        {'item': 'Flat 3/4"', 'qty': '8 pieces', 'cost': '2,400'},
      ],
      'labor': [
        {'item': 'Construction labor', 'cost': '30,000'},
        {'item': 'Painting & branding', 'cost': '8,000'},
      ],
      'equipmentRecommendations': [
        '8 auto-feeders (KSh 12,000)',
        '8 drinkers (KSh 6,000)',
        '4 brooders (KSh 8,000)',
        'Climate monitor (KSh 5,000)',
      ],
      'recommendedSuppliers': [
        {'name': 'Steel Structures Africa', 'type': 'Industrial Materials', 'rating': '4.6/5', 'location': 'Nairobi'},
        {'name': 'Poultry Masters Ltd', 'type': 'Complete Packages', 'rating': '4.5/5', 'location': 'Kisumu'},
      ],
      'biosecurityFeatures': [
        'Proper ventilation system',
        'Rodent-proof base',
        'Visitor control area',
        'Waste management system',
      ],
      'estimatedMonthlyCosts': [
        'Feed: 35,000 - 50,000 KSh',
        'Medication: 7,000 - 10,000 KSh',
        'Utilities: 4,000 - 6,000 KSh',
        'Labor: 15,000 - 20,000 KSh',
      ],
      'profitability': {
        'breakEven': '5-6 months',
        'estimatedMonthlyProfit': '70,000 - 100,000 KSh',
        'roi': '10-12 months',
      },
      'materialCostSubtotal': '101,700',
      'laborCostSubtotal': '38,000',
      'grandTotal': '139,700',
    },
    '601-1000': {
      'recommendedHouseSize': '15m x 20m (300 sqm)',
      'estimatedCost': '450,000 - 600,000 KSh',
      'constructionTime': '6-8 weeks',
      'keySpecifications': [
        'Commercial Plate G-16 roofing',
        'Industrial Angleline framework',
        'Professional Tube structure',
        'High-quality wiremesh',
        'Premium finishing',
      ],
      'materials': [
        {'item': 'Plate G-16', 'qty': '20 pieces', 'cost': '90,000'},
        {'item': 'Angleline 1.5"', 'qty': '40 pieces', 'cost': '40,000'},
        {'item': 'Tube 1.5"x1.5"', 'qty': '60 pieces', 'cost': '36,000'},
        {'item': 'Pipe 1"', 'qty': '20 pieces', 'cost': '6,000'},
        {'item': 'D 8 (Door hinge)', 'qty': '20 pieces', 'cost': '8,000'},
        {'item': 'Wiremesh heavy gauge', 'qty': '25 sheets', 'cost': '10,000'},
        {'item': 'Tube 3/4"', 'qty': '50 pieces', 'cost': '30,000'},
        {'item': 'Plainsheet G-32', 'qty': '50 meters', 'cost': '20,000'},
        {'item': 'Welding rods', 'qty': '20 kg', 'cost': '4,000'},
        {'item': 'Fittings', 'qty': '100 pieces', 'cost': '5,000'},
        {'item': 'Black paint', 'qty': '15 liters', 'cost': '4,500'},
        {'item': 'Pop rivets', 'qty': '50 pieces', 'cost': '1,500'},
        {'item': 'Flat 3/4"', 'qty': '20 pieces', 'cost': '6,000'},
      ],
      'labor': [
        {'item': 'Construction labor', 'cost': '80,000'},
        {'item': 'Painting & branding', 'cost': '20,000'},
      ],
      'equipmentRecommendations': [
        'Auto-feeders system (KSh 40,000)',
        'Automatic drinkers (KSh 25,000)',
        'Brooder system (KSh 20,000)',
        'Climate control (KSh 30,000)',
      ],
      'recommendedSuppliers': [
        {'name': 'Big Dutchman Kenya', 'type': 'Commercial Systems', 'rating': '4.8/5', 'location': 'Nairobi'},
        {'name': 'Poultry Pro Africa', 'type': 'Turnkey Solutions', 'rating': '4.6/5', 'location': 'Nairobi'},
      ],
      'biosecurityFeatures': [
        'Complete biosecurity protocol',
        'Air filtration system',
        'Staff changing area',
        'Vehicle disinfection',
      ],
      'estimatedMonthlyCosts': [
        'Feed: 90,000 - 120,000 KSh',
        'Medication: 20,000 - 30,000 KSh',
        'Utilities: 10,000 - 15,000 KSh',
        'Labor: 30,000 - 40,000 KSh',
      ],
      'profitability': {
        'breakEven': '6-8 months',
        'estimatedMonthlyProfit': '150,000 - 200,000 KSh',
        'roi': '15-18 months',
      },
      'materialCostSubtotal': '261,000',
      'laborCostSubtotal': '100,000',
      'grandTotal': '361,000',
    },
  };

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
                          'Select your desired bird capacity to see detailed house specifications with REAL MATERIALS and cost estimates.',
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

                // Capacity Selection
                Text(
                  'Select Bird Capacity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Choose your target bird population range:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),

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
    final priceRange = _getPriceRangeForCapacity(capacity.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCapacity = capacity.id;
          Future.delayed(const Duration(milliseconds: 300), () {
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
          padding: const EdgeInsets.all(12),
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
              const SizedBox(height: 8),
              Text(
                capacity.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? primaryColor : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                priceRange,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? primaryColor.withOpacity(0.9) : Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                capacity.description,
                style: TextStyle(
                  fontSize: 11,
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

  String _getPriceRangeForCapacity(String capacityId) {
    switch (capacityId) {
      case '50-100':
        return 'KSh 26,250';
      case '101-300':
        return 'KSh 75,000';
      case '301-600':
        return 'KSh 180,000';
      case '601-1000':
        return 'KSh 450,000';
      default:
        return '';
    }
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DETAILED MATERIAL QUOTATION',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Based on REAL construction materials used in Kenya',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Material Cost Breakdown
        _buildMaterialCostBreakdown(),
        const SizedBox(height: 20),

        // Quick Overview
        _buildInfoCard(
          title: 'Quick Overview',
          icon: Icons.dashboard,
          color: primaryColor,
          children: [
            _buildOverviewItem('Recommended House Size', _selectedQuotation!['recommendedHouseSize']),
            _buildOverviewItem('Material Cost', 'KSh ${_selectedQuotation!['materialCostSubtotal']}'),
            _buildOverviewItem('Labor Cost', 'KSh ${_selectedQuotation!['laborCostSubtotal']}'),
            _buildOverviewItem('GRAND TOTAL', 'KSh ${_selectedQuotation!['grandTotal']}'),
            _buildOverviewItem('Construction Time', _selectedQuotation!['constructionTime']),
          ],
        ),
        const SizedBox(height: 20),

        // Key Specifications
        _buildInfoCard(
          title: 'House Specifications',
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

        // Labor Cost Breakdown
        _buildInfoCard(
          title: 'Labor Cost Breakdown',
          icon: Icons.engineering,
          color: accentColor,
          children: [
            Column(
              children: (_selectedQuotation!['labor'] as List)
                  .map((labor) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(labor['item']),
                    Text(
                      'KSh ${labor['cost']}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ))
                  .toList(),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Labor Cost',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'KSh ${_selectedQuotation!['laborCostSubtotal']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.green,
                  ),
                ),
              ],
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
            Column(
              children: (_selectedQuotation!['equipmentRecommendations'] as List)
                  .map((equipment) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(Icons.check, size: 16, color: Colors.purple),
                    const SizedBox(width: 8),
                    Expanded(child: Text(equipment)),
                  ],
                ),
              ))
                  .toList(),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Recommended Suppliers
        _buildInfoCard(
          title: 'Recommended Suppliers in Kenya',
          icon: Icons.store,
          color: Colors.blue,
          children: [
            Column(
              children: (_selectedQuotation!['recommendedSuppliers'] as List)
                  .map((supplier) => ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.business, size: 20, color: Colors.blue),
                ),
                title: Text(supplier['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(supplier['type']),
                    Text(
                      'Location: ${supplier['location']}',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    ),
                  ],
                ),
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

        // Monthly Cost Estimates
        _buildInfoCard(
          title: 'Estimated Monthly Running Costs',
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

        MarketDisclaimerWidget()
      ],
    );
  }

  Widget _buildMaterialCostBreakdown() {
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
                  child: const Icon(Icons.inventory, color: primaryColor, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'MATERIAL COST BREAKDOWN',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              constraints: const BoxConstraints(
                maxHeight: 350,
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24,
                  dataRowMaxHeight: 40,
                  dataRowMinHeight: 40,
                  headingRowHeight: 40,
                  columns: const [
                    DataColumn(label: Text('Material')),
                    DataColumn(label: Text('Quantity')),
                    DataColumn(label: Text('Unit Cost (KSh)')),
                    DataColumn(label: Text('Total Cost (KSh)')),
                  ],
                  rows: (_selectedQuotation!['materials'] as List)
                      .map((material) => DataRow(cells: [
                    DataCell(Text(material['item'])),
                    DataCell(Text(material['qty'])),
                    DataCell(Text(_getUnitCost(material['item'], material['cost'], material['qty']))),
                    DataCell(Text(material['cost'])),
                  ]))
                      .toList(),
                ),
              ),
            ),
            const Divider(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'MATERIAL COST SUBTOTAL',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'KSh ${_selectedQuotation!['materialCostSubtotal']}',
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'LABOR COST',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'KSh ${_selectedQuotation!['laborCostSubtotal']}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'GRAND TOTAL',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(
                    'KSh ${_selectedQuotation!['grandTotal']}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: primaryColor,
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

  String _getUnitCost(String item, String totalCost, String qty) {
    if (item.contains('Plate')) return '4,500';
    if (item.contains('Angleline')) return '1,000';
    if (item.contains('Tube 1.5')) return '600';
    if (item.contains('Pipe')) return '300';
    if (item.contains('D 8')) return '400';
    if (item.contains('Wiremesh')) return '400';
    if (item.contains('Tube 3/4')) return '600';
    if (item.contains('Plainsheet')) return '400';
    if (item.contains('Welding')) return '200';
    if (item.contains('Fittings')) return '50';
    if (item.contains('paint')) return '300';
    if (item.contains('Pop rivet')) return '30';
    if (item.contains('Flat')) return '300';
    return '0';
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
                SizedBox(
                  width: MediaQuery.of(context).size.width * 0.6,
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
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: label == 'GRAND TOTAL' ? primaryColor : Colors.black87,
                fontSize: label == 'GRAND TOTAL' ? 16 : 14,
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