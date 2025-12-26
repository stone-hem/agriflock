import 'package:agriflock360/features/farmer/farm/models/farm_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ActiveBatchesTab extends StatefulWidget {
  final FarmModel farm;
  const ActiveBatchesTab({super.key, required this.farm});

  @override
  State<ActiveBatchesTab> createState() => _ActiveBatchesTabState();
}

class _ActiveBatchesTabState extends State<ActiveBatchesTab> {
  final Map<String, bool> _expandedHouses = {};

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      children: [
        // Header
        Text(
          'Manage Your Batches & Houses - ${widget.farm.farmName}',
          style: Theme.of(context).textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
           widget.farm.location ?? widget.farm.description ?? 'Track and monitor all your poultry batches',
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 18),

        // Action Grid
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.1,
          children: [
            _ActionCard(
              icon: Icons.group_add,
              title: 'Add New Batch',
              subtitle: 'Start a new batch',
              color: Colors.green,
              onTap: () => context.push('/batches/add'),
            ),
            _ActionCard(
              icon: Icons.warehouse,
              title: 'Add New House',
              subtitle: 'Create new house',
              color: Colors.teal,
              onTap: () => _showAddHouseDialog(context),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Houses Section
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Houses Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Houses & Batches',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.warehouse,
                            color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          '${_getAllBatches().length} Active',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Houses List
              _buildHousesList(),
              const SizedBox(height: 20),
            ],
          ),
        ),

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildHousesList() {
    final houses = [
      {
        'id': '1',
        'name': 'House A - Broiler Section',
        'capacity': 5000,
        'currentBirds': 1500,
        'utilization': 30,
        'batches': [
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
            'name': 'Summer Batch 2024',
            'breed': 'Broiler',
            'quantity': 600,
            'startDate': '2024-05-10',
            'age': 25,
            'mortality': 5,
          },
        ]
      },
      {
        'id': '2',
        'name': 'House B - Layer Section',
        'capacity': 3000,
        'currentBirds': 1200,
        'utilization': 40,
        'batches': [
          {
            'id': '3',
            'name': 'Layer Flock A',
            'breed': 'Hybrid Layer',
            'quantity': 300,
            'startDate': '2024-01-10',
            'age': 120,
            'mortality': 8,
          },
          {
            'id': '4',
            'name': 'Layer Flock B',
            'breed': 'Hybrid Layer',
            'quantity': 900,
            'startDate': '2024-02-15',
            'age': 90,
            'mortality': 15,
          },
        ]
      },
      {
        'id': '3',
        'name': 'House C - Free Range',
        'capacity': 1000,
        'currentBirds': 150,
        'utilization': 15,
        'batches': [
          {
            'id': '5',
            'name': 'Free Range Batch',
            'breed': 'Heritage',
            'quantity': 150,
            'startDate': '2024-04-01',
            'age': 30,
            'mortality': 3,
          },
        ]
      },
      {
        'id': '4',
        'name': 'House D - Empty',
        'capacity': 4000,
        'currentBirds': 0,
        'utilization': 0,
        'batches': []
      },
    ];

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: houses.length,
      itemBuilder: (context, index) {
        final house = houses[index];
        return _HouseCard(
          house: house,
          isExpanded: _expandedHouses[house['id']] ?? false,
          onExpand: () {
            setState(() {
              _expandedHouses[house['id'] as String] =
              !(_expandedHouses[house['id']] ?? false);
            });
          },
        );
      },
    );
  }

  List<Map<String, dynamic>> _getAllBatches() {
    final houses = [
      {
        'batches': [
          {
            'id': '1',
            'name': 'Spring Batch 2024',
            'breed': 'Broiler',
            'quantity': 500,
            'age': 45
          },
          {
            'id': '2',
            'name': 'Summer Batch 2024',
            'breed': 'Broiler',
            'quantity': 600,
            'age': 25
          },
        ]
      },
      {
        'batches': [
          {
            'id': '3',
            'name': 'Layer Flock A',
            'breed': 'Hybrid Layer',
            'quantity': 300,
            'age': 120
          },
          {
            'id': '4',
            'name': 'Layer Flock B',
            'breed': 'Hybrid Layer',
            'quantity': 900,
            'age': 90
          },
        ]
      },
      {
        'batches': [
          {
            'id': '5',
            'name': 'Free Range Batch',
            'breed': 'Heritage',
            'quantity': 150,
            'age': 30
          },
        ]
      },
    ];

    final List<Map<String, dynamic>> allBatches = [];
    for (var house in houses) {
      allBatches.addAll(List<Map<String, dynamic>>.from(house['batches']!));
    }
    return allBatches;
  }

  void _showAddHouseDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New House'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'House Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Capacity',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                suffixText: 'birds',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement add house functionality
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New house added successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: const Text('Add House'),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: FittedBox(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color.withAlpha(40),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, size: 24, color: color),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Flexible(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 4),
              Flexible(
                child: Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HouseCard extends StatelessWidget {
  final Map<String, dynamic> house;
  final bool isExpanded;
  final VoidCallback onExpand;

  const _HouseCard({
    required this.house,
    required this.isExpanded,
    required this.onExpand,
  });

  @override
  Widget build(BuildContext context) {
    final batches = List<Map<String, dynamic>>.from(house['batches'] ?? []);
    final capacity = house['capacity'] ?? 0;
    final currentBirds = house['currentBirds'] ?? 0;
    final utilization = house['utilization'] ?? 0;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // House Header
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: utilization > 0
                    ? Colors.green.shade50
                    : Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                utilization > 0 ? Icons.warehouse : Icons.warehouse_outlined,
                color: utilization > 0 ? Colors.green : Colors.grey,
              ),
            ),
            title: Text(
              house['name'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  'Capacity: $capacity birds • Current: $currentBirds birds',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${batches.length} batch${batches.length == 1 ? '' : 'es'}',
                    style: TextStyle(
                      color: Colors.green.shade800,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: utilization / 100,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    utilization > 80
                        ? Colors.red
                        : utilization > 50
                        ? Colors.orange
                        : Colors.green,
                  ),
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(3),
                ),
                const SizedBox(height: 4),
                Text(
                  '$utilization% utilized',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [

                IconButton(
                  icon: Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                  onPressed: onExpand,
                ),
              ],
            ),
          ),

          // Expandable Content
          if (isExpanded) ...[
            Divider(color: Colors.grey.shade200, height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  if (batches.isEmpty)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.group_off,
                            size: 48,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No batches in this house',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: () => context.push('/batches/add'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                              side: BorderSide(color: Colors.green.shade300),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Add Batch to this House'),
                          ),
                        ],
                      ),
                    )
                  else
                    ...batches
                        .map((batch) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _MiniBatchCard(batch: batch),
                    ))
                        .toList(),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/batches/add',
                              extra: {'houseId': house['id']}),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.green,
                            side: BorderSide(color: Colors.green.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Batch'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // TODO: Navigate to house details
                          },
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.blue,
                            side: BorderSide(color: Colors.blue.shade300),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.visibility, size: 18),
                          label: const Text('View Details'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MiniBatchCard extends StatelessWidget {
  final Map<String, dynamic> batch;

  const _MiniBatchCard({required this.batch});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.pets,
                color: Colors.green.shade700,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    batch['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${batch['breed']} • ${batch['quantity']} birds • ${batch['age']} days',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, color: Colors.grey.shade400),
              onPressed: () => context.push('/batches/details', extra: batch),
            ),
          ],
        ),
      ),
    );
  }
}