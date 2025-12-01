import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _notesController = TextEditingController();
  bool _isLoading = false;
  bool _isSuppliersLoading = true;
  bool _isProductsLoading = false;

  List<Map<String, dynamic>> _suppliers = [];
  List<Map<String, dynamic>> _products = [];
  final List<Map<String, dynamic>> _orderItems = [];

  Map<String, dynamic>? _selectedSupplier;
  String? _suppliersError;
  String? _productsError;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      _isSuppliersLoading = true;
      _suppliersError = null;
    });

    try {
      final response = await ApiService.getSuppliers();
      if (response['success'] == true) {
        setState(() {
          _suppliers = List<Map<String, dynamic>>.from(response['data']['suppliers']);
          _isSuppliersLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _suppliersError = e.toString();
        _isSuppliersLoading = false;
      });
    }
  }

  Future<void> _loadProducts() async {
    setState(() {
      _isProductsLoading = true;
      _productsError = null;
    });

    try {
      final response = await ApiService.getProducts();
      if (response['success'] == true) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(response['data']['products']);
          _isProductsLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _productsError = e.toString();
        _isProductsLoading = false;
      });
    }
  }

  void _addOrderItem() {
    if (_products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Loading products...'),
          backgroundColor: Color(AppConstants.warningColor),
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _AddOrderItemScreen(
          products: _products,
          onProductSelected: (product, quantity, unitPrice) async {
            setState(() {
              _orderItems.add({
                'product_id': product['id'],
                'product': product,
                'quantity': quantity,
                'unit_price': unitPrice,
                'total_price': quantity * unitPrice,
              });
            });
            Navigator.pop(context);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _removeOrderItem(int index) {
    setState(() {
      _orderItems.removeAt(index);
    });
  }

  double get _totalAmount {
    return _orderItems.fold(0.0, (sum, item) => sum + (item['total_price'] ?? 0.0));
  }

  Future<void> _createOrder() async {
    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a supplier'),
          backgroundColor: Color(AppConstants.errorColor),
        ),
      );
      return;
    }

    if (_orderItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one item'),
          backgroundColor: Color(AppConstants.errorColor),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final items = _orderItems.map((item) => {
        'product_id': item['product_id'],
        'quantity': item['quantity'],
        'unit_price': item['unit_price'],
      }).toList();

      await ApiService.createOrder(
        supplierId: _selectedSupplier!['id'],
        items: items,
        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order created successfully'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create order: $e'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: const Icon(
                        Icons.arrow_back_rounded,
                        color: Color(AppConstants.textDark),
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Create Order',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.textDark),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Supplier selection
                    const Text(
                      'Select Supplier',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.textDark),
                      ),
                    ),
                    const SizedBox(height: 12),

                    if (_isSuppliersLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: Color(AppConstants.primaryGreen),
                          ),
                        ),
                      )
                    else if (_suppliersError != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.errorColor).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Error: $_suppliersError',
                              style: const TextStyle(
                                color: Color(AppConstants.errorColor),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadSuppliers,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.white),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(AppConstants.textLight).withAlpha(51),
                          ),
                        ),
                        child: DropdownButton<Map<String, dynamic>>(
                          value: _selectedSupplier,
                          hint: const Text('Choose a supplier'),
                          isExpanded: true,
                          underline: const SizedBox(),
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Color(AppConstants.textGray),
                            size: 20,
                          ),
                          items: _suppliers.map((supplier) {
                            return DropdownMenuItem(
                              value: supplier,
                              child: Text(
                                supplier['business_name'] != null
                                    ? '${supplier['name']} (${supplier['business_name']})'
                                    : supplier['name'],
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (supplier) {
                            setState(() => _selectedSupplier = supplier);
                            if (_products.isEmpty) {
                              _loadProducts();
                            }
                          },
                        ),
                      ),

                    const SizedBox(height: 24),

                    // Order items
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Order Items',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(AppConstants.textDark),
                          ),
                        ),
                        InkWell(
                          onTap: _selectedSupplier != null && !_isProductsLoading ? _addOrderItem : null,
                          borderRadius: BorderRadius.circular(6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedSupplier != null && !_isProductsLoading
                                  ? const Color(AppConstants.primaryGreen)
                                  : const Color(AppConstants.textLight),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add_rounded, size: 16, color: Color(AppConstants.white)),
                                SizedBox(width: 4),
                                Text(
                                  'Add Item',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Color(AppConstants.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    if (_isProductsLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(
                            color: Color(AppConstants.primaryGreen),
                          ),
                        ),
                      )
                    else if (_productsError != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.errorColor).withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              'Error: $_productsError',
                              style: const TextStyle(
                                color: Color(AppConstants.errorColor),
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: _loadProducts,
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    else if (_orderItems.isEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Column(
                          children: [
                            Icon(
                              Icons.shopping_cart_outlined,
                              size: 48,
                              color: Color(AppConstants.textLight),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No items added yet',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(AppConstants.textGray),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      Column(
                        children: _orderItems.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return _buildOrderItemCard(item, index);
                        }).toList(),
                      ),

                    const SizedBox(height: 24),

                    // Notes
                    const Text(
                      'Notes (Optional)',
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
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(AppConstants.textLight).withAlpha(51),
                        ),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 3,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Add any special instructions...',
                          hintStyle: TextStyle(
                            color: Color(AppConstants.textLight),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.all(12),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Total and create button
                    if (_orderItems.isNotEmpty) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(AppConstants.paleGreen),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total Amount',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(AppConstants.textDark),
                                  ),
                                ),
                                Text(
                                  '${_totalAmount.toStringAsFixed(2)} MAD',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Color(AppConstants.primaryGreen),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            InkWell(
                              onTap: _isLoading ? null : _createOrder,
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                decoration: BoxDecoration(
                                  color: _isLoading
                                      ? const Color(AppConstants.textGray)
                                      : const Color(AppConstants.primaryGreen),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            color: Color(AppConstants.white),
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      )
                                    : const Text(
                                        'Create Order',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(AppConstants.white),
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemCard(Map<String, dynamic> item, int index) {
    final product = item['product'];
    final quantity = item['quantity'];
    final unitPrice = item['unit_price'];
    final totalPrice = item['total_price'];

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(AppConstants.white),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(AppConstants.textLight).withAlpha(51),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.textDark),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$quantity ${product['unit']} × ${unitPrice.toStringAsFixed(2)} MAD',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(AppConstants.textGray),
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${totalPrice.toStringAsFixed(2)} MAD',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textDark),
                ),
              ),
              const SizedBox(height: 4),
              InkWell(
                onTap: () => _removeOrderItem(index),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  child: const Icon(
                    Icons.delete_rounded,
                    color: Color(AppConstants.errorColor),
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}

// Full-screen Add Order Item Form with inline validation
class _AddOrderItemScreen extends StatefulWidget {
  final List<Map<String, dynamic>> products;
  final Future<void> Function(Map<String, dynamic>, int, double) onProductSelected;

  const _AddOrderItemScreen({
    required this.products,
    required this.onProductSelected,
  });

  @override
  State<_AddOrderItemScreen> createState() => _AddOrderItemScreenState();
}

class _AddOrderItemScreenState extends State<_AddOrderItemScreen> {
  final _quantityController = TextEditingController();
  final _unitPriceController = TextEditingController();

  Map<String, dynamic>? _selectedProduct;
  String? _productError;
  String? _quantityError;
  String? _unitPriceError;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _quantityController.addListener(_validateQuantity);
    _unitPriceController.addListener(_validateUnitPrice);
  }

  void _validateQuantity() {
    final text = _quantityController.text.trim();

    if (text.isEmpty) {
      setState(() => _quantityError = null);
      return;
    }

    final quantity = int.tryParse(text);
    if (quantity == null) {
      setState(() => _quantityError = 'Must be a whole number');
      return;
    } else if (quantity <= 0) {
      setState(() => _quantityError = 'Quantity must be greater than 0');
      return;
    } else if (quantity > 100000) {
      setState(() => _quantityError = 'Quantity too large (max 100,000)');
      return;
    }

    setState(() => _quantityError = null);
  }

  void _validateUnitPrice() {
    final text = _unitPriceController.text.trim();

    if (text.isEmpty) {
      setState(() => _unitPriceError = null);
      return;
    }

    final price = double.tryParse(text);
    if (price == null) {
      setState(() => _unitPriceError = 'Must be a valid number');
      return;
    } else if (price <= 0) {
      setState(() => _unitPriceError = 'Price must be greater than 0');
      return;
    } else if (price > 1000000) {
      setState(() => _unitPriceError = 'Price too large (max 1,000,000)');
      return;
    }

    setState(() => _unitPriceError = null);
  }

  bool get _hasErrors {
    return _productError != null || _quantityError != null || _unitPriceError != null;
  }

  bool get _isFormValid {
    return _selectedProduct != null &&
           _quantityController.text.trim().isNotEmpty &&
           _unitPriceController.text.trim().isNotEmpty &&
           !_hasErrors;
  }

  double? get _calculatedTotal {
    if (!_isFormValid) return null;

    final quantity = int.tryParse(_quantityController.text.trim());
    final unitPrice = double.tryParse(_unitPriceController.text.trim());

    if (quantity == null || unitPrice == null) return null;

    return quantity * unitPrice;
  }

  Future<void> _handleSave() async {
    // Validate product selection
    if (_selectedProduct == null) {
      setState(() => _productError = 'Please select a product');
      return;
    }

    // Force validation
    _validateQuantity();
    _validateUnitPrice();

    if (!_isFormValid || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      final quantity = int.parse(_quantityController.text.trim());
      final unitPrice = double.parse(_unitPriceController.text.trim());

      await widget.onProductSelected(_selectedProduct!, quantity, unitPrice);
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add item: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(AppConstants.errorColor),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.background),
      appBar: AppBar(
        backgroundColor: const Color(AppConstants.white),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Color(AppConstants.textDark)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Item',
          style: TextStyle(
            color: Color(AppConstants.textDark),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          TextButton(
            onPressed: _isFormValid && !_isSaving ? _handleSave : null,
            child: _isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(AppConstants.primaryGreen),
                    ),
                  )
                : Text(
                    'Add',
                    style: TextStyle(
                      color: _isFormValid
                          ? const Color(AppConstants.primaryGreen)
                          : const Color(AppConstants.textLight),
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),

            // Product Selection Section
            Container(
              color: const Color(AppConstants.white),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Selection',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textLight),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Product Dropdown
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _productError != null
                            ? const Color(AppConstants.errorColor)
                            : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        width: _productError != null ? 2 : 1,
                      ),
                    ),
                    child: DropdownButtonFormField<Map<String, dynamic>>(
                      initialValue: _selectedProduct,
                      hint: const Text('Select a product', style: TextStyle(fontSize: 14)),
                      isExpanded: true,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        errorText: _productError,
                        errorStyle: const TextStyle(height: 0.8),
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: Color(AppConstants.textGray),
                        size: 20,
                      ),
                      items: widget.products.map((product) {
                        return DropdownMenuItem(
                          value: product,
                          child: Text(
                            product['name'],
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: Color(AppConstants.textDark),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        );
                      }).toList(),
                      onChanged: (product) {
                        setState(() {
                          _selectedProduct = product;
                          _productError = null;
                          // Set default unit price from product price if available
                          if (product != null && product['price'] != null) {
                            _unitPriceController.text = product['price'].toString();
                          }
                        });
                      },
                    ),
                  ),

                  if (_selectedProduct != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.background),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.inventory_2_outlined,
                            size: 18,
                            color: Color(AppConstants.textGray),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Stock',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(AppConstants.textLight),
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${_selectedProduct!['current_stock'] ?? 0} ${_selectedProduct!['unit'] ?? 'pc'}',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Color(AppConstants.textDark),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Quantity & Pricing Section
            Container(
              color: const Color(AppConstants.white),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Quantity & Pricing',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textLight),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Quantity *',
                      labelStyle: const TextStyle(fontSize: 14),
                      suffixText: _selectedProduct?['unit'] ?? 'units',
                      suffixStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(AppConstants.textGray),
                      ),
                      errorText: _quantityError,
                      prefixIcon: const Icon(Icons.shopping_cart_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _quantityError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _quantityError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Unit Price
                  TextField(
                    controller: _unitPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Unit Price (MAD) *',
                      labelStyle: const TextStyle(fontSize: 14),
                      errorText: _unitPriceError,
                      prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _unitPriceError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _unitPriceError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Order Preview Section
            if (_calculatedTotal != null) ...[
              Container(
                color: const Color(AppConstants.white),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Order Preview',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.textLight),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 16),

                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.paleGreen),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(AppConstants.primaryGreen).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedProduct!['name'],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(AppConstants.textDark),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${_quantityController.text} ${_selectedProduct!['unit'] ?? 'pc'} × ${double.parse(_unitPriceController.text).toStringAsFixed(2)} MAD',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(AppConstants.textGray),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(height: 1),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Item Total',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(AppConstants.textDark),
                                ),
                              ),
                              Text(
                                '${_calculatedTotal!.toStringAsFixed(2)} MAD',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(AppConstants.primaryGreen),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _unitPriceController.dispose();
    super.dispose();
  }
}
