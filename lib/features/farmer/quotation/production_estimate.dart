import 'package:agriflock360/features/farmer/batch/repo/batch_house_repo.dart';
import 'package:agriflock360/features/farmer/quotation/models/production_quotation_model.dart';
import 'package:agriflock360/features/farmer/quotation/repo/quotation_repository.dart';
import 'package:agriflock360/features/farmer/quotation/widgets/image_with_desc.dart';
import 'package:flutter/material.dart';
import 'package:agriflock360/core/utils/result.dart';
import 'package:agriflock360/core/utils/api_error_handler.dart';
import 'package:agriflock360/core/utils/toast_util.dart';
import 'package:agriflock360/features/farmer/batch/model/bird_type.dart';

// ─── FRONTEND CALCULATOR CONSTANTS ───────────────────────────────────────────

class _FeedPhase {
  final String key, name, weeks;
  final int bagsPerUnit, defaultPrice;
  const _FeedPhase({
    required this.key,
    required this.name,
    required this.bagsPerUnit,
    required this.defaultPrice,
    required this.weeks,
  });
}

class _MedItem {
  final String name;
  final int unitPrice;
  const _MedItem(this.name, this.unitPrice);
}

class _BirdConfig {
  final String label, icon, targetWeight, duration;
  final int cyclesPerYear;
  final List<_FeedPhase> feedPhases;
  final List<_MedItem> medicationItems, vaccineItems;
  const _BirdConfig({
    required this.label,
    required this.icon,
    required this.targetWeight,
    required this.duration,
    required this.cyclesPerYear,
    required this.feedPhases,
    required this.medicationItems,
    required this.vaccineItems,
  });
}

const _broilerConfig = _BirdConfig(
  label: 'Broilers',
  icon: '🐔',
  targetWeight: '2 kg',
  duration: '5 weeks',
  cyclesPerYear: 6,
  feedPhases: [
    _FeedPhase(key: 'starter',  name: 'Starter Crumbs',  bagsPerUnit: 1, defaultPrice: 3800, weeks: 'Week 1–2'),
    _FeedPhase(key: 'finisher', name: 'Finisher Pellets', bagsPerUnit: 2, defaultPrice: 3600, weeks: 'Week 3–5'),
  ],
  medicationItems: [
    _MedItem('Multivitamin', 300),
    _MedItem('Disinfectant', 300),
    _MedItem('Antibiotic',   300),
  ],
  vaccineItems: [
    _MedItem('Newcastle Vaccine', 450),
    _MedItem('Gumboro Vaccine',   450),
  ],
);

const _kienyejiConfig = _BirdConfig(
  label: 'Improved Indigenous (Kienyeji)',
  icon: '🐓',
  targetWeight: '1.8 kg',
  duration: '12 weeks (3 months)',
  cyclesPerYear: 3,
  feedPhases: [
    _FeedPhase(key: 'chickmash',  name: 'Chick Mash',           bagsPerUnit: 2, defaultPrice: 3500, weeks: 'Week 1–6'),
    _FeedPhase(key: 'growermash', name: 'Kienyeji Grower Mash', bagsPerUnit: 3, defaultPrice: 3400, weeks: 'Week 7–12'),
  ],
  medicationItems: [
    _MedItem('Multivitamin', 300),
    _MedItem('Disinfectant', 300),
    _MedItem('Antibiotic',   300),
  ],
  vaccineItems: [
    _MedItem('Newcastle Vaccine',    450),
    _MedItem('Gumboro Vaccine',      450),
    _MedItem('Fowl Typhoid Vaccine', 450),
  ],
);

const _equipmentItems = [
  'Brooding equipment (heat lamps, brooders, extension cords)',
  'Feeders & drinkers — ratio: 1 feeder + 1 drinker per 50 birds',
  'Weighing scale',
  'Feed storage pallets / bins',
  'Spray pumps for biosecurity',
];

const _utilityItems = [
  'Electricity / fuel for brooding',
  'Water supply costs',
  'Transport (chick collection, feed delivery, bird sales)',
  'Labour / casual workers',
  'House construction, maintenance & repairs',
  'Litter / bedding material (wood shavings, rice husks)',
  'Biosecurity consumables (foot baths, PPE)',
  'Contingency / emergency vet costs',
];

// ─── THEME ───────────────────────────────────────────────────────────────────

