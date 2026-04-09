import 'package:agriflock/core/models/bird_type.dart';
import 'package:agriflock/core/repositories/bird_type_repository.dart';
import 'package:agriflock/features/farmer/quotation/models/production_quotation_model.dart';
import 'package:agriflock/features/farmer/quotation/repo/quotation_repository.dart';
import 'package:agriflock/features/farmer/quotation/widgets/image_with_desc.dart';
import 'package:flutter/material.dart';
import 'package:agriflock/core/utils/result.dart';
import 'package:agriflock/core/widgets/app_snack_bar.dart';

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

// ─── LAYERS PHASE 2 DATA MODEL ────────────────────────────────────────────────

class _LayersPhase2State {
  int layingWeeks;
  int flock;
  double prodPct;
  int bagsPerMonth;
  int bagCost;
  int trayPrice;
  int otherMonthly;
  int exBirds;
  int exBirdPrice;

  /// Controller for the "Flock size (birds)" input so it stays in sync
  /// with the top-level flock size dropdown.
  final TextEditingController flockController;

  _LayersPhase2State({
    this.layingWeeks  = 78,
    this.flock        = 128,
    this.prodPct      = 75,
    this.bagsPerMonth = 9,
    this.bagCost      = 3700,
    this.trayPrice    = 460,
    this.otherMonthly = 0,
    this.exBirds      = 128,
    this.exBirdPrice  = 300,
  }) : flockController = TextEditingController(text: '128');
}

class _LayersPhase2Result {
  final double months;
  final double eggsPerDay;
  final double traysPerMonth;
  final double revPerMonth;
  final double feedCostPerMonth;
  final double totalCostPerMonth;
  final double netPerMonth;
  final double totalRevenue;
  final double totalCosts;
  final double exLayerTotal;
  final double grandRevenue;
  final double overallNet;
  final double? breakEvenWeek; // null if never

  _LayersPhase2Result({
    required this.months,
    required this.eggsPerDay,
    required this.traysPerMonth,
    required this.revPerMonth,
    required this.feedCostPerMonth,
    required this.totalCostPerMonth,
    required this.netPerMonth,
    required this.totalRevenue,
    required this.totalCosts,
    required this.exLayerTotal,
    required this.grandRevenue,
    required this.overallNet,
    required this.breakEvenWeek,
  });
}

