/// Main Shell Screen
///
/// Bottom navigation shell that contains all main app screens.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../../../dashboard/presentation/screens/dashboard_screen.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../products/presentation/screens/products_screen.dart';
import '../../../suppliers/presentation/screens/suppliers_screen.dart';
import '../providers/navigation_provider.dart';

class MainShellScreen extends ConsumerWidget {
  const MainShellScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: const [
          DashboardScreen(),
          ProductsScreen(),
          SuppliersScreen(),
          OrdersScreen(),
        ],
      ),
      bottomNavigationBar: _FloatingPillNav(
        currentIndex: currentIndex,
        isDark: isDark,
        onTap: (index) => ref.read(bottomNavIndexProvider.notifier).state = index,
        items: [
          _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, labelBuilder: (ctx) => ctx.l10n.nav_dashboard),
          _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, labelBuilder: (ctx) => ctx.l10n.nav_products),
          _NavItem(icon: Icons.people_outline, activeIcon: Icons.people, labelBuilder: (ctx) => ctx.l10n.nav_suppliers),
          _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, labelBuilder: (ctx) => ctx.l10n.nav_orders),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String Function(BuildContext) labelBuilder;

  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.labelBuilder,
  });
}

class _FloatingPillNav extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _FloatingPillNav({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    // Pill background: dark card in dark mode, white card in light mode
    final pillColor = isDark ? const Color(0xFF171723) : Colors.white;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? const Color(0xFF5A5A70) : AppColors.iconSecondary;
    final activeBg = AppColors.primary.withValues(alpha: 0.12);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.paddingMedium,
          0,
          AppDimensions.paddingMedium,
          AppDimensions.paddingSmall,
        ),
        child: Container(
          height: 64,
          decoration: BoxDecoration(
            color: pillColor,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.1),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              final label = item.labelBuilder(context);

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeInOut,
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingSmall,
                          vertical: AppDimensions.paddingXSmall,
                        ),
                        decoration: isActive
                            ? BoxDecoration(
                                color: activeBg,
                                borderRadius: BorderRadius.circular(AppDimensions.radiusSmall),
                              )
                            : null,
                        child: Icon(
                          isActive ? item.activeIcon : item.icon,
                          color: isActive ? activeColor : inactiveColor,
                          size: AppDimensions.iconMedium,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: isActive ? activeColor : inactiveColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
