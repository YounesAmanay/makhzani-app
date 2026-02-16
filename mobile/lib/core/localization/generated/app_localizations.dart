import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Makhzani'**
  String get appName;

  /// No description provided for @auth_phoneInputTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter your phone number to continue'**
  String get auth_phoneInputTitle;

  /// No description provided for @auth_phoneLabel.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get auth_phoneLabel;

  /// No description provided for @auth_phoneHint.
  ///
  /// In en, this message translates to:
  /// **'6XXXXXXXX'**
  String get auth_phoneHint;

  /// No description provided for @auth_phonePrefixMorocco.
  ///
  /// In en, this message translates to:
  /// **'+212'**
  String get auth_phonePrefixMorocco;

  /// No description provided for @auth_sendCode.
  ///
  /// In en, this message translates to:
  /// **'Send Code'**
  String get auth_sendCode;

  /// No description provided for @auth_verifyTitle.
  ///
  /// In en, this message translates to:
  /// **'Enter verification code'**
  String get auth_verifyTitle;

  /// No description provided for @auth_verifySubtitle.
  ///
  /// In en, this message translates to:
  /// **'We sent a 4-digit code to\n{phoneNumber}'**
  String auth_verifySubtitle(String phoneNumber);

  /// No description provided for @auth_verify.
  ///
  /// In en, this message translates to:
  /// **'Verify'**
  String get auth_verify;

  /// No description provided for @auth_resendCode.
  ///
  /// In en, this message translates to:
  /// **'Resend Code'**
  String get auth_resendCode;

  /// No description provided for @auth_codeResent.
  ///
  /// In en, this message translates to:
  /// **'Code resent successfully'**
  String get auth_codeResent;

  /// No description provided for @auth_invalidCode.
  ///
  /// In en, this message translates to:
  /// **'Invalid code. Please try again.'**
  String get auth_invalidCode;

  /// No description provided for @auth_failedToSendOtp.
  ///
  /// In en, this message translates to:
  /// **'Failed to send OTP. Please try again.'**
  String get auth_failedToSendOtp;

  /// No description provided for @validation_required.
  ///
  /// In en, this message translates to:
  /// **'This field is required'**
  String get validation_required;

  /// No description provided for @validation_phoneLength.
  ///
  /// In en, this message translates to:
  /// **'Phone number must be 9 digits'**
  String get validation_phoneLength;

  /// No description provided for @validation_phonePrefix.
  ///
  /// In en, this message translates to:
  /// **'Phone number must start with 5, 6, or 7'**
  String get validation_phonePrefix;

  /// No description provided for @validation_otpLength.
  ///
  /// In en, this message translates to:
  /// **'Please enter the 4-digit code'**
  String get validation_otpLength;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @dashboard_totalProducts.
  ///
  /// In en, this message translates to:
  /// **'Total Products'**
  String get dashboard_totalProducts;

  /// No description provided for @dashboard_lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get dashboard_lowStock;

  /// No description provided for @dashboard_totalSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get dashboard_totalSuppliers;

  /// No description provided for @dashboard_pendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get dashboard_pendingOrders;

  /// No description provided for @dashboard_recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get dashboard_recentOrders;

  /// No description provided for @dashboard_quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get dashboard_quickActions;

  /// No description provided for @dashboard_viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get dashboard_viewAll;

  /// No description provided for @dashboard_allStocked.
  ///
  /// In en, this message translates to:
  /// **'All products are well stocked'**
  String get dashboard_allStocked;

  /// No description provided for @dashboard_seeAllItems.
  ///
  /// In en, this message translates to:
  /// **'See all {count} items'**
  String dashboard_seeAllItems(int count);

  /// No description provided for @dashboard_noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get dashboard_noOrders;

  /// No description provided for @dashboard_seeAllOrders.
  ///
  /// In en, this message translates to:
  /// **'See all orders'**
  String get dashboard_seeAllOrders;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get products;

  /// No description provided for @products_add.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get products_add;

  /// No description provided for @products_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Product'**
  String get products_edit;

  /// No description provided for @products_name.
  ///
  /// In en, this message translates to:
  /// **'Product Name'**
  String get products_name;

  /// No description provided for @products_sku.
  ///
  /// In en, this message translates to:
  /// **'SKU'**
  String get products_sku;

  /// No description provided for @products_price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get products_price;

  /// No description provided for @products_costPrice.
  ///
  /// In en, this message translates to:
  /// **'Cost Price'**
  String get products_costPrice;

  /// No description provided for @products_sellingPrice.
  ///
  /// In en, this message translates to:
  /// **'Selling Price'**
  String get products_sellingPrice;

  /// No description provided for @products_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get products_quantity;

  /// No description provided for @products_minStock.
  ///
  /// In en, this message translates to:
  /// **'Minimum Stock'**
  String get products_minStock;

  /// No description provided for @products_category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get products_category;

  /// No description provided for @products_description.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get products_description;

  /// No description provided for @products_inStock.
  ///
  /// In en, this message translates to:
  /// **'In Stock'**
  String get products_inStock;

  /// No description provided for @products_outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get products_outOfStock;

  /// No description provided for @products_lowStockWarning.
  ///
  /// In en, this message translates to:
  /// **'Low stock'**
  String get products_lowStockWarning;

  /// No description provided for @products_empty.
  ///
  /// In en, this message translates to:
  /// **'No products yet'**
  String get products_empty;

  /// No description provided for @products_emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first product to get started'**
  String get products_emptyDescription;

  /// No description provided for @products_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get products_searchHint;

  /// No description provided for @products_noResults.
  ///
  /// In en, this message translates to:
  /// **'No products found'**
  String get products_noResults;

  /// No description provided for @products_adjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search or filters'**
  String get products_adjustFilters;

  /// No description provided for @products_currentStock.
  ///
  /// In en, this message translates to:
  /// **'Current Stock'**
  String get products_currentStock;

  /// No description provided for @products_reorderThreshold.
  ///
  /// In en, this message translates to:
  /// **'Reorder Threshold'**
  String get products_reorderThreshold;

  /// No description provided for @products_barcode.
  ///
  /// In en, this message translates to:
  /// **'Barcode'**
  String get products_barcode;

  /// No description provided for @products_unit.
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get products_unit;

  /// No description provided for @products_details.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get products_details;

  /// No description provided for @products_adjustStock.
  ///
  /// In en, this message translates to:
  /// **'Adjust Stock'**
  String get products_adjustStock;

  /// No description provided for @products_stockAdjusted.
  ///
  /// In en, this message translates to:
  /// **'Stock adjusted successfully'**
  String get products_stockAdjusted;

  /// No description provided for @products_created.
  ///
  /// In en, this message translates to:
  /// **'Product created successfully'**
  String get products_created;

  /// No description provided for @products_updated.
  ///
  /// In en, this message translates to:
  /// **'Product updated successfully'**
  String get products_updated;

  /// No description provided for @products_deleted.
  ///
  /// In en, this message translates to:
  /// **'Product deleted successfully'**
  String get products_deleted;

  /// No description provided for @products_deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this product?'**
  String get products_deleteConfirm;

  /// No description provided for @products_lowStockOnly.
  ///
  /// In en, this message translates to:
  /// **'Low stock only'**
  String get products_lowStockOnly;

  /// No description provided for @products_newStock.
  ///
  /// In en, this message translates to:
  /// **'New stock'**
  String get products_newStock;

  /// No description provided for @products_stockNegativeError.
  ///
  /// In en, this message translates to:
  /// **'Stock cannot be negative'**
  String get products_stockNegativeError;

  /// No description provided for @products_reason.
  ///
  /// In en, this message translates to:
  /// **'Reason (optional)'**
  String get products_reason;

  /// No description provided for @products_adjustment.
  ///
  /// In en, this message translates to:
  /// **'Adjustment'**
  String get products_adjustment;

  /// No description provided for @products_adjustmentHint.
  ///
  /// In en, this message translates to:
  /// **'+10 or -5'**
  String get products_adjustmentHint;

  /// No description provided for @products_adjustmentHelper.
  ///
  /// In en, this message translates to:
  /// **'Use + to add stock, - to remove'**
  String get products_adjustmentHelper;

  /// No description provided for @suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get suppliers;

  /// No description provided for @suppliers_add.
  ///
  /// In en, this message translates to:
  /// **'Add Supplier'**
  String get suppliers_add;

  /// No description provided for @suppliers_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Supplier'**
  String get suppliers_edit;

  /// No description provided for @suppliers_name.
  ///
  /// In en, this message translates to:
  /// **'Supplier Name'**
  String get suppliers_name;

  /// No description provided for @suppliers_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get suppliers_phone;

  /// No description provided for @suppliers_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get suppliers_email;

  /// No description provided for @suppliers_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get suppliers_address;

  /// No description provided for @suppliers_city.
  ///
  /// In en, this message translates to:
  /// **'City'**
  String get suppliers_city;

  /// No description provided for @suppliers_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get suppliers_notes;

  /// No description provided for @suppliers_empty.
  ///
  /// In en, this message translates to:
  /// **'No suppliers yet'**
  String get suppliers_empty;

  /// No description provided for @suppliers_emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Add your first supplier to manage your purchases'**
  String get suppliers_emptyDescription;

  /// No description provided for @suppliers_unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown Supplier'**
  String get suppliers_unknown;

  /// No description provided for @suppliers_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search suppliers...'**
  String get suppliers_searchHint;

  /// No description provided for @suppliers_noResults.
  ///
  /// In en, this message translates to:
  /// **'No suppliers found'**
  String get suppliers_noResults;

  /// No description provided for @suppliers_adjustFilters.
  ///
  /// In en, this message translates to:
  /// **'Try adjusting your search'**
  String get suppliers_adjustFilters;

  /// No description provided for @suppliers_businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get suppliers_businessName;

  /// No description provided for @suppliers_totalOrders.
  ///
  /// In en, this message translates to:
  /// **'{count} orders'**
  String suppliers_totalOrders(int count);

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @orders_purchase.
  ///
  /// In en, this message translates to:
  /// **'Purchase Orders'**
  String get orders_purchase;

  /// No description provided for @orders_create.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get orders_create;

  /// No description provided for @orders_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit Order'**
  String get orders_edit;

  /// No description provided for @orders_supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get orders_supplier;

  /// No description provided for @orders_selectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get orders_selectSupplier;

  /// No description provided for @orders_items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orders_items;

  /// No description provided for @orders_addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get orders_addItem;

  /// No description provided for @orders_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orders_total;

  /// No description provided for @orders_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orders_status;

  /// No description provided for @orders_status_draft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get orders_status_draft;

  /// No description provided for @orders_status_sent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get orders_status_sent;

  /// No description provided for @orders_status_received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get orders_status_received;

  /// No description provided for @orders_status_cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get orders_status_cancelled;

  /// No description provided for @orders_markSent.
  ///
  /// In en, this message translates to:
  /// **'Mark as Sent'**
  String get orders_markSent;

  /// No description provided for @orders_markReceived.
  ///
  /// In en, this message translates to:
  /// **'Mark as Received'**
  String get orders_markReceived;

  /// No description provided for @orders_generatePdf.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get orders_generatePdf;

  /// No description provided for @orders_downloadPdf.
  ///
  /// In en, this message translates to:
  /// **'Download PDF'**
  String get orders_downloadPdf;

  /// No description provided for @orders_empty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orders_empty;

  /// No description provided for @orders_emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first purchase order'**
  String get orders_emptyDescription;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @profile_businessName.
  ///
  /// In en, this message translates to:
  /// **'Business Name'**
  String get profile_businessName;

  /// No description provided for @profile_ownerName.
  ///
  /// In en, this message translates to:
  /// **'Owner Name'**
  String get profile_ownerName;

  /// No description provided for @profile_phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get profile_phone;

  /// No description provided for @profile_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get profile_email;

  /// No description provided for @profile_region.
  ///
  /// In en, this message translates to:
  /// **'Region'**
  String get profile_region;

  /// No description provided for @profile_subscription.
  ///
  /// In en, this message translates to:
  /// **'Subscription'**
  String get profile_subscription;

  /// No description provided for @profile_trialEnds.
  ///
  /// In en, this message translates to:
  /// **'Trial ends {date}'**
  String profile_trialEnds(String date);

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @settings_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settings_language;

  /// No description provided for @settings_notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get settings_notifications;

  /// No description provided for @settings_about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get settings_about;

  /// No description provided for @settings_version.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String settings_version(String version);

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get common_delete;

  /// No description provided for @common_edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get common_edit;

  /// No description provided for @common_add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get common_add;

  /// No description provided for @common_search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get common_search;

  /// No description provided for @common_filter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get common_filter;

  /// No description provided for @common_sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get common_sort;

  /// No description provided for @common_refresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get common_refresh;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get common_yes;

  /// No description provided for @common_no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get common_no;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get common_clear;

  /// No description provided for @common_close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get common_close;

  /// No description provided for @common_back.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get common_back;

  /// No description provided for @common_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get common_next;

  /// No description provided for @common_done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get common_done;

  /// No description provided for @common_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get common_skip;

  /// No description provided for @common_moreOptions.
  ///
  /// In en, this message translates to:
  /// **'More options'**
  String get common_moreOptions;

  /// No description provided for @common_selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select All'**
  String get common_selectAll;

  /// No description provided for @common_clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear All'**
  String get common_clearAll;

  /// No description provided for @common_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get common_today;

  /// No description provided for @common_yesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get common_yesterday;

  /// No description provided for @common_daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} days ago'**
  String common_daysAgo(int count);

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_generic;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get error_network;

  /// No description provided for @error_server.
  ///
  /// In en, this message translates to:
  /// **'Server error. Please try again later.'**
  String get error_server;

  /// No description provided for @error_timeout.
  ///
  /// In en, this message translates to:
  /// **'Request timed out'**
  String get error_timeout;

  /// No description provided for @error_unknown.
  ///
  /// In en, this message translates to:
  /// **'An unknown error occurred'**
  String get error_unknown;

  /// No description provided for @success_saved.
  ///
  /// In en, this message translates to:
  /// **'Saved successfully'**
  String get success_saved;

  /// No description provided for @success_deleted.
  ///
  /// In en, this message translates to:
  /// **'Deleted successfully'**
  String get success_deleted;

  /// No description provided for @success_updated.
  ///
  /// In en, this message translates to:
  /// **'Updated successfully'**
  String get success_updated;

  /// No description provided for @success_created.
  ///
  /// In en, this message translates to:
  /// **'Created successfully'**
  String get success_created;

  /// No description provided for @confirm_delete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this?'**
  String get confirm_delete;

  /// No description provided for @confirm_deleteTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get confirm_deleteTitle;

  /// No description provided for @confirm_logout.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get confirm_logout;

  /// No description provided for @confirm_logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get confirm_logoutTitle;

  /// No description provided for @confirm_discard.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to discard changes?'**
  String get confirm_discard;

  /// No description provided for @confirm_discardTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard Changes'**
  String get confirm_discardTitle;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @theme_light.
  ///
  /// In en, this message translates to:
  /// **'Light Mode'**
  String get theme_light;

  /// No description provided for @theme_dark.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get theme_dark;

  /// No description provided for @language_switchToArabic.
  ///
  /// In en, this message translates to:
  /// **'العربية'**
  String get language_switchToArabic;

  /// No description provided for @language_switchToEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_switchToEnglish;

  /// No description provided for @nav_dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get nav_dashboard;

  /// No description provided for @nav_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get nav_products;

  /// No description provided for @nav_suppliers.
  ///
  /// In en, this message translates to:
  /// **'Suppliers'**
  String get nav_suppliers;

  /// No description provided for @nav_orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get nav_orders;

  /// No description provided for @comingSoon.
  ///
  /// In en, this message translates to:
  /// **'Coming Soon'**
  String get comingSoon;

  /// No description provided for @comingSoon_description.
  ///
  /// In en, this message translates to:
  /// **'This feature is under development'**
  String get comingSoon_description;

  /// No description provided for @sort_nameAsc.
  ///
  /// In en, this message translates to:
  /// **'Name A→Z'**
  String get sort_nameAsc;

  /// No description provided for @sort_nameDesc.
  ///
  /// In en, this message translates to:
  /// **'Name Z→A'**
  String get sort_nameDesc;

  /// No description provided for @sort_stockLow.
  ///
  /// In en, this message translates to:
  /// **'Stock: Low first'**
  String get sort_stockLow;

  /// No description provided for @sort_stockHigh.
  ///
  /// In en, this message translates to:
  /// **'Stock: High first'**
  String get sort_stockHigh;

  /// No description provided for @sort_priceLow.
  ///
  /// In en, this message translates to:
  /// **'Price: Low first'**
  String get sort_priceLow;

  /// No description provided for @sort_priceHigh.
  ///
  /// In en, this message translates to:
  /// **'Price: High first'**
  String get sort_priceHigh;

  /// No description provided for @sort_newest.
  ///
  /// In en, this message translates to:
  /// **'Newest first'**
  String get sort_newest;

  /// No description provided for @products_resultsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String products_resultsCount(int count);

  /// No description provided for @currency_mad.
  ///
  /// In en, this message translates to:
  /// **'MAD'**
  String get currency_mad;

  /// No description provided for @itemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String itemCount(int count);

  /// No description provided for @itemCountPlural.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{No items} =1{1 item} other{{count} items}}'**
  String itemCountPlural(int count);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