const _kGreen900 = Color(0xFF1B4332);
const _kGreen100 = Color(0xFFD8F3DC);
const _kCream    = Color(0xFFF4EFE6);
const _kCard     = Color(0xFFFFFFFF);
const _kBorder   = Color(0xFFE8DFC8);
const _kMuted    = Color(0xFF999999);

// ─── CALC HELPERS ─────────────────────────────────────────────────────────────

int _unitsOf50(int n) => (n / 50).ceil();

String _fmtCalc(double n) {
  final formatted = n.abs().toStringAsFixed(0).replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
        (m) => '${m[1]},',
  );
  return 'Ksh $formatted';
}

class _CalcResult {
  final int units, survived, breakEven;
  final double chickCost, totalFeedCost, medCost, vacCost,
      totalProductionCost, costPerBird, revenue, grossProfit;
  final String roi;
  final List<Map<String, dynamic>> feedLines, medLines, vacLines;

  _CalcResult({
    required this.units,      required this.survived,         required this.breakEven,
    required this.chickCost,  required this.totalFeedCost,
    required this.medCost,    required this.vacCost,
    required this.totalProductionCost, required this.costPerBird,
    required this.revenue,    required this.grossProfit,       required this.roi,
    required this.feedLines,  required this.medLines,          required this.vacLines,
  });
}

_CalcResult _calculate({
  required _BirdConfig config,
  required int birds,
  required int chickPrice,
  required double mortalityRate,
  required int sellingPrice,
  required Map<String, int> feedPrices,
}) {
  final units     = _unitsOf50(birds);
  final chickCost = (birds * chickPrice).toDouble();

  final feedLines = config.feedPhases.map((p) {
    final bags = units * p.bagsPerUnit;
    final cost = bags * (feedPrices[p.key] ?? p.defaultPrice);
    return {'phase': p, 'bags': bags, 'cost': cost.toDouble()};
  }).toList();
  final totalFeedCost = feedLines.fold(0.0, (s, f) => s + (f['cost'] as double));

  final medLines = config.medicationItems.map((m) =>
  {'item': m, 'qty': units, 'cost': (m.unitPrice * units).toDouble()}).toList();
  final medCost = medLines.fold(0.0, (s, m) => s + (m['cost'] as double));

  final vacLines = config.vaccineItems.map((v) =>
  {'item': v, 'qty': units, 'cost': (v.unitPrice * units).toDouble()}).toList();
  final vacCost = vacLines.fold(0.0, (s, v) => s + (v['cost'] as double));

  final totalProductionCost = chickCost + totalFeedCost + medCost + vacCost;
  final costPerBird = totalProductionCost / birds;
  final survived    = (birds * (1 - mortalityRate / 100)).round();
  final revenue     = (survived * sellingPrice).toDouble();
  final grossProfit = revenue - totalProductionCost;
  final roi = totalProductionCost > 0
      ? ((grossProfit / totalProductionCost) * 100).toStringAsFixed(1)
      : '0.0';
  final breakEven = sellingPrice > 0 ? (totalProductionCost / sellingPrice).ceil() : 0;

  return _CalcResult(
    units: units, survived: survived, breakEven: breakEven,
    chickCost: chickCost, totalFeedCost: totalFeedCost,
    medCost: medCost, vacCost: vacCost,
    totalProductionCost: totalProductionCost, costPerBird: costPerBird,
    revenue: revenue, grossProfit: grossProfit, roi: roi,
    feedLines: feedLines, medLines: medLines, vacLines: vacLines,
  );
}

// ─── MAIN SCREEN — 3 TABS ────────────────────────────────────────────────────

class ProductionEstimateScreen extends StatefulWidget {
  const ProductionEstimateScreen({super.key});

  @override
  State<ProductionEstimateScreen> createState() => _ProductionEstimateScreenState();
}

