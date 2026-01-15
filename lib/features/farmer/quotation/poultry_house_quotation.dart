import 'package:agriflock360/features/farmer/quotation/widgets/market_disclaimer.dart';
import 'package:flutter/material.dart';

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

  // Bird capacity options
  final List<Map<String, dynamic>> _capacityOptions = [
    {
      'id': '100',
      'label': '100 Birds',
      'description': 'Small-scale setup',
      'icon': Icons.eco_outlined,
    },
    {
      'id': '300',
      'label': '300 Birds',
      'description': 'Medium-scale setup',
      'icon': Icons.business_outlined,
    },
    {
      'id': '500',
      'label': '500 Birds',
      'description': 'Commercial farm',
      'icon': Icons.agriculture_outlined,
    },
    {
      'id': '1000',
      'label': '1000 Birds',
      'description': 'Large operation',
      'icon': Icons.factory_outlined,
    },
  ];

  String? _selectedCapacity;
  Map<String, dynamic>? _selectedQuotation;

  // Exact quotation data from the table
  final Map<String, Map<String, dynamic>> _quotationsData = {
    '100': {
      'recommendedHouseSize': 'Small-scale house for 100 birds',
      'grandTotal': '77,164',
      'tableData': {
        'headers': ['NO', 'MATERIAL', 'UNIT', '@', 'QUANTITY', 'AMOUNT'],
        'rows': [
          ['1', 'Roofing Sheets 32 gauge 10ft', 'pcs', '740', '14', '2,960'],
          ['2', 'Roofing sheets 32gauge 8ft', 'pcs', '640', '12', '7,680'],
          ['3', 'Wall sheets 32 gauge 10 ft', 'pcs', '740', '38', '28,120'],
          ['4', 'Wire mesh', 'pcs', '800', '10', '8,000'],
          ['5', 'Chicken mesh 6ft', 'pc', '4,000', '1', '4,000'],
          ['6', 'Fito for wall', 'pcs', '30', '180', '5,400'],
          ['7', 'Cedar Posts', 'pcs', '500', '32', '16,000'],
          ['8', 'Round poles for roof', 'pcs', '250', '45', '11,250'],
          ['9', 'King posts', 'pcs', '350', '10', '3,500'],
          ['10', 'Assorted nails', 'kg', '140', '18', '2,520'],
          ['11', 'Roofing nails', 'kg', '200', '16', '3,200'],
          ['12', 'Door', 'pc', '3,500', '1', '3,500'],
          ['13', 'Cement', 'pcs', '720', '20', '14,400'],
          ['14', 'Sand', 'Tones', '1,000', '12', '12,000'],
          ['15', 'Power installation', '', '15,000', '1', '15,000'],
          ['16', 'Polythine Roll', 'pc', '4,500', '1', '4,500'],
          ['17', 'Gladiator', 'pc', '1,000', '1', '1,000'],
          ['18', 'Marram', 'Tones', '7,000', '1', '7,000'],
          ['19', 'Shatter', 'pcs', '250', '2', '500'],
          ['20', 'Hinges', 'pcs', '200', '2', '400'],
          ['21', 'Ballast', 'Tones', '1,857', '7', '13,000'],
          ['22', 'Waterproof cement', 'pc', '200', '2', '400'],
          ['23', 'Plywood', 'pcs', '750', '2', '1,500'],
          ['24', 'Padlock', 'pcs', '500', '2', '1,000'],
          ['25', 'Edge strip', 'ft', '30', '100', '3,000'],
          ['26', 'Transport', '', '10,000', '1', '10,000'],
          ['27', 'Cedar posts for fencing', 'pcs', '500', '20', '10,000'],
          ['28', 'Trashes', 'pcs', '250', '18', '4,500'],
          ['29', 'Chain Link', 'rolls', '3,300', '1', '3,300'],
          ['30', 'U Nail', 'kg', '200', '1', '200'],
          ['31', 'Barbed Wire (610 mtr)', 'rolls', '5,500', '1', '5,500'],
          ['', 'SUB TOTAL', '', '', '', '231,450'],
          ['32', 'Labour (26%)', '', '', '', '60,177'],
          ['', 'GRAND TOTAL', '', '', '', '291,627'],
        ]
      },
      'labourCost': '60,177',
      'materialCostSubtotal': '231,450',
    },
    '300': {
      'recommendedHouseSize': 'Medium-scale house for 300 birds',
      'grandTotal': '146,465',
      'tableData': {
        'headers': ['NO', 'MATERIAL', 'UNIT', '@', 'QUANTITY', 'AMOUNT'],
        'rows': [
          ['1', 'Roofing Sheets 32 gauge 10ft', 'pcs', '740', '24', '10,360'],
          ['2', 'Roofing sheets 32gauge 8ft', 'pcs', '640', '12', '7,680'],
          ['3', 'Wall sheets 32 gauge 10 ft', 'pcs', '740', '28', '20,720'],
          ['4', 'Wire mesh', 'pcs', '800', '6', '4,800'],
          ['5', 'Chicken mesh 6ft', 'pc', '4,000', '1', '4,000'],
          ['6', 'Fito for wall', 'pcs', '30', '160', '4,800'],
          ['7', 'Cedar Posts', 'pcs', '500', '18', '9,000'],
          ['8', 'Round poles for roof', 'pcs', '250', '30', '7,500'],
          ['9', 'King posts', 'pcs', '350', '6', '2,100'],
          ['10', 'Assorted nails', 'kg', '140', '15', '2,100'],
          ['11', 'Roofing nails', 'kg', '200', '12', '2,400'],
          ['12', 'Door', 'pc', '3,500', '1', '3,500'],
          ['13', 'Cement', 'pcs', '720', '10', '7,200'],
          ['14', 'Sand', 'Tones', '1,000', '7', '7,000'],
          ['15', 'Power installation', '', '15,000', '1', '15,000'],
          ['16', 'Polythine Roll', 'pc', '4,500', '1', '4,500'],
          ['17', 'Gladiator', 'pc', '1,000', '1', '1,000'],
          ['18', 'Marram', 'Tones', '7,000', '1', '7,000'],
          ['19', 'Shatter', 'pcs', '250', '2', '500'],
          ['20', 'Hinges', 'pcs', '200', '2', '400'],
          ['21', 'Ballast', 'Tones', '1,857', '5', '9,286'],
          ['22', 'Waterproof cement', 'pc', '200', '2', '400'],
          ['23', 'Plywood', 'pcs', '750', '2', '1,500'],
          ['24', 'Padlock', 'pcs', '500', '2', '1,000'],
          ['25', 'Edge strip', 'ft', '30', '50', '1,500'],
          ['26', 'Transport', '', '10,000', '1', '10,000'],
          ['27', 'Cedar posts for fencing', 'pcs', '500', '15', '7,500'],
          ['28', 'Trashes', 'pcs', '250', '16', '4,000'],
          ['29', 'Chain Link', 'rolls', '3,300', '1', '3,300'],
          ['30', 'U Nail', 'kg', '200', '1', '200'],
          ['31', 'Barbed Wire (610 mtr)', 'rolls', '5,500', '', ''],
          ['', 'SUB TOTAL', '', '', '', '154,966'],
          ['32', 'Labour (26%)', '', '', '', '46,490'],
          ['', 'GRAND TOTAL', '', '', '', '201,455'],
        ]
      },
      'labourCost': '46,490',
      'materialCostSubtotal': '154,966',
    },
    '500': {
      'recommendedHouseSize': 'Commercial house for 500 birds',
      'grandTotal': '201,455',
      'tableData': {
        'headers': ['NO', 'MATERIAL', 'UNIT', '@', 'QUANTITY', 'AMOUNT'],
        'rows': [
          ['1', 'Roofing Sheets 32 gauge 10ft', 'pcs', '740', '42', '17,760'],
          ['2', 'Roofing sheets 32gauge 8ft', 'pcs', '640', '12', '7,680'],
          ['3', 'Wall sheets 32 gauge 10 ft', 'pcs', '740', '38', '28,120'],
          ['4', 'Wire mesh', 'pcs', '800', '10', '8,000'],
          ['5', 'Chicken mesh 6ft', 'pc', '4,000', '1', '4,000'],
          ['6', 'Fito for wall', 'pcs', '30', '180', '5,400'],
          ['7', 'Cedar Posts', 'pcs', '500', '32', '16,000'],
          ['8', 'Round poles for roof', 'pcs', '250', '45', '11,250'],
          ['9', 'King posts', 'pcs', '350', '10', '3,500'],
          ['10', 'Assorted nails', 'kg', '140', '18', '2,520'],
          ['11', 'Roofing nails', 'kg', '200', '16', '3,200'],
          ['12', 'Door', 'pc', '3,500', '1', '3,500'],
          ['13', 'Cement', 'pcs', '720', '20', '14,400'],
          ['14', 'Sand', 'Tones', '1,000', '12', '12,000'],
          ['15', 'Power installation', '', '15,000', '1', '15,000'],
          ['16', 'Polythine Roll', 'pc', '4,500', '1', '4,500'],
          ['17', 'Gladiator', 'pc', '1,000', '1', '1,000'],
          ['18', 'Marram', 'Tones', '7,000', '1', '7,000'],
          ['19', 'Shatter', 'pcs', '250', '2', '500'],
          ['20', 'Hinges', 'pcs', '200', '2', '400'],
          ['21', 'Ballast', 'Tones', '1,857', '7', '13,000'],
          ['22', 'Waterproof cement', 'pc', '200', '2', '400'],
          ['23', 'Plywood', 'pcs', '750', '2', '1,500'],
          ['24', 'Padlock', 'pcs', '500', '2', '1,000'],
          ['25', 'Edge strip', 'ft', '30', '100', '3,000'],
          ['26', 'Transport', '', '10,000', '1', '10,000'],
          ['27', 'Cedar posts for fencing', 'pcs', '500', '20', '10,000'],
          ['28', 'Trashes', 'pcs', '250', '18', '4,500'],
          ['29', 'Chain Link', 'rolls', '3,300', '1', '3,300'],
          ['30', 'U Nail', 'kg', '200', '1', '200'],
          ['31', 'Barbed Wire (610 mtr)', 'rolls', '5,500', '1', '5,500'],
          ['', 'SUB TOTAL', '', '', '', '231,450'],
          ['32', 'Labour (26%)', '', '', '', '60,177'],
          ['', 'GRAND TOTAL', '', '', '', '291,627'],
        ]
      },
      'labourCost': '60,177',
      'materialCostSubtotal': '231,450',
    },
    '1000': {
      'recommendedHouseSize': 'Large-scale house for 1000 birds',
      'grandTotal': '291,627',
      'tableData': {
        'headers': ['NO', 'MATERIAL', 'UNIT', '@', 'QUANTITY', 'AMOUNT'],
        'rows': [
          ['1', 'Roofing Sheets 32 gauge 10ft', 'pcs', '740', '42', '31,080'],
          ['2', 'Roofing sheets 32gauge 8ft', 'pcs', '640', '12', '7,680'],
          ['3', 'Wall sheets 32 gauge 10 ft', 'pcs', '740', '38', '28,120'],
          ['4', 'Wire mesh', 'pcs', '800', '10', '8,000'],
          ['5', 'Chicken mesh 6ft', 'pc', '4,000', '1', '4,000'],
          ['6', 'Fito for wall', 'pcs', '30', '180', '5,400'],
          ['7', 'Cedar Posts', 'pcs', '500', '32', '16,000'],
          ['8', 'Round poles for roof', 'pcs', '250', '45', '11,250'],
          ['9', 'King posts', 'pcs', '350', '10', '3,500'],
          ['10', 'Assorted nails', 'kg', '140', '18', '2,520'],
          ['11', 'Roofing nails', 'kg', '200', '16', '3,200'],
          ['12', 'Door', 'pc', '3,500', '1', '3,500'],
          ['13', 'Cement', 'pcs', '720', '20', '14,400'],
          ['14', 'Sand', 'Tones', '1,000', '12', '12,000'],
          ['15', 'Power installation', '', '15,000', '1', '15,000'],
          ['16', 'Polythine Roll', 'pc', '4,500', '1', '4,500'],
          ['17', 'Gladiator', 'pc', '1,000', '1', '1,000'],
          ['18', 'Marram', 'Tones', '7,000', '1', '7,000'],
          ['19', 'Shatter', 'pcs', '250', '2', '500'],
          ['20', 'Hinges', 'pcs', '200', '2', '400'],
          ['21', 'Ballast', 'Tones', '1,857', '7', '13,000'],
          ['22', 'Waterproof cement', 'pc', '200', '2', '400'],
          ['23', 'Plywood', 'pcs', '750', '2', '1,500'],
          ['24', 'Padlock', 'pcs', '500', '2', '1,000'],
          ['25', 'Edge strip', 'ft', '30', '100', '3,000'],
          ['26', 'Transport', '', '10,000', '1', '10,000'],
          ['27', 'Cedar posts for fencing', 'pcs', '500', '20', '10,000'],
          ['28', 'Trashes', 'pcs', '250', '18', '4,500'],
          ['29', 'Chain Link', 'rolls', '3,300', '1', '3,300'],
          ['30', 'U Nail', 'kg', '200', '1', '200'],
          ['31', 'Barbed Wire (610 mtr)', 'rolls', '5,500', '1', '5,500'],
          ['', 'SUB TOTAL', '', '', '', '231,450'],
          ['32', 'Labour (26%)', '', '', '', '60,177'],
          ['', 'GRAND TOTAL', '', '', '', '291,627'],
        ]
      },
      'labourCost': '60,177',
      'materialCostSubtotal': '231,450',
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
                                'Poultry House Quotation',
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
                          'Select bird capacity to view detailed material requirements and costs',
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
                const SizedBox(height: 18),

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
                  'Choose your target bird population:',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 12),

                // Capacity Options Grid
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: _capacityOptions.length,
                  itemBuilder: (context, index) {
                    final capacity = _capacityOptions[index];
                    return _buildCapacityCard(capacity);
                  },
                ),
                const SizedBox(height: 26),

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

  Widget _buildCapacityCard(Map<String, dynamic> capacity) {
    final isSelected = _selectedCapacity == capacity['id'];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedCapacity = capacity['id'];
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() {
              _selectedQuotation = _quotationsData[capacity['id']];
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
                  capacity['icon'] as IconData,
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  size: 24,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                capacity['label'],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? primaryColor : Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                capacity['description'],
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

  Widget _buildQuotationSection() {
    if (_selectedQuotation == null) return Container();

    final tableData = _selectedQuotation!['tableData'] as Map<String, dynamic>;
    final headers = tableData['headers'] as List<String>;
    final rows = tableData['rows'] as List<List<String>>;

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
                      'Exact material quantities and costs for ${_selectedCapacity!} birds',
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

        // Quick Overview Card
        _buildInfoCard(
          title: 'Quick Overview',
          icon: Icons.dashboard,
          color: primaryColor,
          children: [
            _buildOverviewItem('Recommended House Size', _selectedQuotation!['recommendedHouseSize']),
            const SizedBox(height: 8),
            _buildOverviewItem('Material Cost Subtotal', 'KSh ${_selectedQuotation!['materialCostSubtotal']}'),
            const SizedBox(height: 8),
            _buildOverviewItem('Labour Cost (26%)', 'KSh ${_selectedQuotation!['labourCost']}'),
            const Divider(height: 20),
            Row(
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
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Material Table
        Card(
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
                      child: const Icon(Icons.table_chart, color: primaryColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'MATERIALS BREAKDOWN',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 24,
                    dataRowMaxHeight: 40,
                    dataRowMinHeight: 40,
                    headingRowHeight: 40,
                    columns: headers.map((header) {
                      return DataColumn(
                        label: Text(
                          header,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      );
                    }).toList(),
                    rows: rows.map((row) {
                      final isSubtotal = row[0] == '' && row[1].contains('SUB TOTAL');
                      final isLabour = row[0] == '32';
                      final isGrandTotal = row[0] == '' && row[1].contains('GRAND TOTAL');

                      return DataRow(
                        cells: row.asMap().entries.map((entry) {
                          final index = entry.key;
                          final cell = entry.value;

                          TextStyle cellStyle = const TextStyle(fontSize: 11);
                          Color backgroundColor = Colors.transparent;

                          if (isSubtotal) {
                            cellStyle = const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            );
                            backgroundColor = Colors.blue.withOpacity(0.1);
                          } else if (isLabour) {
                            cellStyle = const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            );
                            backgroundColor = Colors.orange.withOpacity(0.1);
                          } else if (isGrandTotal) {
                            cellStyle = const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            );
                            backgroundColor = Colors.green.withOpacity(0.1);
                          } else if (index == headers.length - 1 && cell.isNotEmpty) {
                            cellStyle = const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            );
                          }

                          return DataCell(
                            Container(
                              color: backgroundColor,
                              child: Text(
                                cell,
                                style: cellStyle,
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Important Notes
        Card(
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
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'IMPORTANT NOTES',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '• Prices are estimates and may vary based on location and market conditions\n'
                      '• Labour cost is calculated at 26% of material cost\n'
                      '• "-" indicates item not required for this capacity\n'
                      '• All prices are in Kenyan Shillings (KSh)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ),

        MarketDisclaimerWidget()
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
    return Row(
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
              color: label == 'GRAND TOTAL' ? Colors.green : Colors.black87,
              fontSize: label == 'GRAND TOTAL' ? 18 : 14,
            ),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}