_LayersPhase2Result _calcPhase2(_LayersPhase2State s, double phase1Cost) {
  final months         = s.layingWeeks / 4.33;
  final eggsPerDay     = s.flock * (s.prodPct / 100);
  final traysPerMonth  = (eggsPerDay * 30) / 30;
  final revPerMonth    = traysPerMonth * s.trayPrice;
  final feedPerMonth   = s.bagsPerMonth * s.bagCost.toDouble();
  final totalCostPerMonth = feedPerMonth + s.otherMonthly;
  final netPerMonth    = revPerMonth - totalCostPerMonth;
  final totalRevenue   = revPerMonth * months;
  final totalCosts     = totalCostPerMonth * months;
  final exLayerTotal   = (s.exBirds * s.exBirdPrice).toDouble();
  final grandRevenue   = totalRevenue + exLayerTotal;
  final overallNet     = grandRevenue - totalCosts - phase1Cost;

  double? bepWeek;
  if (netPerMonth > 0) {
    bepWeek = (phase1Cost / netPerMonth) * 4.33;
    if (bepWeek > s.layingWeeks) bepWeek = null; // won't hit within period
  }

  return _LayersPhase2Result(
    months: months,
    eggsPerDay: eggsPerDay,
    traysPerMonth: traysPerMonth,
    revPerMonth: revPerMonth,
    feedCostPerMonth: feedPerMonth,
    totalCostPerMonth: totalCostPerMonth,
    netPerMonth: netPerMonth,
    totalRevenue: totalRevenue,
    totalCosts: totalCosts,
    exLayerTotal: exLayerTotal,
    grandRevenue: grandRevenue,
    overallNet: overallNet,
    breakEvenWeek: bepWeek,
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
      body: SafeArea(
        child: Column(
          children: [
            _TabBar(controller: _tab),
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
}

// ─── TAB BAR COMPONENT ───────────────────────────────────────────────────────

class _TabBar extends StatelessWidget {
  final TabController controller;
  const _TabBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: const Color(0xFFE5DDD0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          _tabBtn(context, 0, '🥚', 'Layers',     '128+ birds · eggs'),
          const SizedBox(width: 4),
          _tabBtn(context, 1, '🐔', 'Broilers',   '5 wks · 2 kg'),
          const SizedBox(width: 4),
          _tabBtn(context, 2, '🐓', 'Indigenous', '12 wks · 1.8 kg'),
        ],
      ),
    );
  }

  Widget _tabBtn(BuildContext context, int idx, String icon, String label, String sub) {
    final active = controller.index == idx;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.animateTo(idx),
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

// ─── LAYERS TAB ───────────────────────────────────────────────────────────────

class _LayersTab extends StatefulWidget {
  const _LayersTab();

  @override
  State<_LayersTab> createState() => _LayersTabState();
}

class _LayersTabState extends State<_LayersTab> {
  static const Color primaryColor = Color(0xFF2E7D32);

  final _birdTypeRepository = BirdTypeRepository();
  final _quotationRepo = QuotationRepository();

  bool _isLoadingBirdTypes    = false;
  bool _isGeneratingQuotation = false;
  List<BirdType> _birdTypes   = [];
  ProductionQuotationData? _quotationData;
  BirdType? _selectedBreed;
  int?      _selectedCapacity;

  final Map<String, TextEditingController> _ctrl = {};
  final _phase2 = _LayersPhase2State();

  int _multiplier = 1;

  double get _scale => _multiplier.toDouble();

  List<BirdType> get _layerBreeds =>
      _birdTypes.where((b) => b.type == 'layer').toList();

  // Compute Phase 1 total from controllers (Stage 1 items)
  double get _phase1Total {
    if (_quotationData == null) return 0;
    final lb = _quotationData!.layersBreakdown;
    if (lb == null) return 0;
    double total = 0;
    for (int i = 0; i < lb.stage1.items.length; i++) {
      final p = double.tryParse(_ctrl['s1_$i']?.text ?? '') ??
          double.tryParse(lb.stage1.items[i].unitPrice) ?? 0.0;
      total += p * (lb.stage1.items[i].quantity * _scale).round();
    }
    return total;
  }

  /// Formats a price without unnecessary trailing zeros.
  /// e.g. 9.0 → "9", 9.5 → "9.5", 9.25 → "9.25"
  String _formatPrice(double value) {
    if (value == value.truncateToDouble()) {
      return value.truncate().toString();
    }
    // Remove trailing zeros after decimal
    final raw = value.toString();
    return raw.endsWith('0') ? raw.replaceAll(RegExp(r'0+$'), '') : raw;
  }

  @override
  void initState() {
    super.initState();
    _loadBirdTypes();
  }

  @override
  void dispose() {
    for (final c in _ctrl.values) c.dispose();
    _phase2.flockController.dispose();
    super.dispose();
  }

  Future<void> _loadBirdTypes() async {
    try {
      setState(() => _isLoadingBirdTypes = true);
      final result = await _birdTypeRepository.getBirdTypes();
      switch (result) {
        case Success(data: final types):
          setState(() { _birdTypes = types; _isLoadingBirdTypes = false; });
          // Auto-select when there is only one laying breed
          if (_layerBreeds.length == 1) {
            _selectedBreed = _layerBreeds.first;
            _multiplier = 1;
            _selectedCapacity = 128;
            _phase2.flock = 128;
            _phase2.exBirds = 128;
            _generateQuotation();
          }
        case Failure(:final message):
          if (mounted) AppSnackBar.show(context, message: message, type: SnackBarType.error);
          setState(() => _isLoadingBirdTypes = false);
      }
    } catch (e) {
      if (mounted) AppSnackBar.show(context, message: e.toString(), type: SnackBarType.error);
      setState(() => _isLoadingBirdTypes = false);
    }
  }

  void _initControllers(ProductionQuotationData data) {
    for (final c in _ctrl.values) {
      c.dispose();
    }
    _ctrl.clear();
    final lb = data.layersBreakdown;
    if (lb == null) return;
    for (int i = 0; i < lb.stage1.items.length; i++) {
      final p = double.tryParse(lb.stage1.items[i].unitPrice) ?? 0.0;
      _ctrl['s1_$i'] = TextEditingController(text: _formatPrice(p));
    }
  }

  void _applyMultiplier(int newMultiplier) {
    if (newMultiplier < 1) return;
    final capacity = newMultiplier * 128;
    setState(() {
      _multiplier = newMultiplier;
      _selectedCapacity = capacity;
      _phase2.flock = capacity;
      _phase2.flockController.text = capacity.toString();
      _phase2.exBirds = capacity;
    });
    if (_quotationData == null) {
      _generateQuotation();
    }
  }

  Future<void> _generateQuotation() async {
    if (_selectedBreed == null || _selectedCapacity == null) {
      AppSnackBar.show(context, message: 'Please select breed and flock size', type: SnackBarType.error);
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
          if (mounted) AppSnackBar.show(context, message: 'Quotation generated successfully', type: SnackBarType.success);
        case Failure(:final message):
          if (mounted) AppSnackBar.show(context, message: message, type: SnackBarType.error);
          setState(() => _isGeneratingQuotation = false);
      }
    } catch (e) {
      if (mounted) AppSnackBar.show(context, message: e.toString(), type: SnackBarType.error);
      setState(() => _isGeneratingQuotation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.sizeOf(context).width;
    final hPad = sw > 600 ? (sw - 580) / 2 : 16.0;
    return CustomScrollView(slivers: [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            // ── Breed Selection ──
            if (_isLoadingBirdTypes)
              const Center(child: CircularProgressIndicator(color: primaryColor))
            else if (_layerBreeds.isEmpty)
              const Center(child: Text('No laying breeds available'))
            else if (_layerBreeds.length == 1)
              // Single breed — auto-selected; show nothing here, content loads below
              const SizedBox.shrink()
            else ...[
              Text('Select to continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              const SizedBox(height: 8),
              SizedBox(
                height: 170,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _layerBreeds.length,
                  itemBuilder: (_, i) => _BreedCard(
                    breed: _layerBreeds[i],
                    isSelected: _selectedBreed?.id == _layerBreeds[i].id,
                    onTap: () => setState(() {
                      _selectedBreed = _layerBreeds[i];
                      _multiplier = 1;
                      _selectedCapacity = null;
                      _quotationData = null;
                    }),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),

            // ── Flock Size ──
            if (_selectedBreed != null) ...[
              Text('Flock Size',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
              const SizedBox(height: 4),
              Text('Base: 128 birds. Tap + or − to scale the estimate.',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.remove_circle_outline,
                          color: _multiplier > 1 ? primaryColor : Colors.grey.shade300, size: 28),
                      onPressed: _isGeneratingQuotation || _multiplier <= 1
                          ? null
                          : () => _applyMultiplier(_multiplier - 1),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Text('×$_multiplier',
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.bold, color: primaryColor)),
                          Text('${_multiplier * 128} birds',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.add_circle_outline, color: primaryColor, size: 28),
                      onPressed: _isGeneratingQuotation
                          ? null
                          : () => _applyMultiplier(_multiplier + 1),
                    ),
                  ],
                ),
              ),
              if (_isGeneratingQuotation) ...[
                const SizedBox(height: 10),
                const Center(child: CircularProgressIndicator(color: primaryColor, strokeWidth: 2)),
              ],
              const SizedBox(height: 16),
            ],

            // ── Quotation (Phase 1 only) ──
            if (_quotationData != null) ...[
              _Stage1Table(
                quotationData: _quotationData!,
                scale: _scale,
                capacity: _selectedCapacity ?? 128,
                controllers: _ctrl,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),

              // ── Phase 2 — Laying Stage ──
              _LayingStageSection(
                state: _phase2,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),

              // ── End-of-Cycle Sale ──
              _ExLayerSaleSection(
                key: ValueKey('ex-layer-${_selectedCapacity}'),
                state: _phase2,
                onChanged: () => setState(() {}),
              ),
              const SizedBox(height: 16),

              // ── Full Investment Analysis ──
              _FullInvestmentAnalysis(
                phase1Cost: _phase1Total,
                state: _phase2,
              ),
              const SizedBox(height: 32),

              ImageWithDescriptionWidget(
                  imageAssetPath: 'assets/quotation/img_7.png',
                  description: 'Figure 1'),
              ImageWithDescriptionWidget(
                  imageAssetPath: 'assets/quotation/img_8.png',
                  description: 'Figure 2'),
              const SizedBox(height: 10),
              _LayersDisclaimer(),
              const SizedBox(height: 32),
            ],
          ]),
        ),
      ),
    ]);
  }
}

