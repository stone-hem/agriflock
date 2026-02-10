import 'package:agriflock360/features/farmer/home/model/batch_home_model.dart';
import 'package:flutter/material.dart';

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
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // PageView
        SizedBox(
          height: screenHeight * 0.33,
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
              icon: const Icon(Icons.chevron_left, size: 18),
              label: const Text('Previous'),
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
              label: const Text('Next'),
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

  Widget _buildBatchCard(BatchHomeData batch) {
    final isLayers = batch.birdType.toLowerCase() == 'layers';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Text(
                              batch.birdType.toUpperCase(),
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Text(
                              batch.productionStage.stage,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        batch.batchNumber,
                        style: TextStyle(
                          color: Colors.grey.shade900,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${batch.farmName} • ${batch.houseName}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Age',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 11,
                      ),
                    ),
                    Text(
                      '${batch.ageWeeks}w ${batch.ageDays}d',
                      style: TextStyle(
                        color: Colors.grey.shade900,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            Divider(color: Colors.grey.shade200, height: 1),
            const SizedBox(height: 12),

            // Main Stats Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left Column
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildInfoRow(
                        'Total Birds',
                        '${batch.totalBirds}',
                        Icons.pets_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Birds Placed',
                        '${batch.birdsPlaced}',
                        Icons.add_circle_outline,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Mortality',
                        '${batch.mortality} (${batch.mortalityRate})',
                        Icons.warning_amber_outlined,
                        valueColor: batch.mortality > 0
                            ? Colors.red.shade700
                            : Colors.grey.shade700,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Feed (Bags)',
                        '${batch.foodInStoreBags} bags',
                        Icons.inventory_2_outlined,
                      ),
                      if (isLayers) ...[
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Egg Production',
                          '${batch.totalEggProduction ?? 0}',
                          Icons.egg_outlined,
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right Column
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isLayers) ...[
                        _buildInfoRow(
                          'Production %',
                          '${batch.productionPercentage ?? 0}%',
                          Icons.trending_up,
                        ),
                        const SizedBox(height: 8),
                        _buildInfoRow(
                          'Egg Cost',
                          'KES ${batch.eggCost?.toStringAsFixed(2) ?? '0.00'}',
                          Icons.attach_money,
                        ),
                        const SizedBox(height: 8),
                      ],
                      _buildInfoRow(
                        'Expected Weight',
                        '${batch.expectedWeight?.toStringAsFixed(1) ?? 'N/A'} kg',
                        Icons.monitor_weight_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Actual Weight',
                        '${batch.actualWeight?.toStringAsFixed(1) ?? 'N/A'} kg',
                        Icons.scale_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Feed/Bird/Day',
                        '${batch.actualFoodPerBirdPerDayG.toStringAsFixed(1)}g',
                        Icons.restaurant_outlined,
                      ),
                      const SizedBox(height: 8),
                      _buildInfoRow(
                        'Days to Milestone',
                        '${batch.productionStage.expectedMilestone.daysRemaining} days',
                        Icons.calendar_today_outlined,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Vaccination Info
            if (batch.vaccination.vaccinesDone.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.vaccines_outlined,
                      size: 14,
                      color: Colors.green.shade700,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Vaccines: ${batch.vaccination.vaccinesDone.take(2).join(", ")}${batch.vaccination.vaccinesDone.length > 2 ? " +${batch.vaccination.vaccinesDone.length - 2}" : ""}',
                        style: TextStyle(
                          color: Colors.green.shade700,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Widget _buildInfoRow(
      String label,
      String value,
      IconData icon, {
        Color? valueColor,
      }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: Colors.grey.shade500,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 10,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor ?? Colors.grey.shade800,
                  fontSize: 13,
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