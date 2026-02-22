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
  String get auth_resendFailed => 'Failed to resend code';

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
  String get products_photos => 'Photos';

  @override
  String get products_addPhoto => 'Add Photo';

  @override
  String get products_deletePhoto => 'Delete Photo';

  @override
  String get products_maxPhotos => 'Maximum 5 photos allowed';

  @override
  String get products_scanBarcode => 'Scan Barcode';

  @override
  String get products_scanSubtitle => 'Auto-fill product details instantly';

  @override
  String get products_lookingUp => 'Looking up product...';

  @override
  String get products_toggleTorch => 'Toggle flashlight';

  @override
  String get products_rescan => 'Re-scan';

  @override
  String get products_notFound => 'Product not found';

  @override
  String get products_notFoundMessage =>
      'This barcode isn\'t in our database. You can fill the details manually.';

  @override
  String get products_enterManually => 'Enter Manually';

  @override
  String get products_scanAgain => 'Scan Again';

  @override
  String products_autoFilled(String source) {
    return 'Data from $source';
  }

  @override
  String get products_stockSection => 'Stock Information';

  @override
  String get products_pricingSection => 'Pricing';

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
  String get suppliers_filterAllCities => 'All Cities';

  @override
  String get suppliers_citySelect => 'Select City';

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
  String get profile_editProfile => 'Edit Profile';

  @override
  String get profile_shopName => 'Shop Name';

  @override
  String get profile_address => 'Address';

  @override
  String get profile_updated => 'Profile updated successfully';

  @override
  String get profile_selectRegion => 'Select region';

  @override
  String get profile_logout => 'Log Out';

  @override
  String get profile_logoutTitle => 'Log Out';

  @override
  String get profile_logoutConfirm => 'Are you sure you want to log out?';

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

  @override
  String get orders => 'Orders';

  @override
  String get orders_title => 'Purchase Orders';

  @override
  String get orders_searchHint => 'Search by order # or supplier...';

  @override
  String get orders_empty => 'No orders yet';

  @override
  String get orders_emptyDescription =>
      'Create your first purchase order to track inventory';

  @override
  String get orders_add => 'New Order';

  @override
  String get orders_orderNumber => 'Order Number';

  @override
  String get orders_supplier => 'Supplier';

  @override
  String get orders_totalItems => 'Total Items';

  @override
  String get orders_totalValue => 'Total Value';

  @override
  String get orders_notes => 'Notes';

  @override
  String get orders_status => 'Status';

  @override
  String get orders_statusDraft => 'Draft';

  @override
  String get orders_statusGenerated => 'Ready';

  @override
  String get orders_statusSent => 'Sent';

  @override
  String get orders_filterSupplier => 'Filter by Supplier';

  @override
  String get orders_filterStatus => 'Filter by Status';

  @override
  String get orders_filterAll => 'All Orders';

  @override
  String get orders_filterAllSuppliers => 'All Suppliers';

  @override
  String get orders_createdAt => 'Created';

  @override
  String get orders_sentAt => 'Sent';

  @override
  String get orders_items => 'items';

  @override
  String get orders_item => 'item';

  @override
  String get orders_createTitle => 'Create Purchase Order';

  @override
  String get orders_selectSupplier => 'Select Supplier';

  @override
  String get orders_supplierRequired => 'Supplier is required';

  @override
  String get orders_products => 'Products';

  @override
  String get orders_addProduct => 'Add Product';

  @override
  String get orders_selectProduct => 'Select Product';

  @override
  String get orders_quantity => 'Quantity';

  @override
  String get orders_unitPrice => 'Unit Price';

  @override
  String get orders_itemTotal => 'Total';

  @override
  String get orders_remove => 'Remove';

  @override
  String get orders_grandTotal => 'Grand Total';

  @override
  String get orders_notesOptional => 'Notes (optional)';

  @override
  String get orders_notesPlaceholder => 'Add delivery instructions or notes';

  @override
  String get orders_createButton => 'Create Order';

  @override
  String get orders_atLeastOneProduct => 'Add at least one product';

  @override
  String get orders_quantityRequired => 'Quantity is required';

  @override
  String get orders_quantityMin => 'Quantity must be greater than 0';

  @override
  String get orders_priceMin => 'Price must be 0 or greater';

  @override
  String get orders_noSuppliersAvailable => 'No suppliers available';

  @override
  String get orders_addSupplierFirst => 'You need to add a supplier first';

  @override
  String get orders_noProductsAvailable => 'No products available';

  @override
  String get orders_addProductFirst => 'You need to add products first';

  @override
  String get orders_productAlreadyAdded => 'This product is already added';

  @override
  String get orders_orderCreated => 'Order created successfully';

  @override
  String get orders_errorSupplierNotFound => 'Supplier not found';

  @override
  String get orders_errorProductsNotFound => 'One or more products not found';

  @override
  String get orders_orderDetails => 'Order Details';

  @override
  String get orders_orderNotFound => 'Order not found';

  @override
  String get orders_totalQuantity => 'Total Quantity';

  @override
  String get orders_generatePdf => 'Generate PDF';

  @override
  String get orders_downloadPdf => 'Download PDF';

  @override
  String get orders_markAsSent => 'Mark as Sent';

  @override
  String get orders_pdfGenerated => 'PDF generated successfully';

  @override
  String get orders_markedAsSent => 'Order marked as sent';

  @override
  String get orders_pdfNotAvailable => 'PDF not available';

  @override
  String get orders_downloadingPdf => 'Opening PDF...';

  @override
  String get orders_markSentTitle => 'How was the order sent?';

  @override
  String get orders_markSentDescription =>
      'Select the method used to send the order';

  @override
  String get orders_sentViaWhatsApp => 'WhatsApp';

  @override
  String get orders_sentViaEmail => 'Email';

  @override
  String get orders_sentViaPhone => 'Phone Call';

  @override
  String get orders_sentViaInPerson => 'In Person';

  @override
  String get orders_sendViaWhatsApp => 'Send via WhatsApp';

  @override
  String get orders_generateAndOpen => 'Generate PDF';

  @override
  String get orders_noWhatsapp => 'WhatsApp is not installed';

  @override
  String get orders_pdfError => 'Failed to generate PDF. Please try again.';

  @override
  String get orders_whatsappSent => 'Order sent via WhatsApp';

  @override
  String get orders_newOrderTitle => 'New Order';

  @override
  String get orders_selectSupplierHint => 'Search suppliers...';

  @override
  String get orders_selectSupplierPrompt =>
      'Select a supplier to start building your order';

  @override
  String get orders_changeSupplier => 'Change Supplier';

  @override
  String get orders_selectSupplierAction => 'Select Supplier';

  @override
  String get orders_recentSuppliers => 'Recent';

  @override
  String get orders_allSuppliers => 'All Suppliers';

  @override
  String orders_buildOrderTitle(String supplierName) {
    return '$supplierName\'s Order';
  }

  @override
  String get orders_searchProducts => 'Search products...';

  @override
  String get orders_addToOrder => 'Add';

  @override
  String orders_addToOrderTotal(String total) {
    return 'Add to Order ($total MAD)';
  }

  @override
  String orders_updateTotal(String total) {
    return 'Update ($total MAD)';
  }

  @override
  String get orders_removeFromOrder => 'Remove from order';

  @override
  String get orders_inOrder => 'In Order';

  @override
  String get orders_reviewTitle => 'Review Order';

  @override
  String get orders_saveAsDraft => 'Save as Draft';

  @override
  String get orders_draftSaved => 'Order saved as draft';

  @override
  String get orders_callSupplier => 'Call supplier';

  @override
  String orders_itemsSummary(int count, String total) {
    return '$count items · $total MAD';
  }

  @override
  String get orders_reviewOrder => 'Create & Review';

  @override
  String get orders_outOfStock => 'Out of stock';

  @override
  String orders_stockLabel(int count, String unit) {
    return 'Stock: $count $unit';
  }

  @override
  String orders_whatsappGreeting(String supplierName) {
    return 'Hello $supplierName,';
  }

  @override
  String orders_whatsappIntro(String orderNumber) {
    return 'Here is my order ($orderNumber):';
  }

  @override
  String orders_whatsappTotal(String total) {
    return 'Total: $total MAD';
  }

  @override
  String get orders_whatsappClosing => 'Thank you';

  @override
  String get orders_receiveOrder => 'Receive Order';

  @override
  String get orders_statusReceived => 'Received';

  @override
  String get orders_receiveConfirmTitle => 'Receive this order?';

  @override
  String get orders_receiveConfirmMessage =>
      'This will automatically add the ordered quantities to your stock. This action cannot be undone.';

  @override
  String get orders_receiveSuccess =>
      'Order received — stock updated successfully';

  @override
  String get orders_receiveError =>
      'Failed to receive order. Please try again.';

  @override
  String get orders_alreadyReceived => 'Already Received';

  @override
  String common_minutesAgo(int count) {
    return '$count min ago';
  }

  @override
  String common_hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String get common_seeAll => 'See all';

  @override
  String get categories_title => 'Categories';

  @override
  String get categories_add => 'Add Category';

  @override
  String get categories_empty => 'No categories yet';

  @override
  String get categories_emptyDescription =>
      'Create categories to organize your products';

  @override
  String get categories_selectHint => 'None (uncategorized)';

  @override
  String get categories_none => 'None';

  @override
  String get categories_created => 'Category created';

  @override
  String get categories_deleted => 'Category deleted';

  @override
  String get categories_nameLabel => 'Category Name';

  @override
  String get categories_namePlaceholder => 'e.g. Beverages';

  @override
  String get categories_manage => 'Manage Categories';

  @override
  String get categories_searchHint => 'Search categories...';

  @override
  String get categories_loadDefaults => 'Load default categories';

  @override
  String categories_loadDefaultsSuccess(int count) {
    return '$count default categories added';
  }

  @override
  String get categories_loadDefaultsAlready =>
      'All default categories already exist';

  @override
  String get categories_loadDefaultsError =>
      'Failed to load default categories';

  @override
  String get stockHistory => 'Stock History';

  @override
  String get stockHistory_empty => 'No stock changes recorded';

  @override
  String get stockHistory_manualAdjustment => 'Manual Adjustment';

  @override
  String get stockHistory_orderReceived => 'Order Received';

  @override
  String get stockHistory_wastage => 'Wastage';

  @override
  String get stockHistory_initialStock => 'Initial Stock';

  @override
  String get stockHistory_correction => 'Correction';

  @override
  String get csv_title => 'Import / Export';

  @override
  String get csv_exportTitle => 'Export Products';

  @override
  String get csv_exportDescription =>
      'Download your product list as a CSV file. The CSV will be copied to your clipboard.';

  @override
  String get csv_export => 'Export CSV';

  @override
  String get csv_exportedCopied => 'CSV copied to clipboard';

  @override
  String get csv_importTitle => 'Import Products';

  @override
  String get csv_importDescription =>
      'Paste a CSV to bulk-import products. Existing products will be skipped.';

  @override
  String get csv_formatHint =>
      'Columns: name, barcode, current_stock, reorder_threshold, unit, price, category';

  @override
  String get csv_pasteLabel => 'Paste CSV here';

  @override
  String get csv_pasteHint => 'name,barcode,current_stock,...';

  @override
  String get csv_pasteFirst => 'Please paste CSV data first';

  @override
  String get csv_import => 'Import CSV';

  @override
  String csv_importResult(int created, int skipped) {
    return '$created created, $skipped skipped';
  }

  @override
  String get notifications_title => 'Notifications';

  @override
  String get notifications_empty => 'No notifications yet';

  @override
  String get notifications_emptyDescription =>
      'You\'ll see low-stock alerts and order updates here.';

  @override
  String get notifications_markAllRead => 'Mark all as read';

  @override
  String get notifications_clearAll => 'Clear all';

  @override
  String get notifications_justNow => 'Just now';

  @override
  String notifications_minutesAgo(int count) {
    return '${count}m ago';
  }

  @override
  String notifications_hoursAgo(int count) {
    return '${count}h ago';
  }

  @override
  String notifications_daysAgo(int count) {
    return '${count}d ago';
  }

  @override
  String get notifications_clearConfirmTitle => 'Clear all notifications?';

  @override
  String get notifications_clearConfirmMessage =>
      'This will permanently delete all notifications.';

  @override
  String get notifications_cleared => 'All notifications cleared';

  @override
  String get nav_sales => 'Sales';

  @override
  String get sales_title => 'Sales';

  @override
  String get sales_newSale => 'New Sale';

  @override
  String get sales_history => 'History';

  @override
  String get sales_searchProducts => 'Search products...';

  @override
  String get sales_cartEmpty => 'Cart is empty';

  @override
  String get sales_cartEmptyDescription =>
      'Search or scan a product to add it to the cart.';

  @override
  String get sales_total => 'Total';

  @override
  String sales_items(int count) {
    return '$count items';
  }

  @override
  String get sales_confirmSale => 'Confirm Sale';

  @override
  String get sales_confirmTitle => 'Confirm sale?';

  @override
  String sales_confirmMessage(int count) {
    return 'This will record the sale and update stock for $count product(s).';
  }

  @override
  String get sales_success => 'Sale recorded successfully';

  @override
  String get sales_shareReceipt => 'Share Receipt';

  @override
  String sales_receiptText(String saleNumber, String date, String total) {
    return '🧾 Sale Receipt\nSale #: $saleNumber\nDate: $date\nTotal: $total MAD\n\nThank you!';
  }

  @override
  String get sales_insufficientStock => 'Insufficient stock';

  @override
  String get sales_cancelTitle => 'Cancel sale?';

  @override
  String get sales_cancelMessage =>
      'This will restore stock for all items. Only possible within 24 hours.';

  @override
  String get sales_cancelSuccess => 'Sale cancelled and stock restored';

  @override
  String get sales_noHistory => 'No sales yet';

  @override
  String get sales_noHistoryDescription =>
      'Your confirmed sales will appear here.';

  @override
  String sales_saleNumber(String number) {
    return 'Sale #$number';
  }

  @override
  String get sales_unitPrice => 'Unit price';

  @override
  String get sales_qty => 'Qty';

  @override
  String get sales_notes => 'Note (optional)';

  @override
  String get sales_enterPrice => 'Enter price';

  @override
  String get sales_enterPriceMessage =>
      'This product has no price set. Enter the unit price to add it to the cart.';

  @override
  String get sales_editPrice => 'Edit price';

  @override
  String get sales_priceHint => '0.00';

  @override
  String get sales_noPriceError => 'Please enter a valid price';

  @override
  String get dashboard_todayRevenue => 'Today\'s Revenue';

  @override
  String get dashboard_monthRevenue => 'This Month';
}