// ─── BREED CARD COMPONENT ─────────────────────────────────────────────────────

class _BreedCard extends StatelessWidget {
  final BirdType breed;
  final bool isSelected;
  final VoidCallback onTap;

  const _BreedCard({required this.breed, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const color = Colors.orange;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: const EdgeInsets.only(right: 10),
        child: Card(
          elevation: isSelected ? 2 : 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: isSelected ? color : Colors.grey.shade300, width: isSelected ? 2 : 1),
          ),
          color: isSelected ? color.withOpacity(0.1) : Colors.white,
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
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color),
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
}

// ─── STAGE 1 TABLE COMPONENT ──────────────────────────────────────────────────

class _Stage1Table extends StatelessWidget {
  final ProductionQuotationData quotationData;
  final double scale;
  final int capacity;
  final Map<String, TextEditingController> controllers;
  final VoidCallback onChanged;

  const _Stage1Table({
    required this.quotationData,
    required this.scale,
    required this.capacity,
    required this.controllers,
    required this.onChanged,
  });

  String _fmt(double v) => v.toInt().toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final lb = quotationData.layersBreakdown!;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(color: Theme.of(context).primaryColor, borderRadius: BorderRadius.circular(12)),
        child: Row(children: [
          const Icon(Icons.layers, color: Colors.white, size: 24),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('LAYERS PRODUCTION QUOTATION',
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
            Text('$capacity birds  •  scale ×${scale == scale.roundToDouble() ? scale.toInt() : scale}',
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
          ])),
        ]),
      ),
      const SizedBox(height: 12),
      TextButton.icon(
          onPressed: null,
          icon: const Icon(Icons.arrow_forward_ios, size: 14),
          label: const Text('Scroll left or right to see the full table.')),
      Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: Colors.teal.withOpacity(0.2))),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: _stageTable('s1', 'Stage 1 — Rearing Phase (0–18 weeks/4.5 months)', lb.stage1.items),
        ),
      ),
    ]);
  }

  Widget _stageTable(String key, String title, List<BreakdownItem> items) {
    double subtotal = 0;
    final rows = <DataRow>[];

    for (int i = 0; i < items.length; i++) {
      final item     = items[i];
      final c        = controllers['${key}_$i'];
      final price    = double.tryParse(c?.text ?? '') ?? double.tryParse(item.unitPrice) ?? 0.0;
      final qty      = (item.quantity * scale).round();
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
            keyboardType: const TextInputType.numberWithOptions(decimal: false),
            style: const TextStyle(fontSize: 12),
            decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                border: OutlineInputBorder()),
            onChanged: (_) => onChanged(),
          ),
        )),
        DataCell(Container(constraints: const BoxConstraints(minWidth: 100),
            child: Text(_fmt(rowTotal),
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)))),
      ]));
    }

    rows.add(DataRow(cells: [
      DataCell(Container(
          color: Colors.teal.withOpacity(0.08),
          constraints: const BoxConstraints(minWidth: 150),
          child: const Text('SUB TOTAL',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)))),
      const DataCell(Text('')), const DataCell(Text('')), const DataCell(Text('')),
      DataCell(Container(
          color: Colors.teal.withOpacity(0.08),
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
}

// ─── PHASE 2 — LAYING STAGE SECTION ──────────────────────────────────────────

class _LayingStageSection extends StatelessWidget {
  final _LayersPhase2State state;
  final VoidCallback onChanged;

  const _LayingStageSection({required this.state, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.green.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header
          Row(children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: _kGreen900, borderRadius: BorderRadius.circular(6)),
              child: const Text('SELF-FINANCING',
                  style: TextStyle(fontSize: 9, color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(width: 8),
            const Text('Phase 2 — Laying Stage',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _kGreen900)),
          ]),
          const SizedBox(height: 16),

          // Week Slider
          _buildWeekSlider(context),
          const SizedBox(height: 12),

          // Inputs
          _buildInputRow(context, 'Flock size (birds)', state.flock.toString(), (v) {
            state.flock = int.tryParse(v) ?? state.flock;
            onChanged();
          }, controller: state.flockController),
          _buildInputRow(context, 'Avg egg production %', state.prodPct.toString(),
              note: '75% = industry average for layers', (v) {
                state.prodPct = double.tryParse(v) ?? state.prodPct;
                onChanged();
              }),
          _buildInputRow(context, 'Feed bags / month', state.bagsPerMonth.toString(),
              note: '9 bags × 50 kg recommended', (v) {
                state.bagsPerMonth = int.tryParse(v) ?? state.bagsPerMonth;
                onChanged();
              }),
          _buildInputRow(context, 'Cost per bag (Ksh)', state.bagCost.toString(), (v) {
            state.bagCost = int.tryParse(v) ?? state.bagCost;
            onChanged();
          }),
          _buildInputRow(context, 'Tray price (Ksh)', state.trayPrice.toString(),
              note: '30 eggs per tray', (v) {
                state.trayPrice = int.tryParse(v) ?? state.trayPrice;
                onChanged();
              }),
          _buildInputRow(context, 'Other monthly costs', state.otherMonthly.toString(),
              note: 'Labour, medication, misc.', (v) {
                state.otherMonthly = int.tryParse(v) ?? state.otherMonthly;
                onChanged();
              }, isLast: true),
        ]),
      ),
    );
  }

  Widget _buildWeekSlider(BuildContext context) {
    final months = (state.layingWeeks / 4.33).round().clamp(1, 24);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        const Text('Total Laying Period (months)',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
              color: const Color(0xFFFFF3E0), borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFFFFCC80))),
          child: Text('$months months',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                  color: Color(0xFFE65100))),
        ),
      ]),
      const SizedBox(height: 8),
      SliderTheme(
        data: SliderThemeData(
          activeTrackColor: _kGreen900,
          inactiveTrackColor: _kBorder,
          thumbColor: _kGreen900,
          overlayColor: _kGreen900.withOpacity(0.15),
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
          trackHeight: 4,
        ),
        child: Slider(
          value: months.toDouble(),
          min: 1, max: 24, divisions: 23,
          onChanged: (v) {
            state.layingWeeks = (v * 4.33).round();
            onChanged();
          },
        ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: ['1 mo', '6 mo', '12 mo', '18 mo', '24 mo']
              .map((s) => Text(s, style: const TextStyle(fontSize: 9, color: _kMuted)))
              .toList()),
    ]);
  }

  Widget _buildInputRow(BuildContext context, String label, String value, ValueChanged<String> onSave,
      {String? note, bool isLast = false, TextEditingController? controller}) {
    final sw = MediaQuery.sizeOf(context).width;
    final inputWidth = sw < 360 ? 88.0 : sw < 600 ? 110.0 : 130.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: _kBorder))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          if (note != null)
            Text(note, style: const TextStyle(fontSize: 10, color: _kMuted)),
        ])),
        SizedBox(
          width: inputWidth,
          child: TextFormField(
            controller: controller,
            initialValue: controller == null ? value : null,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: _kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: _kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: _kGreen900)),
              filled: true, fillColor: const Color(0xFFF4EFE6),
            ),
            onChanged: onSave,
          ),
        ),
      ]),
    );
  }
}

