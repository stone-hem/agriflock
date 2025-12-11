import 'package:flutter/material.dart';

class NavDestinationItem extends StatelessWidget {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool isSelected;

  const NavDestinationItem({
    super.key,
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationDestination(
      icon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green.withValues(alpha: 0.1)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.green : Colors.grey.shade600,
          size: 24,
        ),
      ),
      selectedIcon: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(
          selectedIcon,
          color: Colors.green,
          size: 24,
        ),
      ),
      label: label,
    );
  }
}

// Navigation configuration model
class NavConfig {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Widget screen;

  const NavConfig({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.screen,
  });
}