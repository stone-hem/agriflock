import 'package:agriflock360/lib/features/auth/quiz/shared/file_upload.dart';
import 'package:flutter/material.dart';
import 'package:agriflock360/lib/features/auth/quiz/shared/custom_text_field.dart';
import 'package:agriflock360/lib/features/auth/quiz/shared/photo_upload.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class PoultryHouseQuotationScreen extends StatefulWidget {
  const PoultryHouseQuotationScreen({super.key});

  @override
  State<PoultryHouseQuotationScreen> createState() => _PoultryHouseQuotationScreenState();
}

class _PoultryHouseQuotationScreenState extends State<PoultryHouseQuotationScreen> {
  // Color scheme
  static const Color primaryColor = Color(0xFF2E7D32);
  static const Color secondaryColor = Color(0xFF2196F3);
  static const Color accentColor = Color(0xFFFF9800);
  static const Color backgroundColor = Color(0xFFF8F9FA);

  // Form controllers
  final TextEditingController _houseLengthController = TextEditingController();
  final TextEditingController _houseWidthController = TextEditingController();
  final TextEditingController _houseHeightController = TextEditingController();
  String? _selectedWallMaterial;
  String? _selectedRoofMaterial;
  String? _selectedFloorType;
  final TextEditingController _ventilationCountController = TextEditingController();

  // Biosecurity
  bool _hasFootbath = false;
  bool _hasNetting = false;
  bool _hasFencing = false;
  final TextEditingController _fencingLengthController = TextEditingController();

  // Utilities
  String? _selectedWaterSource;
  String? _selectedElectricityType;
  final TextEditingController _solarBackupCountController = TextEditingController();

  // Equipment
  final TextEditingController _brooderCountController = TextEditingController();
  final TextEditingController _feederCountController = TextEditingController();
  final TextEditingController _drinkerCountController = TextEditingController();
  final TextEditingController _weighingScaleCountController = TextEditingController();
  final TextEditingController _feedPalletCountController = TextEditingController();

  // Photos
  File? _houseExteriorPhoto;
  File? _houseInteriorPhoto;
  File? _brooderPhoto;
  File? _feederPhoto;
  File? _drinkerPhoto;
  File? _feedStorePhoto;

  // Additional documents
  final List<PlatformFile> _uploadedFiles = [];

  // Quotation data (mocked for now)
  Map<String, dynamic> _quotationData = {};
  bool _showQuotation = false;

  // Material options
  final List<String> _wallMaterials = [
    'Corrugated Iron Sheets',
    'Wood & Wire Mesh',
    'Brick & Mortar',
    'Prefabricated Panels',
    'Thatch & Pole'
  ];

  final List<String> _roofMaterials = [
    'Corrugated Iron Sheets',
    'Polycarbonate Sheets',
    'Asphalt Shingles',
    'Thatch',
    'Tile'
  ];

  final List<String> _floorTypes = [
    'Concrete Floor',
    'Earthen Floor',
    'Deep Litter',
    'Slatted Floor',
    'Wire Mesh Floor'
  ];

  final List<String> _waterSources = [
    'Borehole',
    'Municipal Water',
    'Rain Water Harvesting',
    'River/Stream',
    'Well'
  ];

  final List<String> _electricityTypes = [
    'National Grid',
    'Solar Power',
    'Generator',
    'No Electricity',
    'Hybrid (Grid + Solar)'
  ];

  void _onFilesSelected(List<PlatformFile> files) {
    setState(() {
      _uploadedFiles.addAll(files);
    });
  }

  void _onFileRemoved(int index) {
    setState(() {
      _uploadedFiles.removeAt(index);
    });
  }

  bool _isFormValid() {
    return _houseLengthController.text.isNotEmpty &&
        _houseWidthController.text.isNotEmpty &&
        _selectedWallMaterial != null &&
        _selectedRoofMaterial != null;
  }