class _ProductionEstimateScreenState extends State<ProductionEstimateScreen>
    with SingleTickerProviderStateMixin {

  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
    _tab.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kCream,
      body: SafeArea(
        child: Column(
          children: [
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tab,
                children: const [
                  _LayersTab(),
                  _FrontendCalculatorPage(config: _broilerConfig),
                  _FrontendCalculatorPage(config: _kienyejiConfig),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE5DDD0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tabBtn(0, '🥚', 'Layers',     '128+ birds · eggs'),
          const SizedBox(width: 4),
          _tabBtn(1, '🐔', 'Broilers',   '5 wks · 2 kg'),
          const SizedBox(width: 4),
          _tabBtn(2, '🐓', 'Indigenous', '12 wks · 1.8 kg'),
        ],
      ),
    );
  }

  Widget _tabBtn(int idx, String icon, String label, String sub) {
    final active = _tab.index == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => _tab.animateTo(idx),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
          decoration: BoxDecoration(
            color: active ? _kGreen900 : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [BoxShadow(color: _kGreen900.withOpacity(0.28), blurRadius: 10, offset: const Offset(0, 3))]
                : [],
          ),
          child: Column(children: [
            Text('$icon $label',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: active ? Colors.white : const Color(0xFF666666),
                )),
            const SizedBox(height: 2),
            Text(sub,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 9, color: active ? Colors.white70 : _kMuted)),
          ]),
        ),
      ),
    );
  }
}

// ─── LAYERS TAB (API-driven — unchanged from original) ───────────────────────

class _LayersTab extends StatefulWidget {
  const _LayersTab();

  @override
  State<_LayersTab> createState() => _LayersTabState();
}

class _LayersTabState extends State<_LayersTab> {
  static const Color primaryColor = Color(0xFF2E7D32);

  final _batchRepo      = BatchHouseRepository();
  final _quotationRepo  = QuotationRepository();

  bool _isLoadingBirdTypes    = false;
  bool _isGeneratingQuotation = false;
  List<BirdType> _birdTypes   = [];
  ProductionQuotationData? _quotationData;
  BirdType? _selectedBreed;
  int?      _selectedCapacity;

  final Map<String, TextEditingController> _ctrl = {};

  static const List<int> _quantities = [128, 256, 512, 1024, 2048];

  double get _scale => _selectedCapacity != null ? _selectedCapacity! / 128.0 : 1.0;

  // Only show laying breeds in this tab
  List<BirdType> get _layerBreeds =>
      _birdTypes.where((b) => b.name.toLowerCase().contains('laying eggs')).toList();

