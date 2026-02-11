import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/quotation/models/production_quotation_model.dart';
import 'package:agriflock360/features/farmer/quotation/repo/quotation_repository.dart';
import 'package:agriflock360/features/farmer/quotation/widgets/image_with_desc.dart';
import 'package:flutter/material.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/farmer/batch/model/bird_type.dart';

class ProductionEstimateScreen extends StatefulWidget {
  const ProductionEstimateScreen({super.key});

  @override
  State<ProductionEstimateScreen> createState() => _ProductionEstimateScreenState();
}

class _ProductionEstimateScreenState extends State<ProductionEstimateScreen> {
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // Repositories
  final _batchRepository = BatchHouseRepository();
  final _quotationRepository = QuotationRepository();

  // State
  bool _isLoadingBirdTypes = false;
  bool _isGeneratingQuotation = false;
  List<BirdType> _birdTypes = [];
  ProductionQuotationData? _quotationData;
  BirdType? _selectedBreed;
  int? _selectedCapacity;

  // STATIC CAPACITY OPTIONS (same for all breeds)
  final List<ProductionCapacity> _capacities = [
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
  ];

  @override
  void initState() {
    super.initState();
    _loadBirdTypes();
  }

  Future<void> _loadBirdTypes() async {
    try {
      setState(() {
        _isLoadingBirdTypes = true;
      });

      final result = await _batchRepository.getBirdTypes();

      switch (result) {
        case Success(data: final types):
          setState(() {
            _birdTypes = types;
            _isLoadingBirdTypes = false;
          });

        case Failure(:final response, :final message):
          if (response != null) {
            ApiErrorHandler.handle(response);
          } else {
            ToastUtil.showError(message);
          }
          setState(() {
            _isLoadingBirdTypes = false;
          });
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
      setState(() {
        _isLoadingBirdTypes = false;
      });
    }
  }

  Future<void> _generateQuotation() async {
    if (_selectedBreed == null || _selectedCapacity == null) {
      ToastUtil.showError('Please select breed and flock size');
      return;
    }

    try {
      setState(() {
        _isGeneratingQuotation = true;
      });

      final result = await _quotationRepository.productionQuotation(
        breedId: _selectedBreed!.id,  // Use the UUID from API
        quantity: _selectedCapacity!,
      );

      switch (result) {
        case Success(data: final quotation):
          setState(() {
            _quotationData = quotation;
            _isGeneratingQuotation = false;
          });
          ToastUtil.showSuccess('Quotation generated successfully');

        case Failure(:final response, :final message):
          if (response != null) {
            ApiErrorHandler.handle(response);
          } else {
            ToastUtil.showError(message);
          }
          setState(() {
            _isGeneratingQuotation = false;
          });
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
      setState(() {
        _isGeneratingQuotation = false;
      });
    }
  }

  // Helper method to determine icon and color based on breed type
  IconData _getBreedIcon(String breedType) {
    final type = breedType.toLowerCase();
    if (type.contains('broiler')) return Icons.restaurant;
    if (type.contains('layer')) return Icons.egg;
    return Icons.nature; // kienyeji or other
  }

  Color _getBreedColor(String breedType) {
    final type = breedType.toLowerCase();
    if (type.contains('broiler')) return Colors.red.shade400;
    if (type.contains('layer')) return Colors.orange.shade400;
    return Colors.green.shade400; // kienyeji or other
  }

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

                // Breed Type Cards (from API)
                if (_isLoadingBirdTypes)
                  const Center(
                    child: CircularProgressIndicator(color: primaryColor),
                  )
                else if (_birdTypes.isEmpty)
                  const Center(
                    child: Text('No breeds available'),
                  )
                else
                  SizedBox(
                    height: 170,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _birdTypes.length,
                      itemBuilder: (context, index) {
                        final breed = _birdTypes[index];
                        return _buildBreedCard(breed);
                      },
                    ),
                  ),
                const SizedBox(height: 24),

                // Capacity Selection
                if (_selectedBreed != null) ...[
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

                  // Capacity Grid (static options)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: _capacities.length,
                    itemBuilder: (context, index) {
                      final capacity = _capacities[index];
                      return _buildCapacityCard(capacity);
                    },
                  ),
                  const SizedBox(height: 20),

                  // Loading indicator when generating
                  if (_isGeneratingQuotation)
                    const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    ),
                  const SizedBox(height: 32),
                ],

                // Quotation Display
                if (_quotationData != null) ...[
                  _buildQuotationTables(),
                  const SizedBox(height: 40),

                  // Images Section
                  const SizedBox(height: 10),
                  ImageWithDescriptionWidget(
                      imageAssetPath: 'assets/quotation/img_7.png',
                      description: 'This is the first image description'
                  ),
                  ImageWithDescriptionWidget(
                      imageAssetPath: 'assets/quotation/img_8.png',
                      description: 'This is the first image description'
                  ),
                  const SizedBox(height: 10),

                  // Disclaimer
                  _buildDisclaimer(),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreedCard(BirdType breed) {
    final isSelected = _selectedBreed?.id == breed.id;
    final icon = _getBreedIcon(breed.name);
    final color = _getBreedColor(breed.name);

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBreed = breed;
          _selectedCapacity = null;
          _quotationData = null;
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
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 18),
                ),
                const SizedBox(height: 6),
                Text(
                  breed.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  breed.name,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
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
    final isGenerating = _isGeneratingQuotation && _selectedCapacity == capacity.value;

    return GestureDetector(
      onTap: () {
        if (!isGenerating && _selectedBreed != null) {
          setState(() {
            _selectedCapacity = capacity.value;
            _quotationData = null;
          });
          _generateQuotation(); // Auto-generate on tap
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          color: isGenerating
              ? primaryColor.withOpacity(0.2)
              : isSelected ? primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isGenerating
                ? primaryColor
                : isSelected ? primaryColor : Colors.grey.shade300,
            width: isGenerating || isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (isGenerating)
                SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: primaryColor,
                  ),
                )
              else
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

  // ========== QUOTATION TABLES SECTION ==========
  Widget _buildQuotationTables() {
    if (_quotationData == null) return Container();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: _getBreedColor(_selectedBreed?.name ?? ''),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(Icons.table_chart, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'PRODUCTION QUOTATION',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Text(
                '${_quotationData!.quantity} birds',
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

        // // Basic Information Table
        // _buildBasicInfoTable(),
        // const SizedBox(height: 20),
        //
        // // Financial Summary Table
        // _buildFinancialSummaryTable(),
        // const SizedBox(height: 20),
        //
        // // Category-wise Breakdown
        // _buildCategoryBreakdownTable(),
        // const SizedBox(height: 20),

        // Detailed Items Table
        _buildDetailedItemsTable(),
      ],
    );
  }

  Widget _buildBasicInfoTable() {
    final breedName = _selectedBreed?.name ?? 'Unknown Breed';

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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 16,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 40,
                columns: const [
                  DataColumn(label: Text('Field')),
                  DataColumn(label: Text('Value')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text('Breed'),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(breedName),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text('Quantity'),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text('${_quotationData!.quantity} birds'),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text('Created'),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(
                        '${_quotationData!.createdAt.day}/${_quotationData!.createdAt.month}/${_quotationData!.createdAt.year}',
                      ),
                    )),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinancialSummaryTable() {
    final data = _quotationData!;
    final isProfit = data.expectedProfit >= 0;
    final profitColor = isProfit ? Colors.green : Colors.red;

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
                  'FINANCIAL SUMMARY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 16,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 40,
                columns: const [
                  DataColumn(label: Text('Item')),
                  DataColumn(label: Text('Amount (KSh)')),
                ],
                rows: [
                  DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: Text('Total Production Cost'),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(_formatCurrency(data.totalProductionCost)),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: Text('Equipment Cost'),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(_formatCurrency(data.equipmentCost)),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: Text('Expected Revenue'),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(_formatCurrency(data.expectedRevenue)),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: Text(
                        'Expected Profit/Loss',
                        style: TextStyle(
                          color: profitColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(
                        _formatCurrency(data.expectedProfit),
                        style: TextStyle(
                          color: profitColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: Text('Cost per Bird'),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(_formatCurrency(data.costPerBird)),
                    )),
                  ]),
                  DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 200),
                      child: Text('Profit per Bird'),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(
                        _formatCurrency(data.profitPerBird),
                        style: TextStyle(color: profitColor),
                      ),
                    )),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryBreakdownTable() {
    final breakdown = _quotationData!.breakdown;
    final categories = breakdown.getTotalCostsByCategory();

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
                Icon(Icons.category, color: Colors.purple, size: 20),
                const SizedBox(width: 8),
                SizedBox(
                  width: MediaQuery.sizeOf(context).width*0.6,
                  child: Text(
                    'COST BREAKDOWN BY CATEGORY',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple,
                    ),
                  ),
                ),

              ],
            ),
            TextButton.icon(onPressed: null, label: Text('Scroll to the right to see the whole table.'), icon: Icon(Icons.arrow_forward_ios),),

            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columnSpacing: 16,
                horizontalMargin: 16,
                dataRowMinHeight: 40,
                dataRowMaxHeight: 40,
                columns: const [
                  DataColumn(label: Text('Category')),
                  DataColumn(label: Text('Amount (KSh)')),
                ],
                rows: categories.entries.map((entry) {
                  return DataRow(cells: [
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(_capitalizeFirst(entry.key)),
                    )),
                    DataCell(Container(
                      constraints: const BoxConstraints(minWidth: 150),
                      child: Text(_formatCurrency(entry.value)),
                    )),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedItemsTable() {
    final itemsByCategory = _quotationData!.getItemsGroupedByCategory();

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
                Icon(Icons.list, color: Colors.teal, size: 20),
                const SizedBox(width: 8),
                Text(
                  'DETAILED ITEMS',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...itemsByCategory.entries.map((categoryEntry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      _capitalizeFirst(categoryEntry.key),
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columnSpacing: 16,
                      horizontalMargin: 16,
                      dataRowMinHeight: 40,
                      dataRowMaxHeight: 40,
                      columns: const [
                        DataColumn(label: Text('Item')),
                        DataColumn(label: Text('Qty')),
                        DataColumn(label: Text('Unit Price')),
                        DataColumn(label: Text('Total')),
                      ],
                      rows: categoryEntry.value.map((item) {
                        return DataRow(cells: [
                          DataCell(Container(
                            constraints: const BoxConstraints(minWidth: 150),
                            child: Text(item.name),
                          )),
                          DataCell(Container(
                            constraints: const BoxConstraints(minWidth: 100),
                            child: Text('${item.quantity} ${item.unit}'),
                          )),
                          DataCell(Container(
                            constraints: const BoxConstraints(minWidth: 100),
                            child: Text('KSh ${item.unitPrice}'),
                          )),
                          DataCell(Container(
                            constraints: const BoxConstraints(minWidth: 100),
                            child: Text(_formatCurrency(item.total)),
                          )),
                        ]);
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
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
              '• Prices are estimates and may vary based on location and market conditions\n'
                  '• Mortality rates and production figures are industry averages\n'
                  '• Consult with agricultural experts for specific farm conditions\n'
                  '• Equipment costs are one-time expenses\n'
                  '• Revenue projections are based on current market prices',
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

  String _formatCurrency(double amount) {
    final numValue = amount.toInt();
    return numValue.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }
}

// Models for UI
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