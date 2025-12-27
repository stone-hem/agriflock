import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';

class ArchivedBatchesTab extends StatefulWidget {
  final FarmModel farm;
  const ArchivedBatchesTab({super.key, required this.farm});

  @override
  State<ArchivedBatchesTab> createState() => _ArchivedBatchesTabState();
}

class _ArchivedBatchesTabState extends State<ArchivedBatchesTab> {
  @override
  Widget build(BuildContext context) {
    final archivedBatches = [
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

    return archivedBatches.isEmpty
        ? _buildEmptyState()
        : ListView(
      padding: const EdgeInsets.all(20),
      children: [
        // Header
        Text(
          'Archived Batches',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'View and manage your completed batches',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 24),

        // Archived batches list
        ...archivedBatches.map((flock) => _ArchivedBatchCard(flock: flock)).toList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.archive,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Archived Batches',
            style: TextStyle(
              fontSize: 20,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Archived batches will appear here',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ArchivedBatchCard extends StatelessWidget {
  final Map<String, dynamic> flock;

  const _ArchivedBatchCard({required this.flock});

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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showRestoreDialog(context, flock['name']);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: BorderSide(color: Colors.green.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.restore, size: 18),
                    label: const Text('Restore'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _showDeleteDialog(context, flock['name']);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: BorderSide(color: Colors.red.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                  ),
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

// Dialog functions for archived screen
void _showRestoreDialog(BuildContext context, String batchName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Restore Batch'),
      content: Text('Are you sure you want to restore "$batchName" to active batches?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement restore functionality
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"$batchName" has been restored'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
          child: const Text('Restore'),
        ),
      ],
    ),
  );
}

void _showDeleteDialog(BuildContext context, String batchName) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Delete Batch'),
      content: Text('Are you sure you want to permanently delete "$batchName"? This action cannot be undone.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // TODO: Implement delete functionality
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('"$batchName" has been deleted'),
                backgroundColor: Colors.red,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
          ),
          child: const Text('Delete'),
        ),
      ],
    ),
  );
}