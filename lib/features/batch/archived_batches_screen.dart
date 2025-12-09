// lib/flocks/archived_batches_screen.dart
import 'package:flutter/material.dart';

class ArchivedBatchesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> archivedBatches = [
    {
      'id': '1',
      'name': 'Winter Batch 2023',
      'breed': 'Broiler',
      'quantity': 450,
      'startDate': '2023-11-15',
      'endDate': '2024-02-20',
      'duration': 97,
    },
    {
      'id': '2',
      'name': 'Layer Flock B',
      'breed': 'Hybrid Layer',
      'quantity': 280,
      'startDate': '2023-08-01',
      'endDate': '2024-03-15',
      'duration': 227,
    },
  ];

  ArchivedBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
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
            const Text('Archived Batches'),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: archivedBatches.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.archive, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Archived Batches',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: archivedBatches.length,
        itemBuilder: (context, index) {
          final flock = archivedBatches[index];
          return _ArchivedFlockCard(flock: flock);
        },
      ),
    );
  }
}

class _ArchivedFlockCard extends StatelessWidget {
  final Map<String, dynamic> flock;

  const _ArchivedFlockCard({required this.flock});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  flock['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Archived',
                    style: TextStyle(
                      color: Colors.orange.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              flock['breed'],
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _ArchivedStat(
                  icon: Icons.agriculture,
                  value: '${flock['quantity']}',
                  label: 'Total Birds',
                ),
                _ArchivedStat(
                  icon: Icons.calendar_today,
                  value: '${flock['duration']}',
                  label: 'Days',
                ),
                _ArchivedStat(
                  icon: Icons.date_range,
                  value: 'Completed',
                  label: 'Status',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ArchivedStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _ArchivedStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: Colors.grey.shade600),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}