import 'package:agriflock360/features/farmer/home/model/batch_home_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BatchOverviewCarousel extends StatefulWidget {
  final List<BatchHomeData> batches;

  const BatchOverviewCarousel({
    super.key,
    required this.batches,
  });

  @override
  State<BatchOverviewCarousel> createState() => _BatchOverviewCarouselState();
}

class _BatchOverviewCarouselState extends State<BatchOverviewCarousel> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < widget.batches.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        // Breakpoints
        if (width >= 900) {
          // Large tablet / desktop — 3-column grid
          return _buildGrid(crossAxisCount: 3);
        } else if (width >= 600) {
          // Tablet — 2-column grid
          return _buildGrid(crossAxisCount: 2);
        } else {
          // Mobile — original carousel
          return _buildCarousel(context);
        }
      },
    );
  }

  // ─── Grid layout (tablet / desktop) ───────────────────────────────────────

  Widget _buildGrid({required int crossAxisCount}) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        // Let cards size themselves — childAspectRatio controls the height.
        childAspectRatio: 0.72,
      ),
      itemCount: widget.batches.length,
      itemBuilder: (context, index) {
        return _buildBatchCard(widget.batches[index]);
      },
    );
  }

  // ─── Carousel layout (mobile) ──────────────────────────────────────────────

  Widget _buildCarousel(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        SizedBox(
          height: screenHeight * 0.42, // Increased height for more content
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemCount: widget.batches.length,
            itemBuilder: (context, index) {
              return _buildBatchCard(widget.batches[index]);
            },
          ),
        ),
        const SizedBox(height: 12),

        // Navigation Buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: _currentPage > 0 ? _previousPage : null,
              icon: const Icon(Icons.chevron_left, size: 16),
              label: const Text('Previous Batch'),
              style: TextButton.styleFrom(
                foregroundColor: _currentPage > 0
                    ? Colors.grey.shade700
                    : Colors.grey.shade400,
              ),
            ),
            const SizedBox(width: 16),
            TextButton.icon(
              onPressed: _currentPage < widget.batches.length - 1
                  ? _nextPage
                  : null,
              icon: const Icon(Icons.chevron_right, size: 18),
              label: const Text('Next Batch'),
              style: TextButton.styleFrom(
                foregroundColor: _currentPage < widget.batches.length - 1
                    ? Colors.grey.shade700
                    : Colors.grey.shade400,
              ),
            ),
          ],
        ),

        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.batches.length,
                (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentPage == index ? 20 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: _currentPage == index
                    ? Colors.grey.shade700
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ─── Shared card ───────────────────────────────────────────────────────────

  Widget _buildBatchCard(BatchHomeData batch) {
    final isLayers = batch.birdType.toLowerCase().contains('layers');
    final primaryColor = isLayers ? Colors.amber : Colors.blue;
    final accentColor = isLayers ? Colors.orange : Colors.indigo;

    // Calculate mortality percentage
    final mortalityPercent = batch.totalBirds > 0
        ? ((batch.mortality / batch.totalBirds) * 100).toStringAsFixed(1)
        : '0';

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            isLayers
                ? Colors.amber.shade50.withOpacity(0.3)
                : Colors.blue.shade50.withOpacity(0.3),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isLayers ? Colors.amber.shade200 : Colors.blue.shade200,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isLayers ? Colors.amber : Colors.blue).withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.shade100,
                    accentColor.shade100,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.shade700,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            batch.birdType.toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: accentColor.shade300),
                          ),
                          child: Text(
                            batch.productionStage.stage,
                            style: TextStyle(
                              color: accentColor.shade700,
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          batch.batchNumber,
                          style: TextStyle(
                            color: primaryColor.shade900,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${batch.farmName} • ${batch.houseName}',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Age',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 9,
                          ),
                        ),
                        Text(
                          '${batch.ageWeeks} weeks / ${batch.ageDays} days',
                          style: TextStyle(
                            color: primaryColor.shade800,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Stats Grid - Main Info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoRow(
                        'Number of birds',
                        '${batch.totalBirds}',
                        Icons.pets_outlined,
                        primaryColor,
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        'Mortality',
                        '${batch.mortality} birds – $mortalityPercent%',
                        Icons.warning_amber_outlined,
                        Colors.red,
                        valueColor: batch.mortality > 0
                            ? Colors.red.shade700
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        'Production cost/bird',
                        'KES ${batch.productionCostPerBird.toStringAsFixed(0)}',
                        Icons.attach_money_outlined,
                        Colors.green,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoRow(
                        'Total feeds in store',
                        '${batch.foodInStoreKg} kgs ${batch.foodInStoreBags} bags',
                        Icons.inventory_2_outlined,
                        Colors.brown,
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        'Expected avg feeding',
                        '${batch.expectedFoodPerBirdPerDayG.toStringAsFixed(0)}g/bird = ${batch.totalExpectedFoodPerDayKg.toStringAsFixed(1)} kgs',
                        Icons.restaurant_outlined,
                        Colors.orange,
                      ),
                      const SizedBox(height: 6),
                      _buildInfoRow(
                        'Actual consumed',
                        '${batch.actualFoodPerBirdPerDayG.toStringAsFixed(0)}g/bird = ${batch.totalActualFoodPerDayKg.toStringAsFixed(1)} kgs',
                        Icons.restaurant_menu_outlined,
                        Colors.teal,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Second Row - Weight Info
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Expected avg weight',
                          '${batch.expectedWeight?.toStringAsFixed(2) ?? '0.00'} kgs',
                          Icons.monitor_weight_outlined,
                          Colors.purple,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: [
                        _buildInfoRow(
                          'Actual avg weight',
                          '${batch.actualWeight?.toStringAsFixed(2) ?? '0.00'} kgs',
                          Icons.scale_outlined,
                          accentColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Layers Specific Info
            if (isLayers) ...[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            'Total egg collected',
                            '${batch.totalEggProduction ?? 0}',
                            Icons.egg_outlined,
                            Colors.amber.shade700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoRow(
                            'Production %',
                            '${batch.productionPercentage ?? 0}%',
                            Icons.trending_up,
                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: _buildInfoRow(
                            'Production cost/egg',
                            'KES ${batch.productionCostPerEgg?.toStringAsFixed(2) ?? '0.00'}',
                            Icons.attach_money,
                            Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildInfoRow(
                            'Egg cost',
                            'KES ${batch.eggCost?.toStringAsFixed(2) ?? '0.00'}',
                            Icons.price_check_outlined,
                            Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],

            // Other Production Type
            if (batch.othersProduction != null && batch.othersProduction!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    batch.othersProduction!,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

            // Vaccination Info - Simplified as requested (just numbers/status)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.vaccines_outlined, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(
                        'Vaccination Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        // Count of vaccines done (Green ✓)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade400),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '${batch.vaccination.vaccinesDone.length} done',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Count of vaccines due today (Yellow)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.amber.shade400),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.warning_amber, color: Colors.amber, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '${batch.vaccination.vaccinesUpcoming.where((v) => v.dayDue == batch.ageDays).length} due today',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Count of upcoming (Stay ○)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.blue.shade400),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.access_time, color: Colors.blue, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '${batch.vaccination.vaccinesUpcoming.where((v) => v.dayDue != batch.ageDays).length} upcoming',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.blue.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Count of not done (Red ✗)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.red.shade400),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.cancel, color: Colors.red, size: 12),
                              const SizedBox(width: 2),
                              Text(
                                '0 not done',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // View Details Button
            TextButton.icon(
              onPressed: () {
                context.push('/batch-report', extra: batch.batchId);
              },
              style: TextButton.styleFrom(
                foregroundColor: primaryColor.shade700,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: const Size(double.infinity, 30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              label: const Text(
                'Click for detail reports →',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
              icon: const Icon(Icons.arrow_forward, size: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label,
      String value,
      IconData icon,
      Color iconColor, {
        Color? valueColor,
      }) {
    return Row(
      children: [
        Icon(icon, size: 14, color: iconColor),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(color: Colors.grey.shade500, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.grey.shade800,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}