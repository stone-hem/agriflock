import 'package:agriflock360/features/farm/farms_home_screen.dart';
import 'package:agriflock360/features/profile/profile_screen.dart';
import 'package:agriflock360/features/shared/nav_destination_item.dart';
import 'package:agriflock360/features/vet/vet_home_screen.dart';
import 'package:agriflock360/features/vet/vet_payments_screen.dart';
import 'package:agriflock360/features/vet/vet_profile_screen.dart';
import 'package:agriflock360/features/vet/vet_schedules_screen.dart';
import 'package:agriflock360/home_screen.dart';
import 'package:agriflock360/quotation_screen.dart';
import 'package:flutter/material.dart';
import 'package:agriflock360/reports_screen.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;

  // Flag for testing RBAC - change to 'vet' to load vet screens
  final String _role = 'vet'; // Or set to 'vet' for testing

  late List<NavConfig> _navConfigs;

  @override
  void initState() {
    super.initState();
    if (_role == 'vet') {
      _navConfigs = [
        NavConfig(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          screen: VetHomeScreen(),
        ),
        NavConfig(
          icon: Icons.schedule_outlined,
          selectedIcon: Icons.schedule,
          label: 'Schedules',
          screen: VetSchedulesScreen(),
        ),
        NavConfig(
          icon: Icons.payment_outlined,
          selectedIcon: Icons.payment,
          label: 'Payments',
          screen: VetPaymentsScreen(),
        ),
        NavConfig(
          icon: Icons.person_outlined,
          selectedIcon: Icons.person,
          label: 'Profile',
          screen: VetProfileScreen(),
        ),
      ];
    } else {
      _navConfigs = [
        NavConfig(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          screen: HomeScreen(),
        ),
        NavConfig(
          icon: Icons.agriculture_outlined,
          selectedIcon: Icons.agriculture,
          label: 'Farms',
          screen: FarmsHomeScreen(),
        ),
        NavConfig(
          icon: Icons.format_quote_outlined,
          selectedIcon: Icons.format_quote,
          label: 'Quotation',
          screen: QuotationScreen(),
        ),
        NavConfig(
          icon: Icons.bar_chart_outlined,
          selectedIcon: Icons.bar_chart,
          label: 'Reports',
          screen: ReportsScreen(),
        ),
        NavConfig(
          icon: Icons.person_outlined,
          selectedIcon: Icons.person,
          label: 'Profile',
          screen: ProfileScreen(),
        ),
      ];
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _navConfigs[_selectedIndex].screen,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, -2),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          indicatorColor: Colors.green.withValues(alpha: 0.15),
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 72,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          animationDuration: const Duration(milliseconds: 300),
          destinations: _navConfigs
              .asMap()
              .entries
              .map((entry) {
            final index = entry.key;
            final config = entry.value;
            return NavDestinationItem(
              icon: config.icon,
              selectedIcon: config.selectedIcon,
              label: config.label,
              isSelected: _selectedIndex == index,
            );
          })
              .toList(),
        ),
      ),
    );
  }
}