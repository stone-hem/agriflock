import 'package:agriflock360/features/farmer/batch/model/batch_list_model.dart';
import 'package:agriflock360/features/farmer/report/models/batch_report_model.dart';
import 'package:flutter/material.dart';

class BatchReportView extends StatelessWidget {
  final BatchListItem batch;
  final BatchReportResponse? reportData;
  final bool isLoading;
  final String? error;
  final VoidCallback onBack;
  final VoidCallback onRetry;
  final String currency;

  const BatchReportView({
    super.key,
    required this.batch,
    this.reportData,
    required this.isLoading,
    this.error,
    required this.onBack,
    required this.onRetry,
    this.currency = 'KES',
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return _buildErrorView();
    }

    if (reportData == null || reportData!.data.isEmpty) {
      return _buildEmptyReportView();
    }

    final report = reportData!.data.first;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBatchHeader(report),
          const SizedBox(height: 20),
          _buildMortalityCard(report.mortality),
          const SizedBox(height: 16),
          _buildFeedCard(report.feed),
          const SizedBox(height: 16),
          _buildVaccinationCard(report.vaccination),
          const SizedBox(height: 16),
          _buildMedicationCard(report.medication),
          if (report.eggProduction != null) ...[
            const SizedBox(height: 16),
            _buildEggProductionCard(report.eggProduction!),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text('Error: $error'),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyReportView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assignment_outlined, size: 64, color: Colors.grey.shade400),
          const SizedBox(height: 16),
          Text(
            'No report data available',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting the date range',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBatchHeader(BatchReportData report) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.assessment, color: Colors.blue.shade700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      report.batchNumber,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade800,
                      ),
                    ),
                    Text(
                      '${report.farmName} - ${report.houseName}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildHeaderStat('Bird Type', report.birdType),
              _buildHeaderStat('Total Birds', '${report.totalBirds}'),
              _buildHeaderStat('Age', '${report.ageDays} days'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blue.shade800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.blue.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMortalityCard(BatchMortality mortality) {
    return _buildReportCard(
      title: 'Mortality',
      icon: Icons.warning_amber,
      color: Colors.red,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Day', '${mortality.day}', Colors.orange),
              _buildStatItem('Night', '${mortality.night}', Colors.indigo),
              _buildStatItem('24hrs', '${mortality.total24hrs}', Colors.red),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('Cumulative', '${mortality.cumulativeTotal}', Colors.purple),
              _buildStatItem('Remaining', '${mortality.birdsRemaining}', Colors.green),
            ],
          ),
          if (mortality.reason.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Reason: ${mortality.reason}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedCard(BatchFeed feed) {
    return _buildReportCard(
      title: 'Feed',
      icon: Icons.fastfood,
      color: Colors.orange,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Consumed', '${feed.bagsConsumed} bags', Colors.orange),
              _buildStatItem('Total', '${feed.totalBagsConsumed} bags', Colors.amber),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('In Store', '${feed.balanceInStore} bags', Colors.green),
              _buildStatItem('Type', feed.feedType, Colors.blue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVaccinationCard(BatchVaccination vaccination) {
    return _buildReportCard(
      title: 'Vaccination',
      icon: Icons.vaccines,
      color: Colors.blue,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Done', '${vaccination.vaccinesDone.length}', Colors.green),
              _buildStatItem('Upcoming', '${vaccination.vaccinesUpcoming.length}', Colors.orange),
            ],
          ),
          if (vaccination.vaccinesDone.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildVaccineList('Completed', vaccination.vaccinesDone, Colors.green),
          ],
          if (vaccination.vaccinesUpcoming.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildVaccineList('Upcoming', vaccination.vaccinesUpcoming, Colors.orange),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicationCard(BatchMedication medication) {
    return _buildReportCard(
      title: 'Medication',
      icon: Icons.medical_services,
      color: Colors.purple,
      child: Column(
        children: [
          _buildStatItem(
            'Available',
            '${medication.medicationsAvailable.length}',
            Colors.purple,
          ),
          if (medication.medicationsAvailable.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: medication.medicationsAvailable.map((med) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      med.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildEggProductionCard(EggProduction production) {
    return _buildReportCard(
      title: 'Egg Production',
      icon: Icons.egg,
      color: Colors.amber,
      child: Column(
        children: [
          Row(
            children: [
              _buildStatItem('Trays', '${production.traysCollected}', Colors.amber),
              _buildStatItem('Total Eggs', '${production.totalEggsCollected}', Colors.orange),
              _buildStatItem('Pieces', '${production.piecesCollected}', Colors.brown),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('In Store', '${production.traysInStore} trays', Colors.green),
              _buildStatItem('Production', '${production.productionPercentage.toStringAsFixed(1)}%', Colors.blue),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatItem('Broken', '${production.partialBroken + production.completeBroken}', Colors.red),
              _buildStatItem('Good Eggs', '${production.goodEggs}', Colors.green),
              _buildStatItem('Value', '$currency ${production.totalValue.toStringAsFixed(2)}', Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Color color,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: color.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVaccineList(String label, List<dynamic> vaccines, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: vaccines.take(5).map((vaccine) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                vaccine.toString(),
                style: TextStyle(
                  fontSize: 11,
                  color: color,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
