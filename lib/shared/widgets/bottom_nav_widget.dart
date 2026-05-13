import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/route_constants.dart';

class _NavItem {
  const _NavItem({required this.label, required this.route, required this.icon, required this.activeIcon});
  final String label;
  final String route;
  final IconData icon;
  final IconData activeIcon;
}

class BottomNavWidget extends StatelessWidget {
  const BottomNavWidget({super.key, required this.child});
  final Widget child;

  static const List<_NavItem> _items = [
    _NavItem(label: 'Home',   route: RouteConstants.home,    icon: Icons.home_rounded,       activeIcon: Icons.home_rounded),
    _NavItem(label: 'Plants', route: RouteConstants.plants,  icon: Icons.eco_rounded,         activeIcon: Icons.eco_rounded),
    _NavItem(label: 'Space',  route: RouteConstants.space,   icon: Icons.rocket_launch_rounded, activeIcon: Icons.rocket_launch_rounded),
    _NavItem(label: 'Profile',route: RouteConstants.profile, icon: Icons.person_rounded,       activeIcon: Icons.person_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final currentLocation = GoRouterState.of(context).uri.toString();
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = _getSelectedIndex(currentLocation) == index;

              return InkWell(
                onTap: () => context.go(item.route),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSelected ? item.activeIcon : item.icon,
                        color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.label,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  int _getSelectedIndex(String location) {
    if (location == RouteConstants.home)             return 0;
    if (location.startsWith(RouteConstants.plants))  return 1;
    if (location.startsWith(RouteConstants.space))   return 2;
    if (location.startsWith(RouteConstants.profile)) return 3;
    return 0;
  }
}
