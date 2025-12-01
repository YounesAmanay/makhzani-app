import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../utils/constants.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final _searchController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _suppliers = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSuppliers();
  }

  Future<void> _loadSuppliers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final response = await ApiService.getSuppliers();
      if (response['success'] == true) {
        setState(() {
          _suppliers = List<Map<String, dynamic>>.from(response['data']['suppliers']);
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

  List<Map<String, dynamic>> get _filteredSuppliers {
    if (_searchController.text.isEmpty) return _suppliers;

    return _suppliers.where((supplier) =>
      supplier['name'].toLowerCase().contains(_searchController.text.toLowerCase()) ||
      (supplier['business_name']?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false) ||
      (supplier['phone_number']?.toLowerCase().contains(_searchController.text.toLowerCase()) ?? false)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppConstants.background),
      body: SafeArea(
        child: RefreshIndicator(
          color: const Color(AppConstants.primaryGreen),
          onRefresh: _loadSuppliers,
          child: Column(
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                color: const Color(AppConstants.white),
                child: Column(
                  children: [
                    // Top bar with back button, title, and add button
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
                            'Suppliers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(AppConstants.textDark),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: _showAddSupplierScreen,
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

                    // Search bar
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(AppConstants.background),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(AppConstants.textDark),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search suppliers',
                          hintStyle: const TextStyle(
                            color: Color(AppConstants.textLight),
                            fontSize: 14,
                          ),
                          prefixIcon: const Icon(
                            Icons.search_rounded,
                            color: Color(AppConstants.textLight),
                            size: 20,
                          ),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(
                                    Icons.clear_rounded,
                                    color: Color(AppConstants.textLight),
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {});
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onChanged: (value) => setState(() {}),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Supplier count
                    Row(
                      children: [
                        Text(
                          '${_filteredSuppliers.length} supplier${_filteredSuppliers.length == 1 ? '' : 's'}',
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

              // Suppliers list
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
                                    'Failed to load suppliers',
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
                                    onPressed: _loadSuppliers,
                                    child: const Text('Retry'),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : _filteredSuppliers.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _searchController.text.isEmpty
                                          ? Icons.people_outline_rounded
                                          : Icons.search_off_rounded,
                                      size: 64,
                                      color: const Color(AppConstants.textLight),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      _searchController.text.isEmpty
                                          ? 'No suppliers yet'
                                          : 'No suppliers found',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Color(AppConstants.textGray),
                                      ),
                                    ),
                                    if (_searchController.text.isEmpty) ...[
                                      const SizedBox(height: 8),
                                      const Text(
                                        'Add your first supplier to get started',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Color(AppConstants.textLight),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              )
                            : ListView.builder(
                                itemCount: _filteredSuppliers.length,
                                itemBuilder: (context, index) {
                                  final supplier = _filteredSuppliers[index];
                                  return _buildSupplierItem(supplier);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSupplierItem(Map<String, dynamic> supplier) {
    return InkWell(
      onTap: () => _showSupplierActions(supplier),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(AppConstants.white),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  supplier['name'][0].toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF8B5CF6),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Supplier info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    supplier['name'],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                  if (supplier['business_name'] != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      supplier['business_name'],
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(AppConstants.textGray),
                      ),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.phone_rounded,
                        size: 14,
                        color: Color(AppConstants.textLight),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        supplier['phone_number'] ?? 'No phone',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(AppConstants.textLight),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Chevron
            const Icon(
              Icons.chevron_right_rounded,
              color: Color(AppConstants.textLight),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  void _showSupplierActions(Map<String, dynamic> supplier) {
    final relationship = supplier['relationship'] ?? {};
    final totalOrders = relationship['total_orders'] ?? 0;

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
              // Handle bar for dragging
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
                      // Supplier Header with large title
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              supplier['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                                color: Color(AppConstants.textDark),
                              ),
                            ),
                            if (supplier['business_name'] != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  const Icon(Icons.business_rounded, size: 16, color: Color(AppConstants.textGray)),
                                  const SizedBox(width: 6),
                                  Text(
                                    supplier['business_name'],
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Color(AppConstants.textGray),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Order Stats Card
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8B5CF6),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.receipt_long_rounded,
                                  color: Color(AppConstants.white),
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Total Orders',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF8B5CF6),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$totalOrders order${totalOrders == 1 ? '' : 's'}',
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
                      const SizedBox(height: 20),

                      // Contact Details Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Contact Details',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(AppConstants.textLight),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(AppConstants.background),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                children: [
                                  _buildDetailRow(
                                    icon: Icons.phone_rounded,
                                    label: 'Phone',
                                    value: supplier['phone_number'] ?? 'Not provided',
                                    valueColor: const Color(AppConstants.textDark),
                                  ),
                                  if (supplier['email'] != null) ...[
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                      icon: Icons.email_rounded,
                                      label: 'Email',
                                      value: supplier['email'],
                                      valueColor: const Color(AppConstants.textDark),
                                    ),
                                  ],
                                  if (supplier['address'] != null) ...[
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                      icon: Icons.location_on_rounded,
                                      label: 'Address',
                                      value: supplier['address'],
                                      valueColor: const Color(AppConstants.textDark),
                                    ),
                                  ],
                                  if (supplier['city'] != null) ...[
                                    const SizedBox(height: 12),
                                    _buildDetailRow(
                                      icon: Icons.location_city_rounded,
                                      label: 'City',
                                      value: supplier['city'],
                                      valueColor: const Color(AppConstants.textDark),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Relationship Notes Section (if exists)
                      if (relationship['merchant_notes'] != null) ...[
                        const SizedBox(height: 20),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Notes',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(AppConstants.textLight),
                                  letterSpacing: 0.5,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(AppConstants.background),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  relationship['merchant_notes'],
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(AppConstants.textDark),
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),

                      // Action buttons
                      _buildActionButton(
                        icon: Icons.delete_outline_rounded,
                        label: 'Remove Supplier',
                        subtitle: 'Remove from your suppliers',
                        onTap: () {
                          Navigator.pop(context);
                          _showDeleteConfirmation(supplier);
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: const Color(AppConstants.textLight)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(AppConstants.textLight),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
            ],
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
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(AppConstants.textGray),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Color(AppConstants.textLight),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSupplierScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _SupplierFormScreen(
          title: 'Add Supplier',
          existingSuppliers: _suppliers,
          onSave: (name, businessName, phoneNumber, email, address, city, paymentTerms, notes, preferredContact) async {
            await _createSupplier(name, businessName, phoneNumber, email, address, city, paymentTerms, notes, preferredContact);
          },
        ),
        fullscreenDialog: true,
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> supplier) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remove Supplier',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Color(AppConstants.textDark),
          ),
        ),
        content: Text(
          'Are you sure you want to remove ${supplier['name']}? This action cannot be undone.',
          style: const TextStyle(
            fontSize: 14,
            color: Color(AppConstants.textGray),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(
                color: Color(AppConstants.textGray),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSupplier(supplier['id']);
            },
            style: TextButton.styleFrom(
              backgroundColor: const Color(AppConstants.errorColor),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text(
              'Remove',
              style: TextStyle(
                color: Color(AppConstants.white),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _createSupplier(
    String name,
    String? businessName,
    String phoneNumber,
    String? email,
    String? address,
    String? city,
    String? paymentTerms,
    String? notes,
    String preferredContact,
  ) async {
    try {
      await ApiService.createSupplier(
        name: name,
        businessName: businessName,
        phoneNumber: phoneNumber,
        email: email,
        address: address,
      );
      _loadSuppliers();
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier added successfully'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add supplier: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(AppConstants.errorColor),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      rethrow;
    }
  }

  Future<void> _deleteSupplier(String id) async {
    try {
      await ApiService.deleteSupplier(id);
      _loadSuppliers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Supplier removed successfully'),
            backgroundColor: Color(AppConstants.successColor),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove supplier: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: const Color(AppConstants.errorColor),
          ),
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

// Full-screen Supplier Form with inline validation
class _SupplierFormScreen extends StatefulWidget {
  final String title;
  final List<Map<String, dynamic>> existingSuppliers;
  final Future<void> Function(
    String name,
    String? businessName,
    String phoneNumber,
    String? email,
    String? address,
    String? city,
    String? paymentTerms,
    String? notes,
    String preferredContact,
  ) onSave;

  const _SupplierFormScreen({
    required this.title,
    required this.existingSuppliers,
    required this.onSave,
  });

  @override
  State<_SupplierFormScreen> createState() => _SupplierFormScreenState();
}

class _SupplierFormScreenState extends State<_SupplierFormScreen> {
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _paymentTermsController = TextEditingController();
  final _notesController = TextEditingController();

  String? _nameError;
  String? _phoneError;
  String? _emailError;

  String _selectedCity = 'Casablanca';
  String _preferredContact = 'whatsapp';
  bool _isSaving = false;

  final List<String> _cities = [
    'Casablanca',
    'Rabat',
    'Marrakech',
    'Agadir',
    'Tangier',
    'Fes',
    'Meknes',
    'Other',
  ];

  final List<Map<String, dynamic>> _contactMethods = [
    {'value': 'whatsapp', 'label': 'WhatsApp', 'icon': Icons.chat_rounded},
    {'value': 'phone', 'label': 'Phone Call', 'icon': Icons.phone_rounded},
    {'value': 'email', 'label': 'Email', 'icon': Icons.email_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateName);
    _phoneController.addListener(_validatePhone);
    _emailController.addListener(_validateEmail);
  }

  void _validateName() {
    final name = _nameController.text.trim();

    if (name.isEmpty) {
      setState(() => _nameError = null);
      return;
    } else if (name.length < 2) {
      setState(() => _nameError = 'Name must be at least 2 characters');
      return;
    } else if (name.length > 100) {
      setState(() => _nameError = 'Name must not exceed 100 characters');
      return;
    }

    setState(() => _nameError = null);
  }

  void _validatePhone() {
    final phone = _phoneController.text.trim();

    if (phone.isEmpty) {
      setState(() => _phoneError = null);
      return;
    }

    // Check format: +212XXXXXXXXX (Morocco format)
    final phoneRegex = RegExp(r'^\+212[5-7]\d{8}$');
    if (!phoneRegex.hasMatch(phone)) {
      setState(() => _phoneError = 'Use format: +212XXXXXXXXX (Morocco)');
      return;
    }

    // Check for duplicate phone number locally
    final duplicate = widget.existingSuppliers.any((s) =>
      s['phone_number'] == phone
    );

    setState(() {
      _phoneError = duplicate ? 'A supplier with this phone already exists' : null;
    });
  }

  void _validateEmail() {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      setState(() => _emailError = null);
      return;
    }

    // Basic email validation
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      setState(() => _emailError = 'Invalid email format');
      return;
    }

    setState(() => _emailError = null);
  }

  bool get _hasErrors {
    return _nameError != null || _phoneError != null || _emailError != null;
  }

  bool get _isFormValid {
    return _nameController.text.trim().isNotEmpty &&
           _phoneController.text.trim().isNotEmpty &&
           !_hasErrors;
  }

  Future<void> _handleSave() async {
    if (!_isFormValid || _isSaving) return;

    setState(() => _isSaving = true);

    try {
      await widget.onSave(
        _nameController.text.trim(),
        _businessNameController.text.trim().isEmpty ? null : _businessNameController.text.trim(),
        _phoneController.text.trim(),
        _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
        _addressController.text.trim().isEmpty ? null : _addressController.text.trim(),
        _selectedCity,
        _paymentTermsController.text.trim().isEmpty ? null : _paymentTermsController.text.trim(),
        _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
        _preferredContact,
      );
    } catch (e) {
      setState(() => _isSaving = false);
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
                    'Save',
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

            // Basic Information Section
            Container(
              color: const Color(AppConstants.white),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Basic Information',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textLight),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Contact Name
                  TextField(
                    controller: _nameController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Contact Name *',
                      labelStyle: const TextStyle(fontSize: 14),
                      errorText: _nameError,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _nameError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _nameError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Business Name
                  TextField(
                    controller: _businessNameController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Business Name',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'Optional',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(AppConstants.textLight)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Contact Details Section
            Container(
              color: const Color(AppConstants.white),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Contact Details',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textLight),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Phone Number
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Phone Number *',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: '+212XXXXXXXXX',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(AppConstants.textLight)),
                      errorText: _phoneError,
                      prefixIcon: const Icon(Icons.phone_rounded, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _phoneError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _phoneError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Email
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'Optional',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(AppConstants.textLight)),
                      errorText: _emailError,
                      prefixIcon: const Icon(Icons.email_rounded, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _emailError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: _emailError != null
                              ? const Color(AppConstants.errorColor)
                              : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Preferred Contact Method
                  const Text(
                    'Preferred Contact Method',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(AppConstants.textDark),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: _contactMethods.map((method) {
                      final isSelected = _preferredContact == method['value'];
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: InkWell(
                            onTap: () => setState(() => _preferredContact = method['value']),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(AppConstants.primaryGreen).withValues(alpha: 0.1)
                                    : const Color(AppConstants.background),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(AppConstants.primaryGreen)
                                      : const Color(AppConstants.textLight).withValues(alpha: 0.3),
                                  width: isSelected ? 2 : 1,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    method['icon'],
                                    size: 20,
                                    color: isSelected
                                        ? const Color(AppConstants.primaryGreen)
                                        : const Color(AppConstants.textGray),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    method['label'],
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                                      color: isSelected
                                          ? const Color(AppConstants.primaryGreen)
                                          : const Color(AppConstants.textGray),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Location Section
            Container(
              color: const Color(AppConstants.white),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textLight),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // City Dropdown
                  DropdownButtonFormField<String>(
                    initialValue: _selectedCity,
                    decoration: InputDecoration(
                      labelText: 'City',
                      labelStyle: const TextStyle(fontSize: 14),
                      prefixIcon: const Icon(Icons.location_city_rounded, size: 20),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                    items: _cities.map((city) {
                      return DropdownMenuItem(
                        value: city,
                        child: Text(city, style: const TextStyle(fontSize: 15)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedCity = value);
                      }
                    },
                  ),
                  const SizedBox(height: 16),

                  // Address
                  TextField(
                    controller: _addressController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Address',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'Optional',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(AppConstants.textLight)),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Business Terms Section
            Container(
              color: const Color(AppConstants.white),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Business Terms',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Color(AppConstants.textLight),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Payment Terms
                  TextField(
                    controller: _paymentTermsController,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Payment Terms',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'e.g., Net 30, Cash on Delivery',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(AppConstants.textLight)),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Notes
                  TextField(
                    controller: _notesController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 15),
                    decoration: InputDecoration(
                      labelText: 'Notes',
                      labelStyle: const TextStyle(fontSize: 14),
                      hintText: 'Any additional notes about this supplier',
                      hintStyle: const TextStyle(fontSize: 13, color: Color(AppConstants.textLight)),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: const Color(AppConstants.textLight).withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _paymentTermsController.dispose();
    _notesController.dispose();
    super.dispose();
  }
}
