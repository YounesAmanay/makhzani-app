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

  /// No description provided for @auth_resendFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to resend code'**
  String get auth_resendFailed;

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

  /// No description provided for @profile_editProfile.
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get profile_editProfile;

  /// No description provided for @profile_shopName.
  ///
  /// In en, this message translates to:
  /// **'Shop Name'**
  String get profile_shopName;

  /// No description provided for @profile_address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get profile_address;

  /// No description provided for @profile_updated.
  ///
  /// In en, this message translates to:
  /// **'Profile updated successfully'**
  String get profile_updated;

  /// No description provided for @profile_selectRegion.
  ///
  /// In en, this message translates to:
  /// **'Select region'**
  String get profile_selectRegion;

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

  /// No description provided for @orders_sendViaWhatsApp.
  ///
  /// In en, this message translates to:
  /// **'Send via WhatsApp'**
  String get orders_sendViaWhatsApp;

  /// No description provided for @orders_generateAndOpen.
  ///
  /// In en, this message translates to:
  /// **'Generate PDF'**
  String get orders_generateAndOpen;

  /// No description provided for @orders_noWhatsapp.
  ///
  /// In en, this message translates to:
  /// **'WhatsApp is not installed'**
  String get orders_noWhatsapp;

  /// No description provided for @orders_pdfError.
  ///
  /// In en, this message translates to:
  /// **'Failed to generate PDF. Please try again.'**
  String get orders_pdfError;

  /// No description provided for @orders_whatsappSent.
  ///
  /// In en, this message translates to:
  /// **'Order sent via WhatsApp'**
  String get orders_whatsappSent;

  /// No description provided for @orders_newOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get orders_newOrderTitle;

  /// No description provided for @orders_selectSupplierHint.
  ///
  /// In en, this message translates to:
  /// **'Search suppliers...'**
  String get orders_selectSupplierHint;

  /// No description provided for @orders_selectSupplierPrompt.
  ///
  /// In en, this message translates to:
  /// **'Select a supplier to start building your order'**
  String get orders_selectSupplierPrompt;

  /// No description provided for @orders_changeSupplier.
  ///
  /// In en, this message translates to:
  /// **'Change Supplier'**
  String get orders_changeSupplier;

  /// No description provided for @orders_selectSupplierAction.
  ///
  /// In en, this message translates to:
  /// **'Select Supplier'**
  String get orders_selectSupplierAction;

  /// No description provided for @orders_recentSuppliers.
  ///
  /// In en, this message translates to:
  /// **'Recent'**
  String get orders_recentSuppliers;

  /// No description provided for @orders_allSuppliers.
  ///
  /// In en, this message translates to:
  /// **'All Suppliers'**
  String get orders_allSuppliers;

  /// No description provided for @orders_buildOrderTitle.
  ///
  /// In en, this message translates to:
  /// **'{supplierName}\'s Order'**
  String orders_buildOrderTitle(String supplierName);

  /// No description provided for @orders_searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get orders_searchProducts;

  /// No description provided for @orders_addToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get orders_addToOrder;

  /// No description provided for @orders_addToOrderTotal.
  ///
  /// In en, this message translates to:
  /// **'Add to Order ({total} MAD)'**
  String orders_addToOrderTotal(String total);

  /// No description provided for @orders_updateTotal.
  ///
  /// In en, this message translates to:
  /// **'Update ({total} MAD)'**
  String orders_updateTotal(String total);

  /// No description provided for @orders_removeFromOrder.
  ///
  /// In en, this message translates to:
  /// **'Remove from order'**
  String get orders_removeFromOrder;

  /// No description provided for @orders_inOrder.
  ///
  /// In en, this message translates to:
  /// **'In Order'**
  String get orders_inOrder;

  /// No description provided for @orders_reviewTitle.
  ///
  /// In en, this message translates to:
  /// **'Review Order'**
  String get orders_reviewTitle;

  /// No description provided for @orders_saveAsDraft.
  ///
  /// In en, this message translates to:
  /// **'Save as Draft'**
  String get orders_saveAsDraft;

  /// No description provided for @orders_draftSaved.
  ///
  /// In en, this message translates to:
  /// **'Order saved as draft'**
  String get orders_draftSaved;

  /// No description provided for @orders_callSupplier.
  ///
  /// In en, this message translates to:
  /// **'Call supplier'**
  String get orders_callSupplier;

  /// No description provided for @orders_itemsSummary.
  ///
  /// In en, this message translates to:
  /// **'{count} items · {total} MAD'**
  String orders_itemsSummary(int count, String total);

  /// No description provided for @orders_reviewOrder.
  ///
  /// In en, this message translates to:
  /// **'Create & Review'**
  String get orders_reviewOrder;

  /// No description provided for @orders_outOfStock.
  ///
  /// In en, this message translates to:
  /// **'Out of stock'**
  String get orders_outOfStock;

  /// No description provided for @orders_stockLabel.
  ///
  /// In en, this message translates to:
  /// **'Stock: {count} {unit}'**
  String orders_stockLabel(int count, String unit);

  /// No description provided for @orders_whatsappGreeting.
  ///
  /// In en, this message translates to:
  /// **'Hello {supplierName},'**
  String orders_whatsappGreeting(String supplierName);

  /// No description provided for @orders_whatsappIntro.
  ///
  /// In en, this message translates to:
  /// **'Here is my order ({orderNumber}):'**
  String orders_whatsappIntro(String orderNumber);

  /// No description provided for @orders_whatsappTotal.
  ///
  /// In en, this message translates to:
  /// **'Total: {total} MAD'**
  String orders_whatsappTotal(String total);

  /// No description provided for @orders_whatsappClosing.
  ///
  /// In en, this message translates to:
  /// **'Thank you'**
  String get orders_whatsappClosing;

  /// No description provided for @orders_receiveOrder.
  ///
  /// In en, this message translates to:
  /// **'Receive Order'**
  String get orders_receiveOrder;

  /// No description provided for @orders_statusReceived.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get orders_statusReceived;

  /// No description provided for @orders_receiveConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Receive this order?'**
  String get orders_receiveConfirmTitle;

  /// No description provided for @orders_receiveConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will automatically add the ordered quantities to your stock. This action cannot be undone.'**
  String get orders_receiveConfirmMessage;

  /// No description provided for @orders_receiveSuccess.
  ///
  /// In en, this message translates to:
  /// **'Order received — stock updated successfully'**
  String get orders_receiveSuccess;

  /// No description provided for @orders_receiveError.
  ///
  /// In en, this message translates to:
  /// **'Failed to receive order. Please try again.'**
  String get orders_receiveError;

  /// No description provided for @orders_alreadyReceived.
  ///
  /// In en, this message translates to:
  /// **'Already Received'**
  String get orders_alreadyReceived;

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

  /// No description provided for @categories_title.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories_title;

  /// No description provided for @categories_add.
  ///
  /// In en, this message translates to:
  /// **'Add Category'**
  String get categories_add;

  /// No description provided for @categories_empty.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get categories_empty;

  /// No description provided for @categories_emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Create categories to organize your products'**
  String get categories_emptyDescription;

  /// No description provided for @categories_selectHint.
  ///
  /// In en, this message translates to:
  /// **'None (uncategorized)'**
  String get categories_selectHint;

  /// No description provided for @categories_none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get categories_none;

  /// No description provided for @categories_created.
  ///
  /// In en, this message translates to:
  /// **'Category created'**
  String get categories_created;

  /// No description provided for @categories_deleted.
  ///
  /// In en, this message translates to:
  /// **'Category deleted'**
  String get categories_deleted;

  /// No description provided for @categories_nameLabel.
  ///
  /// In en, this message translates to:
  /// **'Category Name'**
  String get categories_nameLabel;

  /// No description provided for @categories_namePlaceholder.
  ///
  /// In en, this message translates to:
  /// **'e.g. Beverages'**
  String get categories_namePlaceholder;

  /// No description provided for @categories_manage.
  ///
  /// In en, this message translates to:
  /// **'Manage Categories'**
  String get categories_manage;

  /// No description provided for @categories_searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search categories...'**
  String get categories_searchHint;

  /// No description provided for @categories_loadDefaults.
  ///
  /// In en, this message translates to:
  /// **'Load default categories'**
  String get categories_loadDefaults;

  /// No description provided for @categories_loadDefaultsSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count} default categories added'**
  String categories_loadDefaultsSuccess(int count);

  /// No description provided for @categories_loadDefaultsAlready.
  ///
  /// In en, this message translates to:
  /// **'All default categories already exist'**
  String get categories_loadDefaultsAlready;

  /// No description provided for @categories_loadDefaultsError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load default categories'**
  String get categories_loadDefaultsError;

  /// No description provided for @stockHistory.
  ///
  /// In en, this message translates to:
  /// **'Stock History'**
  String get stockHistory;

  /// No description provided for @stockHistory_empty.
  ///
  /// In en, this message translates to:
  /// **'No stock changes recorded'**
  String get stockHistory_empty;

  /// No description provided for @stockHistory_manualAdjustment.
  ///
  /// In en, this message translates to:
  /// **'Manual Adjustment'**
  String get stockHistory_manualAdjustment;

  /// No description provided for @stockHistory_orderReceived.
  ///
  /// In en, this message translates to:
  /// **'Order Received'**
  String get stockHistory_orderReceived;

  /// No description provided for @stockHistory_wastage.
  ///
  /// In en, this message translates to:
  /// **'Wastage'**
  String get stockHistory_wastage;

  /// No description provided for @stockHistory_initialStock.
  ///
  /// In en, this message translates to:
  /// **'Initial Stock'**
  String get stockHistory_initialStock;

  /// No description provided for @stockHistory_correction.
  ///
  /// In en, this message translates to:
  /// **'Correction'**
  String get stockHistory_correction;

  /// No description provided for @csv_title.
  ///
  /// In en, this message translates to:
  /// **'Import / Export'**
  String get csv_title;

  /// No description provided for @csv_exportTitle.
  ///
  /// In en, this message translates to:
  /// **'Export Products'**
  String get csv_exportTitle;

  /// No description provided for @csv_exportDescription.
  ///
  /// In en, this message translates to:
  /// **'Share your product list as a CSV file — open in Excel or Google Sheets.'**
  String get csv_exportDescription;

  /// No description provided for @csv_export.
  ///
  /// In en, this message translates to:
  /// **'Export & Share'**
  String get csv_export;

  /// No description provided for @csv_exportedCopied.
  ///
  /// In en, this message translates to:
  /// **'CSV copied to clipboard'**
  String get csv_exportedCopied;

  /// No description provided for @csv_importTitle.
  ///
  /// In en, this message translates to:
  /// **'Import Products'**
  String get csv_importTitle;

  /// No description provided for @csv_importDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick a CSV file from your phone to bulk-import products. Existing products will be skipped.'**
  String get csv_importDescription;

  /// No description provided for @csv_formatHint.
  ///
  /// In en, this message translates to:
  /// **'Columns: name, barcode, current_stock, reorder_threshold, unit, price, category'**
  String get csv_formatHint;

  /// No description provided for @csv_pasteLabel.
  ///
  /// In en, this message translates to:
  /// **'Paste CSV here'**
  String get csv_pasteLabel;

  /// No description provided for @csv_pasteHint.
  ///
  /// In en, this message translates to:
  /// **'name,barcode,current_stock,...'**
  String get csv_pasteHint;

  /// No description provided for @csv_pasteFirst.
  ///
  /// In en, this message translates to:
  /// **'Please paste CSV data first'**
  String get csv_pasteFirst;

  /// No description provided for @csv_pickFile.
  ///
  /// In en, this message translates to:
  /// **'Pick CSV File'**
  String get csv_pickFile;

  /// No description provided for @csv_fileSelected.
  ///
  /// In en, this message translates to:
  /// **'Selected: {fileName}'**
  String csv_fileSelected(String fileName);

  /// No description provided for @csv_importButton.
  ///
  /// In en, this message translates to:
  /// **'Import Products'**
  String get csv_importButton;

  /// No description provided for @csv_noFileSelected.
  ///
  /// In en, this message translates to:
  /// **'Please select a CSV file first'**
  String get csv_noFileSelected;

  /// No description provided for @csv_import.
  ///
  /// In en, this message translates to:
  /// **'Import CSV'**
  String get csv_import;

  /// No description provided for @csv_importResult.
  ///
  /// In en, this message translates to:
  /// **'{created} created, {skipped} skipped'**
  String csv_importResult(int created, int skipped);

  /// No description provided for @notifications_title.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications_title;

  /// No description provided for @notifications_empty.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get notifications_empty;

  /// No description provided for @notifications_emptyDescription.
  ///
  /// In en, this message translates to:
  /// **'You\'ll see low-stock alerts and order updates here.'**
  String get notifications_emptyDescription;

  /// No description provided for @notifications_markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all as read'**
  String get notifications_markAllRead;

  /// No description provided for @notifications_clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get notifications_clearAll;

  /// No description provided for @notifications_justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get notifications_justNow;

  /// No description provided for @notifications_minutesAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}m ago'**
  String notifications_minutesAgo(int count);

  /// No description provided for @notifications_hoursAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}h ago'**
  String notifications_hoursAgo(int count);

  /// No description provided for @notifications_daysAgo.
  ///
  /// In en, this message translates to:
  /// **'{count}d ago'**
  String notifications_daysAgo(int count);

  /// No description provided for @notifications_clearConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear all notifications?'**
  String get notifications_clearConfirmTitle;

  /// No description provided for @notifications_clearConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will permanently delete all notifications.'**
  String get notifications_clearConfirmMessage;

  /// No description provided for @notifications_cleared.
  ///
  /// In en, this message translates to:
  /// **'All notifications cleared'**
  String get notifications_cleared;

  /// No description provided for @nav_sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get nav_sales;

  /// No description provided for @sales_title.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get sales_title;

  /// No description provided for @sales_newSale.
  ///
  /// In en, this message translates to:
  /// **'New Sale'**
  String get sales_newSale;

  /// No description provided for @sales_history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get sales_history;

  /// No description provided for @sales_searchProducts.
  ///
  /// In en, this message translates to:
  /// **'Search products...'**
  String get sales_searchProducts;

  /// No description provided for @sales_cartEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get sales_cartEmpty;

  /// No description provided for @sales_cartEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Search or scan a product to add it to the cart.'**
  String get sales_cartEmptyDescription;

  /// No description provided for @sales_total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get sales_total;

  /// No description provided for @sales_items.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String sales_items(int count);

  /// No description provided for @sales_confirmSale.
  ///
  /// In en, this message translates to:
  /// **'Confirm Sale'**
  String get sales_confirmSale;

  /// No description provided for @sales_confirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Confirm sale?'**
  String get sales_confirmTitle;

  /// No description provided for @sales_confirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will record the sale and update stock for {count} product(s).'**
  String sales_confirmMessage(int count);

  /// No description provided for @sales_success.
  ///
  /// In en, this message translates to:
  /// **'Sale recorded successfully'**
  String get sales_success;

  /// No description provided for @sales_shareReceipt.
  ///
  /// In en, this message translates to:
  /// **'Share Receipt'**
  String get sales_shareReceipt;

  /// No description provided for @sales_receiptText.
  ///
  /// In en, this message translates to:
  /// **'🧾 Sale Receipt\nSale #: {saleNumber}\nDate: {date}\nTotal: {total} MAD\n\nThank you!'**
  String sales_receiptText(String saleNumber, String date, String total);

  /// No description provided for @sales_insufficientStock.
  ///
  /// In en, this message translates to:
  /// **'Insufficient stock'**
  String get sales_insufficientStock;

  /// No description provided for @sales_cancelTitle.
  ///
  /// In en, this message translates to:
  /// **'Cancel sale?'**
  String get sales_cancelTitle;

  /// No description provided for @sales_cancelMessage.
  ///
  /// In en, this message translates to:
  /// **'This will restore stock for all items. Only possible within 24 hours.'**
  String get sales_cancelMessage;

  /// No description provided for @sales_cancelSuccess.
  ///
  /// In en, this message translates to:
  /// **'Sale cancelled and stock restored'**
  String get sales_cancelSuccess;

  /// No description provided for @sales_noHistory.
  ///
  /// In en, this message translates to:
  /// **'No sales yet'**
  String get sales_noHistory;

  /// No description provided for @sales_noHistoryDescription.
  ///
  /// In en, this message translates to:
  /// **'Your confirmed sales will appear here.'**
  String get sales_noHistoryDescription;

  /// No description provided for @sales_saleNumber.
  ///
  /// In en, this message translates to:
  /// **'Sale #{number}'**
  String sales_saleNumber(String number);

  /// No description provided for @sales_unitPrice.
  ///
  /// In en, this message translates to:
  /// **'Unit price'**
  String get sales_unitPrice;

  /// No description provided for @sales_qty.
  ///
  /// In en, this message translates to:
  /// **'Qty'**
  String get sales_qty;

  /// No description provided for @sales_notes.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get sales_notes;

  /// No description provided for @sales_enterPrice.
  ///
  /// In en, this message translates to:
  /// **'Enter price'**
  String get sales_enterPrice;

  /// No description provided for @sales_enterPriceMessage.
  ///
  /// In en, this message translates to:
  /// **'This product has no price set. Enter the unit price to add it to the cart.'**
  String get sales_enterPriceMessage;

  /// No description provided for @sales_editPrice.
  ///
  /// In en, this message translates to:
  /// **'Edit price'**
  String get sales_editPrice;

  /// No description provided for @sales_priceHint.
  ///
  /// In en, this message translates to:
  /// **'0.00'**
  String get sales_priceHint;

  /// No description provided for @sales_noPriceError.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get sales_noPriceError;

  /// No description provided for @sales_clearCart.
  ///
  /// In en, this message translates to:
  /// **'Clear Cart'**
  String get sales_clearCart;

  /// No description provided for @sales_clearCartConfirm.
  ///
  /// In en, this message translates to:
  /// **'Remove all items from the cart?'**
  String get sales_clearCartConfirm;

  /// No description provided for @dashboard_todayRevenue.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Revenue'**
  String get dashboard_todayRevenue;

  /// No description provided for @dashboard_monthRevenue.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get dashboard_monthRevenue;

  /// No description provided for @dashboard_salesChart.
  ///
  /// In en, this message translates to:
  /// **'Sales — Last 7 Days'**
  String get dashboard_salesChart;

  /// No description provided for @dashboard_topSelling.
  ///
  /// In en, this message translates to:
  /// **'Top Selling This Month'**
  String get dashboard_topSelling;

  /// No description provided for @dashboard_noSalesThisMonth.
  ///
  /// In en, this message translates to:
  /// **'No sales recorded this month'**
  String get dashboard_noSalesThisMonth;

  /// No description provided for @dashboard_sold.
  ///
  /// In en, this message translates to:
  /// **'sold'**
  String get dashboard_sold;

  /// No description provided for @products_margin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get products_margin;

  /// No description provided for @dashboard_profitMonth.
  ///
  /// In en, this message translates to:
  /// **'Profit This Month'**
  String get dashboard_profitMonth;

  /// No description provided for @dashboard_profitTotal.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get dashboard_profitTotal;

  /// No description provided for @dashboard_stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get dashboard_stockValue;

  /// No description provided for @stock_reason_damaged.
  ///
  /// In en, this message translates to:
  /// **'Damaged'**
  String get stock_reason_damaged;

  /// No description provided for @stock_reason_lost.
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get stock_reason_lost;

  /// No description provided for @stock_reason_countCorrection.
  ///
  /// In en, this message translates to:
  /// **'Count Correction'**
  String get stock_reason_countCorrection;

  /// No description provided for @stock_reason_other.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get stock_reason_other;

  /// No description provided for @products_barcodeExists.
  ///
  /// In en, this message translates to:
  /// **'Already in your inventory'**
  String get products_barcodeExists;

  /// No description provided for @products_viewProduct.
  ///
  /// In en, this message translates to:
  /// **'View Product'**
  String get products_viewProduct;

  /// No description provided for @orders_reorderSuggestions.
  ///
  /// In en, this message translates to:
  /// **'Reorder Suggestions'**
  String get orders_reorderSuggestions;

  /// No description provided for @orders_reorderSuggestionsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{count} products need restocking'**
  String orders_reorderSuggestionsSubtitle(int count);

  /// No description provided for @orders_createOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get orders_createOrder;

  /// No description provided for @orders_noSupplierHistory.
  ///
  /// In en, this message translates to:
  /// **'No supplier history'**
  String get orders_noSupplierHistory;

  /// No description provided for @orders_shortage.
  ///
  /// In en, this message translates to:
  /// **'-{count} {unit}'**
  String orders_shortage(int count, String unit);

  /// No description provided for @orders_allStocked.
  ///
  /// In en, this message translates to:
  /// **'All products are well stocked'**
  String get orders_allStocked;

  /// No description provided for @orders_reorderProductCount1.
  ///
  /// In en, this message translates to:
  /// **'1 product to reorder'**
  String get orders_reorderProductCount1;

  /// No description provided for @orders_reorderProductCount.
  ///
  /// In en, this message translates to:
  /// **'{count} products to reorder'**
  String orders_reorderProductCount(int count);

  /// No description provided for @orders_stockInfo.
  ///
  /// In en, this message translates to:
  /// **'Stock: {stock} {unit} · Need {shortage} more'**
  String orders_stockInfo(int stock, String unit, int shortage);

  /// No description provided for @orders_orderManually.
  ///
  /// In en, this message translates to:
  /// **'Order manually'**
  String get orders_orderManually;

  /// No description provided for @orders_orderManuallySubtitle.
  ///
  /// In en, this message translates to:
  /// **'These products have no order history — pick a supplier when creating the order'**
  String get orders_orderManuallySubtitle;

  /// No description provided for @orders_sharePdf.
  ///
  /// In en, this message translates to:
  /// **'Share PDF'**
  String get orders_sharePdf;

  /// No description provided for @reports_title.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get reports_title;

  /// No description provided for @reports_sales.
  ///
  /// In en, this message translates to:
  /// **'Sales'**
  String get reports_sales;

  /// No description provided for @reports_products.
  ///
  /// In en, this message translates to:
  /// **'Products'**
  String get reports_products;

  /// No description provided for @reports_inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get reports_inventory;

  /// No description provided for @reports_period_today.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get reports_period_today;

  /// No description provided for @reports_period_week.
  ///
  /// In en, this message translates to:
  /// **'This Week'**
  String get reports_period_week;

  /// No description provided for @reports_period_month.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get reports_period_month;

  /// No description provided for @reports_period_last_month.
  ///
  /// In en, this message translates to:
  /// **'Last Month'**
  String get reports_period_last_month;

  /// No description provided for @reports_period_custom.
  ///
  /// In en, this message translates to:
  /// **'Custom'**
  String get reports_period_custom;

  /// No description provided for @reports_totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get reports_totalRevenue;

  /// No description provided for @reports_totalSales.
  ///
  /// In en, this message translates to:
  /// **'Total Sales'**
  String get reports_totalSales;

  /// No description provided for @reports_totalProfit.
  ///
  /// In en, this message translates to:
  /// **'Total Profit'**
  String get reports_totalProfit;

  /// No description provided for @reports_avgSaleValue.
  ///
  /// In en, this message translates to:
  /// **'Avg. Sale'**
  String get reports_avgSaleValue;

  /// No description provided for @reports_cancelledCount.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get reports_cancelledCount;

  /// No description provided for @reports_cancelledValue.
  ///
  /// In en, this message translates to:
  /// **'Cancelled Value'**
  String get reports_cancelledValue;

  /// No description provided for @reports_bestDay.
  ///
  /// In en, this message translates to:
  /// **'Best Day'**
  String get reports_bestDay;

  /// No description provided for @reports_worstDay.
  ///
  /// In en, this message translates to:
  /// **'Worst Day'**
  String get reports_worstDay;

  /// No description provided for @reports_topProducts.
  ///
  /// In en, this message translates to:
  /// **'Top Products'**
  String get reports_topProducts;

  /// No description provided for @reports_bestSellers.
  ///
  /// In en, this message translates to:
  /// **'Best Sellers'**
  String get reports_bestSellers;

  /// No description provided for @reports_deadStock.
  ///
  /// In en, this message translates to:
  /// **'Dead Stock'**
  String get reports_deadStock;

  /// No description provided for @reports_byCategory.
  ///
  /// In en, this message translates to:
  /// **'By Category'**
  String get reports_byCategory;

  /// No description provided for @reports_revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get reports_revenue;

  /// No description provided for @reports_profit.
  ///
  /// In en, this message translates to:
  /// **'Profit'**
  String get reports_profit;

  /// No description provided for @reports_margin.
  ///
  /// In en, this message translates to:
  /// **'Margin'**
  String get reports_margin;

  /// No description provided for @reports_quantitySold.
  ///
  /// In en, this message translates to:
  /// **'Sold'**
  String get reports_quantitySold;

  /// No description provided for @reports_stockValue.
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get reports_stockValue;

  /// No description provided for @reports_healthScore.
  ///
  /// In en, this message translates to:
  /// **'Health Score'**
  String get reports_healthScore;

  /// No description provided for @reports_healthyStock.
  ///
  /// In en, this message translates to:
  /// **'Healthy'**
  String get reports_healthyStock;

  /// No description provided for @reports_lowStock.
  ///
  /// In en, this message translates to:
  /// **'Low Stock'**
  String get reports_lowStock;

  /// No description provided for @reports_zeroStock.
  ///
  /// In en, this message translates to:
  /// **'Out of Stock'**
  String get reports_zeroStock;

  /// No description provided for @reports_reorderImpact.
  ///
  /// In en, this message translates to:
  /// **'Reorder Cost'**
  String get reports_reorderImpact;

  /// No description provided for @reports_daysSinceLastSale.
  ///
  /// In en, this message translates to:
  /// **'{days} days since last sale'**
  String reports_daysSinceLastSale(int days);

  /// No description provided for @reports_neverSold.
  ///
  /// In en, this message translates to:
  /// **'Never sold'**
  String get reports_neverSold;

  /// No description provided for @reports_noData.
  ///
  /// In en, this message translates to:
  /// **'No data for this period'**
  String get reports_noData;

  /// No description provided for @reports_sales_title.
  ///
  /// In en, this message translates to:
  /// **'Sales Report'**
  String get reports_sales_title;

  /// No description provided for @reports_products_title.
  ///
  /// In en, this message translates to:
  /// **'Products Report'**
  String get reports_products_title;

  /// No description provided for @reports_inventory_title.
  ///
  /// In en, this message translates to:
  /// **'Inventory Report'**
  String get reports_inventory_title;

  /// No description provided for @reports_currency.
  ///
  /// In en, this message translates to:
  /// **'MAD'**
  String get reports_currency;

  /// No description provided for @reports_products_count.
  ///
  /// In en, this message translates to:
  /// **'{count} products'**
  String reports_products_count(int count);
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
