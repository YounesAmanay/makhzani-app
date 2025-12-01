import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../../services/api_service.dart';
import '../../utils/constants.dart';
import 'create_order_screen.dart';

typedef CanLaunchUrl = Future<bool> Function(Uri);
typedef LaunchUrl = Future<bool> Function(Uri);

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
                          _showSendOptionsDialog(order['id'], order['pdf_url']);
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

  void _showSendOptionsDialog(String orderId, String? pdfUrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Share order via:',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(AppConstants.textDark),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSendOption(Icons.chat_rounded, 'WhatsApp', () {
              Navigator.pop(context);
              _shareViaPlatform(orderId, 'whatsapp', pdfUrl);
            }),
            const SizedBox(height: 8),
            _buildSendOption(Icons.email_rounded, 'Email', () {
              Navigator.pop(context);
              _shareViaPlatform(orderId, 'email', pdfUrl);
            }),
            const SizedBox(height: 8),
            _buildSendOption(Icons.phone_rounded, 'Phone', () {
              Navigator.pop(context);
              _shareViaPlatform(orderId, 'phone', pdfUrl);
            }),
            const SizedBox(height: 8),
            _buildSendOption(Icons.person_rounded, 'In Person', () {
              Navigator.pop(context);
              _shareViaPlatform(orderId, 'in_person', pdfUrl);
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

  Future<void> _shareViaPlatform(String orderId, String platform, String? pdfUrl) async {
    try {
      // Show loading indicator
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Preparing PDF for sharing...'),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Download PDF if URL exists
      File? pdfFile;
      if (pdfUrl != null && pdfUrl.isNotEmpty) {
        pdfFile = await _downloadPDF(pdfUrl);
      }

      // Share via appropriate platform
      switch (platform.toLowerCase()) {
        case 'whatsapp':
          await _shareViaWhatsApp(orderId, pdfFile);
          break;
        case 'email':
          await _shareViaEmail(orderId, pdfFile);
          break;
        case 'phone':
          await _shareViaPhone(orderId);
          break;
        case 'in_person':
          // For in-person, just mark as sent
          await _markAsSent(orderId, platform);
          return;
        default:
          throw Exception('Unknown platform: $platform');
      }

      // Mark as sent in backend
      await _markAsSent(orderId, platform);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to share: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(AppConstants.errorColor),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<File?> _downloadPDF(String pdfUrl) async {
    try {
      // Construct full URL
      final fullUrl = pdfUrl.startsWith('http')
          ? pdfUrl
          : '${AppConstants.baseUrl.replaceAll('/api', '')}$pdfUrl';

      final response = await http.get(Uri.parse(fullUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to download PDF');
      }

      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final filename = 'order_${DateTime.now().millisecondsSinceEpoch}.pdf';
      final file = File('${tempDir.path}/$filename');

      // Write bytes to file
      await file.writeAsBytes(response.bodyBytes);
      return file;
    } catch (e) {
      debugPrint('Error downloading PDF: $e');
      return null;
    }
  }

  Future<void> _shareViaWhatsApp(String orderId, File? pdfFile) async {
    try {
      final order = _orders.firstWhere((o) => o['id'] == orderId);
      final orderNumber = order['order_number'] ?? 'Order';
      final supplier = order['supplier'] ?? {};
      final supplierName = supplier['name'] ?? 'Supplier';

      final message = 'Hi $supplierName,\n\n'
          'I have a purchase order for you.\n'
          'Order #: $orderNumber\n\n'
          'Thank you!';

      // Use native Share dialog
      if (pdfFile != null) {
        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(pdfFile.path)],
            text: message,
          ),
        );
      } else {
        await SharePlus.instance.share(
          ShareParams(text: message),
        );
      }
    } catch (e) {
      throw Exception('Failed to share via WhatsApp: $e');
    }
  }

  Future<void> _shareViaEmail(String orderId, File? pdfFile) async {
    try {
      final order = _orders.firstWhere((o) => o['id'] == orderId);
      final orderNumber = order['order_number'] ?? 'Order';
      final supplier = order['supplier'] ?? {};
      final supplierEmail = supplier['email'] ?? '';

      if (supplierEmail.isEmpty) {
        throw Exception('No email address available for this supplier');
      }

      final subject = 'Purchase Order - $orderNumber';
      final body = 'Hi,\n\nPlease find the attached purchase order.\n\nThank you!';

      // Construct mailto URI
      final mailtoUri = Uri(
        scheme: 'mailto',
        path: supplierEmail,
        queryParameters: {
          'subject': subject,
          'body': body,
        },
      );

      if (await canLaunchUrl(mailtoUri)) {
        await launchUrl(mailtoUri);
      } else {
        throw Exception('Could not launch email');
      }
    } catch (e) {
      throw Exception('Failed to share via Email: $e');
    }
  }

  Future<void> _shareViaPhone(String orderId) async {
    try {
      final order = _orders.firstWhere((o) => o['id'] == orderId);
      final orderNumber = order['order_number'] ?? 'Order';
      final supplier = order['supplier'] ?? {};
      final supplierPhone = supplier['phone_number'] ?? '';

      if (supplierPhone.isEmpty) {
        throw Exception('No phone number available for this supplier');
      }

      // Remove any non-numeric characters for URI
      final cleanPhone = supplierPhone.replaceAll(RegExp(r'[^0-9+]'), '');
      final message = 'Hi, I have a purchase order for you. Order #: $orderNumber';

      final smsUri = Uri(
        scheme: 'sms',
        path: cleanPhone,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        throw Exception('Could not launch SMS');
      }
    } catch (e) {
      throw Exception('Failed to share via Phone: $e');
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
