
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
class CreateFarmScreen extends StatelessWidget {
  const CreateFarmScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Farm Profile'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Farm Profile',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Set up your farm details',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Account Created!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Now let\'s set up your farm',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  context.go('/select-farm-type');
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Select Farm Type Screen
class SelectFarmTypeScreen extends StatefulWidget {
  const SelectFarmTypeScreen({super.key});

  @override
  State<SelectFarmTypeScreen> createState() => _SelectFarmTypeScreenState();
}

class _SelectFarmTypeScreenState extends State<SelectFarmTypeScreen> {
  String? _selectedType;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Farm Type'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Farm Type',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What type of poultry do you raise?',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 40),
              _buildFarmTypeCard(
                'Layers',
                'Egg production focused',
                Icons.egg_outlined,
              ),
              const SizedBox(height: 16),
              _buildFarmTypeCard(
                'Broilers',
                'Meat production focused',
                Icons.restaurant,
              ),
              const SizedBox(height: 16),
              _buildFarmTypeCard(
                'Mixed',
                'Both layers and broilers',
                Icons.agriculture,
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _selectedType != null
                    ? () {
                  context.go('/add-coops');
                }
                    : null,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFarmTypeCard(String title, String subtitle, IconData icon) {
    final isSelected = _selectedType == title;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedType = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: isSelected ? Colors.green.shade50 : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 40,
              color: isSelected ? Colors.green : Colors.grey.shade600,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.green.shade900 : null,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
              ),
          ],
        ),
      ),
    );
  }
}
