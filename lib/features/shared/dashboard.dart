import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/log_util.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/features/farmer/farm/view/farms_home_screen.dart';
import 'package:agriflock360/features/farmer/profile/profile_screen.dart';
import 'package:agriflock360/features/farmer/vet/browse_vets_screen.dart';
import 'package:agriflock360/features/shared/nav_destination_item.dart';
import 'package:agriflock360/features/vet/home/vet_home_screen.dart';
import 'package:agriflock360/features/vet/payments/vet_payments_screen.dart';
import 'package:agriflock360/features/vet/profile/vet_profile_screen.dart';
import 'package:agriflock360/features/vet/schedules/vet_schedules_screen.dart';
import 'package:agriflock360/features/farmer/home/view/home_screen.dart';
import 'package:agriflock360/features/farmer/quotation/quotation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainDashboard extends StatefulWidget {
  final String? initialTab;
  const MainDashboard({super.key, this.initialTab});

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  int _selectedIndex = 0;
  String? _userRole;
  bool _isLoading = true;
  late List<NavConfig> _navConfigs;
  final SecureStorage _secureStorage = SecureStorage();
  bool _hasSetInitialTab = false; // Track if we've set the initial tab

  // Define tab identifiers for both roles
  static const Map<String, Map<String, int>> _tabMappings = {
    'extension_officer': {
      'vet_home': 0,
      'vet_schedules': 1,
      'vet_payments': 2,
      'vet_profile': 3,
    },
    'farmer': {
      'farmer_home': 0,
      'farmer_farms': 1,
      'farmer_quotation': 2,
      'farmer_vets': 3,
      'farmer_profile': 4,
    },
  };

  @override
  void initState() {
    super.initState();
    if(widget.initialTab != null) {
      LogUtil.warning('In main init state ${widget.initialTab}');
    }else{
      LogUtil.warning('initialTab is null in main init state');
    }
    _loadUserRole();
  }

  @override
  void didUpdateWidget(MainDashboard oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if initialTab changed and we haven't set it yet
    if (widget.initialTab != oldWidget.initialTab &&
        widget.initialTab != null &&
        !_hasSetInitialTab &&
        !_isLoading) {
      LogUtil.warning('didUpdateWidget: initialTab changed to ${widget.initialTab}');
      _setInitialTab();
    }
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
          _setInitialTab();
          _isLoading = false;
        });
      } else {
        // Fallback: If no role found, default to farmer or handle error
        setState(() {
          _userRole = 'farmer';
          _initializeNavConfigs();
          _setInitialTab();
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
        _setInitialTab();
        _isLoading = false;
      });
    }
  }

  void _setInitialTab() {
    if (widget.initialTab != null && _userRole != null && !_hasSetInitialTab) {
      LogUtil.warning('_setInitialTab called with tab: ${widget.initialTab}, role: $_userRole');

      // Get the tab mappings for the current user role
      final roleTabs = _tabMappings[_userRole];

      if (roleTabs != null && roleTabs.containsKey(widget.initialTab)) {
        LogUtil.warning('Setting index to: ${roleTabs[widget.initialTab]}');
        setState(() {
          _selectedIndex = roleTabs[widget.initialTab]!;
          _hasSetInitialTab = true;
        });
      } else {
        // Invalid tab for this role, default to home (index 0)
        LogUtil.warning('Warning: Tab "${widget.initialTab}" not valid for role "$_userRole"');
        setState(() {
          _selectedIndex = 0;
          _hasSetInitialTab = true;
        });
      }
    } else {
      LogUtil.warning('Skipping _setInitialTab: initialTab=${widget.initialTab}, userRole=$_userRole, hasSet=$_hasSetInitialTab');
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

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return;
        }

        final shouldExit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Exit Agriflock 360?'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Image.asset(
                    'assets/logos/Logo_0725.png',
                    fit: BoxFit.cover,
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.green,
                        child: const Icon(
                          Icons.image,
                          size: 120,
                          color: Colors.white54,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Agriflock 360',
                  style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade800,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Are you sure you want to exit Agriflock 360?'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No, stay around'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Yes, exit and continue later'),
              ),
            ],
          ),
        );

        if (shouldExit == true) {
          SystemNavigator.pop();
        }
      },
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Breakpoints
          final isTablet = constraints.maxWidth >= 600;
          final isLargeTablet = constraints.maxWidth >= 840;

          return Scaffold(
            body: Row(
              children: [
                // NavigationRail for tablets only
                if (isTablet)
                  Material(
                    elevation: 0,
                    color: Colors.white,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border(
                          right: BorderSide(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                      ),
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: _onItemTapped,
                        extended: isLargeTablet,
                        labelType: isLargeTablet
                            ? NavigationRailLabelType.none
                            : NavigationRailLabelType.all,
                        backgroundColor: Colors.transparent,
                        indicatorColor: Colors.green.withValues(alpha: 0.15),
                        useIndicator: true,
                        minWidth: isLargeTablet ? 200 : 72,
                        minExtendedWidth: 200,
                        leading: SizedBox(
                          height: 80,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: 16.0,
                              horizontal: isLargeTablet ? 16.0 : 0,
                            ),
                            child: isLargeTablet
                                ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(
                                  'assets/logos/Logo_0725.png',
                                  width: 40,
                                  height: 40,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Icon(
                                      Icons.agriculture,
                                      size: 40,
                                      color: Colors.green,
                                    );
                                  },
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Agriflock 360',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            )
                                : Center(
                              child: Image.asset(
                                'assets/logos/Logo_0725.png',
                                width: 48,
                                height: 48,
                                errorBuilder: (context, error, stackTrace) {
                                  return const Icon(
                                    Icons.agriculture,
                                    size: 48,
                                    color: Colors.green,
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        destinations: _navConfigs.map((config) {
                          return NavigationRailDestination(
                            icon: Icon(config.icon),
                            selectedIcon: Icon(config.selectedIcon),
                            label: Text(config.label),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                // Main content area
                Expanded(
                  child: _navConfigs[_selectedIndex].screen,
                ),
              ],
            ),

            // BottomNavigationBar for mobile only
            bottomNavigationBar: isTablet ? null : Container(
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
                destinations: _navConfigs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final config = entry.value;
                  return NavDestinationItem(
                    icon: config.icon,
                    selectedIcon: config.selectedIcon,
                    label: config.label,
                    isSelected: _selectedIndex == index,
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }
}