  @override
  void initState() {
    super.initState();
    _loadBirdTypes();
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) c.dispose();
    super.dispose();
  }

  Future<void> _loadBirdTypes() async {
    try {
      setState(() => _isLoadingBirdTypes = true);
      final result = await _batchRepo.getBirdTypes();
      switch (result) {
        case Success(data: final types):
          setState(() { _birdTypes = types; _isLoadingBirdTypes = false; });
        case Failure(:final response, :final message):
          if (response != null) ApiErrorHandler.handle(response);
          else ToastUtil.showError(message);
          setState(() => _isLoadingBirdTypes = false);
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
      setState(() => _isLoadingBirdTypes = false);
    }
  }

  void _initControllers(ProductionQuotationData data) {
    for (final c in _ctrl.values) c.dispose();
    _ctrl.clear();
    final lb = data.layersBreakdown;
    if (lb == null) return;
    for (int i = 0; i < lb.stage1.items.length; i++) {
      final p = double.tryParse(lb.stage1.items[i].unitPrice) ?? 0.0;
      _ctrl['s1_$i'] = TextEditingController(text: p.toStringAsFixed(2));
    }
    for (int i = 0; i < lb.stage2.items.length; i++) {
      final p = double.tryParse(lb.stage2.items[i].unitPrice) ?? 0.0;
      _ctrl['s2_$i'] = TextEditingController(text: p.toStringAsFixed(2));
    }
  }

  Future<void> _generateQuotation() async {
    if (_selectedBreed == null || _selectedCapacity == null) {
      ToastUtil.showError('Please select breed and flock size');
      return;
    }
    try {
      setState(() => _isGeneratingQuotation = true);
      final result = await _quotationRepo.productionQuotation(
          breedId: _selectedBreed!.id, quantity: 128);
      switch (result) {
        case Success(data: final quotation):
          _initControllers(quotation);
          setState(() { _quotationData = quotation; _isGeneratingQuotation = false; });
          ToastUtil.showSuccess('Quotation generated successfully');
        case Failure(:final response, :final message):
          if (response != null) ApiErrorHandler.handle(response);
          else ToastUtil.showError(message);
          setState(() => _isGeneratingQuotation = false);
      }
    } catch (e) {
      ApiErrorHandler.handle(e);
      setState(() => _isGeneratingQuotation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
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
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Icon(Icons.egg_alt, color: primaryColor, size: 32),
                    const SizedBox(width: 12),
                    const Expanded(child: Text('Layers Production Quotation',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  ]),
                  const SizedBox(height: 8),
                  Text(
                    'Select your laying breed and flock size to get a full two-stage production cost estimate.',
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600, height: 1.5),
                  ),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // Breed selection
            Text('Select Laying Breed',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 8),

            if (_isLoadingBirdTypes)
              const Center(child: CircularProgressIndicator(color: primaryColor))
            else if (_layerBreeds.isEmpty)
              const Center(child: Text('No laying breeds available'))
            else
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _layerBreeds.length,
                  itemBuilder: (_, i) => _breedCard(_layerBreeds[i]),
                ),
              ),
            const SizedBox(height: 24),

            // Flock size
            if (_selectedBreed != null) ...[
              Text('Select Flock Size',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              const SizedBox(height: 4),
              Text('Base estimate uses 128 birds. Select a size to scale the quotation:',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                value: _selectedCapacity,
                decoration: InputDecoration(
                  labelText: 'Flock Size',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                hint: const Text('Select flock size'),
                items: _quantities.map((qty) {
                  final f = qty ~/ 128;
                  return DropdownMenuItem<int>(
                      value: qty,
                      child: Text(f == 1 ? '$qty Birds (Base)' : '$qty Birds (×$f)'));
                }).toList(),
                onChanged: _isGeneratingQuotation
                    ? null
                    : (v) {
                  if (v == null) return;
                  setState(() => _selectedCapacity = v);
                  if (_quotationData == null) _generateQuotation();
                },
              ),
              const SizedBox(height: 20),
              if (_isGeneratingQuotation)
                const Center(child: CircularProgressIndicator(color: primaryColor)),
              const SizedBox(height: 16),
            ],

            // Quotation
            if (_quotationData != null) ...[
              _layersTables(),
              const SizedBox(height: 40),
              ImageWithDescriptionWidget(
                  imageAssetPath: 'assets/quotation/img_7.png',
                  description: 'This is the first image description'),
              ImageWithDescriptionWidget(
                  imageAssetPath: 'assets/quotation/img_8.png',
                  description: 'This is the first image description'),
              const SizedBox(height: 10),
              _disclaimer(),
              const SizedBox(height: 32),
            ],
          ]),
        ),
      ),
    ]);
  }

  Widget _breedCard(BirdType breed) {
    final sel = _selectedBreed?.id == breed.id;
    const color = Colors.orange;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedBreed = breed; _selectedCapacity = null; _quotationData = null;
      }),
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        child: Card(
          elevation: sel ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: sel ? color : Colors.grey.shade300, width: sel ? 2 : 1),
          ),
          color: sel ? color.withOpacity(0.1) : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.2), shape: BoxShape.circle),
                child: const Icon(Icons.egg, color: color, size: 18),
              ),
              const SizedBox(height: 6),
              Text(breed.name,
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
                  textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(breed.name,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                  textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
        ),
      ),
    );
  }

  // ── Layers quotation tables (unchanged logic from original) ──────────────

  Widget _stageTable(String key, String title, List<BreakdownItem> items, double factor) {
    double subtotal = 0;
    final rows = <DataRow>[];

    for (int i = 0; i < items.length; i++) {
      final item     = items[i];
      final c        = _ctrl['${key}_$i'];
      final price    = double.tryParse(c?.text ?? '') ?? double.tryParse(item.unitPrice) ?? 0.0;
      final qty      = (item.quantity * factor).round();
      final rowTotal = price * qty;
      subtotal      += rowTotal;

      rows.add(DataRow(cells: [
        DataCell(Container(constraints: const BoxConstraints(minWidth: 150),
            child: Text(item.name, style: const TextStyle(fontSize: 12)))),
        DataCell(Container(constraints: const BoxConstraints(minWidth: 70),
            child: Text(item.unit, style: const TextStyle(fontSize: 12)))),
        DataCell(Container(constraints: const BoxConstraints(minWidth: 50),
            child: Text('$qty', style: const TextStyle(fontSize: 12)))),
        DataCell(SizedBox(width: 100,
          child: TextField(
            controller: c,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                border: OutlineInputBorder()),
            onChanged: (_) => setState(() {}),
          ),
        )),
        DataCell(Container(constraints: const BoxConstraints(minWidth: 100),
            child: Text(_fmt(rowTotal),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))),
      ]));
    }

    rows.add(DataRow(cells: [
      DataCell(Container(color: Colors.teal.withOpacity(0.08),
          constraints: const BoxConstraints(minWidth: 150),
          child: const Text('SUB TOTAL',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)))),
      const DataCell(Text('')), const DataCell(Text('')), const DataCell(Text('')),
      DataCell(Container(color: Colors.teal.withOpacity(0.08),
          constraints: const BoxConstraints(minWidth: 100),
          child: Text(_fmt(subtotal),
              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)))),
    ]));

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
      const SizedBox(height: 8),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columnSpacing: 16, horizontalMargin: 16,
          dataRowMinHeight: 52, dataRowMaxHeight: 52,
          columns: const [
            DataColumn(label: Text('Item')),
            DataColumn(label: Text('Unit')),
            DataColumn(label: Text('Qty')),
            DataColumn(label: Text('Unit Price (KSh)')),
            DataColumn(label: Text('Total (KSh)')),
          ],
          rows: rows,
        ),
      ),
    ]);
  }

  Widget _layersTables() {
    final lb       = _quotationData!.layersBreakdown!;
    final factor   = _scale;
    final qty      = _selectedCapacity ?? 128;

    double grand = 0;
    for (int i = 0; i < lb.stage1.items.length; i++) {
      final p = double.tryParse(_ctrl['s1_$i']?.text ?? '') ??
          double.tryParse(lb.stage1.items[i].unitPrice) ?? 0.0;
      grand += p * (lb.stage1.items[i].quantity * factor).round();
    }
    for (int i = 0; i < lb.stage2.items.length; i++) {
      final p = double.tryParse(_ctrl['s2_$i']?.text ?? '') ??
          double.tryParse(lb.stage2.items[i].unitPrice) ?? 0.0;
      grand += p * (lb.stage2.items[i].quantity * factor).round();
    }

    final analysis = lb.analysis;
    final scaledInv   = analysis.totalInvestment * factor;
    final scaledTrays = (analysis.traysAt70LayRate * factor).round();

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.layers, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LAYERS PRODUCTION QUOTATION',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text('$qty birds  •  scale ×${factor == factor.roundToDouble() ? factor.toInt() : factor}',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
          ])),
        ]),
      ),
      const SizedBox(height: 16),
      TextButton.icon(onPressed: null,
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          label: const Text('Scroll left or right to see the full table.')),

      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.teal.withOpacity(0.2))),
        child: Padding(padding: const EdgeInsets.all(16),
            child: _stageTable('s1', 'Stage 1 — Rearing Phase (0–20 weeks)', lb.stage1.items, factor)),
      ),
      const SizedBox(height: 16),
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.teal.withOpacity(0.2))),
        child: Padding(padding: const EdgeInsets.all(16),
            child: _stageTable('s2', 'Stage 2 — Laying Phase (20–80 weeks)', lb.stage2.items, factor)),
      ),
      const SizedBox(height: 16),

      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('GRAND TOTAL',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
          Text('KSh ${_fmt(grand)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.green)),
        ]),
      ),
      const SizedBox(height: 20),

      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.blue.withOpacity(0.2))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Icon(Icons.analytics_outlined, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text('INVESTMENT ANALYSIS',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.blue)),
            ]),
            const SizedBox(height: 12),
            _aRow('Total Investment',         'KSh ${_fmt(scaledInv)}'),
            _aRow('Trays at 70% Lay Rate',    '$scaledTrays trays'),
            _aRow('Cost per Egg',             'KSh ${analysis.costPerEgg.toStringAsFixed(2)}', note: 'fixed'),
            _aRow('Break-even Cost per Tray', 'KSh ${_fmt(analysis.breakEvenCostPerTray)}',   note: 'fixed'),
          ]),
        ),
      ),
    ]);
  }

  Widget _aRow(String label, String value, {String? note}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
      Row(children: [
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        if (note != null) ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(4)),
            child: Text(note, style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
          ),
        ],
      ]),
    ]),
  );

  Widget _disclaimer() => Card(
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.withOpacity(0.2))),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.warning, color: Colors.orange, size: 20),
          const SizedBox(width: 8),
          const Text('DISCLAIMER',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.orange)),
        ]),
        const SizedBox(height: 12),
        Text(
          '• Prices are estimates and may vary based on location and market conditions\n'
              '• Mortality rates and production figures are industry averages\n'
              '• Consult with agricultural experts for specific farm conditions\n'
              '• Equipment costs are one-time expenses\n'
              '• Revenue projections are based on current market prices',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700, height: 1.5),
        ),
      ]),
    ),
  );

  String _fmt(double v) => v.toInt().toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ─── FRONTEND CALCULATOR PAGE (Broilers & Indigenous) ────────────────────────

