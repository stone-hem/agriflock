import 'package:agriflock/features/farmer/quotation/models/housing_quotation_model.dart';
import 'package:agriflock/features/farmer/quotation/repo/quotation_repository.dart';
import 'package:agriflock/features/farmer/quotation/widgets/image_with_desc.dart';
import 'package:agriflock/features/farmer/quotation/widgets/market_disclaimer.dart';
import 'package:flutter/material.dart';
import 'package:agriflock/core/utils/result.dart';

class PoultryHouseQuotationScreen extends StatefulWidget {
  const PoultryHouseQuotationScreen({super.key});

  @override
  State<PoultryHouseQuotationScreen> createState() => _PoultryHouseQuotationScreenState();
}

class _PoultryHouseQuotationScreenState extends State<PoultryHouseQuotationScreen> {
  // Color scheme
  static const Color primaryColor = Color(0xFF2E7D32);

  // Bird capacity options
  final List<Map<String, dynamic>> _capacityOptions = [
    {
      'id': 100,
      'label': '100 Birds',
      'description': 'Small-scale setup',
      'icon': Icons.eco_outlined,
    },
    {
      'id': 300,
      'label': '300 Birds',
      'description': 'Medium-scale setup',
      'icon': Icons.business_outlined,
    },
    {
      'id': 500,
      'label': '500 Birds',
      'description': 'Commercial farm',
      'icon': Icons.agriculture_outlined,
    },
    {
      'id': 1000,
      'label': '1000 Birds',
      'description': 'Large operation',
      'icon': Icons.factory_outlined,
    },
  ];

  int? _selectedCapacity;
  HousingQuotationData? _quotationData;
  bool _isLoading = false;
  String? _errorMessage;

  final QuotationRepository _repository = QuotationRepository();

  // Unit price controllers keyed by material index
  final Map<int, TextEditingController> _unitPriceControllers = {};

  void _initUnitPriceControllers(HousingQuotationData data) {
    for (final c in _unitPriceControllers.values) c.dispose();
    _unitPriceControllers.clear();
    for (int i = 0; i < data.materials.length; i++) {
      _unitPriceControllers[i] = TextEditingController(
        text: data.materials[i].unitPrice.toStringAsFixed(2),
      );
    }
  }

  double get _computedSubtotal {
    if (_quotationData == null) return 0;
    double total = 0;
    for (int i = 0; i < _quotationData!.materials.length; i++) {
      final price = double.tryParse(_unitPriceControllers[i]?.text ?? '') ??
          _quotationData!.materials[i].unitPrice;
      total += price * _quotationData!.materials[i].quantity;
    }
    return total;
  }

  double get _computedLabourCost {
    final pct = double.tryParse(_quotationData?.laborPercentage ?? '0') ?? 0;
    return _computedSubtotal * pct / 100;
  }

  double get _computedGrandTotal => _computedSubtotal + _computedLabourCost;

