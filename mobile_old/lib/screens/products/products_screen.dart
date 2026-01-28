import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final _searchController = TextEditingController();
  bool _showLowStockOnly = false;
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getProducts(
        search: _searchController.text.isNotEmpty ? _searchController.text : null,
        lowStock: _showLowStockOnly ? true : null,
      );

      if (response['success'] == true) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response['data']['products']);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredProducts {
    List<Map<String, dynamic>> filtered = _products;

    if (_searchController.text.isNotEmpty) {
      filtered = filtered.where((product) =>
        product['name'].toLowerCase().contains(_searchController.text.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.background),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              color: const Color(AppConstants.white),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Row
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 22),
                        color: const Color(AppConstants.textDark),
                        onPressed: () => Navigator.pop(context),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Inventory',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.textDark),
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.add, size: 22),
                        color: const Color(AppConstants.primaryGreen),
                        onPressed: () => _showAddProductScreen(),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Search Bar
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: const Color(AppConstants.background),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: 'Search products',
                        hintStyle: const TextStyle(
                          color: Color(AppConstants.textLight),
                          fontSize: 14,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Color(AppConstants.textLight),
                          size: 20,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 18),
                                color: const Color(AppConstants.textLight),
                                onPressed: () {
                                  _searchController.clear();
                                  _loadProducts();
                                  setState(() {});
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onChanged: (value) {
                        Future.delayed(const Duration(milliseconds: 300), () {
                          if (_searchController.text == value) {
                            _loadProducts();
                          }
                        });
                        setState(() {});
                      },
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter & Count
                  Row(
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() => _showLowStockOnly = !_showLowStockOnly);
                          _loadProducts();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _showLowStockOnly
                                ? const Color(AppConstants.primaryGreen).withValues(alpha: 0.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _showLowStockOnly
                                  ? const Color(AppConstants.primaryGreen)
                                  : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _showLowStockOnly ? Icons.check_circle : Icons.circle_outlined,
                                size: 16,
                                color: _showLowStockOnly
                                    ? const Color(AppConstants.primaryGreen)
                                    : const Color(AppConstants.textLight),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Low stock',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: _showLowStockOnly ? FontWeight.w600 : FontWeight.normal,
                                  color: _showLowStockOnly
                                      ? const Color(AppConstants.primaryGreen)
                                      : const Color(AppConstants.textGray),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_filteredProducts.length} ${_filteredProducts.length == 1 ? 'product' : 'products'}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(AppConstants.textGray),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Divider
            Container(
              height: 1,
              color: const Color(AppConstants.textLight).withValues(alpha: 0.1),
            ),

            // Products List
            Expanded(
              child: RefreshIndicator(
                color: const Color(AppConstants.primaryGreen),
                onRefresh: _loadProducts,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(AppConstants.primaryGreen),
                          strokeWidth: 2,
                        ),
                      )
                    : _error != null
                        ? _buildErrorState()
                        : _filteredProducts.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                itemCount: _filteredProducts.length,
                                itemBuilder: (context, index) {
                                  final product = _filteredProducts[index];
                                  return _buildProductItem(product);
                                },
                              ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    final isLowStock = (product['current_stock'] ?? 0) <= (product['reorder_threshold'] ?? 0);
    final stock = product['current_stock'] ?? 0;
    final unit = product['unit'] ?? 'pc';
    final price = product['price'] ?? 0;

    return InkWell(
      onTap: () => _showProductActions(product),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(AppConstants.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'],
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isLowStock
                              ? const Color(AppConstants.errorColor).withValues(alpha: 0.08)
                              : const Color(AppConstants.primaryGreen).withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '$stock $unit',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isLowStock
                                ? const Color(AppConstants.errorColor)
                                : const Color(AppConstants.primaryGreen),
                          ),
                        ),
                      ),
                      if (isLowStock) ...[
                        const SizedBox(width: 8),
                        const Icon(
                          Icons.warning_rounded,
                          size: 14,
                          color: Color(AppConstants.errorColor),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$price MAD',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(AppConstants.textDark),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'per $unit',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(AppConstants.textLight),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_outlined,
            size: 80,
            color: const Color(AppConstants.textLight).withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No products yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(AppConstants.textGray),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Add your first product to get started',
            style: TextStyle(
              fontSize: 14,
              color: Color(AppConstants.textLight),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showAddProductScreen(),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(AppConstants.primaryGreen),
              foregroundColor: const Color(AppConstants.white),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Color(AppConstants.errorColor),
            ),
            const SizedBox(height: 16),
            const Text(
              'Failed to load products',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.textDark),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? 'Unknown error',
              style: const TextStyle(
                fontSize: 13,
                color: Color(AppConstants.textGray),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadProducts,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryGreen),
                foregroundColor: const Color(AppConstants.white),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showProductActions(Map<String, dynamic> product) {
    final isLowStock = (product['current_stock'] ?? 0) <= (product['reorder_threshold'] ?? 0);
    final stock = product['current_stock'] ?? 0;
    final threshold = product['reorder_threshold'] ?? 0;
    final unit = product['unit'] ?? 'pc';
    final price = product['price'] ?? 0;
    final barcode = product['barcode'];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(AppConstants.white),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Scrollable content
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Header
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(AppConstants.textDark),
                              ),
                            ),
                            if (barcode != null) ...[
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.qr_code_rounded,
                                    size: 16,
                                    color: Color(AppConstants.textLight),
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    barcode,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(AppConstants.textGray),
                                      fontFamily: 'monospace',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Stock Status Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isLowStock
                                ? const Color(AppConstants.errorColor).withValues(alpha: 0.08)
                                : const Color(AppConstants.paleGreen),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isLowStock
                                  ? const Color(AppConstants.errorColor).withValues(alpha: 0.2)
                                  : const Color(AppConstants.primaryGreen).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isLowStock
                                      ? const Color(AppConstants.errorColor)
                                      : const Color(AppConstants.primaryGreen),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  isLowStock ? Icons.warning_rounded : Icons.check_circle_rounded,
                                  color: const Color(AppConstants.white),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isLowStock ? 'Low Stock Alert' : 'Stock Level Good',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: isLowStock
                                            ? const Color(AppConstants.errorColor)
                                            : const Color(AppConstants.primaryGreen),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$stock $unit available',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                        color: Color(AppConstants.textDark),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Details Grid
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(AppConstants.background),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildDetailRow(
                                icon: Icons.inventory_2_outlined,
                                label: 'Current Stock',
                                value: '$stock $unit',
                                valueColor: const Color(AppConstants.textDark),
                              ),
                              const Divider(height: 24),
                              _buildDetailRow(
                                icon: Icons.refresh_rounded,
                                label: 'Reorder Threshold',
                                value: '$threshold $unit',
                                valueColor: const Color(AppConstants.warningColor),
                              ),
                              const Divider(height: 24),
                              _buildDetailRow(
                                icon: Icons.sell_outlined,
                                label: 'Price',
                                value: '$price MAD',
                                valueColor: const Color(AppConstants.primaryGreen),
                              ),
                              const Divider(height: 24),
                              _buildDetailRow(
                                icon: Icons.category_outlined,
                                label: 'Unit',
                                value: unit,
                                valueColor: const Color(AppConstants.textDark),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Actions Header
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'Actions',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(AppConstants.textGray),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Action Buttons
                      _buildActionButton(
                        icon: Icons.edit_outlined,
                        label: 'Adjust Stock',
                        subtitle: 'Add or remove stock',
                        onTap: () {
                          Navigator.pop(context);
                          _showStockAdjustmentScreen(product);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.edit,
                        label: 'Edit Product',
                        subtitle: 'Update product details',
                        onTap: () {
                          Navigator.pop(context);
                          _showEditProductScreen(product);
                        },
                      ),
                      _buildActionButton(
                        icon: Icons.delete_outline,
                        label: 'Delete Product',
                        subtitle: 'Remove from inventory',
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(product);
                        },
                        isDestructive: true,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(AppConstants.textLight),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Color(AppConstants.textGray),
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    String? subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? const Color(AppConstants.errorColor).withValues(alpha: 0.1)
                    : const Color(AppConstants.primaryGreen).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 20,
                color: isDestructive
                    ? const Color(AppConstants.errorColor)
                    : const Color(AppConstants.primaryGreen),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDestructive
                          ? const Color(AppConstants.errorColor)
                          : const Color(AppConstants.textDark),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(AppConstants.textLight),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: const Color(AppConstants.textLight),
            ),
          ],
        ),
      ),
    );
  }

  // FULL SCREEN MODALS

  void _showAddProductScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ProductFormScreen(
          title: 'Add Product',
          existingProducts: _products, // Pass existing products for duplicate check
          onSave: (name, stock, threshold, unit, price, barcode) async {
            await _createProduct(name, stock, threshold, unit, price);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showEditProductScreen(Map<String, dynamic> product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _ProductFormScreen(
          title: 'Edit Product',
          product: product,
          existingProducts: _products, // Pass existing products for duplicate check
          onSave: (name, stock, threshold, unit, price, barcode) async {
            await _updateProduct(product['id'], name, stock, threshold, unit, price, barcode);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showStockAdjustmentScreen(Map<String, dynamic> product) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _StockAdjustmentScreen(
          product: product,
          onAdjust: (adjustment) {
            _adjustStock(product['id'], adjustment);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Product',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        content: Text(
          'Delete "${product['name']}"? This action cannot be undone.',
          style: const TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(AppConstants.textGray)),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: const Color(AppConstants.errorColor),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              _deleteProduct(product['id']);
              Navigator.pop(context);
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Color(AppConstants.white)),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createProduct(String name, int currentStock, int reorderThreshold, String unit, double? price) async {
    try {
      await ApiService.createProduct(
        name: name,
        currentStock: currentStock,
        reorderThreshold: reorderThreshold,
        unit: unit,
        price: price,
      );
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product added successfully'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error but DON'T close the form - user data is preserved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add product: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(AppConstants.errorColor),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow; // Prevent form from closing
    }
  }

  Future<void> _updateProduct(
    String productId,
    String name,
    int currentStock,
    int reorderThreshold,
    String unit,
    double? price,
    String? barcode,
  ) async {
    try {
      await ApiService.updateProduct(
        productId: productId,
        name: name,
        currentStock: currentStock,
        reorderThreshold: reorderThreshold,
        unit: unit,
        price: price,
        barcode: barcode,
      );
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Product updated successfully'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Show error but DON'T close the form - user data is preserved
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update product: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(AppConstants.errorColor),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow; // Prevent form from closing
    }
  }

  Future<void> _adjustStock(String productId, int adjustment) async {
    try {
      await ApiService.adjustStock(productId, adjustment);
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stock adjusted by $adjustment')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  Future<void> _deleteProduct(String productId) async {
    try {
      await ApiService.deleteProduct(productId);
      _loadProducts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product deleted')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

// FULL SCREEN PRODUCT FORM
class _ProductFormScreen extends StatefulWidget {
  final String title;
  final Map<String, dynamic>? product;
  final List<Map<String, dynamic>> existingProducts;
  final Future<void> Function(String name, int stock, int threshold, String unit, double? price, String? barcode) onSave;

  const _ProductFormScreen({
    required this.title,
    this.product,
    required this.existingProducts,
    required this.onSave,
  });

  @override
  State<_ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<_ProductFormScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _stockController;
  late final TextEditingController _thresholdController;
  late final TextEditingController _priceController;
  late final TextEditingController _barcodeController;
  late String _selectedUnit;

  // Validation errors
  String? _nameError;
  String? _stockError;
  String? _thresholdError;
  String? _priceError;
  String? _barcodeError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?['name'] ?? '');
    _stockController = TextEditingController(text: widget.product?['current_stock']?.toString() ?? '');
    _thresholdController = TextEditingController(text: widget.product?['reorder_threshold']?.toString() ?? '5');
    _priceController = TextEditingController(text: widget.product?['price']?.toString() ?? '');
    _barcodeController = TextEditingController(text: widget.product?['barcode'] ?? '');
    _selectedUnit = widget.product?['unit'] ?? 'piece';

    // Add listeners for real-time validation
    _nameController.addListener(_validateName);
    _stockController.addListener(_validateStock);
    _thresholdController.addListener(_validateThreshold);
    _priceController.addListener(_validatePrice);
    _barcodeController.addListener(_validateBarcode);
  }

  void _validateName() {
    final name = _nameController.text.trim();

    // Basic validation first
    if (name.isEmpty) {
      setState(() => _nameError = 'Product name is required');
      return;
    } else if (name.length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
      return;
    } else if (name.length > 100) {
      setState(() => _nameError = 'Name must not exceed 100 characters');
      return;
    }

    // Check for duplicates locally (instant, no API call!)
    if (widget.product == null || name.toLowerCase() != widget.product!['name'].toLowerCase()) {
      final duplicate = widget.existingProducts.any((p) =>
        p['name'].toLowerCase() == name.toLowerCase() &&
        (widget.product == null || p['id'] != widget.product!['id'])
      );

      setState(() {
        _nameError = duplicate ? 'A product with this name already exists' : null;
      });
    } else {
      setState(() {
        _nameError = null;
      });
    }
  }

  void _validateStock() {
    setState(() {
      final stock = _stockController.text.trim();
      if (stock.isEmpty) {
        _stockError = null; // Optional field
      } else {
        final stockValue = int.tryParse(stock);
        if (stockValue == null) {
          _stockError = 'Must be a valid number';
        } else if (stockValue < 0) {
          _stockError = 'Stock cannot be negative';
        } else {
          _stockError = null;
        }
      }
    });
  }

  void _validateThreshold() {
    setState(() {
      final threshold = _thresholdController.text.trim();
      if (threshold.isEmpty) {
        _thresholdError = null; // Will use default
      } else {
        final thresholdValue = int.tryParse(threshold);
        if (thresholdValue == null) {
          _thresholdError = 'Must be a valid number';
        } else if (thresholdValue < 0) {
          _thresholdError = 'Cannot be negative';
        } else {
          _thresholdError = null;
        }
      }
    });
  }

  void _validatePrice() {
    setState(() {
      final price = _priceController.text.trim();
      if (price.isEmpty) {
        _priceError = null; // Optional field
      } else {
        final priceValue = double.tryParse(price);
        if (priceValue == null) {
          _priceError = 'Must be a valid number';
        } else if (priceValue < 0) {
          _priceError = 'Price cannot be negative';
        } else if (priceValue.toString().split('.').length > 1 &&
            priceValue.toString().split('.')[1].length > 2) {
          _priceError = 'Max 2 decimal places';
        } else {
          _priceError = null;
        }
      }
    });
  }

  void _validateBarcode() {
    setState(() {
      final barcode = _barcodeController.text.trim();
      if (barcode.isEmpty) {
        _barcodeError = null; // Optional field
      } else if (barcode.length < 8) {
        _barcodeError = 'Barcode must be at least 8 characters';
      } else if (barcode.length > 50) {
        _barcodeError = 'Barcode must not exceed 50 characters';
      } else {
        _barcodeError = null;
      }
    });
  }

  bool get _hasErrors {
    return _nameError != null ||
        _stockError != null ||
        _thresholdError != null ||
        _priceError != null ||
        _barcodeError != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.background),
      appBar: AppBar(
        backgroundColor: const Color(AppConstants.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(AppConstants.textDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Color(AppConstants.textDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _hasErrors || _nameController.text.trim().isEmpty ? null : _save,
            child: Text(
              'Save',
              style: TextStyle(
                color: _hasErrors || _nameController.text.trim().isEmpty
                    ? const Color(AppConstants.textLight)
                    : const Color(AppConstants.primaryGreen),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Name
            const Text(
              'Product Information',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.textDark),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _nameController,
              label: 'Product Name',
              hint: 'e.g. Tomatoes, Bread, Milk',
              errorText: _nameError,
            ),
            const SizedBox(height: 16),

            // Stock & Unit
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildTextField(
                    controller: _stockController,
                    label: 'Current Stock',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    errorText: _stockError,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildUnitDropdown(),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Reorder Settings
            const Text(
              'Reorder Settings',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.textDark),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _thresholdController,
              label: 'Reorder Threshold',
              hint: '5',
              helperText: 'Get notified when stock falls below this level',
              keyboardType: TextInputType.number,
              errorText: _thresholdError,
            ),
            const SizedBox(height: 24),

            // Pricing
            const Text(
              'Pricing',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.textDark),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _priceController,
              label: 'Price (MAD)',
              hint: '0.00',
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              errorText: _priceError,
            ),
            const SizedBox(height: 24),

            // Optional
            const Text(
              'Optional',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.textDark),
              ),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _barcodeController,
              label: 'Barcode',
              hint: 'Scan or enter barcode',
              errorText: _barcodeError,
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? helperText,
    String? errorText,
    TextInputType? keyboardType,
    bool isLoading = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(AppConstants.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          helperText: helperText,
          errorText: errorText,
          helperStyle: const TextStyle(fontSize: 12, color: Color(AppConstants.textLight)),
          errorStyle: const TextStyle(fontSize: 12, color: Color(AppConstants.errorColor)),
          labelStyle: const TextStyle(fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          suffixIcon: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(AppConstants.primaryGreen),
                    ),
                  ),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(AppConstants.textLight).withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorText != null
                  ? const Color(AppConstants.errorColor)
                  : const Color(AppConstants.textLight).withValues(alpha: 0.2),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: errorText != null
                  ? const Color(AppConstants.errorColor)
                  : const Color(AppConstants.primaryGreen),
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(AppConstants.errorColor)),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(AppConstants.errorColor), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildUnitDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(AppConstants.white),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonFormField<String>(
        initialValue: _selectedUnit,
        decoration: InputDecoration(
          labelText: 'Unit',
          labelStyle: const TextStyle(fontSize: 14),
          floatingLabelBehavior: FloatingLabelBehavior.always,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(AppConstants.textLight).withValues(alpha: 0.3)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: const Color(AppConstants.textLight).withValues(alpha: 0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(AppConstants.primaryGreen), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
        items: ['piece', 'kg', 'liter', 'box', 'bottle']
            .map((unit) => DropdownMenuItem(value: unit, child: Text(unit)))
            .toList(),
        onChanged: (value) => setState(() => _selectedUnit = value!),
      ),
    );
  }

  void _save() async {
    // Validation is already done inline, just save
    try {
      await widget.onSave(
        _nameController.text.trim(),
        int.tryParse(_stockController.text) ?? 0,
        int.tryParse(_thresholdController.text) ?? 5,
        _selectedUnit,
        double.tryParse(_priceController.text),
        _barcodeController.text.trim().isEmpty ? null : _barcodeController.text.trim(),
      );
      // Only close if successful
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      // Error is already shown by the parent, form stays open with data preserved
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _stockController.dispose();
    _thresholdController.dispose();
    _priceController.dispose();
    _barcodeController.dispose();
    super.dispose();
  }
}

// FULL SCREEN STOCK ADJUSTMENT
class _StockAdjustmentScreen extends StatefulWidget {
  final Map<String, dynamic> product;
  final Function(int) onAdjust;

  const _StockAdjustmentScreen({
    required this.product,
    required this.onAdjust,
  });

  @override
  State<_StockAdjustmentScreen> createState() => _StockAdjustmentScreenState();
}

class _StockAdjustmentScreenState extends State<_StockAdjustmentScreen> {
  final _controller = TextEditingController();
  int _adjustment = 0;

  @override
  Widget build(BuildContext context) {
    final currentStock = widget.product['current_stock'] ?? 0;
    final unit = widget.product['unit'] ?? 'pc';
    final newStock = currentStock + _adjustment;

    return Scaffold(
      backgroundColor: const Color(AppConstants.background),
      appBar: AppBar(
        backgroundColor: const Color(AppConstants.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Color(AppConstants.textDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Adjust Stock',
          style: TextStyle(
            color: Color(AppConstants.textDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(AppConstants.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product['name'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Current Stock: $currentStock $unit',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(AppConstants.textGray),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Adjustment Input
            const Text(
              'Adjustment',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.textDark),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: const Color(AppConstants.white),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _controller,
                keyboardType: const TextInputType.numberWithOptions(signed: true),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '+10 or -5',
                  hintStyle: const TextStyle(
                    fontSize: 20,
                    color: Color(AppConstants.textLight),
                    fontWeight: FontWeight.w500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(AppConstants.textLight).withValues(alpha: 0.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: const Color(AppConstants.textLight).withValues(alpha: 0.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(AppConstants.primaryGreen), width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                ),
                onChanged: (value) {
                  setState(() {
                    _adjustment = int.tryParse(value) ?? 0;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.textDark),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildQuickAction('+10', 10),
                const SizedBox(width: 12),
                _buildQuickAction('+50', 50),
                const SizedBox(width: 12),
                _buildQuickAction('-10', -10),
                const SizedBox(width: 12),
                _buildQuickAction('-50', -50),
              ],
            ),
            const SizedBox(height: 32),

            // New Stock Preview
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _adjustment >= 0
                    ? const Color(AppConstants.paleGreen)
                    : const Color(AppConstants.errorColor).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'New Stock',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                  Text(
                    '$newStock $unit',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: _adjustment >= 0
                          ? const Color(AppConstants.primaryGreen)
                          : const Color(AppConstants.errorColor),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Save Button
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _adjustment != 0
                    ? () {
                        widget.onAdjust(_adjustment);
                        Navigator.pop(context);
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(AppConstants.primaryGreen),
                  foregroundColor: const Color(AppConstants.white),
                  disabledBackgroundColor: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Adjustment',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(String label, int value) {
    return Expanded(
      child: InkWell(
        onTap: () {
          _controller.text = value.toString();
          setState(() => _adjustment = value);
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(AppConstants.white),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(AppConstants.textDark),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}