class _FrontendCalculatorPage extends StatefulWidget {
  final _BirdConfig config;
  const _FrontendCalculatorPage({super.key, required this.config});

  @override
  State<_FrontendCalculatorPage> createState() => _FrontendCalculatorPageState();
}

class _FrontendCalculatorPageState extends State<_FrontendCalculatorPage> {
  late int    birds, chickPrice, sellingPrice;
  late double mortalityRate;
  late Map<String, int> feedPrices;

  @override
  void initState() {
    super.initState();
    _reset();
  }

  void _reset() {
    birds         = 50;
    chickPrice    = widget.config.label.contains('Broiler') ? 120 : 80;
    sellingPrice  = widget.config.label.contains('Broiler') ? 550 : 700;
    mortalityRate = 5.0;
    feedPrices    = {for (final p in widget.config.feedPhases) p.key: p.defaultPrice};
  }

  @override
  Widget build(BuildContext context) {
    final r = _calculate(
      config: widget.config, birds: birds, chickPrice: chickPrice,
      mortalityRate: mortalityRate, sellingPrice: sellingPrice, feedPrices: feedPrices,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        _pills(),
        const SizedBox(height: 8),
        _flockSection(),
        const SizedBox(height: 12),
        _feedSection(),
        const SizedBox(height: 12),
        _sellingSection(),
        const SizedBox(height: 12),
        _quotationSection(r),
        const SizedBox(height: 12),
        _profitSection(r),
        const SizedBox(height: 12),
        _equipmentSection(r),
        const SizedBox(height: 12),
        const _DisclaimerWidget(),
        const SizedBox(height: 20),
        _footer(),
      ],
    );
  }

  Widget _pills() {
    final pills = ['${widget.config.targetWeight} target', widget.config.duration,
      '${widget.config.cyclesPerYear} cycles/yr'];
    return Wrap(spacing: 6, children: pills.map((p) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: _kGreen100, borderRadius: BorderRadius.circular(20)),
      child: Text(p, style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700, color: _kGreen900, letterSpacing: 0.3)),
    )).toList());
  }

  Widget _flockSection() => _card(title: '🐣 Flock Setup', children: [
    _input(label: 'Number of chicks', note: 'Scales automatically in units of 50',
        value: birds.toDouble(), min: 10, step: 50,
        onChange: (v) => setState(() => birds = v.toInt())),
    _input(label: 'Price per chick', prefix: 'Ksh',
        value: chickPrice.toDouble(), min: 1,
        onChange: (v) => setState(() => chickPrice = v.toInt())),
    _input(label: 'Mortality rate', suffix: '%',
        value: mortalityRate, min: 0, max: 50, step: 0.5, isDouble: true,
        onChange: (v) => setState(() => mortalityRate = v)),
  ]);

  Widget _feedSection() => _card(title: '🌾 Feed Prices (per 50 kg bag)',
      children: widget.config.feedPhases.map((p) => _input(
        label: p.name, note: p.weeks, prefix: 'Ksh',
        value: feedPrices[p.key]!.toDouble(), min: 1,
        onChange: (v) => setState(() => feedPrices[p.key] = v.toInt()),
      )).toList());

  Widget _sellingSection() => _card(title: '💰 Market Selling Price', children: [
    _input(label: 'Price per bird',
        note: 'Live weight ~${widget.config.targetWeight} — adjust for your region',
        prefix: 'Ksh', value: sellingPrice.toDouble(), min: 1,
        onChange: (v) => setState(() => sellingPrice = v.toInt())),
  ]);

  Widget _quotationSection(_CalcResult r) => _card(
    title: '📋 Production Cost Quotation — $birds Birds',
    children: [
      _grp('Day-Old Chicks'),
      _row('$birds chicks × Ksh ${chickPrice._loc()}', _fmtCalc(r.chickCost)),
      const SizedBox(height: 10),
      _grp('Feeds'),
      ...r.feedLines.map((f) {
        final p = f['phase'] as _FeedPhase;
        return _row('${p.name} — ${f['bags']} bag(s) × 50 kg  [${p.weeks}]',
            _fmtCalc(f['cost'] as double), sub: true);
      }),
      _row('Total Feed Cost', _fmtCalc(r.totalFeedCost), hi: true),
      const SizedBox(height: 10),
      _grp('Medications (per ${r.units} unit${r.units > 1 ? "s" : ""} of 50)'),
      ...r.medLines.map((m) {
        final item = m['item'] as _MedItem;
        return _row('${item.name} — ${m['qty']} dose(s)', _fmtCalc(m['cost'] as double), sub: true);
      }),
      const SizedBox(height: 10),
      _grp('Vaccines (per ${r.units} unit${r.units > 1 ? "s" : ""} of 50)'),
      ...r.vacLines.map((v) {
        final item = v['item'] as _MedItem;
        return _row('${item.name} — ${v['qty']} dose(s)', _fmtCalc(v['cost'] as double), sub: true);
      }),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _kCream, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          _row('TOTAL PRODUCTION COST', _fmtCalc(r.totalProductionCost), hi: true),
          _row('Cost per bird', _fmtCalc(r.costPerBird)),
        ]),
      ),
    ],
  );

  Widget _profitSection(_CalcResult r) {
    final ok = r.grossProfit >= 0;
    return _card(title: '📊 Profit Summary', children: [
      _row('Revenue — ${r.survived} birds × Ksh ${sellingPrice._loc()}', _fmtCalc(r.revenue), sub: true),
      _row('Less: Total production cost', '(${_fmtCalc(r.totalProductionCost)})', sub: true),
      _row('Gross Profit / Loss', '${ok ? "+" : ""}${_fmtCalc(r.grossProfit)}', hi: true),
      _row('Return on Investment (ROI)', '${r.roi}%'),
      _row('Break-even: birds to sell', '${r.breakEven} birds'),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: ok ? _kGreen100 : const Color(0xFFFFE4E4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          ok ? '✅ Profitable at Ksh ${sellingPrice._loc()}/bird — Est. net: ${_fmtCalc(r.grossProfit)}'
              : '⚠️ Loss at Ksh ${sellingPrice._loc()}/bird — raise selling price or reduce costs',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
              color: ok ? _kGreen900 : const Color(0xFF9B1C1C)),
        ),
      ),
    ]);
  }

  Widget _equipmentSection(_CalcResult r) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: const Color(0xFFFFFDF5),
        borderRadius: BorderRadius.circular(18), border: Border.all(color: _kBorder, width: 1.5)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _secTitle('🔧 Equipment Ratio Guide'),
      Text('For $birds birds (${r.units} unit${r.units > 1 ? "s" : ""} of 50) you need at minimum:',
          style: const TextStyle(fontSize: 13)),
      const SizedBox(height: 12),
      Row(children: [
        _equipCard('🥣', '${r.units}', 'Feeder(s)\n10 kg capacity'),
        const SizedBox(width: 12),
        _equipCard('💧', '${r.units}', 'Drinker(s)\n10 L capacity'),
      ]),
      const SizedBox(height: 10),
      const Text('Feeder & drinker costs are not included in the quotation above — see the disclaimer below.',
          style: TextStyle(fontSize: 11, color: _kMuted, fontStyle: FontStyle.italic)),
    ]),
  );

  Widget _equipCard(String icon, String count, String label) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: _kCream, borderRadius: BorderRadius.circular(12)),
      child: Column(children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 4),
        Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: _kGreen900)),
        const SizedBox(height: 4),
        Text(label, textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF777777))),
      ]),
    ),
  );

  Widget _footer() => const Text(
    'Powered by AgriFlock 360 & ePoultry · Tenekaland Holdings\nFor planning purposes only.',
    textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFFBBBBBB)),
  );

  // ── UI helpers ──

  Widget _card({required String title, required List<Widget> children}) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(color: _kCard, borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)]),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
        children: [_secTitle(title), ...children]),
  );

  Widget _secTitle(String t) => Container(
    margin: const EdgeInsets.only(bottom: 14),
    padding: const EdgeInsets.only(bottom: 8),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0E8D8), width: 1.5))),
    child: Text(t.toUpperCase(), style: const TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: _kGreen900)),
  );

  Widget _grp(String t) => Padding(
    padding: const EdgeInsets.only(bottom: 5),
    child: Text(t, style: const TextStyle(
        fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 1, color: Color(0xFFAAAAAA))),
  );

  Widget _row(String label, String value, {bool hi = false, bool sub = false}) => Padding(
    padding: EdgeInsets.only(left: sub ? 10 : 0, top: 4, bottom: 4),
    child: Row(children: [
      Expanded(child: Text(label, style: TextStyle(
        fontSize: hi ? 14 : (sub ? 12 : 13),
        fontWeight: hi ? FontWeight.w700 : FontWeight.w400,
        color: hi ? _kGreen900 : (sub ? const Color(0xFF666666) : const Color(0xFF1A1A1A)),
      ))),
      const SizedBox(width: 8),
      Text(value, style: TextStyle(fontSize: hi ? 14 : 13, fontWeight: FontWeight.w700,
          color: hi ? _kGreen900 : const Color(0xFF1A1A1A))),
    ]),
  );

  Widget _input({
    required String label, String? note,
    String prefix = '', String suffix = '',
    required double value, required ValueChanged<double> onChange,
    double min = 0, double? max, double step = 1, bool isDouble = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
          if (note != null) Text(note, style: const TextStyle(fontSize: 10, color: _kMuted)),
        ])),
        const SizedBox(width: 14),
        Container(
          decoration: BoxDecoration(color: const Color(0xFFF8F3EA),
              borderRadius: BorderRadius.circular(9), border: Border.all(color: _kBorder, width: 1.5)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            if (prefix.isNotEmpty) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(color: Color(0xFFEDE5D4),
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8))),
              child: Text(prefix, style: const TextStyle(fontSize: 11, color: _kMuted)),
            ),
            GestureDetector(
              onTap: () { final nv = (value - step).clamp(min, max ?? double.infinity);
              onChange(isDouble ? nv : nv.roundToDouble()); },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: const Icon(Icons.remove, size: 14, color: _kMuted)),
            ),
            SizedBox(width: 60,
                child: Text(isDouble ? value.toStringAsFixed(1) : value.toInt().toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700))),
            GestureDetector(
              onTap: () { final nv = max != null ? (value + step).clamp(min, max) : value + step;
              onChange(isDouble ? nv : nv.roundToDouble()); },
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                  child: const Icon(Icons.add, size: 14, color: _kMuted)),
            ),
            if (suffix.isNotEmpty) Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: const BoxDecoration(color: Color(0xFFEDE5D4),
                  borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8))),
              child: Text(suffix, style: const TextStyle(fontSize: 11, color: _kMuted)),
            ),
          ]),
        ),
      ]),
    );
  }
}