  Future<void> _fetchQuotation(int birdCapacity) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _quotationData = null;
    });

    final result = await _repository.housingQuotation(birdCapacity: birdCapacity);

    switch(result) {
      case Success<HousingQuotationData>():
        _initUnitPriceControllers(result.data);
        setState(() {
          _isLoading = false;
          _quotationData = result.data;
        });
      case Failure<HousingQuotationData>():
        setState(() {
          _isLoading = false;
          _errorMessage = result.message;
        });


    }


  }

  @override
  void dispose() {
    for (final c in _unitPriceControllers.values) c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 1.2, maxCrossAxisExtent: 250,
                  ),
                  itemCount: _capacityOptions.length,
                  itemBuilder: (context, index) {
                    final capacity = _capacityOptions[index];
                    return _buildCapacityCard(capacity);
                  },
                ),
                const SizedBox(height: 26),

                // Error Message
                if (_errorMessage != null) ...[
                  Card(
                    elevation: 0,
                    color: Colors.red.shade50,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(
                                color: Colors.red.shade700,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],

                // Loading Indicator
                if (_isLoading) ...[
                  const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  ),
                  const SizedBox(height: 40),
                ],

                // Quotation Display
                if (_quotationData != null && !_isLoading) ...[
                  _buildQuotationSection(),
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
        });
        _fetchQuotation(capacity['id']);
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
    if (_quotationData == null) return Container();

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
                      'Exact material quantities and costs for ${_quotationData!.birdCapacity} birds',
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
        const SizedBox(height: 12),


        // Material Table
        _buildMaterialsTable(),
        const SizedBox(height: 10),

        Text(
          'Visual Representations',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 10),

        ImageWithDescriptionWidget(
          imageAssetPath: 'assets/quotation/img.png',
          description: 'This is the first image description',
        ),
        ImageWithDescriptionWidget(
          imageAssetPath: 'assets/quotation/img_1.png',
          description: 'This is the second image description',
        ),
        ImageWithDescriptionWidget(
          imageAssetPath: 'assets/quotation/img_2.png',
          description: 'This is the third image description',
        ),
        ImageWithDescriptionWidget(
          imageAssetPath: 'assets/quotation/img_3.png',
          description: 'This is the fourth image description',
        ),
        ImageWithDescriptionWidget(
          imageAssetPath: 'assets/quotation/img_4.png',
          description: 'This is the fifth image description',
        ),
        ImageWithDescriptionWidget(
          imageAssetPath: 'assets/quotation/img_5.png',
          description: 'This is the sixth image description',
        ),

        const SizedBox(height: 10),

        // Important Notes
        _buildImportantNotes(),

        MarketDisclaimerWidget(),
      ],
    );
  }

  Widget _buildMaterialsTable() {
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
            TextButton.icon(onPressed: null, label: Text('Scroll to the right or left to see the whole table.'), icon: Icon(Icons.arrow_forward_ios),),
            Text('The Unit Price can be manually edited to suit your needs'),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 24,
                dataRowMaxHeight: 52,
                dataRowMinHeight: 52,
                headingRowHeight: 40,
                columns: const [
                  DataColumn(
                    label: Text(
                      'NO',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'MATERIAL',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'CATEGORY',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'UNIT',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'UNIT PRICE',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'QTY',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'TOTAL',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ],
                rows: [
                  // Material rows
                  ..._quotationData!.materials.asMap().entries.map((entry) {
                    final index = entry.key + 1;
                    final material = entry.value;
                    final price = double.tryParse(
                          _unitPriceControllers[entry.key]?.text ?? '',
                        ) ??
                        material.unitPrice;
                    final rowTotal = price * material.quantity;
                    return DataRow(
                      cells: [
                        DataCell(Text(index.toString(), style: const TextStyle(fontSize: 11))),
                        DataCell(
                          SizedBox(
                            width: 150,
                            child: Text(
                              material.materialName,
                              style: const TextStyle(fontSize: 11),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            material.category.toUpperCase(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        DataCell(Text(material.unit, style: const TextStyle(fontSize: 11))),
                        DataCell(
                          SizedBox(
                            width: 80,
                            child: TextField(
                              controller: _unitPriceControllers[entry.key],
                              keyboardType: const TextInputType.numberWithOptions(decimal: true),
                              style: const TextStyle(fontSize: 11),
                              decoration: const InputDecoration(
                                isDense: true,
                                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (_) => setState(() {}),
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            material.quantity.toString(),
                            style: const TextStyle(fontSize: 11),
                          ),
                        ),
                        DataCell(
                          Text(
                            _formatNumber(rowTotal),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    );
                  }),
                  // Subtotal row
                  DataRow(
                    cells: [
                      const DataCell(Text('')),
                      DataCell(
                        Container(
                          color: Colors.blue.withOpacity(0.1),
                          child: const Text(
                            'SUB TOTAL',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(
                        Container(
                          color: Colors.blue.withOpacity(0.1),
                          child: Text(
                            _formatNumber(_computedSubtotal),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Labour row
                  DataRow(
                    cells: [
                      const DataCell(Text('')),
                      DataCell(
                        Container(
                          color: Colors.orange.withOpacity(0.1),
                          child: Text(
                            'Labour (${_quotationData!.laborPercentage}%)',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(
                        Container(
                          color: Colors.orange.withOpacity(0.1),
                          child: Text(
                            _formatNumber(_computedLabourCost),
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Grand Total row
                  DataRow(
                    cells: [
                      const DataCell(Text('')),
                      DataCell(
                        Container(
                          color: Colors.green.withOpacity(0.1),
                          child: const Text(
                            'GRAND TOTAL',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ),
                      ),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      const DataCell(Text('')),
                      DataCell(
                        Container(
                          color: Colors.green.withOpacity(0.1),
                          child: Text(
                            _formatNumber(_computedGrandTotal),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
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
    );
  }

  Widget _buildImportantNotes() {
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
                  '• Labour cost is calculated at ${_quotationData!.laborPercentage}% of material cost\n'
                  '• All prices are in ${_quotationData!.currency == 'KES' ? 'Kenyan Shillings (KSh)' : _quotationData!.currency}\n'
                  '• Quotation status: ${_quotationData!.status.toUpperCase()}\n'
                  '• Generated on: ${_formatDate(_quotationData!.createdAt)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade700,
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }




  String _formatNumber(double number) {
    return number.toStringAsFixed(2).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}