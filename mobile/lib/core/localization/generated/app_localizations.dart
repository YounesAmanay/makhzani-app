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

  /// No description provided for @validation_phoneFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid Morocco phone format (+212XXXXXXXXX)'**
  String get validation_phoneFormat;

  /// No description provided for @validation_emailFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid email format'**
  String get validation_emailFormat;

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

  /// No description provided for @products_photos.
  ///
  /// In en, this message translates to:
  /// **'Photos'**
  String get products_photos;

  /// No description provided for @products_addPhoto.
  ///
  /// In en, this message translates to:
  /// **'Add Photo'**
  String get products_addPhoto;

  /// No description provided for @products_deletePhoto.
  ///
  /// In en, this message translates to:
  /// **'Delete Photo'**
  String get products_deletePhoto;

  /// No description provided for @products_maxPhotos.
  ///
  /// In en, this message translates to:
  /// **'Maximum 5 photos allowed'**
  String get products_maxPhotos;

  /// No description provided for @products_scanBarcode.
  ///
  /// In en, this message translates to:
  /// **'Scan Barcode'**
  String get products_scanBarcode;

  /// No description provided for @products_scanSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Auto-fill product details instantly'**
  String get products_scanSubtitle;

  /// No description provided for @products_lookingUp.
  ///
  /// In en, this message translates to:
  /// **'Looking up product...'**
  String get products_lookingUp;

  /// No description provided for @products_toggleTorch.
  ///
  /// In en, this message translates to:
  /// **'Toggle flashlight'**
  String get products_toggleTorch;

  /// No description provided for @products_rescan.
  ///
  /// In en, this message translates to:
  /// **'Re-scan'**
  String get products_rescan;

  /// No description provided for @products_notFound.
  ///
  /// In en, this message translates to:
  /// **'Product not found'**
  String get products_notFound;

  /// No description provided for @products_notFoundMessage.
  ///
  /// In en, this message translates to:
  /// **'This barcode isn\'t in our database. You can fill the details manually.'**
  String get products_notFoundMessage;

  /// No description provided for @products_enterManually.
  ///
  /// In en, this message translates to:
  /// **'Enter Manually'**
  String get products_enterManually;

  /// No description provided for @products_scanAgain.
  ///
  /// In en, this message translates to:
  /// **'Scan Again'**
  String get products_scanAgain;

  /// No description provided for @products_autoFilled.
  ///
  /// In en, this message translates to:
  /// **'Data from {source}'**
  String products_autoFilled(String source);

  /// No description provided for @products_stockSection.
  ///
  /// In en, this message translates to:
  /// **'Stock Information'**
  String get products_stockSection;

  /// No description provided for @products_pricingSection.
  ///
  /// In en, this message translates to:
  /// **'Pricing'**
  String get products_pricingSection;

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

  /// No description provided for @suppliers_contactInfo.
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get suppliers_contactInfo;

  /// No description provided for @suppliers_relationship.
  ///
  /// In en, this message translates to:
  /// **'Relationship'**
  String get suppliers_relationship;

  /// No description provided for @suppliers_preferredContact.
  ///
  /// In en, this message translates to:
  /// **'Preferred Contact'**
  String get suppliers_preferredContact;

  /// No description provided for @suppliers_paymentTerms.
  ///
  /// In en, this message translates to:
  /// **'Payment Terms'**
  String get suppliers_paymentTerms;

  /// No description provided for @suppliers_linkedSince.
  ///
  /// In en, this message translates to:
  /// **'Linked Since'**
  String get suppliers_linkedSince;

  /// No description provided for @suppliers_lastOrder.
  ///
  /// In en, this message translates to:
  /// **'Last Order'**
  String get suppliers_lastOrder;

  /// No description provided for @suppliers_recentOrders.
  ///
  /// In en, this message translates to:
  /// **'Recent Orders'**
  String get suppliers_recentOrders;

  /// No description provided for @suppliers_noOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders with this supplier yet'**
  String get suppliers_noOrders;

  /// No description provided for @suppliers_deleted.
  ///
  /// In en, this message translates to:
  /// **'Supplier removed successfully'**
  String get suppliers_deleted;

  /// No description provided for @suppliers_deleteConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to remove this supplier?'**
  String get suppliers_deleteConfirm;

  /// No description provided for @suppliers_deleteBlockedOrders.
  ///
  /// In en, this message translates to:
  /// **'Cannot remove supplier with existing orders'**
  String get suppliers_deleteBlockedOrders;

  /// No description provided for @suppliers_contactWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get suppliers_contactWhatsApp;

  /// No description provided for @suppliers_contactPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get suppliers_contactPhone;

  /// No description provided for @suppliers_contactEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get suppliers_contactEmail;

  /// No description provided for @suppliers_orderPdf.
  ///
  /// In en, this message translates to:
  /// **'PDF'**
  String get suppliers_orderPdf;

  /// No description provided for @suppliers_orderSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get suppliers_orderSent;

  /// No description provided for @suppliers_created.
  ///
  /// In en, this message translates to:
  /// **'Supplier added successfully'**
  String get suppliers_created;

  /// No description provided for @suppliers_updated.
  ///
  /// In en, this message translates to:
  /// **'Supplier updated successfully'**
  String get suppliers_updated;

  /// No description provided for @suppliers_phoneHelper.
  ///
  /// In en, this message translates to:
  /// **'Format: +212XXXXXXXXX (9 digits after +212)'**
  String get suppliers_phoneHelper;

  /// No description provided for @suppliers_filterAllCities.
  ///
  /// In en, this message translates to:
  /// **'All Cities'**
  String get suppliers_filterAllCities;

  /// No description provided for @suppliers_citySelect.
  ///
  /// In en, this message translates to:
  /// **'Select City'**
  String get suppliers_citySelect;

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

  /// No description provided for @profile_logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profile_logout;

  /// No description provided for @profile_logoutTitle.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get profile_logoutTitle;

  /// No description provided for @profile_logoutConfirm.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to log out?'**
  String get profile_logoutConfirm;

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

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @orders_title.
  ///
  /// In en, this message translates to:
  /// **'Purchase Orders'**
  String get orders_title;

  /// No description provided for @orders_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search by order # or supplier...'**
  String get orders_searchHint;

  /// No description provided for @orders_empty.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get orders_empty;

  /// No description provided for @orders_emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create your first purchase order to track inventory'**
  String get orders_emptyDescription;

  /// No description provided for @orders_add.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get orders_add;

  /// No description provided for @orders_orderNumber.
  ///
  /// In en, this message translates to:
  /// **'Order Number'**
  String get orders_orderNumber;

  /// No description provided for @orders_supplier.
  ///
  /// In en, this message translates to:
  /// **'Supplier'**
  String get orders_supplier;

  /// No description provided for @orders_totalItems.
  ///
  /// In en, this message translates to:
  /// **'Total Items'**
  String get orders_totalItems;

  /// No description provided for @orders_totalValue.
  ///
  /// In en, this message translates to:
  /// **'Total Value'**
  String get orders_totalValue;

  /// No description provided for @orders_notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get orders_notes;

  /// No description provided for @orders_status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orders_status;

  /// No description provided for @orders_statusDraft.
  ///
  /// In en, this message translates to:
  /// **'Draft'**
  String get orders_statusDraft;

  /// No description provided for @orders_statusGenerated.
  ///
  /// In en, this message translates to:
  /// **'Ready'**
  String get orders_statusGenerated;

  /// No description provided for @orders_statusSent.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get orders_statusSent;

  /// No description provided for @orders_filterSupplier.
  ///
  /// In en, this message translates to:
  /// **'Filter by Supplier'**
  String get orders_filterSupplier;

  /// No description provided for @orders_filterStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get orders_filterStatus;

  /// No description provided for @orders_filterAll.
  ///
  /// In en, this message translates to:
  /// **'All Orders'**
  String get orders_filterAll;

  /// No description provided for @orders_filterAllSuppliers.
  ///
  /// In en, this message translates to:
  /// **'All Suppliers'**
  String get orders_filterAllSuppliers;

  /// No description provided for @orders_createdAt.
  ///
  /// In en, this message translates to:
  /// **'Created'**
  String get orders_createdAt;

  /// No description provided for @orders_sentAt.
  ///
  /// In en, this message translates to:
  /// **'Sent'**
  String get orders_sentAt;

  /// No description provided for @orders_items.
  ///
  /// In en, this message translates to:
  /// **'items'**
  String get orders_items;

  /// No description provided for @orders_item.
  ///
  /// In en, this message translates to:
  /// **'item'**
  String get orders_item;

  /// No description provided for @orders_createTitle.
  ///
  /// In en, this message translates to:
  /// **'Create Purchase Order'**
  String get orders_createTitle;

  /// No description provided for @orders_selectSupplier.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get orders_selectSupplier;

  /// No description provided for @orders_supplierRequired.
  ///
  /// In en, this message translates to:
  /// **'Supplier is required'**
  String get orders_supplierRequired;

  /// No description provided for @orders_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get orders_products;

  /// No description provided for @orders_addProduct.
  ///
  /// In en, this message translates to:
  /// **'Add Product'**
  String get orders_addProduct;

  /// No description provided for @orders_selectProduct.
  ///
  /// In en, this message translates to:
  /// **'Select Product'**
  String get orders_selectProduct;

  /// No description provided for @orders_quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get orders_quantity;

  /// No description provided for @orders_unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit Price'**
  String get orders_unitPrice;

  /// No description provided for @orders_itemTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orders_itemTotal;

  /// No description provided for @orders_remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get orders_remove;

  /// No description provided for @orders_grandTotal.
  ///
  /// In en, this message translates to:
  /// **'Grand Total'**
  String get orders_grandTotal;

  /// No description provided for @orders_notesOptional.
  ///
  /// In en, this message translates to:
  /// **'Notes (optional)'**
  String get orders_notesOptional;

  /// No description provided for @orders_notesPlaceholder.
  ///
  /// In en, this message translates to:
  /// **'Add delivery instructions or notes'**
  String get orders_notesPlaceholder;

  /// No description provided for @orders_createButton.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get orders_createButton;

  /// No description provided for @orders_atLeastOneProduct.
  ///
  /// In en, this message translates to:
  /// **'Add at least one product'**
  String get orders_atLeastOneProduct;

  /// No description provided for @orders_quantityRequired.
  ///
  /// In en, this message translates to:
  /// **'Quantity is required'**
  String get orders_quantityRequired;

  /// No description provided for @orders_quantityMin.
  ///
  /// In en, this message translates to:
  /// **'Quantity must be greater than 0'**
  String get orders_quantityMin;

  /// No description provided for @orders_priceMin.
  ///
  /// In en, this message translates to:
  /// **'Price must be 0 or greater'**
  String get orders_priceMin;

  /// No description provided for @orders_noSuppliersAvailable.
  ///
  /// In en, this message translates to:
  /// **'No suppliers available'**
  String get orders_noSuppliersAvailable;

  /// No description provided for @orders_addSupplierFirst.
  ///
  /// In en, this message translates to:
  /// **'You need to add a supplier first'**
  String get orders_addSupplierFirst;

  /// No description provided for @orders_noProductsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No products available'**
  String get orders_noProductsAvailable;

  /// No description provided for @orders_addProductFirst.
  ///
  /// In en, this message translates to:
  /// **'You need to add products first'**
  String get orders_addProductFirst;

  /// No description provided for @orders_productAlreadyAdded.
  ///
  /// In en, this message translates to:
  /// **'This product is already added'**
  String get orders_productAlreadyAdded;

  /// No description provided for @orders_orderCreated.
  ///
  /// In en, this message translates to:
  /// **'Order created successfully'**
  String get orders_orderCreated;

  /// No description provided for @orders_errorSupplierNotFound.
  ///
  /// In en, this message translates to:
  /// **'Supplier not found'**
  String get orders_errorSupplierNotFound;

  /// No description provided for @orders_errorProductsNotFound.
  ///
  /// In en, this message translates to:
  /// **'One or more products not found'**
  String get orders_errorProductsNotFound;

  /// No description provided for @orders_orderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get orders_orderDetails;

  /// No description provided for @orders_orderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orders_orderNotFound;

  /// No description provided for @orders_totalQuantity.
  ///
  /// In en, this message translates to:
  /// **'Total Quantity'**
  String get orders_totalQuantity;

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

  /// No description provided for @orders_markAsSent.
  ///
  /// In en, this message translates to:
  /// **'Mark as Sent'**
  String get orders_markAsSent;

  /// No description provided for @orders_pdfGenerated.
  ///
  /// In en, this message translates to:
  /// **'PDF generated successfully'**
  String get orders_pdfGenerated;

  /// No description provided for @orders_markedAsSent.
  ///
  /// In en, this message translates to:
  /// **'Order marked as sent'**
  String get orders_markedAsSent;

  /// No description provided for @orders_pdfNotAvailable.
  ///
  /// In en, this message translates to:
  /// **'PDF not available'**
  String get orders_pdfNotAvailable;

  /// No description provided for @orders_downloadingPdf.
  ///
  /// In en, this message translates to:
  /// **'Opening PDF...'**
  String get orders_downloadingPdf;

  /// No description provided for @orders_markSentTitle.
  ///
  /// In en, this message translates to:
  /// **'How was the order sent?'**
  String get orders_markSentTitle;

  /// No description provided for @orders_markSentDescription.
  ///
  /// In en, this message translates to:
  /// **'Select the method used to send the order'**
  String get orders_markSentDescription;

  /// No description provided for @orders_sentViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp'**
  String get orders_sentViaWhatsApp;

  /// No description provided for @orders_sentViaEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get orders_sentViaEmail;

  /// No description provided for @orders_sentViaPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone Call'**
  String get orders_sentViaPhone;

  /// No description provided for @orders_sentViaInPerson.
  ///
  /// In en, this message translates to:
  /// **'In Person'**
  String get orders_sentViaInPerson;

  /// No description provided for @common_minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count} min ago'**
  String common_minutesAgo(int count);

  /// No description provided for @common_hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String common_hoursAgo(int count);

  /// No description provided for @common_seeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get common_seeAll;
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
