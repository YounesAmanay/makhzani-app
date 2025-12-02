import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import 'create_order_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _orders = [];
  String? _error;
  String _selectedStatus = 'all';
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Map UI status to API status
      String apiStatus = _selectedStatus;
      if (_selectedStatus == 'draft') {
        apiStatus = 'draft'; // Not Ready
      } else if (_selectedStatus == 'ready') {
        apiStatus = 'all'; // Ready - fetch all, filter locally
      } else if (_selectedStatus == 'sent') {
        apiStatus = 'sent'; // Shared
      }

      final response = await ApiService.getOrders(status: apiStatus);
      if (response['success'] == true) {
        setState(() {
          _orders = List<Map<String, dynamic>>.from(response['data']['orders']);
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

  // Filter orders based on search and status
  List<Map<String, dynamic>> _getFilteredOrders() {
    var filtered = _orders;

    // Apply status filter locally
    if (_selectedStatus != 'all') {
      filtered = filtered.where((order) {
        final orderStatus = _getOrderStatus(order);
        return orderStatus == _selectedStatus;
      }).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((order) {
        final orderNumber = order['order_number']?.toString().toLowerCase() ?? '';
        final supplierName = order['supplier']?['name']?.toString().toLowerCase() ?? '';
        final query = _searchQuery.toLowerCase();

        return orderNumber.contains(query) || supplierName.contains(query);
      }).toList();
    }

    return filtered;
  }

  // Determine order status based on pdf_generated_at and sent_at
  String _getOrderStatus(Map<String, dynamic> order) {
    final status = order['status'] as Map<String, dynamic>?;
    if (status == null) return 'draft';

    if (status['sent'] == true) {
      return 'sent';
    } else if (status['pdf_generated'] == true) {
      return 'ready';
    } else {
      return 'draft';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(AppConstants.textGray);
      case 'ready':
        return const Color(0xFF3B82F6); // Blue
      case 'sent':
        return const Color(AppConstants.primaryGreen);
      default:
        return const Color(AppConstants.textGray);
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return Icons.description_outlined;
      case 'ready':
        return Icons.check_circle_outline;
      case 'sent':
        return Icons.verified;
      default:
        return Icons.help_outline;
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Not Ready';
      case 'ready':
        return 'Ready to Share';
      case 'sent':
        return 'Shared';
      default:
        return status;
    }
  }

  // Get PDF file path on device
  Future<String> _getPDFFilePath(String orderId) async {
    final dir = await getApplicationDocumentsDirectory();
    final pdfDir = Directory('${dir.path}/pdfs');

    if (!await pdfDir.exists()) {
      await pdfDir.create(recursive: true);
    }

    return '${pdfDir.path}/order-$orderId.pdf';
  }

  // Download PDF from backend and save to phone
  Future<File?> _downloadAndSavePDF(String orderId, String pdfUrl) async {
    try {
      final filePath = await _getPDFFilePath(orderId);
      final file = File(filePath);

      // If file already exists, return it
      if (await file.exists()) {
        return file;
      }

      // Download from backend
      // Use serverUrl (without /api) for file downloads
      final fullUrl = pdfUrl.startsWith('http')
          ? pdfUrl
          : '${AppConstants.serverUrl}$pdfUrl';

      final response = await http.get(Uri.parse(fullUrl)).timeout(
        const Duration(seconds: 30),
        onTimeout: () => throw Exception('Download timeout'),
      );

      if (response.statusCode == 200) {
        await file.writeAsBytes(response.bodyBytes);
        return file;
      } else {
        throw Exception('Failed to download PDF: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to download PDF: $e'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
        );
      }
      return null;
    }
  }

  // Check if PDF exists locally
  Future<bool> _pdfExistsLocally(String orderId) async {
    final filePath = await _getPDFFilePath(orderId);
    return File(filePath).exists();
  }

  // Open PDF file
  Future<void> _openPDF(String orderId, String? pdfUrl) async {
    if (pdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF not available'),
          backgroundColor: Color(AppConstants.warningColor),
        ),
      );
      return;
    }

    try {
      // Check if PDF exists locally
      final exists = await _pdfExistsLocally(orderId);

      File? pdfFile;
      if (exists) {
        // File exists, open it directly
        final filePath = await _getPDFFilePath(orderId);
        pdfFile = File(filePath);
      } else {
        // File doesn't exist, download it first
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Downloading PDF...'),
              backgroundColor: Color(AppConstants.primaryGreen),
            ),
          );
        }

        pdfFile = await _downloadAndSavePDF(orderId, pdfUrl);
      }

      if (pdfFile != null && await pdfFile.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('PDF ready: ${pdfFile.path}'),
              backgroundColor: const Color(AppConstants.primaryGreen),
              action: SnackBarAction(
                label: 'Share',
                onPressed: () => _shareOrderPDF(orderId, pdfFile),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening PDF: $e'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }

  // Generate PDF on backend
  Future<void> _generatePDF(String orderId) async {
    try {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Generating PDF...'),
          backgroundColor: Color(AppConstants.primaryGreen),
        ),
      );

      final response = await ApiService.generateOrderPDF(orderId);

      if (response['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('PDF generated successfully!'),
              backgroundColor: Color(AppConstants.primaryGreen),
            ),
          );

          // Reload orders to update status
          await _loadOrders();

          // Close popup
          Navigator.pop(context);

          // Auto-download the PDF
          final pdfUrl = response['data']?['pdf_url'];
          if (pdfUrl != null) {
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              await _downloadAndSavePDF(orderId, pdfUrl);
            }
          }
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to generate PDF');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }

  // Share PDF via native share dialog
  Future<void> _shareOrderPDF(String orderId, File? pdfFile) async {
    try {
      final order = _orders.firstWhere((o) => o['id'] == orderId);
      final orderNumber = order['order_number'] ?? 'Order';

      // In production, use share_plus to share file
      // For now, just show message that file is ready
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ready to share: $orderNumber'),
            backgroundColor: const Color(AppConstants.primaryGreen),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: const Color(AppConstants.errorColor),
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
        title: const Text('Purchase Orders'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Search and filter bar
          _buildSearchAndFilterBar(),
          // Orders list
          Expanded(
            child: _buildBody(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
          ).then((_) => _loadOrders());
        },
        backgroundColor: const Color(AppConstants.primaryGreen),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Container(
      color: const Color(AppConstants.white),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Search box
          Container(
            decoration: BoxDecoration(
              color: const Color(AppConstants.background),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(AppConstants.textLight).withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
              },
              decoration: InputDecoration(
                hintText: 'Search by order # or supplier...',
                hintStyle: const TextStyle(
                  color: Color(AppConstants.textLight),
                  fontSize: 13,
                ),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Color(AppConstants.textGray),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Filter chips
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildFilterChip('All', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Not Ready', 'draft'),
                const SizedBox(width: 8),
                _buildFilterChip('Ready', 'ready'),
                const SizedBox(width: 8),
                _buildFilterChip('Shared', 'sent'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String status) {
    final isSelected = _selectedStatus == status;

    return GestureDetector(
      onTap: () {
        setState(() => _selectedStatus = status);
        _loadOrders();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(AppConstants.primaryGreen)
              : const Color(AppConstants.background),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(AppConstants.primaryGreen)
                : const Color(AppConstants.textLight).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? const Color(AppConstants.white)
                : const Color(AppConstants.textGray),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(AppConstants.primaryGreen),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 48,
              color: Color(AppConstants.errorColor),
            ),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(AppConstants.textGray),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadOrders,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(AppConstants.primaryGreen),
              ),
            ),
          ],
        ),
      );
    }

    final filteredOrders = _getFilteredOrders();

    if (filteredOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.inbox_outlined,
              size: 48,
              color: Color(AppConstants.textGray),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty ? 'No orders found' : 'No orders yet',
              style: const TextStyle(
                color: Color(AppConstants.textGray),
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredOrders.length,
      itemBuilder: (context, index) {
        final order = filteredOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = _getOrderStatus(order);
    final statusColor = _getStatusColor(status);
    final statusIcon = _getStatusIcon(status);
    final statusText = _getStatusDisplayText(status);

    return GestureDetector(
      onTap: () => _showOrderDetails(order),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: const Color(AppConstants.white),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: statusColor.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Order number and status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order #${order['order_number'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(AppConstants.textDark),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order['supplier']?['name'] ?? 'Unknown Supplier',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(AppConstants.textGray),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: statusColor.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          size: 14,
                          color: statusColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Order details
              Row(
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 16,
                    color: const Color(AppConstants.textGray),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${order['total_items'] ?? 0} items',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(AppConstants.textGray),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.payments_outlined,
                    size: 16,
                    color: const Color(AppConstants.textGray),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${order['total_value']?.toStringAsFixed(2) ?? '0.00'} MAD',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Date
              Text(
                'Created: ${_formatDate(order['created_at'])}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(AppConstants.textLight),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final status = _getOrderStatus(order);
    final pdfUrl = order['pdf_url'];
    final pdfGenerated = order['status']?['pdf_generated'] == true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(AppConstants.white),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order #${order['order_number'] ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(AppConstants.textDark),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatDate(order['created_at']),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(AppConstants.textGray),
                              ),
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(AppConstants.background),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Color(AppConstants.textGray),
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Supplier info
                  _buildSectionTitle('Supplier Information'),
                  const SizedBox(height: 12),
                  _buildSupplierCard(order['supplier']),
                  const SizedBox(height: 24),

                  // Order items
                  _buildSectionTitle('Order Items'),
                  const SizedBox(height: 12),
                  _buildOrderItems(order),
                  const SizedBox(height: 24),

                  // Order summary
                  _buildOrderSummary(order),
                  const SizedBox(height: 32),

                  // Action button
                  _buildActionButton(order, status, pdfUrl, pdfGenerated),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(AppConstants.textDark),
      ),
    );
  }

  Widget _buildSupplierCard(Map<String, dynamic>? supplier) {
    if (supplier == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(AppConstants.background),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'No supplier information',
          style: TextStyle(
            fontSize: 12,
            color: Color(AppConstants.textGray),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(AppConstants.background),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(AppConstants.textLight).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(AppConstants.primaryGreen)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.business_outlined,
                  size: 20,
                  color: Color(AppConstants.primaryGreen),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      supplier['name'] ?? 'Unknown',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.textDark),
                      ),
                    ),
                    if (supplier['business_name'] != null)
                      Text(
                        supplier['business_name'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppConstants.textGray),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (supplier['phone_number'] != null) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.phone_outlined,
                  size: 14,
                  color: Color(AppConstants.textGray),
                ),
                const SizedBox(width: 8),
                Text(
                  supplier['phone_number'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(AppConstants.textDark),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOrderItems(Map<String, dynamic> order) {
    final items = order['items'] as List?;
    if (items == null || items.isEmpty) {
      return const Text(
        'No items in this order',
        style: TextStyle(
          fontSize: 12,
          color: Color(AppConstants.textGray),
        ),
      );
    }

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index] as Map<String, dynamic>;
        final product = item['product'] as Map<String, dynamic>?;
        final quantity = double.tryParse(item['quantity'].toString()) ?? 0;
        final unitPrice = double.tryParse(item['unit_price'].toString()) ?? 0;
        final totalPrice = quantity * unitPrice;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(AppConstants.white),
              border: Border.all(
                color: const Color(AppConstants.textLight)
                    .withValues(alpha: 0.15),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product?['name'] ?? 'Unknown Product',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.textDark),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$quantity ${product?['unit'] ?? 'pc'} × ${unitPrice.toStringAsFixed(2)} MAD',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppConstants.textGray),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${totalPrice.toStringAsFixed(2)} MAD',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildOrderSummary(Map<String, dynamic> order) {
    final totalValue = double.tryParse(order['total_value'].toString()) ?? 0;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(AppConstants.primaryGreen).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(AppConstants.primaryGreen).withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Items',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(AppConstants.textGray),
                ),
              ),
              Text(
                '${order['total_items'] ?? 0}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textDark),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Quantity',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(AppConstants.textGray),
                ),
              ),
              Text(
                '${order['total_quantity'] ?? 0}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textDark),
                ),
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(AppConstants.textDark),
                ),
              ),
              Text(
                '${totalValue.toStringAsFixed(2)} MAD',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Color(AppConstants.primaryGreen),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(Map<String, dynamic> order, String status,
      String? pdfUrl, bool pdfGenerated) {
    final orderId = order['id'] as String;

    if (status == 'draft') {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _generatePDF(orderId),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppConstants.primaryGreen),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.document_scanner_outlined),
          label: const Text(
            'Generate PDF',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else if (status == 'ready') {
      // If PDF is marked as ready, show Open PDF button (with or without URL)
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: () => _openPDF(orderId, pdfUrl),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(AppConstants.primaryGreen),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.file_open_outlined),
          label: const Text(
            'Open PDF',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else if (status == 'sent') {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(AppConstants.primaryGreen).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: const Color(AppConstants.primaryGreen),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle,
              color: Color(AppConstants.primaryGreen),
              size: 20,
            ),
            const SizedBox(width: 8),
            const Text(
              'Order Shared',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(AppConstants.primaryGreen),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  String _formatDate(dynamic dateStr) {
    try {
      if (dateStr == null) return 'N/A';
      final date = DateTime.parse(dateStr.toString());
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return 'N/A';
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }
}