// ─── END-OF-CYCLE — EX-LAYER SALE SECTION ────────────────────────────────────

class _ExLayerSaleSection extends StatelessWidget {
  final _LayersPhase2State state;
  final VoidCallback onChanged;

  const _ExLayerSaleSection({super.key, required this.state, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final total = state.exBirds * state.exBirdPrice;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.teal.withOpacity(0.3))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: Colors.teal, borderRadius: BorderRadius.circular(6)),
            child: const Text('ONE-TIME INCOME',
                style: TextStyle(fontSize: 9, color: Colors.white, letterSpacing: 1.5, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 5),

          const Text('End-of-Cycle — Ex-Layers',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: _kGreen900)),
          const SizedBox(height: 14),
          _buildRow(context, 'Birds sold at end', state.exBirds.toString(),
              note: 'Adjust for mortality / culled birds', (v) {
                state.exBirds = int.tryParse(v) ?? state.exBirds;
                onChanged();
              }),
          _buildRow(context, 'Price per bird (Ksh)', state.exBirdPrice.toString(),
              note: 'Spent layers typically Ksh 300–500', (v) {
                state.exBirdPrice = int.tryParse(v) ?? state.exBirdPrice;
                onChanged();
              }, isLast: true),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
                color: const Color(0xFFF0F7F0), borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green.withOpacity(0.3))),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('Ex-layer sale total',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
              Text('Ksh ${_loc(total)}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                      color: Color(0xFF2D6A2D))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _buildRow(BuildContext context, String label, String value, ValueChanged<String> onSave,
      {String? note, bool isLast = false}) {
    final sw = MediaQuery.sizeOf(context).width;
    final inputWidth = sw < 360 ? 88.0 : sw < 600 ? 110.0 : 130.0;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
          border: isLast ? null : const Border(bottom: BorderSide(color: _kBorder))),
      child: Row(children: [
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: const TextStyle(fontSize: 12)),
          if (note != null)
            Text(note, style: const TextStyle(fontSize: 10, color: _kMuted)),
        ])),
        SizedBox(
          width: inputWidth,
          child: TextFormField(
            initialValue: value,
            textAlign: TextAlign.right,
            keyboardType: TextInputType.number,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: _kBorder)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: _kBorder)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(4),
                  borderSide: const BorderSide(color: _kGreen900)),
              filled: true, fillColor: const Color(0xFFF4EFE6),
            ),
            onChanged: onSave,
          ),
        ),
      ]),
    );
  }

  String _loc(int v) => v.toString()
      .replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ─── FULL INVESTMENT ANALYSIS SECTION ────────────────────────────────────────

