// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// // ─── CONSTANTS ────────────────────────────────────────────────────────────────
//
// class FeedPhase {
//   final String key, name, weeks;
//   final int bagsPerUnit, defaultPrice;
//   const FeedPhase({
//     required this.key,
//     required this.name,
//     required this.bagsPerUnit,
//     required this.defaultPrice,
//     required this.weeks,
//   });
// }
//
// class MedItem {
//   final String name;
//   final int unitPrice;
//   const MedItem(this.name, this.unitPrice);
// }
//
// class BirdConfig {
//   final String label, icon, targetWeight, duration;
//   final int cyclesPerYear;
//   final List<FeedPhase> feedPhases;
//   final List<MedItem> medicationItems, vaccineItems;
//   const BirdConfig({
//     required this.label,
//     required this.icon,
//     required this.targetWeight,
//     required this.duration,
//     required this.cyclesPerYear,
//     required this.feedPhases,
//     required this.medicationItems,
//     required this.vaccineItems,
//   });
// }
//
// const broilerConfig = BirdConfig(
//   label: 'Broilers',
//   icon: '🐔',
//   targetWeight: '2 kg',
//   duration: '5 weeks',
//   cyclesPerYear: 6,
//   feedPhases: [
//     FeedPhase(key: 'starter', name: 'Starter Crumbs', bagsPerUnit: 1, defaultPrice: 3800, weeks: 'Week 1–2'),
//     FeedPhase(key: 'finisher', name: 'Finisher Pellets', bagsPerUnit: 2, defaultPrice: 3600, weeks: 'Week 3–5'),
//   ],
//   medicationItems: [
//     MedItem('Multivitamin', 300),
//     MedItem('Disinfectant', 300),
//     MedItem('Antibiotic', 300),
//   ],
//   vaccineItems: [
//     MedItem('Newcastle Vaccine', 450),
//     MedItem('Gumboro Vaccine', 450),
//   ],
// );
//
// const kienyejiConfig = BirdConfig(
//   label: 'Improved Indigenous (Kienyeji)',
//   icon: '🐓',
//   targetWeight: '1.8 kg',
//   duration: '12 weeks (3 months)',
//   cyclesPerYear: 3,
//   feedPhases: [
//     FeedPhase(key: 'chickmash', name: 'Chick Mash', bagsPerUnit: 2, defaultPrice: 3500, weeks: 'Week 1–6'),
//     FeedPhase(key: 'growermash', name: 'Kienyeji Grower Mash', bagsPerUnit: 3, defaultPrice: 3400, weeks: 'Week 7–12'),
//   ],
//   medicationItems: [
//     MedItem('Multivitamin', 300),
//     MedItem('Disinfectant', 300),
//     MedItem('Antibiotic', 300),
//   ],
//   vaccineItems: [
//     MedItem('Newcastle Vaccine', 450),
//     MedItem('Gumboro Vaccine', 450),
//     MedItem('Fowl Typhoid Vaccine', 450),
//   ],
// );
//
// const equipmentItems = [
//   'Brooding equipment (heat lamps, brooders, extension cords)',
//   'Feeders & drinkers — ratio: 1 feeder + 1 drinker per 50 birds',
//   'Weighing scale',
//   'Feed storage pallets / bins',
//   'Spray pumps for biosecurity',
// ];
//
// const utilityItems = [
//   'Electricity / fuel for brooding',
//   'Water supply costs',
//   'Transport (chick collection, feed delivery, bird sales)',
//   'Labour / casual workers',
//   'House construction, maintenance & repairs',
//   'Litter / bedding material (wood shavings, rice husks)',
//   'Biosecurity consumables (foot baths, PPE)',
//   'Contingency / emergency vet costs',
// ];
//
// // ─── THEME ───────────────────────────────────────────────────────────────────
//
// const kGreen900 = Color(0xFF1B4332);
// const kGreen100 = Color(0xFFD8F3DC);
// const kGreen200 = Color(0xFFB7E4C7);
// const kCream   = Color(0xFFF4EFE6);
// const kCard    = Color(0xFFFFFFFF);
// const kBorder  = Color(0xFFE8DFC8);
// const kMuted   = Color(0xFF999999);
//
// // ─── HELPERS ─────────────────────────────────────────────────────────────────
//
// int unitsOf50(int n) => (n / 50).ceil();
//
// String fmt(double n) {
//   final formatted = n.abs().toStringAsFixed(0).replaceAllMapped(
//     RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
//         (m) => '${m[1]},',
//   );
//   return 'Ksh $formatted';
// }
//
// // ─── CALC RESULT ─────────────────────────────────────────────────────────────
//
// class CalcResult {
//   final int units, survived, breakEven;
//   final double chickCost, totalFeedCost, medCost, vacCost,
//       totalProductionCost, costPerBird, revenue, grossProfit;
//   final String roi;
//   final List<Map<String, dynamic>> feedLines, medLines, vacLines;
//
//   CalcResult({
//     required this.units, required this.survived, required this.breakEven,
//     required this.chickCost, required this.totalFeedCost,
//     required this.medCost, required this.vacCost,
//     required this.totalProductionCost, required this.costPerBird,
//     required this.revenue, required this.grossProfit, required this.roi,
//     required this.feedLines, required this.medLines, required this.vacLines,
//   });
// }
//
// CalcResult calculate({
//   required BirdConfig config,
//   required int birds,
//   required int chickPrice,
//   required double mortalityRate,
//   required int sellingPrice,
//   required Map<String, int> feedPrices,
// }) {
//   final units = unitsOf50(birds);
//   final chickCost = (birds * chickPrice).toDouble();
//
//   final feedLines = config.feedPhases.map((p) {
//     final bags = units * p.bagsPerUnit;
//     final cost = bags * (feedPrices[p.key] ?? p.defaultPrice);
//     return {'phase': p, 'bags': bags, 'cost': cost.toDouble()};
//   }).toList();
//   final totalFeedCost = feedLines.fold(0.0, (s, f) => s + (f['cost'] as double));
//
//   final medLines = config.medicationItems.map((m) {
//     return {'item': m, 'qty': units, 'cost': (m.unitPrice * units).toDouble()};
//   }).toList();
//   final medCost = medLines.fold(0.0, (s, m) => s + (m['cost'] as double));
//
//   final vacLines = config.vaccineItems.map((v) {
//     return {'item': v, 'qty': units, 'cost': (v.unitPrice * units).toDouble()};
//   }).toList();
//   final vacCost = vacLines.fold(0.0, (s, v) => s + (v['cost'] as double));
//
//   final totalProductionCost = chickCost + totalFeedCost + medCost + vacCost;
//   final costPerBird = totalProductionCost / birds;
//   final survived = (birds * (1 - mortalityRate / 100)).round();
//   final revenue = (survived * sellingPrice).toDouble();
//   final grossProfit = revenue - totalProductionCost;
//   final roi = totalProductionCost > 0
//       ? ((grossProfit / totalProductionCost) * 100).toStringAsFixed(1)
//       : '0.0';
//   final breakEven = sellingPrice > 0 ? (totalProductionCost / sellingPrice).ceil() : 0;
//
//   return CalcResult(
//     units: units, survived: survived, breakEven: breakEven,
//     chickCost: chickCost, totalFeedCost: totalFeedCost,
//     medCost: medCost, vacCost: vacCost,
//     totalProductionCost: totalProductionCost, costPerBird: costPerBird,
//     revenue: revenue, grossProfit: grossProfit, roi: roi,
//     feedLines: feedLines, medLines: medLines, vacLines: vacLines,
//   );
// }
//
//
// class CalculatorScreen extends StatefulWidget {
//   const CalculatorScreen({super.key});
//
//   @override
//   State<CalculatorScreen> createState() => _CalculatorScreenState();
// }
//
// class _CalculatorScreenState extends State<CalculatorScreen> with SingleTickerProviderStateMixin {
//   late TabController _tab;
//
//   @override
//   void initState() {
//     super.initState();
//     _tab = TabController(length: 2, vsync: this);
//     _tab.addListener(() => setState(() {}));
//   }
//
//   @override
//   void dispose() {
//     _tab.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: kCream,
//       body: SafeArea(
//         child: Column(
//           children: [
//             _buildTabBar(),
//             Expanded(
//               child: TabBarView(
//                 controller: _tab,
//                 children: const [
//                   CalculatorPage(config: broilerConfig),
//                   CalculatorPage(config: kienyejiConfig),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//
//   Widget _buildTabBar() {
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
//       padding: const EdgeInsets.all(5),
//       decoration: BoxDecoration(
//         color: const Color(0xFFE5DDD0),
//         borderRadius: BorderRadius.circular(14),
//       ),
//       child: Row(
//         children: [
//           _tabBtn(0, '🐔', 'Broilers', '5 weeks · 2 kg'),
//           const SizedBox(width: 4),
//           _tabBtn(1, '🐓', 'Improved Indigenous', '12 weeks · 1.8 kg'),
//         ],
//       ),
//     );
//   }
//
//   Widget _tabBtn(int idx, String icon, String label, String sub) {
//     final active = _tab.index == idx;
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => _tab.animateTo(idx),
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//           padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 6),
//           decoration: BoxDecoration(
//             color: active ? kGreen900 : Colors.transparent,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: active
//                 ? [BoxShadow(color: kGreen900.withOpacity(0.28), blurRadius: 10, offset: const Offset(0, 3))]
//                 : [],
//           ),
//           child: Column(
//             children: [
//               Text('$icon $label',
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     fontSize: 12, fontWeight: FontWeight.w700,
//                     color: active ? Colors.white : const Color(0xFF666666),
//                   )),
//               const SizedBox(height: 2),
//               Text(sub,
//                   textAlign: TextAlign.center,
//                   style: TextStyle(fontSize: 10, color: active ? Colors.white70 : kMuted)),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── CALCULATOR PAGE ─────────────────────────────────────────────────────────
//
// class CalculatorPage extends StatefulWidget {
//   final BirdConfig config;
//   const CalculatorPage({super.key, required this.config});
//
//   @override
//   State<CalculatorPage> createState() => _CalculatorPageState();
// }
//
// class _CalculatorPageState extends State<CalculatorPage> {
//   late int birds, chickPrice, sellingPrice;
//   late double mortalityRate;
//   late Map<String, int> feedPrices;
//
//   @override
//   void initState() {
//     super.initState();
//     _reset();
//   }
//
//   void _reset() {
//     birds = 50;
//     chickPrice = widget.config.label.contains('Broiler') ? 120 : 80;
//     sellingPrice = widget.config.label.contains('Broiler') ? 550 : 700;
//     mortalityRate = 5.0;
//     feedPrices = {for (final p in widget.config.feedPhases) p.key: p.defaultPrice};
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final r = calculate(
//       config: widget.config,
//       birds: birds,
//       chickPrice: chickPrice,
//       mortalityRate: mortalityRate,
//       sellingPrice: sellingPrice,
//       feedPrices: feedPrices,
//     );
//
//     return ListView(
//       padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
//       children: [
//         _metaPills(),
//         const SizedBox(height: 8),
//         _flockSection(),
//         const SizedBox(height: 12),
//         _feedSection(),
//         const SizedBox(height: 12),
//         _sellingSection(),
//         const SizedBox(height: 12),
//         _quotationSection(r),
//         const SizedBox(height: 12),
//         _profitSection(r),
//         const SizedBox(height: 12),
//         _equipmentSection(r),
//         const SizedBox(height: 12),
//         const DisclaimerWidget(),
//         const SizedBox(height: 20),
//         _footer(),
//       ],
//     );
//   }
//
//   Widget _metaPills() {
//     final pills = [widget.config.targetWeight + ' target', widget.config.duration, '${widget.config.cyclesPerYear} cycles/yr'];
//     return Wrap(
//       spacing: 6,
//       children: pills.map((p) => Container(
//         padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//         decoration: BoxDecoration(color: kGreen100, borderRadius: BorderRadius.circular(20)),
//         child: Text(p, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: kGreen900, letterSpacing: 0.3)),
//       )).toList(),
//     );
//   }
//
//   // ── Sections ──
//
//   Widget _flockSection() => _card(
//     title: '🐣 Flock Setup',
//     children: [
//       _inputRow(
//         label: 'Number of chicks',
//         note: 'Scales automatically in units of 50',
//         value: birds.toDouble(),
//         min: 10, step: 50,
//         onChanged: (v) => setState(() => birds = v.toInt()),
//       ),
//       _inputRow(
//         label: 'Price per chick',
//         prefix: 'Ksh',
//         value: chickPrice.toDouble(),
//         min: 1,
//         onChanged: (v) => setState(() => chickPrice = v.toInt()),
//       ),
//       _inputRow(
//         label: 'Mortality rate',
//         suffix: '%',
//         value: mortalityRate,
//         min: 0, max: 50, step: 0.5, isDouble: true,
//         onChanged: (v) => setState(() => mortalityRate = v),
//       ),
//     ],
//   );
//
//   Widget _feedSection() => _card(
//     title: '🌾 Feed Prices (per 50 kg bag)',
//     children: widget.config.feedPhases.map((p) => _inputRow(
//       label: p.name,
//       note: p.weeks,
//       prefix: 'Ksh',
//       value: feedPrices[p.key]!.toDouble(),
//       min: 1,
//       onChanged: (v) => setState(() => feedPrices[p.key] = v.toInt()),
//     )).toList(),
//   );
//
//   Widget _sellingSection() => _card(
//     title: '💰 Market Selling Price',
//     children: [
//       _inputRow(
//         label: 'Price per bird',
//         note: 'Live weight ~${widget.config.targetWeight} — adjust for your region',
//         prefix: 'Ksh',
//         value: sellingPrice.toDouble(),
//         min: 1,
//         onChanged: (v) => setState(() => sellingPrice = v.toInt()),
//       ),
//     ],
//   );
//
//   Widget _quotationSection(CalcResult r) => _card(
//     title: '📋 Production Cost Quotation — $birds Birds',
//     children: [
//       _groupTitle('Day-Old Chicks'),
//       _resultRow('$birds chicks × Ksh ${chickPrice.toLocaleString()}', fmt(r.chickCost)),
//       const SizedBox(height: 10),
//       _groupTitle('Feeds'),
//       ...r.feedLines.map((f) {
//         final p = f['phase'] as FeedPhase;
//         return _resultRow('${p.name} — ${f['bags']} bag(s) × 50 kg  [${p.weeks}]', fmt(f['cost'] as double), sub: true);
//       }),
//       _resultRow('Total Feed Cost', fmt(r.totalFeedCost), highlight: true),
//       const SizedBox(height: 10),
//       _groupTitle('Medications (per ${r.units} unit${r.units > 1 ? "s" : ""} of 50)'),
//       ...r.medLines.map((m) {
//         final item = m['item'] as MedItem;
//         return _resultRow('${item.name} — ${m['qty']} dose(s)', fmt(m['cost'] as double), sub: true);
//       }),
//       const SizedBox(height: 10),
//       _groupTitle('Vaccines (per ${r.units} unit${r.units > 1 ? "s" : ""} of 50)'),
//       ...r.vacLines.map((v) {
//         final item = v['item'] as MedItem;
//         return _resultRow('${item.name} — ${v['qty']} dose(s)', fmt(v['cost'] as double), sub: true);
//       }),
//       const SizedBox(height: 8),
//       Container(
//         padding: const EdgeInsets.all(14),
//         decoration: BoxDecoration(color: kCream, borderRadius: BorderRadius.circular(12)),
//         child: Column(
//           children: [
//             _resultRow('TOTAL PRODUCTION COST', fmt(r.totalProductionCost), highlight: true),
//             _resultRow('Cost per bird', fmt(r.costPerBird)),
//           ],
//         ),
//       ),
//     ],
//   );
//
//   Widget _profitSection(CalcResult r) {
//     final profitable = r.grossProfit >= 0;
//     return _card(
//       title: '📊 Profit Summary',
//       children: [
//         _resultRow('Revenue — ${r.survived} birds × Ksh ${sellingPrice.toLocaleString()}', fmt(r.revenue), sub: true),
//         _resultRow('Less: Total production cost', '(${fmt(r.totalProductionCost)})', sub: true),
//         _resultRow('Gross Profit / Loss', '${profitable ? "+" : ""}${fmt(r.grossProfit)}', highlight: true),
//         _resultRow('Return on Investment (ROI)', '${r.roi}%'),
//         _resultRow('Break-even: birds to sell', '${r.breakEven} birds'),
//         const SizedBox(height: 12),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             color: profitable ? kGreen100 : const Color(0xFFFFE4E4),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Text(
//             profitable
//                 ? '✅ Profitable at Ksh ${sellingPrice.toLocaleString()}/bird — Est. net: ${fmt(r.grossProfit)}'
//                 : '⚠️ Loss at Ksh ${sellingPrice.toLocaleString()}/bird — raise selling price or reduce costs',
//             textAlign: TextAlign.center,
//             style: TextStyle(
//               fontSize: 13, fontWeight: FontWeight.w600,
//               color: profitable ? kGreen900 : const Color(0xFF9B1C1C),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _equipmentSection(CalcResult r) => Container(
//     padding: const EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       color: const Color(0xFFFFFDF5),
//       borderRadius: BorderRadius.circular(18),
//       border: Border.all(color: kBorder, width: 1.5),
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionTitle('🔧 Equipment Ratio Guide'),
//         Text('For $birds birds (${r.units} unit${r.units > 1 ? "s" : ""} of 50) you need at minimum:',
//             style: const TextStyle(fontSize: 13)),
//         const SizedBox(height: 12),
//         Row(
//           children: [
//             _equipCard('🥣', r.units.toString(), 'Feeder(s)\n10 kg capacity'),
//             const SizedBox(width: 12),
//             _equipCard('💧', r.units.toString(), 'Drinker(s)\n10 L capacity'),
//           ],
//         ),
//         const SizedBox(height: 10),
//         const Text(
//           'Feeder & drinker costs are not included in the quotation above — see the disclaimer below.',
//           style: TextStyle(fontSize: 11, color: kMuted, fontStyle: FontStyle.italic),
//         ),
//       ],
//     ),
//   );
//
//   Widget _equipCard(String icon, String count, String label) => Expanded(
//     child: Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(color: kCream, borderRadius: BorderRadius.circular(12)),
//       child: Column(
//         children: [
//           Text(icon, style: const TextStyle(fontSize: 28)),
//           const SizedBox(height: 4),
//           Text(count, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: kGreen900)),
//           const SizedBox(height: 4),
//           Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, color: Color(0xFF777777))),
//         ],
//       ),
//     ),
//   );
//
//   Widget _footer() => const Text(
//     'Powered by AgriFlock 360 & ePoultry · Tenekaland Holdings\nFor planning purposes only.',
//     textAlign: TextAlign.center,
//     style: TextStyle(fontSize: 10, color: Color(0xFFBBBBBB)),
//   );
//
//   // ── UI Helpers ──
//
//   Widget _card({required String title, required List<Widget> children}) => Container(
//     padding: const EdgeInsets.all(20),
//     decoration: BoxDecoration(
//       color: kCard,
//       borderRadius: BorderRadius.circular(18),
//       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 5)],
//     ),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionTitle(title),
//         ...children,
//       ],
//     ),
//   );
//
//   Widget _sectionTitle(String t) => Container(
//     margin: const EdgeInsets.only(bottom: 14),
//     padding: const EdgeInsets.only(bottom: 8),
//     decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: Color(0xFFF0E8D8), width: 1.5))),
//     child: Text(t.toUpperCase(),
//         style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: kGreen900)),
//   );
//
//   Widget _groupTitle(String t) => Padding(
//     padding: const EdgeInsets.only(bottom: 5),
//     child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
//         letterSpacing: 1, color: Color(0xFFAAAAAA))),
//   );
//
//   Widget _resultRow(String label, String value, {bool highlight = false, bool sub = false}) => Padding(
//     padding: EdgeInsets.only(left: sub ? 10 : 0, top: 4, bottom: 4),
//     child: Row(
//       children: [
//         Expanded(
//           child: Text(label,
//               style: TextStyle(
//                 fontSize: highlight ? 14 : (sub ? 12 : 13),
//                 fontWeight: highlight ? FontWeight.w700 : FontWeight.w400,
//                 color: highlight ? kGreen900 : (sub ? const Color(0xFF666666) : const Color(0xFF1A1A1A)),
//               )),
//         ),
//         const SizedBox(width: 8),
//         Text(value,
//             style: TextStyle(
//               fontSize: highlight ? 14 : 13,
//               fontWeight: FontWeight.w700,
//               color: highlight ? kGreen900 : const Color(0xFF1A1A1A),
//             )),
//       ],
//     ),
//   );
//
//   Widget _inputRow({
//     required String label,
//     String? note,
//     String prefix = '',
//     String suffix = '',
//     required double value,
//     required ValueChanged<double> onChanged,
//     double min = 0,
//     double? max,
//     double step = 1,
//     bool isDouble = false,
//   }) {
//     final ctrl = TextEditingController(text: isDouble ? value.toString() : value.toInt().toString());
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
//                 if (note != null)
//                   Text(note, style: const TextStyle(fontSize: 10, color: kMuted)),
//               ],
//             ),
//           ),
//           const SizedBox(width: 14),
//           Container(
//             decoration: BoxDecoration(
//               color: const Color(0xFFF8F3EA),
//               borderRadius: BorderRadius.circular(9),
//               border: Border.all(color: kBorder, width: 1.5),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 if (prefix.isNotEmpty)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFEDE5D4),
//                       borderRadius: BorderRadius.only(topLeft: Radius.circular(8), bottomLeft: Radius.circular(8)),
//                     ),
//                     child: Text(prefix, style: const TextStyle(fontSize: 11, color: kMuted)),
//                   ),
//                 // Stepper -
//                 GestureDetector(
//                   onTap: () {
//                     final nv = (value - step).clamp(min, max ?? double.infinity);
//                     onChanged(isDouble ? nv : nv.roundToDouble());
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                     child: const Icon(Icons.remove, size: 14, color: kMuted),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 60,
//                   child: Text(
//                     isDouble ? value.toStringAsFixed(1) : value.toInt().toString(),
//                     textAlign: TextAlign.center,
//                     style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
//                   ),
//                 ),
//                 // Stepper +
//                 GestureDetector(
//                   onTap: () {
//                     final nv = max != null ? (value + step).clamp(min, max) : value + step;
//                     onChanged(isDouble ? nv : nv.roundToDouble());
//                   },
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
//                     child: const Icon(Icons.add, size: 14, color: kMuted),
//                   ),
//                 ),
//                 if (suffix.isNotEmpty)
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 8),
//                     decoration: const BoxDecoration(
//                       color: Color(0xFFEDE5D4),
//                       borderRadius: BorderRadius.only(topRight: Radius.circular(8), bottomRight: Radius.circular(8)),
//                     ),
//                     child: Text(suffix, style: const TextStyle(fontSize: 11, color: kMuted)),
//                   ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── DISCLAIMER ──────────────────────────────────────────────────────────────
//
// class DisclaimerWidget extends StatefulWidget {
//   const DisclaimerWidget({super.key});
//
//   @override
//   State<DisclaimerWidget> createState() => _DisclaimerWidgetState();
// }
//
// class _DisclaimerWidgetState extends State<DisclaimerWidget> {
//   bool _open = false;
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         color: const Color(0xFFFFFBEE),
//         border: Border.all(color: const Color(0xFFF0D080), width: 1.5),
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: Column(
//         children: [
//           GestureDetector(
//             onTap: () => setState(() => _open = !_open),
//             child: Container(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   const Expanded(
//                     child: Text(
//                       '⚠️ Costs NOT captured in this quotation',
//                       style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF7A5000)),
//                     ),
//                   ),
//                   Icon(_open ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down, color: const Color(0xFF7A5000)),
//                 ],
//               ),
//             ),
//           ),
//           if (_open) ...[
//             const Divider(height: 1, color: Color(0xFFF0D080)),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'This calculator covers direct production costs only (chicks, feeds, medications, vaccines). Estimate these separately:',
//                     style: TextStyle(fontSize: 12, color: Color(0xFF444444)),
//                   ),
//                   const SizedBox(height: 12),
//                   _discGroup('Equipment', equipmentItems),
//                   const SizedBox(height: 8),
//                   _discGroup('Utilities & Overhead', utilityItems),
//                   const SizedBox(height: 12),
//                   const Text(
//                     'Disclaimer: All figures are estimates based on Kenyan market averages. Actual costs and revenues will vary by region, season, breed performance, management, and market prices. For planning purposes only. Consult a qualified livestock officer for farm-specific guidance.',
//                     style: TextStyle(fontSize: 10, color: Color(0xFF999999), fontStyle: FontStyle.italic),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
//
//   Widget _discGroup(String title, List<String> items) => Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       Text(title.toUpperCase(),
//           style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
//               letterSpacing: 0.8, color: kGreen900)),
//       const SizedBox(height: 4),
//       ...items.map((item) => Padding(
//         padding: const EdgeInsets.only(bottom: 3, left: 8),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text('• ', style: TextStyle(fontSize: 11, color: Color(0xFF666666))),
//             Expanded(child: Text(item, style: const TextStyle(fontSize: 11, color: Color(0xFF444444)))),
//           ],
//         ),
//       )),
//     ],
//   );
// }
//
// // ─── EXTENSION ───────────────────────────────────────────────────────────────
//
// extension IntFormat on int {
//   String toLocaleString() =>
//       toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
// }