// ─── DISCLAIMER WIDGET ───────────────────────────────────────────────────────

class _DisclaimerWidget extends StatefulWidget {
  const _DisclaimerWidget();

  @override
  State<_DisclaimerWidget> createState() => _DisclaimerWidgetState();
}

class _DisclaimerWidgetState extends State<_DisclaimerWidget> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEE),
        border: Border.all(color: const Color(0xFFF0D080), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _open = !_open),
          child: Container(padding: const EdgeInsets.all(16),
              child: Row(children: [
                const Expanded(child: Text('⚠️ Costs NOT captured in this quotation',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7A5000)))),
                Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: const Color(0xFF7A5000)),
              ])),
        ),
        if (_open) ...[
          const Divider(height: 1, color: Color(0xFFF0D080)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('This calculator covers direct production costs only (chicks, feeds, medications, vaccines). Estimate these separately:',
                  style: TextStyle(fontSize: 12, color: Color(0xFF444444))),
              const SizedBox(height: 12),
              _dg('Equipment', _equipmentItems),
              const SizedBox(height: 8),
              _dg('Utilities & Overhead', _utilityItems),
              const SizedBox(height: 12),
              const Text('Disclaimer: All figures are estimates based on Kenyan market averages. Actual costs and revenues will vary by region, season, breed performance, management, and market prices. For planning purposes only. Consult a qualified livestock officer for farm-specific guidance.',
                  style: TextStyle(fontSize: 10, color: Color(0xFF999999), fontStyle: FontStyle.italic)),
            ]),
          ),
        ],
      ]),
    );
  }

  Widget _dg(String title, List<String> items) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(title.toUpperCase(), style: const TextStyle(
          fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: _kGreen900)),
      const SizedBox(height: 4),
      ...items.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 3, left: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('• ', style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
          Expanded(child: Text(item, style: const TextStyle(fontSize: 11, color: Color(0xFF444444)))),
        ]),
      )),
    ],
  );
}

// ─── EXTENSION ───────────────────────────────────────────────────────────────

extension _IntFmt on int {
  String _loc() => toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}