  void _generateQuotation() {
    // Mock quotation generation - will be replaced with backend API
    setState(() {
      _quotationData = {
        'specifications': {
          'dimensions': '${_houseWidthController.text}m x ${_houseLengthController.text}m',
          'wallMaterial': _selectedWallMaterial!,
          'roofMaterial': _selectedRoofMaterial!,
          'floorType': _selectedFloorType,
        },
        'materials': [
          {'name': 'Plate G-16', 'unit': 'pcs', 'rate': '4,500', 'quantity': '1', 'total': '4,500'},
          {'name': 'Angleline 1.5', 'unit': 'pcs', 'rate': '1,000', 'quantity': '2', 'total': '2,000'},
          {'name': 'Tube 1.5*1.5', 'unit': 'pcs', 'rate': '600', 'quantity': '6', 'total': '3,600'},
          {'name': 'Pipe 1"', 'unit': 'pcs', 'rate': '300', 'quantity': '1', 'total': '300'},
          {'name': 'D 8', 'unit': 'pc', 'rate': '400', 'quantity': '2', 'total': '800'},
          {'name': 'Wiremesh heavy gauge', 'unit': 'pcs', 'rate': '400', 'quantity': '1', 'total': '400'},
          {'name': 'Plainsheet G-32', 'unit': 'Mtrs', 'rate': '400', 'quantity': '4', 'total': '1,600'},
          {'name': 'Welding rod', 'unit': 'kg', 'rate': '200', 'quantity': '2', 'total': '400'},
          {'name': 'Fittings', 'unit': 'pcs', 'rate': '50', 'quantity': '10', 'total': '500'},
          {'name': 'Black paint', 'unit': 'Ltr', 'rate': '300', 'quantity': '1', 'total': '300'},
        ],
        'labor': '6,900',
        'subtotal': '19,350',
        'grandTotal': '26,250',
        'timestamp': DateTime.now().toIso8601String(),
      };
      _showQuotation = true;
    });

    // Scroll to quotation
    Future.delayed(const Duration(milliseconds: 300), () {
      Scrollable.ensureVisible(
        _quotationKey.currentContext!,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  void _resetForm() {
    setState(() {
      _showQuotation = false;
      _houseLengthController.clear();
      _houseWidthController.clear();
      _houseHeightController.clear();
      _selectedWallMaterial = null;
      _selectedRoofMaterial = null;
      _selectedFloorType = null;
      _ventilationCountController.clear();
      _hasFootbath = false;
      _hasNetting = false;
      _hasFencing = false;
      _fencingLengthController.clear();
      _selectedWaterSource = null;
      _selectedElectricityType = null;
      _solarBackupCountController.clear();
      _brooderCountController.clear();
      _feederCountController.clear();
      _drinkerCountController.clear();
      _weighingScaleCountController.clear();
      _feedPalletCountController.clear();
      _houseExteriorPhoto = null;
      _houseInteriorPhoto = null;
      _brooderPhoto = null;
      _feederPhoto = null;
      _drinkerPhoto = null;
      _feedStorePhoto = null;
      _uploadedFiles.clear();
    });
  }

  final GlobalKey _quotationKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar:  AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('2 low stock alerts'),
                  backgroundColor: Colors.green,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Form Title
              Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
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
                              'Poultry House Construction Quotation',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Fill in the details below to generate a detailed quotation for your poultry house construction',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // House Dimensions Section
              _buildSection(
                title: '1. House Dimensions & Materials',
                icon: Icons.square_foot,
                color: primaryColor,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: CustomTextField(
                          controller: _houseLengthController,
                          label: 'Length (meters)',
                          hintText: 'e.g., 15',
                          icon: Icons.straighten,
                          keyboardType: TextInputType.number,
                          value: '',
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomTextField(
                          controller: _houseWidthController,
                          label: 'Width (meters)',
                          hintText: 'e.g., 10',
                          icon: Icons.straighten,
                          keyboardType: TextInputType.number,
                          value: '',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _houseHeightController,
                    label: 'Height (meters)',
                    hintText: 'e.g., 3',
                    icon: Icons.height,
                    keyboardType: TextInputType.number,
                    value: '',
                  ),
                  const SizedBox(height: 20),

                  // Material Selection
                  _buildDropdown(
                    label: 'Wall Material *',
                    value: _selectedWallMaterial,
                    items: _wallMaterials,
                    onChanged: (value) {
                      setState(() {
                        _selectedWallMaterial = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Roof Material *',
                    value: _selectedRoofMaterial,
                    items: _roofMaterials,
                    onChanged: (value) {
                      setState(() {
                        _selectedRoofMaterial = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Floor Type',
                    value: _selectedFloorType,
                    items: _floorTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedFloorType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _ventilationCountController,
                    label: 'Number of Ventilation Points',
                    hintText: 'e.g., 8',
                    icon: Icons.air,
                    keyboardType: TextInputType.number,
                    value: '',
                  ),
                ],
              ),

              // Biosecurity Section
              _buildSection(
                title: '2. Biosecurity Measures',
                icon: Icons.security,
                color: secondaryColor,
                children: [
                  _buildCheckboxList(
                    label: 'Biosecurity Features',
                    items: {
                      'Footbath at Entrance': _hasFootbath,
                      'Bird Netting': _hasNetting,
                      'Perimeter Fencing': _hasFencing,
                    },
                    onChanged: (key, value) {
                      setState(() {
                        switch (key) {
                          case 'Footbath at Entrance':
                            _hasFootbath = value;
                            break;
                          case 'Bird Netting':
                            _hasNetting = value;
                            break;
                          case 'Perimeter Fencing':
                            _hasFencing = value;
                            if (!value) _fencingLengthController.clear();
                            break;
                        }
                      });
                    },
                  ),
                  if (_hasFencing) ...[
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _fencingLengthController,
                      label: 'Fencing Length (meters)',
                      hintText: 'e.g., 100',
                      icon: Icons.fence,
                      keyboardType: TextInputType.number,
                      value: '',
                    ),
                  ],
                ],
              ),

              // Utilities Section
              _buildSection(
                title: '3. Utilities',
                icon: Icons.bolt,
                color: accentColor,
                children: [
                  _buildDropdown(
                    label: 'Water Source',
                    value: _selectedWaterSource,
                    items: _waterSources,
                    onChanged: (value) {
                      setState(() {
                        _selectedWaterSource = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdown(
                    label: 'Electricity Type',
                    value: _selectedElectricityType,
                    items: _electricityTypes,
                    onChanged: (value) {
                      setState(() {
                        _selectedElectricityType = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _solarBackupCountController,
                    label: 'Solar Backup Lights Count',
                    hintText: 'e.g., 4',
                    icon: Icons.lightbulb,
                    keyboardType: TextInputType.number,
                    value: '',
                  ),
                ],
              ),

              // Equipment Section
              _buildSection(
                title: '4. Equipment & Accessories',
                icon: Icons.build,
                color: Colors.purple,
                children: [
                  Wrap(
                    spacing: 16,
                    runSpacing: 16,
                    children: [
                      _buildEquipmentField(
                        controller: _brooderCountController,
                        label: 'Brooders',
                        icon: Icons.heat_pump,
                      ),
                      _buildEquipmentField(
                        controller: _feederCountController,
                        label: 'Feeders',
                        icon: Icons.restaurant,
                      ),
                      _buildEquipmentField(
                        controller: _drinkerCountController,
                        label: 'Drinkers',
                        icon: Icons.water_drop,
                      ),
                      _buildEquipmentField(
                        controller: _weighingScaleCountController,
                        label: 'Weighing Scales',
                        icon: Icons.scale,
                      ),
                      _buildEquipmentField(
                        controller: _feedPalletCountController,
                        label: 'Feed Pallets',
                        icon: Icons.palette,
                      ),
                    ],
                  ),
                ],
              ),

              // Photos Section
              _buildSection(
                title: '5. House & Equipment Photos',
                icon: Icons.photo_camera,
                color: Colors.teal,
                children: [
                  const Text(
                    'Upload photos for better quotation accuracy',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    children: [
                      _buildPhotoUpload(
                        file: _houseExteriorPhoto,
                        onFileSelected: (file) => setState(() => _houseExteriorPhoto = file),
                        label: 'House Exterior',
                      ),
                      _buildPhotoUpload(
                        file: _houseInteriorPhoto,
                        onFileSelected: (file) => setState(() => _houseInteriorPhoto = file),
                        label: 'House Interior',
                      ),
                      _buildPhotoUpload(
                        file: _brooderPhoto,
                        onFileSelected: (file) => setState(() => _brooderPhoto = file),
                        label: 'Brooder',
                      ),
                      _buildPhotoUpload(
                        file: _feederPhoto,
                        onFileSelected: (file) => setState(() => _feederPhoto = file),
                        label: 'Feeder',
                      ),
                      _buildPhotoUpload(
                        file: _drinkerPhoto,
                        onFileSelected: (file) => setState(() => _drinkerPhoto = file),
                        label: 'Drinker',
                      ),
                      _buildPhotoUpload(
                        file: _feedStorePhoto,
                        onFileSelected: (file) => setState(() => _feedStorePhoto = file),
                        label: 'Feed Store',
                      ),
                    ],
                  ),
                ],
              ),

              // Additional Documents
              const SizedBox(height: 24),
              FileUpload(
                uploadedFiles: _uploadedFiles,
                onFilesSelected: _onFilesSelected,
                onFileRemoved: _onFileRemoved,
                title: 'Additional Documents (Optional)',
                description: 'Upload any existing plans, sketches, or previous quotations',
                primaryColor: primaryColor,
              ),

              // Generate Button
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isFormValid() ? _generateQuotation : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.calculate),
                  label: const Text(
                    'GENERATE QUOTATION',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Quotation Display
              if (_showQuotation) ...[
                const SizedBox(height: 40),
                Container(
                  key: _quotationKey,
                  padding: const EdgeInsets.only(top: 20),
                  child: _buildQuotationCard(),
                ),
              ],

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
      floatingActionButton: _showQuotation
          ? FloatingActionButton.extended(
        onPressed: _resetForm,
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.refresh),
        label: const Text('New Quotation'),
      )
          : null,
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.2)),
      ),
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
              const SizedBox(width: 10),
              SizedBox(
                width: MediaQuery.of(context).size.width*0.65,
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
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
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16),
            ),
            isExpanded: true,
            hint: const Text('Select option'),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxList({
    required String label,
    required Map<String, bool> items,
    required Function(String, bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        ...items.entries.map((entry) {
          return CheckboxListTile(
            title: Text(entry.key),
            value: entry.value,
            onChanged: (value) => onChanged(entry.key, value ?? false),
            controlAffinity: ListTileControlAffinity.leading,
            dense: true,
            contentPadding: EdgeInsets.zero,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildEquipmentField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return SizedBox(
      width: 150,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              hintText: 'Count',
              prefixIcon: Icon(icon, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoUpload({
    required File? file,
    required Function(File?) onFileSelected,
    required String label,
  }) {
    return SizedBox(
      child: PhotoUpload(
        file: file,
        onFileSelected: onFileSelected,
        title: label,
        description: '',
        primaryColor: primaryColor,
        isRequired: false,
      ),
    );
  }

  Widget _buildQuotationCard() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quotation Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'QUOTATION',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    Text(
                      'Poultry House Construction',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'REF #${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Divider(),
            const SizedBox(height: 16),

            // Specifications
            Text(
              'SPECIFICATIONS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            if (_quotationData['specifications'] != null) ...[
              _buildSpecItem('Dimensions', _quotationData['specifications']['dimensions']),
              _buildSpecItem('Wall Material', _quotationData['specifications']['wallMaterial']),
              _buildSpecItem('Roof Material', _quotationData['specifications']['roofMaterial']),
              if (_quotationData['specifications']['floorType'] != null)
                _buildSpecItem('Floor Type', _quotationData['specifications']['floorType']),
            ],
            const SizedBox(height: 24),

            // Materials Table
            Text(
              'MATERIALS COSTING',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 32,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 40,
                  headingRowHeight: 50,
                  headingTextStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                  columns: const [
                    DataColumn(label: Text('NO')),
                    DataColumn(label: Text('MATERIAL')),
                    DataColumn(label: Text('UNIT')),
                    DataColumn(label: Text('RATE (KSh)')),
                    DataColumn(label: Text('QUANTITY')),
                    DataColumn(label: Text('TOTAL (KSh)')),
                  ],
                  rows: List.generate(_quotationData['materials']?.length ?? 0, (index) {
                    final item = _quotationData['materials'][index];
                    return DataRow(cells: [
                      DataCell(Text('${index + 1}')),
                      DataCell(Text(item['name'])),
                      DataCell(Text(item['unit'])),
                      DataCell(Text(item['rate'])),
                      DataCell(Text(item['quantity'])),
                      DataCell(Text(item['total'])),
                    ]);
                  }),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Totals
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildTotalRow('SUB TOTAL', _quotationData['subtotal'] ?? '0'),
                  const SizedBox(height: 8),
                  _buildTotalRow('LABOUR', _quotationData['labor'] ?? '0'),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primaryColor),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'GRAND TOTAL',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        Text(
                          'KSh ${_quotationData['grandTotal'] ?? '0'}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Notes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange.shade700),
                      const SizedBox(width: 8),
                      Text(
                        'Notes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• This quotation is valid for 30 days from the date of issue\n'
                        '• Prices include VAT where applicable\n'
                        '• Installation and delivery costs are included\n'
                        '• Terms: 50% deposit, balance upon completion\n'
                        '• Warranty: 1 year on materials and workmanship',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Implement share functionality
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share Quotation'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: BorderSide(color: primaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Implement save/approve functionality
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Approve & Save'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpecItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        Text(
          'KSh $amount',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}