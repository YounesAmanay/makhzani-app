import 'package:flutter/material.dart';
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
      final response = await ApiService.getOrders(
        status: _selectedStatus,
      );
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

  // Backend has: draft (no PDF), sent (has PDF)
  // We map to: Draft, Sent
  String _getOrderStatus(Map<String, dynamic> order) {
    final status = order['status'] as Map<String, dynamic>?;
    if (status == null) return 'draft';

    if (status['sent'] == true) {
      return 'sent';
    } else if (status['pdf_generated'] == true) {
      return 'generated';
    } else {
      return 'draft';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return const Color(AppConstants.textGray);
      case 'generated':
        return const Color(0xFF3B82F6); // Blue
      case 'sent':
        return const Color(AppConstants.primaryGreen);
      default:
        return const Color(AppConstants.textGray);
    }
  }

  String _getStatusDisplayText(String status) {
    switch (status.toLowerCase()) {
      case 'draft':
        return 'Draft';
      case 'generated':
        return 'Ready';
      case 'sent':
        return 'Sent';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.background),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(AppConstants.primaryGreen),
          onRefresh: _loadOrders,
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                color: const Color(AppConstants.white),
                child: Column(
                  children: [
                    // Top bar
                    Row(
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
                            'Orders',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(AppConstants.textDark),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CreateOrderScreen()),
                            ).then((_) => _loadOrders());
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: const Icon(
                              Icons.add_rounded,
                              color: Color(AppConstants.primaryGreen),
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Status filter
                    Container(
                      height: 44,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.background),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        isExpanded: true,
                        underline: const SizedBox(),
                        icon: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(AppConstants.textGray),
                          size: 20,
                        ),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(AppConstants.textDark),
                          fontWeight: FontWeight.w500,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'all', child: Text('All Orders')),
                          DropdownMenuItem(value: 'draft', child: Text('Draft Orders')),
                          DropdownMenuItem(value: 'sent', child: Text('Sent Orders')),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedStatus = value ?? 'all');
                          _loadOrders();
                        },
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Order count
                    Row(
                      children: [
                        Text(
                          '${_orders.length} order${_orders.length == 1 ? '' : 's'}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(AppConstants.textGray),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Orders list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(AppConstants.primaryGreen),
                        ),
                      )
                    : _error != null
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    size: 48,
                                    color: Color(AppConstants.errorColor),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Failed to load orders',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Color(AppConstants.textDark),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _error!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Color(AppConstants.textGray),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  TextButton(
                                    onPressed: _loadOrders,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _orders.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(
                                      Icons.receipt_long_outlined,
                                      size: 64,
                                      color: Color(AppConstants.textLight),
                                    ),
                                    const SizedBox(height: 16),
                                    const Text(
                                      'No orders yet',
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(AppConstants.textGray),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      _selectedStatus == 'all'
                                          ? 'Create your first order'
                                          : 'No $_selectedStatus orders found',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: Color(AppConstants.textLight),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _orders.length,
                                itemBuilder: (context, index) {
                                  final order = _orders[index];
                                  return _buildOrderItem(order);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    final orderStatus = _getOrderStatus(order);
    final statusColor = _getStatusColor(orderStatus);
    final statusText = _getStatusDisplayText(orderStatus);
    final totalValue = (order['total_value'] ?? 0.0).toDouble();
    final totalItems = order['total_items'] ?? 0;
    final supplierName = order['supplier']?['name'] ?? 'Unknown';

    return InkWell(
      onTap: () => _showOrderDetails(order),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(AppConstants.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Order icon with status color
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: statusColor.withAlpha(25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.receipt_long_rounded,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Order info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Order #${order['order_number']}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(AppConstants.textDark),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withAlpha(25),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    supplierName,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(AppConstants.textGray),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalItems item${totalItems == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(AppConstants.textLight),
                    ),
                  ),
                ],
              ),
            ),

            // Price and chevron
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${totalValue.toStringAsFixed(2)} MAD',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(AppConstants.textDark),
                  ),
                ),
                const SizedBox(height: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: Color(AppConstants.textLight),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(Map<String, dynamic> order) {
    final orderStatus = _getOrderStatus(order);
    final statusColor = _getStatusColor(orderStatus);
    final statusText = _getStatusDisplayText(orderStatus);
    final supplier = order['supplier'] as Map<String, dynamic>?;
    final supplierName = supplier?['name'] ?? 'Unknown';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(AppConstants.white),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 20),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.textLight).withAlpha(76),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Order #${order['order_number']}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(AppConstants.textDark),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(25),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Order details
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.background),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    _buildDetailRow('Supplier', supplierName),
                    const SizedBox(height: 8),
                    _buildDetailRow(
                      'Date',
                      order['created_at'] != null
                          ? _formatDate(DateTime.parse(order['created_at']))
                          : 'Unknown',
                    ),
                    _buildDetailRow('Items', '${order['total_items'] ?? 0}'),
                    const SizedBox(height: 8),
                    _buildDetailRow('Quantity', '${(order['total_quantity'] ?? 0).toStringAsFixed(0)}'),
                    if (order['notes'] != null) ...[
                      const SizedBox(height: 8),
                      _buildDetailRow('Notes', order['notes']),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Total
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(AppConstants.paleGreen),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Value',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(AppConstants.textDark),
                      ),
                    ),
                    Text(
                      '${(order['total_value'] ?? 0.0).toStringAsFixed(2)} MAD',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(AppConstants.primaryGreen),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Actions
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    if (orderStatus == 'draft') ...[
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _generatePDF(order['id']);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(AppConstants.primaryGreen),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Generate PDF',
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
                    if (orderStatus == 'generated') ...[
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          _showSendOptionsDialog(order['id']);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(AppConstants.primaryGreen),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Mark as Sent',
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
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(AppConstants.textLight),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(AppConstants.textDark),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showSendOptionsDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'How was this order sent?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(AppConstants.textDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSendOption(Icons.phone_rounded, 'WhatsApp', () {
              Navigator.pop(context);
              _markAsSent(orderId, 'whatsapp');
            }),
            const SizedBox(height: 8),
            _buildSendOption(Icons.email_rounded, 'Email', () {
              Navigator.pop(context);
              _markAsSent(orderId, 'email');
            }),
            const SizedBox(height: 8),
            _buildSendOption(Icons.call_rounded, 'Phone', () {
              Navigator.pop(context);
              _markAsSent(orderId, 'phone');
            }),
            const SizedBox(height: 8),
            _buildSendOption(Icons.person_rounded, 'In Person', () {
              Navigator.pop(context);
              _markAsSent(orderId, 'in_person');
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSendOption(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(
            color: const Color(AppConstants.textLight).withAlpha(51),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(AppConstants.primaryGreen)),
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(AppConstants.textDark),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _generatePDF(String orderId) async {
    try {
      await ApiService.generateOrderPDF(orderId);
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('PDF generated successfully'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate PDF: $e'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }

  Future<void> _markAsSent(String orderId, String sentVia) async {
    try {
      await ApiService.markOrderAsSent(orderId, sentVia);
      _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Order marked as sent successfully'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark order as sent: $e'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
        );
      }
    }
  }
}
