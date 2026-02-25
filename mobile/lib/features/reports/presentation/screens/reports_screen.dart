/// Reports Screen
///
/// Tab container: Sales / Products / Inventory reports.
/// Pushed from the Dashboard as a full screen.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/localization/l10n_extension.dart';
import '../../../../../core/theme/app_colors.dart';
import 'sales_report_screen.dart';
import 'products_report_screen.dart';
import 'inventory_report_screen.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.reports_title),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          tabs: [
            Tab(text: context.l10n.reports_sales),
            Tab(text: context.l10n.reports_products),
            Tab(text: context.l10n.reports_inventory),
          ],
        ),
      ),
      body: Container(
        color: AppColors.background,
        child: TabBarView(
          controller: _tabController,
          children: const [
            SalesReportScreen(),
            ProductsReportScreen(),
            InventoryReportScreen(),
          ],
        ),
      ),
    );
  }
}