class _FullInvestmentAnalysis extends StatelessWidget {
  final double phase1Cost;
  final _LayersPhase2State state;

  const _FullInvestmentAnalysis({required this.phase1Cost, required this.state});

  @override
  Widget build(BuildContext context) {
    final r = _calcPhase2(state, phase1Cost);
    final overallPositive = r.overallNet >= 0;
    final netMonthPositive = r.netPerMonth >= 0;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.blue.withOpacity(0.2))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
              color: _kGreen900, borderRadius: const BorderRadius.vertical(top: Radius.circular(12))),
          child: const Row(children: [
            Icon(Icons.analytics_outlined, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text('Full Investment Analysis',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
        ),

        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Results table
            _ResultsTable(r: r, phase1Cost: phase1Cost),
            const SizedBox(height: 16),

            // Break-even label
            _BreakEvenLabel(r: r, state: state),
            const SizedBox(height: 16),

            // Verdict
            _VerdictBox(r: r, phase1Cost: phase1Cost, state: state),
            const SizedBox(height: 16),

            // Hero totals
            _HeroTotals(phase1Cost: phase1Cost, overallNet: r.overallNet),
          ]),
        ),
      ]),
    );
  }
}

// ─── RESULTS TABLE COMPONENT ──────────────────────────────────────────────────

