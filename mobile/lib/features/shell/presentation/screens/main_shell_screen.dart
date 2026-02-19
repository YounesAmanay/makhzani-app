/// Main Shell Screen
///
/// Bottom navigation shell that contains all main app screens.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hugeicons/hugeicons.dart';

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
      bottomNavigationBar: _BottomNav(
        currentIndex: currentIndex,
        isDark: isDark,
        onTap: (index) => ref.read(bottomNavIndexProvider.notifier).state = index,
        items: [
          _NavItem(icon: HugeIcons.strokeRoundedDashboardSquare01, labelBuilder: (ctx) => ctx.l10n.nav_dashboard),
          _NavItem(icon: HugeIcons.strokeRoundedPackage, labelBuilder: (ctx) => ctx.l10n.nav_products),
          _NavItem(icon: HugeIcons.strokeRoundedUserMultiple, labelBuilder: (ctx) => ctx.l10n.nav_suppliers),
          _NavItem(icon: HugeIcons.strokeRoundedInvoice02, labelBuilder: (ctx) => ctx.l10n.nav_orders),
        ],
      ),
    );
  }
}

class _NavItem {
  final List<List<dynamic>> icon;
  final String Function(BuildContext) labelBuilder;

  const _NavItem({
    required this.icon,
    required this.labelBuilder,
  });
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final bool isDark;
  final ValueChanged<int> onTap;
  final List<_NavItem> items;

  const _BottomNav({
    required this.currentIndex,
    required this.isDark,
    required this.onTap,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final bgColor = isDark ? const Color(0xFF171723) : Colors.white;
    final activeColor = AppColors.primary;
    final inactiveColor = isDark ? const Color(0xFF5A5A70) : AppColors.iconSecondary;
    final borderColor = isDark ? const Color(0xFF252535) : AppColors.border;

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        border: Border(
          top: BorderSide(color: borderColor, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isActive = index == currentIndex;
              final label = item.labelBuilder(context);
              final color = isActive ? activeColor : inactiveColor;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HugeIcon(
                        icon: item.icon,
                        color: color,
                        size: AppDimensions.iconMedium,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                          color: color,
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
