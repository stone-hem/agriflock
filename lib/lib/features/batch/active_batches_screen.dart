// lib/flocks/active_batches_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActiveBatchesScreen extends StatelessWidget {
  final List<Map<String, dynamic>> batches = [
    {
      'id': '1',
      'name': 'Spring Batch 2024',
      'breed': 'Broiler',
      'quantity': 500,
      'startDate': '2024-03-15',
      'age': 45,
      'mortality': 12,
    },
    {
      'id': '2',
      'name': 'Layer Flock A',
      'breed': 'Hybrid Layer',
      'quantity': 300,
      'startDate': '2024-01-10',
      'age': 120,
      'mortality': 8,
    },
    {
      'id': '3',
      'name': 'Free Range Batch',
      'breed': 'Heritage',
      'quantity': 150,
      'startDate': '2024-04-01',
      'age': 30,
      'mortality': 3,
    },
  ];

  ActiveBatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Active Batches'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: batches.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Active Flocks',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: batches.length,
        itemBuilder: (context, index) {
          final batch = batches[index];
          return _BatchCard(batch: batch);
        },
      ),
    );
  }
}

class _BatchCard extends StatelessWidget {
  final Map<String, dynamic> batch;

  const _BatchCard({required this.batch});

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
                  batch['name'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    batch['breed'],
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _BatchStat(
                  icon: Icons.agriculture,
                  value: '${batch['quantity']}',
                  label: 'Birds',
                  color: Colors.blue,
                ),
                _BatchStat(
                  icon: Icons.calendar_today,
                  value: '${batch['age']}',
                  label: 'Days Old',
                  color: Colors.orange,
                ),
                _BatchStat(
                  icon: Icons.flag,
                  value: '${batch['mortality']}',
                  label: 'Mortality',
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  context.push('/batches/details');
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green,
                  side: BorderSide(color: Colors.green.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('View Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BatchStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _BatchStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}