class _ResultsTable extends StatelessWidget {
  final _LayersPhase2Result r;
  final double phase1Cost;

  const _ResultsTable({required this.r, required this.phase1Cost});

  @override
  Widget build(BuildContext context) {
    final netPositive = r.netPerMonth >= 0;

    return Table(
      columnWidths: const {0: FlexColumnWidth(), 1: IntrinsicColumnWidth()},
      children: [
        _tRow('Stage 1 total cost', _ksh(phase1Cost), valueColor: const Color(0xFFB83232)),
        _tRow('Stage 2 total laying period',
            '${r.months.toStringAsFixed(1)} months (${(r.months * 4.33 / 4.33).round()} wks)'),
        _tRow('Eggs per day', '${r.eggsPerDay.round()}'),
        _tRow('Trays per month', r.traysPerMonth.toStringAsFixed(1)),
        _tRow('Monthly egg revenue', _ksh(r.revPerMonth), valueColor: const Color(0xFF2D6A2D)),
        _tRow('Monthly feed cost', _ksh(r.feedCostPerMonth), valueColor: const Color(0xFFB83232)),
        _tRow('Other monthly costs', _ksh(r.totalCostPerMonth - r.feedCostPerMonth),
            valueColor: const Color(0xFFB83232)),
        _tRowBold('Total monthly costs', _ksh(r.totalCostPerMonth),
            valueColor: const Color(0xFFB83232), shaded: true),
        _tRow('Monthly net profit (Stage 2)',
            '${r.netPerMonth >= 0 ? "+" : "-"}${_ksh(r.netPerMonth)}',
            valueColor: netPositive ? const Color(0xFF2D6A2D) : const Color(0xFFB83232)),
        _tRow('Total Phase 2 egg revenue', _ksh(r.totalRevenue), valueColor: const Color(0xFF2D6A2D)),
        _tRow('Ex-layer sale (end of cycle)', _ksh(r.exLayerTotal), valueColor: const Color(0xFF2D6A2D)),
        _tRow('Total Phase 2 costs', _ksh(r.totalCosts), valueColor: const Color(0xFFB83232)),
        _tRowBold('Total revenue (eggs + birds)', _ksh(r.grandRevenue),
            valueColor: const Color(0xFF2D6A2D)),
      ],
    );
  }

