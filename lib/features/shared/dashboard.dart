import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/features/farmer/farm/view/farms_home_screen.dart';
import 'package:agriflock360/features/farmer/profile/profile_screen.dart';
import 'package:agriflock360/features/farmer/vet/browse_vets_screen.dart';
import 'package:agriflock360/features/shared/nav_destination_item.dart';
import 'package:agriflock360/features/vet/vet_home_screen.dart';
import 'package:agriflock360/features/vet/vet_payments_screen.dart';
import 'package:agriflock360/features/vet/vet_profile_screen.dart';
import 'package:agriflock360/features/vet/vet_schedules_screen.dart';
import 'package:agriflock360/features/farmer/home/view/home_screen.dart';
import 'package:agriflock360/features/farmer/quotation/quotation_screen.dart';
import 'package:flutter/material.dart';

class MainDashboard extends StatefulWidget {
  const MainDashboard({super.key});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  String? _userRole;
  bool _isLoading = true;
  late List<NavConfig> _navConfigs;
  final SecureStorage _secureStorage = SecureStorage();

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      // Get user data from secure storage
      final User? userData = await _secureStorage.getUserData();

      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      if (userData != null) {
        final Role role = userData.role;
        final roleName = role.name;

        setState(() {
          _userRole = roleName.toLowerCase();
          _initializeNavConfigs();
          _isLoading = false;
        });
      } else {
        // Fallback: If no role found, default to farmer or handle error
        setState(() {
          _userRole = 'farmer';
          _initializeNavConfigs();
          _isLoading = false;
        });
      }
    } catch (e) {
      // Handle error - default to farmer or show error screen
      print('Error loading user role: $e');

      // Check if widget is still mounted before calling setState
      if (!mounted) return;

      setState(() {
        _userRole = 'farmer';
        _initializeNavConfigs();
        _isLoading = false;
      });
    }
  }

  void _initializeNavConfigs() {
    if (_userRole == 'extension_officer') {
      _navConfigs = [
        NavConfig(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          screen: const VetHomeScreen(),
        ),
        NavConfig(
          icon: Icons.schedule_outlined,
          selectedIcon: Icons.schedule,
          label: 'Schedules',
          screen: const VetSchedulesScreen(),
        ),
        NavConfig(
          icon: Icons.payment_outlined,
          selectedIcon: Icons.payment,
          label: 'Payments',
          screen: const VetPaymentsScreen(),
        ),
        NavConfig(
          icon: Icons.person_outlined,
          selectedIcon: Icons.person,
          label: 'Profile',
          screen: const VetProfileScreen(),
        ),
      ];
    } else {
      // Default to farmer navigation
      _navConfigs = [
        NavConfig(
          icon: Icons.home_outlined,
          selectedIcon: Icons.home,
          label: 'Home',
          screen: const HomeScreen(),
        ),
        NavConfig(
          icon: Icons.agriculture_outlined,
          selectedIcon: Icons.agriculture,
          label: 'Farms',
          screen: const FarmsHomeScreen(),
        ),
        NavConfig(
          icon: Icons.format_quote_outlined,
          selectedIcon: Icons.format_quote,
          label: 'Quotation',
          screen: const QuotationScreen(),
        ),
        NavConfig(
          icon: Icons.people_outline,
          selectedIcon: Icons.people,
          label: 'Vets',
          screen: const BrowseVetsScreen(),
        ),
        NavConfig(
          icon: Icons.person_outlined,
          selectedIcon: Icons.person,
          label: 'Profile',
          screen: const ProfileScreen(),
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
    // Show loading indicator while fetching role
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.green,
          ),
        ),
      );
    }

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