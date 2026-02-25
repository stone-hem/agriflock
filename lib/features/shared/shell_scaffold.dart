import 'package:agriflock360/core/model/user_model.dart';
import 'package:agriflock360/core/utils/secure_storage.dart';
import 'package:agriflock360/features/shared/nav_destination_item.dart';
import 'package:agriflock360/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class ShellScaffold extends StatefulWidget {
  final Widget child;
  const ShellScaffold({super.key, required this.child});

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold> {
  String? _userRole;
  bool _isLoading = true;
  late List<NavConfig> _navConfigs;

  static const List<NavConfig> _farmerNavConfigs = [
    NavConfig(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      route: '/home',
    ),
    NavConfig(
      icon: Icons.agriculture_outlined,
      selectedIcon: Icons.agriculture,
      label: 'Farms',
      route: '/farms',
    ),
    NavConfig(
      icon: Icons.format_quote_outlined,
      selectedIcon: Icons.format_quote,
      label: 'Quotation',
      route: '/quotation',
    ),
    NavConfig(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Vets',
      route: '/browse-vets',
    ),
    NavConfig(
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      label: 'Profile',
      route: '/farmer-profile',
    ),
  ];

  static const List<NavConfig> _farmerSubscribedNavConfigs = [
    NavConfig(
      icon: Icons.format_quote_outlined,
      selectedIcon: Icons.format_quote,
      label: 'Quotation',
      route: '/quotation',
    ),
    NavConfig(
      icon: Icons.people_outline,
      selectedIcon: Icons.people,
      label: 'Vets',
      route: '/browse-vets',
    ),
    NavConfig(
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      label: 'Profile',
      route: '/farmer-profile',
    ),
  ];

  static const List<NavConfig> _vetNavConfigs = [
    NavConfig(
      icon: Icons.home_outlined,
      selectedIcon: Icons.home,
      label: 'Home',
      route: '/vet-home',
    ),
    NavConfig(
      icon: Icons.schedule_outlined,
      selectedIcon: Icons.schedule,
      label: 'Schedules',
      route: '/vet-schedules',
    ),
    NavConfig(
      icon: Icons.payment_outlined,
      selectedIcon: Icons.payment,
      label: 'Payments',
      route: '/vet-payments-tab',
    ),
    NavConfig(
      icon: Icons.person_outlined,
      selectedIcon: Icons.person,
      label: 'Profile',
      route: '/vet-profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUserRole();
  }

  Future<void> _loadUserRole() async {
    try {
      final User? userData = await secureStorage.getUserData();
      final String? subscriptionState = await secureStorage.getSubscriptionState();
      final bool isSubscribed = subscriptionState == 'true';

      if (!mounted) return;

      setState(() {
        _userRole = userData?.role.name.toLowerCase() ?? 'farmer';

        if (_userRole == 'extension_officer') {
          _navConfigs = _vetNavConfigs;
        } else {
          _navConfigs = isSubscribed ? _farmerSubscribedNavConfigs : _farmerNavConfigs;
        }

        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _userRole = 'farmer';
        _navConfigs = _farmerNavConfigs;
        _isLoading = false;
      });
    }
  }

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _navConfigs.length; i++) {
      if (location.startsWith(_navConfigs[i].route)) {
        return i;
      }
    }
    return 0;
  }

  void _onItemTapped(int index) {
    context.go(_navConfigs[index].route);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final selectedIndex = _calculateSelectedIndex(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

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
          final isTablet =
              constraints.maxWidth >= 600 || constraints.maxHeight < 500;

          return Scaffold(
            body: Row(
              children: [
                if (isTablet)
                  Container(
                    width: 72,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border(
                        right: BorderSide(
                          color: Colors.grey.shade200,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Image.asset(
                            'assets/logos/Logo_0725.png',
                            width: 40,
                            height: 40,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.agriculture,
                                size: 40,
                                color: Theme.of(context).primaryColor,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Column(
                              children:
                              _navConfigs.asMap().entries.map((entry) {
                                final index = entry.key;
                                final config = entry.value;
                                final isSelected = selectedIndex == index;
                                return InkWell(
                                  onTap: () => _onItemTapped(index),
                                  borderRadius: BorderRadius.circular(16),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                      horizontal: 8.0,
                                    ),
                                    child: AnimatedContainer(
                                      duration:
                                      const Duration(milliseconds: 200),
                                      width: 56,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.green
                                            .withValues(alpha: 0.15)
                                            : Colors.transparent,
                                        borderRadius:
                                        BorderRadius.circular(16),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            isSelected
                                                ? config.selectedIcon
                                                : config.icon,
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.shade600,
                                            size: 24,
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            config.label,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: isSelected
                                                  ? Theme.of(context)
                                                  .primaryColor
                                                  : Colors.grey.shade600,
                                            ),
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(child: widget.child),
              ],
            ),
            bottomNavigationBar: isTablet
                ? null
                : Container(
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
                selectedIndex: selectedIndex,
                onDestinationSelected: _onItemTapped,
                indicatorColor: Theme.of(context)
                    .primaryColor
                    .withValues(alpha: 0.15),
                backgroundColor: Colors.transparent,
                elevation: 0,
                height: 72,
                labelBehavior:
                NavigationDestinationLabelBehavior.alwaysShow,
                animationDuration: const Duration(milliseconds: 300),
                destinations:
                _navConfigs.asMap().entries.map((entry) {
                  final index = entry.key;
                  final config = entry.value;
                  return NavDestinationItem(
                    icon: config.icon,
                    selectedIcon: config.selectedIcon,
                    label: config.label,
                    isSelected: selectedIndex == index,
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