  TableRow _tRow(String label, String value, {Color? valueColor}) {
    return TableRow(
      decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: _kBorder, width: 0.8))),
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(label, style: const TextStyle(fontSize: 12, color: _kMuted))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(value,
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                    color: valueColor ?? const Color(0xFF1A1A1A)))),
      ],
    );
  }

  TableRow _tRowBold(String label, String value, {Color? valueColor, bool shaded = false}) {
    return TableRow(
      decoration: BoxDecoration(
          color: shaded ? const Color(0xFFFDF5F5) : null,
          border: const Border(bottom: BorderSide(color: _kBorder, width: 0.8))),
      children: [
        Padding(padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold))),
        Padding(padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
            child: Text(value,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                    color: valueColor ?? const Color(0xFF1A1A1A)))),
      ],
    );
  }

  String _ksh(double n) => 'Ksh ${n.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

// ─── BREAK-EVEN LABEL COMPONENT ───────────────────────────────────────────────

class _BreakEvenLabel extends StatelessWidget {
  final _LayersPhase2Result r;
  final _LayersPhase2State state;

  const _BreakEvenLabel({required this.r, required this.state});

  @override
  Widget build(BuildContext context) {
    String text;
    Color color;

    if (r.netPerMonth <= 0) {
      text = 'Break-even: Never (monthly loss)';
      color = const Color(0xFFB83232);
    } else if (r.breakEvenWeek != null) {
      text = 'Break-even: Month ${(r.breakEvenWeek! / 4.33).ceil()} of Phase 2';
      color = const Color(0xFFC8813A);
    } else {
      text = 'Break-even: After month ${(state.layingWeeks / 4.33).round()} (extend period)';
      color = const Color(0xFFC8813A);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
          color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color.withOpacity(0.3))),
      child: Row(children: [
        Icon(Icons.schedule, size: 16, color: color),
        const SizedBox(width: 8),
        Text(text, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color)),
      ]),
    );
  }
}

// ─── VERDICT BOX COMPONENT ────────────────────────────────────────────────────

class _VerdictBox extends StatelessWidget {
  final _LayersPhase2Result r;
  final double phase1Cost;
  final _LayersPhase2State state;

  const _VerdictBox({required this.r, required this.phase1Cost, required this.state});

  @override
  Widget build(BuildContext context) {
    final bool good = r.netPerMonth > 0 && r.breakEvenWeek != null;
    final bool monthlyneg = r.netPerMonth < 0;
    final Color borderColor = good ? const Color(0xFF2D6A2D) : const Color(0xFFB83232);
    final Color bgColor = good ? const Color(0xFFF0F7F0) : const Color(0xFFFDF0F0);

    String message;
    String icon;
    if (monthlyneg) {
      icon = '⚠️';
      message = "Monthly egg revenue (${_ksh(r.revPerMonth)}) doesn't cover monthly costs "
          "(${_ksh(r.totalCostPerMonth)}). You're losing ${_ksh(r.netPerMonth.abs())}/month — "
          "consider raising tray price or reducing bags.";
    } else if (good) {
      icon = '✅';
      message = "Egg sales recover your Phase 1 investment of ${_ksh(phase1Cost)} by "
          "month ${(r.breakEvenWeek! / 4.33).ceil()}. With the ex-layer sale of ${_ksh(r.exLayerTotal)}, "
          "total net over ${(state.layingWeeks / 4.33).round()} months is ${r.overallNet >= 0 ? '+' : '-'}${_ksh(r.overallNet)}.";
    } else {
      icon = '⚠️';
      final tip = r.overallNet >= 0
          ? 'The bird sale tips you into profit! ✅'
          : 'Consider extending the cycle or adjusting prices.';
      message = "Egg sales alone don't recover Phase 1 costs within ${(state.layingWeeks / 4.33).round()} months. "
          "Including ex-layer sale of ${_ksh(r.exLayerTotal)}, overall net is "
          "${r.overallNet >= 0 ? '+' : '-'}${_ksh(r.overallNet)}. $tip";
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: bgColor, borderRadius: BorderRadius.circular(8),
          border: Border(left: BorderSide(color: borderColor, width: 4))),
      child: Text('$icon $message',
          style: const TextStyle(fontSize: 12, height: 1.6)),
    );
  }

  String _ksh(double n) => 'Ksh ${n.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

// ─── HERO TOTALS COMPONENT ────────────────────────────────────────────────────

