// lib/farms/farms_home_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class FarmsHomeScreen extends StatefulWidget {
  const FarmsHomeScreen({super.key});

  @override
  State<FarmsHomeScreen> createState() => _FarmsHomeScreenState();
}

class _FarmsHomeScreenState extends State<FarmsHomeScreen> {
  // Controller for scroll notifications
  final ScrollController _scrollController = ScrollController();

  // Track whether to show the FAB
  bool _showFab = true;

  @override
  void initState() {
    super.initState();

    // Listen to scroll events to hide/show FAB
    _scrollController.addListener(() {
      // Hide FAB when user starts scrolling down
      if (_scrollController.offset > 100 && _showFab) {
        setState(() {
          _showFab = false;
        });
      }
      // Show FAB when user is at the top
      else if (_scrollController.offset <= 100 && !_showFab) {
        setState(() {
          _showFab = true;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

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
            const Text('Agriflock 360'),
          ],
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Colors.grey.shade700),
            onPressed: () => context.push('/notifications'),
          ),
        ],
      ),
      floatingActionButton: _showFab ? FloatingActionButton(
        onPressed: () => context.push('/farms/add'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add),
      ) : null,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
        child: CustomScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header section
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Text(
                    'Select a Farm to continue',
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage multiple farm locations and their Batches',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Stats Overview
                  _buildStatsOverview(),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // Farms List
            _buildFarmsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsOverview() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            value: '3',
            label: 'Total Farms',
            color: Colors.blue.shade100,
            textColor: Colors.blue.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '1,240',
            label: 'Total Birds',
            color: Colors.green.shade100,
            textColor: Colors.green.shade800,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            value: '3',
            label: 'Active Batches',
            color: Colors.orange.shade100,
            textColor: Colors.orange.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildFarmsList() {
    final farms = [
      Farm(
        id: 'FARM-001',
        name: 'Main Poultry Farm',
        location: 'Kumasi, Ashanti Region',
        totalBirds: 850,
        activeBatches: 3,
        imageUrl: 'https://upload.wikimedia.org/wikipedia/commons/8/84/Male_and_female_chicken_sitting_together.jpg?w=400',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      Farm(
        id: 'FARM-002',
        name: 'Brooder Nursery',
        location: 'Ejisu, Ashanti Region',
        totalBirds: 240,
        activeBatches: 1,
        imageUrl: 'https://www.onehealthpoultry.org/wp-content/uploads/2022/07/chicken-Xuan-Tuan-Anh-Dang-from-Pixabay.jpg?w=400',
        lastUpdated: DateTime.now().subtract(const Duration(days: 1)),
      ),
      Farm(
        id: 'FARM-003',
        name: 'Free Range Unit',
        location: 'Bekwai, Ashanti Region',
        totalBirds: 150,
        activeBatches: 1,
        imageUrl: 'https://poultryhub.org/content/uploads/2012/06/Broilers.jpg?w=400',
        lastUpdated: DateTime.now().subtract(const Duration(days: 3)),
      ),
    ];

    return SliverList(
      delegate: SliverChildBuilderDelegate(
            (context, index) {
          return _FarmCard(farm: farms[index]);
        },
        childCount: farms.length,
      ),
    );
  }
}

class Farm {
  final String id;
  final String name;
  final String location;
  final int totalBirds;
  final int activeBatches;
  final String imageUrl;
  final DateTime lastUpdated;

  const Farm({
    required this.id,
    required this.name,
    required this.location,
    required this.totalBirds,
    required this.activeBatches,
    required this.imageUrl,
    required this.lastUpdated,
  });
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final Color textColor;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: textColor.withOpacity(0.8),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _FarmCard extends StatelessWidget {
  final Farm farm;

  const _FarmCard({
    required this.farm,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () => context.push('/batches'),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Farm Image
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  image: DecorationImage(
                    image: NetworkImage(farm.imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Farm Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farm.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: 150,
                      child: Text(
                        farm.location,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _FarmStat(
                          icon: Icons.groups_outlined,
                          value: '${farm.totalBirds}',
                          label: 'Birds',
                        ),
                        const SizedBox(width: 2),
                        _FarmStat(
                          icon: Icons.egg_outlined,
                          value: '${farm.activeBatches}',
                          label: 'Batches',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action Menu
              PopupMenuButton<String>(
                icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                onSelected: (value) {
                  _handleMenuAction(value, context);
                },
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Edit Farm'),
                      ],
                    ),
                  ),
                  const PopupMenuItem<String>(
                    value: 'view_batches',
                    child: Row(
                      children: [
                        Icon(Icons.visibility_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('View Batches'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleMenuAction(String value, BuildContext context) {
    switch (value) {
      case 'edit':
      // TODO: Implement edit farm
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Edit ${farm.name}'),
            backgroundColor: Colors.blue,
          ),
        );
        break;
      case 'view_batches':
        context.push('/batches');
        break;
    }
  }
}

class _FarmStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _FarmStat({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.green.shade600),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}