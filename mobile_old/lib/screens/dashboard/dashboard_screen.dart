import 'package:flutter/material.dart';
import '../products/products_screen.dart';
import '../suppliers/suppliers_screen.dart';
import '../orders/orders_screen.dart';
import '../orders/create_order_screen.dart';
import '../auth/login_screen.dart';
import '../../services/api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    try {
      final response = await ApiService.getDashboardStats();
      if (response['success'] == true) {
        setState(() {
          _stats = response['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      // If API fails, use fallback data
      setState(() {
        _stats = {
          'total_products': 0,
          'low_stock_products': 0,
          'total_suppliers': 0,
          'total_orders': 0,
        };
        _isLoading = false;
      });
    }
  }

  Future<void> _handleLogout() async {
    // Show confirmation dialog
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Logout',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(AppConstants.textDark),
          ),
        ),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Color(AppConstants.textGray)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: const Color(AppConstants.textGray),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(
              backgroundColor: const Color(AppConstants.errorColor).withValues(alpha: 0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Logout',
              style: TextStyle(
                color: Color(AppConstants.errorColor),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && mounted) {
      // Perform logout
      await _authService.logout();

      // Navigate to login screen and clear navigation stack
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  void _showMenu() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Settings Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.paleGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  color: Color(AppConstants.primaryGreen),
                  size: 24,
                ),
              ),
              title: const Text(
                'Settings',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textDark),
                ),
              ),
              subtitle: const Text(
                'App preferences and configuration',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(AppConstants.textLight),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to settings screen
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Settings screen coming soon'),
                    backgroundColor: Color(AppConstants.primaryGreen),
                  ),
                );
              },
            ),

            const Divider(height: 1),

            // Logout Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.errorColor).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(AppConstants.errorColor),
                  size: 24,
                ),
              ),
              title: const Text(
                'Logout',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.errorColor),
                ),
              ),
              subtitle: const Text(
                'Sign out of your account',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(AppConstants.textLight),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _handleLogout();
              },
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.background),
      appBar: AppBar(
        backgroundColor: const Color(AppConstants.primaryGreen),
        elevation: 0,
        title: const Text(
          'Makhzani',
          style: TextStyle(
            color: Color(AppConstants.white),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: Color(AppConstants.white),
            ),
            onPressed: _showMenu,
            tooltip: 'Menu',
          ),
        ],
      ),
      body: RefreshIndicator(
        color: const Color(AppConstants.primaryGreen),
        onRefresh: _loadDashboardStats,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section - Simple
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.paleGreen),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.inventory_2_rounded,
                      color: Color(AppConstants.primaryGreen),
                      size: 24,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(AppConstants.textDark),
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Manage your inventory',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(AppConstants.textGray),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Stats Section Header
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textDark),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Stats
              _isLoading
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child: CircularProgressIndicator(
                          color: Color(AppConstants.primaryGreen),
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Products',
                                '${_stats?['total_products'] ?? 0}',
                                Icons.inventory_2_rounded,
                                const Color(AppConstants.primaryGreen),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                'Low Stock',
                                '${_stats?['low_stock_products'] ?? 0}',
                                Icons.warning_rounded,
                                const Color(AppConstants.warningColor),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Suppliers',
                                '${_stats?['total_suppliers'] ?? 0}',
                                Icons.people_rounded,
                                const Color(0xFF8B5CF6), // Purple
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _buildStatCard(
                                'Orders',
                                '${_stats?['total_orders'] ?? 0}',
                                Icons.receipt_long_rounded,
                                const Color(0xFF3B82F6), // Blue
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

              const SizedBox(height: 20),

              // Quick Actions Header
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textDark),
                ),
              ),
              const SizedBox(height: 12),

              // Quick Actions Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.3,
                children: [
                  _buildActionCard(
                    'View Inventory',
                    Icons.inventory_2_rounded,
                    const Color(AppConstants.primaryGreen),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ProductsScreen()),
                    ),
                  ),
                  _buildActionCard(
                    'Create Order',
                    Icons.add_shopping_cart_rounded,
                    const Color(0xFF3B82F6), // Blue
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
                    ),
                  ),
                  _buildActionCard(
                    'Suppliers',
                    Icons.people_rounded,
                    const Color(0xFF8B5CF6), // Purple
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SuppliersScreen()),
                    ),
                  ),
                  _buildActionCard(
                    'Order History',
                    Icons.history_rounded,
                    const Color(AppConstants.warningColor),
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const OrdersScreen()),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(AppConstants.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(AppConstants.textLight).withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(AppConstants.textDark),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: Color(AppConstants.textGray),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(AppConstants.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(AppConstants.textLight).withValues(alpha: 0.15),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: Color(AppConstants.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }
}