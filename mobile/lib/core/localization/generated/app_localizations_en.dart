// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Makhzani';

  @override
  String get auth_phoneInputTitle => 'Enter your phone number to continue';

  @override
  String get auth_phoneLabel => 'Phone Number';

  @override
  String get auth_phoneHint => '6XXXXXXXX';

  @override
  String get auth_phonePrefixMorocco => '+212';

  @override
  String get auth_sendCode => 'Send Code';

  @override
  String get auth_verifyTitle => 'Enter verification code';

  @override
  String auth_verifySubtitle(String phoneNumber) {
    return 'We sent a 4-digit code to\n$phoneNumber';
  }

  @override
  String get auth_verify => 'Verify';

  @override
  String get auth_resendCode => 'Resend Code';

  @override
  String get auth_codeResent => 'Code resent successfully';

  @override
  String get auth_invalidCode => 'Invalid code. Please try again.';

  @override
  String get auth_failedToSendOtp => 'Failed to send OTP. Please try again.';

  @override
  String get validation_required => 'This field is required';

  @override
  String get validation_phoneLength => 'Phone number must be 9 digits';

  @override
  String get validation_phonePrefix =>
      'Phone number must start with 5, 6, or 7';

  @override
  String get validation_otpLength => 'Please enter the 4-digit code';

  @override
  String get validation_phoneFormat =>
      'Invalid Morocco phone format (+212XXXXXXXXX)';

  @override
  String get validation_emailFormat => 'Invalid email format';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get dashboard_totalProducts => 'Total Products';

  @override
  String get dashboard_lowStock => 'Low Stock';

  @override
  String get dashboard_totalSuppliers => 'Suppliers';

  @override
  String get dashboard_pendingOrders => 'Pending Orders';

  @override
  String get dashboard_recentOrders => 'Recent Orders';

  @override
  String get dashboard_quickActions => 'Quick Actions';

  @override
  String get dashboard_viewAll => 'View All';

  @override
  String get dashboard_allStocked => 'All products are well stocked';

  @override
  String dashboard_seeAllItems(int count) {
    return 'See all $count items';
  }

  @override
  String get dashboard_noOrders => 'No orders yet';

  @override
  String get dashboard_seeAllOrders => 'See all orders';

  @override
  String get products => 'Products';

  @override
  String get products_add => 'Add Product';

  @override
  String get products_edit => 'Edit Product';

  @override
  String get products_name => 'Product Name';

  @override
  String get products_sku => 'SKU';

  @override
  String get products_price => 'Price';

  @override
  String get products_costPrice => 'Cost Price';

  @override
  String get products_sellingPrice => 'Selling Price';

  @override
  String get products_quantity => 'Quantity';

  @override
  String get products_minStock => 'Minimum Stock';

  @override
  String get products_category => 'Category';

  @override
  String get products_description => 'Description';

  @override
  String get products_inStock => 'In Stock';

  @override
  String get products_outOfStock => 'Out of Stock';

  @override
  String get products_lowStockWarning => 'Low stock';

  @override
  String get products_empty => 'No products yet';

  @override
  String get products_emptyDescription =>
      'Add your first product to get started';

  @override
  String get products_searchHint => 'Search products...';

  @override
  String get products_noResults => 'No products found';

  @override
  String get products_adjustFilters => 'Try adjusting your search or filters';

  @override
  String get products_currentStock => 'Current Stock';

  @override
  String get products_reorderThreshold => 'Reorder Threshold';

  @override
  String get products_barcode => 'Barcode';

  @override
  String get products_unit => 'Unit';

  @override
  String get products_details => 'Details';

  @override
  String get products_adjustStock => 'Adjust Stock';

  @override
  String get products_stockAdjusted => 'Stock adjusted successfully';

  @override
  String get products_created => 'Product created successfully';

  @override
  String get products_updated => 'Product updated successfully';

  @override
  String get products_deleted => 'Product deleted successfully';

  @override
  String get products_deleteConfirm =>
      'Are you sure you want to delete this product?';

  @override
  String get products_lowStockOnly => 'Low stock only';

  @override
  String get products_newStock => 'New stock';

  @override
  String get products_stockNegativeError => 'Stock cannot be negative';

  @override
  String get products_reason => 'Reason (optional)';

  @override
  String get products_adjustment => 'Adjustment';

  @override
  String get products_adjustmentHint => '+10 or -5';

  @override
  String get products_adjustmentHelper => 'Use + to add stock, - to remove';

  @override
  String get suppliers => 'Suppliers';

  @override
  String get suppliers_add => 'Add Supplier';

  @override
  String get suppliers_edit => 'Edit Supplier';

  @override
  String get suppliers_name => 'Supplier Name';

  @override
  String get suppliers_phone => 'Phone';

  @override
  String get suppliers_email => 'Email';

  @override
  String get suppliers_address => 'Address';

  @override
  String get suppliers_city => 'City';

  @override
  String get suppliers_notes => 'Notes';

  @override
  String get suppliers_empty => 'No suppliers yet';

  @override
  String get suppliers_emptyDescription =>
      'Add your first supplier to manage your purchases';

  @override
  String get suppliers_unknown => 'Unknown Supplier';

  @override
  String get suppliers_searchHint => 'Search suppliers...';

  @override
  String get suppliers_noResults => 'No suppliers found';

  @override
  String get suppliers_adjustFilters => 'Try adjusting your search';

  @override
  String get suppliers_businessName => 'Business Name';

  @override
  String suppliers_totalOrders(int count) {
    return '$count orders';
  }

  @override
  String get suppliers_contactInfo => 'Contact Information';

  @override
  String get suppliers_relationship => 'Relationship';

  @override
  String get suppliers_preferredContact => 'Preferred Contact';

  @override
  String get suppliers_paymentTerms => 'Payment Terms';

  @override
  String get suppliers_linkedSince => 'Linked Since';

  @override
  String get suppliers_lastOrder => 'Last Order';

  @override
  String get suppliers_recentOrders => 'Recent Orders';

  @override
  String get suppliers_noOrders => 'No orders with this supplier yet';

  @override
  String get suppliers_deleted => 'Supplier removed successfully';

  @override
  String get suppliers_deleteConfirm =>
      'Are you sure you want to remove this supplier?';

  @override
  String get suppliers_deleteBlockedOrders =>
      'Cannot remove supplier with existing orders';

  @override
  String get suppliers_contactWhatsApp => 'WhatsApp';

  @override
  String get suppliers_contactPhone => 'Phone';

  @override
  String get suppliers_contactEmail => 'Email';

  @override
  String get suppliers_orderPdf => 'PDF';

  @override
  String get suppliers_orderSent => 'Sent';

  @override
  String get suppliers_created => 'Supplier added successfully';

  @override
  String get suppliers_updated => 'Supplier updated successfully';

  @override
  String get suppliers_phoneHelper =>
      'Format: +212XXXXXXXXX (9 digits after +212)';

  @override
  String get suppliers_citySelect => 'Select City';

  @override
  String get orders => 'Orders';

  @override
  String get orders_purchase => 'Purchase Orders';

  @override
  String get orders_create => 'Create Order';

  @override
  String get orders_edit => 'Edit Order';

  @override
  String get orders_supplier => 'Supplier';

  @override
  String get orders_selectSupplier => 'Select Supplier';

  @override
  String get orders_items => 'Items';

  @override
  String get orders_addItem => 'Add Item';

  @override
  String get orders_total => 'Total';

  @override
  String get orders_status => 'Status';

  @override
  String get orders_status_draft => 'Draft';

  @override
  String get orders_status_sent => 'Sent';

  @override
  String get orders_status_received => 'Received';

  @override
  String get orders_status_cancelled => 'Cancelled';

  @override
  String get orders_markSent => 'Mark as Sent';

  @override
  String get orders_markReceived => 'Mark as Received';

  @override
  String get orders_generatePdf => 'Generate PDF';

  @override
  String get orders_downloadPdf => 'Download PDF';

  @override
  String get orders_empty => 'No orders yet';

  @override
  String get orders_emptyDescription => 'Create your first purchase order';

  @override
  String get profile => 'Profile';

  @override
  String get profile_businessName => 'Business Name';

  @override
  String get profile_ownerName => 'Owner Name';

  @override
  String get profile_phone => 'Phone';

  @override
  String get profile_email => 'Email';

  @override
  String get profile_region => 'Region';

  @override
  String get profile_subscription => 'Subscription';

  @override
  String profile_trialEnds(String date) {
    return 'Trial ends $date';
  }

  @override
  String get settings => 'Settings';

  @override
  String get settings_language => 'Language';

  @override
  String get settings_notifications => 'Notifications';

  @override
  String get settings_about => 'About';

  @override
  String settings_version(String version) {
    return 'Version $version';
  }

  @override
  String get common_save => 'Save';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_delete => 'Delete';

  @override
  String get common_edit => 'Edit';

  @override
  String get common_add => 'Add';

  @override
  String get common_search => 'Search';

  @override
  String get common_filter => 'Filter';

  @override
  String get common_sort => 'Sort';

  @override
  String get common_refresh => 'Refresh';

  @override
  String get common_retry => 'Retry';

  @override
  String get common_loading => 'Loading...';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_yes => 'Yes';

  @override
  String get common_no => 'No';

  @override
  String get common_ok => 'OK';

  @override
  String get common_clear => 'Clear';

  @override
  String get common_close => 'Close';

  @override
  String get common_back => 'Back';

  @override
  String get common_next => 'Next';

  @override
  String get common_done => 'Done';

  @override
  String get common_skip => 'Skip';

  @override
  String get common_moreOptions => 'More options';

  @override
  String get common_selectAll => 'Select All';

  @override
  String get common_clearAll => 'Clear All';

  @override
  String get common_today => 'Today';

  @override
  String get common_yesterday => 'Yesterday';

  @override
  String common_daysAgo(int count) {
    return '$count days ago';
  }

  @override
  String get error_generic => 'Something went wrong';

  @override
  String get error_network => 'No internet connection';

  @override
  String get error_server => 'Server error. Please try again later.';

  @override
  String get error_timeout => 'Request timed out';

  @override
  String get error_unknown => 'An unknown error occurred';

  @override
  String get success_saved => 'Saved successfully';

  @override
  String get success_deleted => 'Deleted successfully';

  @override
  String get success_updated => 'Updated successfully';

  @override
  String get success_created => 'Created successfully';

  @override
  String get confirm_delete => 'Are you sure you want to delete this?';

  @override
  String get confirm_deleteTitle => 'Delete';

  @override
  String get confirm_logout => 'Are you sure you want to logout?';

  @override
  String get confirm_logoutTitle => 'Logout';

  @override
  String get confirm_discard => 'Are you sure you want to discard changes?';

  @override
  String get confirm_discardTitle => 'Discard Changes';

  @override
  String get logout => 'Logout';

  @override
  String get theme_light => 'Light Mode';

  @override
  String get theme_dark => 'Dark Mode';

  @override
  String get language_switchToArabic => 'العربية';

  @override
  String get language_switchToEnglish => 'English';

  @override
  String get nav_dashboard => 'Dashboard';

  @override
  String get nav_products => 'Products';

  @override
  String get nav_suppliers => 'Suppliers';

  @override
  String get nav_orders => 'Orders';

  @override
  String get comingSoon => 'Coming Soon';

  @override
  String get comingSoon_description => 'This feature is under development';

  @override
  String get sort_nameAsc => 'Name A→Z';

  @override
  String get sort_nameDesc => 'Name Z→A';

  @override
  String get sort_stockLow => 'Stock: Low first';

  @override
  String get sort_stockHigh => 'Stock: High first';

  @override
  String get sort_priceLow => 'Price: Low first';

  @override
  String get sort_priceHigh => 'Price: High first';

  @override
  String get sort_newest => 'Newest first';

  @override
  String products_resultsCount(int count) {
    return '$count products';
  }

  @override
  String get currency_mad => 'MAD';

  @override
  String itemCount(int count) {
    return '$count items';
  }

  @override
  String itemCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count items',
      one: '1 item',
      zero: 'No items',
    );
    return '$_temp0';
  }
}