class _HeroTotals extends StatelessWidget {
  final double phase1Cost;
  final double overallNet;

  const _HeroTotals({required this.phase1Cost, required this.overallNet});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: _kBorder),
          borderRadius: BorderRadius.circular(8)),
      child: Row(children: [
        Expanded(child: _heroCell('Total Investment (P1)', _ksh(phase1Cost), 'one-time spend',
            const Color(0xFF1A1A1A))),
        Container(width: 1, height: 80, color: _kBorder),
        Expanded(child: _heroCell(
            'Net Profit / Loss',
            '${overallNet >= 0 ? "+" : "-"}${_ksh(overallNet)}',
            'over full period',
            overallNet >= 0 ? const Color(0xFF2D6A2D) : const Color(0xFFB83232))),
      ]),
    );
  }

  Widget _heroCell(String label, String value, String sub, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(children: [
        Text(label.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 9, letterSpacing: 1.5, color: _kMuted)),
        const SizedBox(height: 6),
        Text(value,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: valueColor)),
        const SizedBox(height: 4),
        Text(sub, style: const TextStyle(fontSize: 10, color: _kMuted)),
      ]),
    );
  }

  String _ksh(double n) => 'Ksh ${n.abs().toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
}

// ─── LAYERS DISCLAIMER COMPONENT ─────────────────────────────────────────────

class _LayersDisclaimer extends StatelessWidget {
  const _LayersDisclaimer();

  @override
  Widget build(BuildContext context) => const _ProductionDisclaimer();
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

    final sw = MediaQuery.sizeOf(context).width;
    final hPad = sw > 600 ? (sw - 580) / 2 : 16.0;
    return ListView(
      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
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
          _row('Cost of production per bird', _fmtCalc(r.costPerBird)),
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
      Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: _kCream, borderRadius: BorderRadius.circular(12)),
        child: Column(children: [
          _row('TOTAL PRODUCTION COST', _fmtCalc(r.totalProductionCost), hi: true),
          _row('Cost of production per bird', _fmtCalc(r.costPerBird)),
        ]),
      ),
    ]);
  }

  Widget _footer() => const Text(
    'Powered by AgriFlock 360 & ePoultry',
    textAlign: TextAlign.center, style: TextStyle(fontSize: 10, color: Color(0xFFBBBBBB)),
  );

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

class _DisclaimerWidget extends StatelessWidget {
  const _DisclaimerWidget();

  @override
  Widget build(BuildContext context) => const _ProductionDisclaimer();
}

// ─── SHARED PRODUCTION DISCLAIMER ────────────────────────────────────────────

class _ProductionDisclaimer extends StatelessWidget {
  const _ProductionDisclaimer();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEE),
        border: Border.all(color: const Color(0xFFF0D080), width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── NOTE ──────────────────────────────────────────────────────────
          Text('NOTE:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7A5000))),
          SizedBox(height: 4),
          Text(
            'Adjust Mortality, Laying period, Input prices, Number of chickens, Egg prices as per your region to get the right quote and analysis.',
            style: TextStyle(fontSize: 12, color: Color(0xFF444444), height: 1.5),
          ),
          SizedBox(height: 12),
          // ── EXCLUDED ──────────────────────────────────────────────────────
          Text('EXCLUDED:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF7A5000))),
          SizedBox(height: 4),
          Text(
            'Housing & Infrastructure, Maintenance & repairs, Brooding, Drinkers & Feeders, Cages, Wood Pallets, Weighing scale, Transport, Electricity, Water, Labour. Among others.',
            style: TextStyle(fontSize: 12, color: Color(0xFF444444), height: 1.5),
          ),
          SizedBox(height: 12),
          // ── DISCLAIMER ────────────────────────────────────────────────────
          Text('Disclaimer', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF7A5000))),
          SizedBox(height: 4),
          Text(
            'These figures are estimates based on your inputs and indicative market assumptions. Actual costs, revenue, and returns will vary depending on flock health, feed conversion, mortality, and market prices at the time of sale. This is not a formal quotation or financial advice, and AgriFlock 360 is not liable for decisions made based on these results.',
            style: TextStyle(fontSize: 11, color: Color(0xFF666666), fontStyle: FontStyle.italic, height: 1.5),
          ),
        ],
      ),
    );
  }
}

// ─── EXTENSION ───────────────────────────────────────────────────────────────

extension _IntFmt on int {
  String _loc() => toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}