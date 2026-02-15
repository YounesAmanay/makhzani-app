// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'مخزني';

  @override
  String get auth_phoneInputTitle => 'أدخل رقم هاتفك للمتابعة';

  @override
  String get auth_phoneLabel => 'رقم الهاتف';

  @override
  String get auth_phoneHint => '6XXXXXXXX';

  @override
  String get auth_phonePrefixMorocco => '+212';

  @override
  String get auth_sendCode => 'إرسال الرمز';

  @override
  String get auth_verifyTitle => 'أدخل رمز التحقق';

  @override
  String auth_verifySubtitle(String phoneNumber) {
    return 'أرسلنا رمزًا مكونًا من 4 أرقام إلى\n$phoneNumber';
  }

  @override
  String get auth_verify => 'تحقق';

  @override
  String get auth_resendCode => 'إعادة إرسال الرمز';

  @override
  String get auth_codeResent => 'تم إعادة إرسال الرمز بنجاح';

  @override
  String get auth_invalidCode => 'رمز غير صالح. حاول مرة أخرى.';

  @override
  String get auth_failedToSendOtp => 'فشل إرسال الرمز. حاول مرة أخرى.';

  @override
  String get validation_required => 'هذا الحقل مطلوب';

  @override
  String get validation_phoneLength => 'رقم الهاتف يجب أن يكون 9 أرقام';

  @override
  String get validation_phonePrefix => 'رقم الهاتف يجب أن يبدأ بـ 5 أو 6 أو 7';

  @override
  String get validation_otpLength => 'الرجاء إدخال الرمز المكون من 4 أرقام';

  @override
  String get dashboard => 'لوحة التحكم';

  @override
  String get dashboard_totalProducts => 'إجمالي المنتجات';

  @override
  String get dashboard_lowStock => 'مخزون منخفض';

  @override
  String get dashboard_totalSuppliers => 'الموردون';

  @override
  String get dashboard_pendingOrders => 'طلبات معلقة';

  @override
  String get dashboard_recentOrders => 'الطلبات الأخيرة';

  @override
  String get dashboard_quickActions => 'إجراءات سريعة';

  @override
  String get dashboard_viewAll => 'عرض الكل';

  @override
  String get products => 'المنتجات';

  @override
  String get products_add => 'إضافة منتج';

  @override
  String get products_edit => 'تعديل المنتج';

  @override
  String get products_name => 'اسم المنتج';

  @override
  String get products_sku => 'رمز المنتج';

  @override
  String get products_price => 'السعر';

  @override
  String get products_costPrice => 'سعر التكلفة';

  @override
  String get products_sellingPrice => 'سعر البيع';

  @override
  String get products_quantity => 'الكمية';

  @override
  String get products_minStock => 'الحد الأدنى للمخزون';

  @override
  String get products_category => 'الفئة';

  @override
  String get products_description => 'الوصف';

  @override
  String get products_inStock => 'متوفر';

  @override
  String get products_outOfStock => 'غير متوفر';

  @override
  String get products_lowStockWarning => 'مخزون منخفض';

  @override
  String get products_empty => 'لا توجد منتجات بعد';

  @override
  String get products_emptyDescription => 'أضف منتجك الأول للبدء';

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
  String get products_stockAdd => 'Add';

  @override
  String get products_stockRemove => 'Remove';

  @override
  String get products_newStock => 'New stock';

  @override
  String get products_stockNegativeError => 'Stock cannot be negative';

  @override
  String get products_reason => 'Reason (optional)';

  @override
  String get suppliers => 'الموردون';

  @override
  String get suppliers_add => 'إضافة مورد';

  @override
  String get suppliers_edit => 'تعديل المورد';

  @override
  String get suppliers_name => 'اسم المورد';

  @override
  String get suppliers_phone => 'الهاتف';

  @override
  String get suppliers_email => 'البريد الإلكتروني';

  @override
  String get suppliers_address => 'العنوان';

  @override
  String get suppliers_city => 'المدينة';

  @override
  String get suppliers_notes => 'ملاحظات';

  @override
  String get suppliers_empty => 'لا يوجد موردون بعد';

  @override
  String get suppliers_emptyDescription => 'أضف موردك الأول لإدارة مشترياتك';

  @override
  String get orders => 'الطلبات';

  @override
  String get orders_purchase => 'طلبات الشراء';

  @override
  String get orders_create => 'إنشاء طلب';

  @override
  String get orders_edit => 'تعديل الطلب';

  @override
  String get orders_supplier => 'المورد';

  @override
  String get orders_selectSupplier => 'اختر المورد';

  @override
  String get orders_items => 'العناصر';

  @override
  String get orders_addItem => 'إضافة عنصر';

  @override
  String get orders_total => 'المجموع';

  @override
  String get orders_status => 'الحالة';

  @override
  String get orders_status_draft => 'مسودة';

  @override
  String get orders_status_sent => 'مُرسل';

  @override
  String get orders_status_received => 'مُستلم';

  @override
  String get orders_status_cancelled => 'ملغي';

  @override
  String get orders_markSent => 'تحديد كمُرسل';

  @override
  String get orders_markReceived => 'تحديد كمُستلم';

  @override
  String get orders_generatePdf => 'إنشاء PDF';

  @override
  String get orders_downloadPdf => 'تحميل PDF';

  @override
  String get orders_empty => 'لا توجد طلبات بعد';

  @override
  String get orders_emptyDescription => 'أنشئ طلب الشراء الأول';

  @override
  String get profile => 'الملف الشخصي';

  @override
  String get profile_businessName => 'اسم النشاط التجاري';

  @override
  String get profile_ownerName => 'اسم المالك';

  @override
  String get profile_phone => 'الهاتف';

  @override
  String get profile_email => 'البريد الإلكتروني';

  @override
  String get profile_region => 'المنطقة';

  @override
  String get profile_subscription => 'الاشتراك';

  @override
  String profile_trialEnds(String date) {
    return 'ينتهي التجريب في $date';
  }

  @override
  String get settings => 'الإعدادات';

  @override
  String get settings_language => 'اللغة';

  @override
  String get settings_notifications => 'الإشعارات';

  @override
  String get settings_about => 'حول التطبيق';

  @override
  String settings_version(String version) {
    return 'الإصدار $version';
  }

  @override
  String get common_save => 'حفظ';

  @override
  String get common_cancel => 'إلغاء';

  @override
  String get common_delete => 'حذف';

  @override
  String get common_edit => 'تعديل';

  @override
  String get common_add => 'إضافة';

  @override
  String get common_search => 'بحث';

  @override
  String get common_filter => 'تصفية';

  @override
  String get common_sort => 'ترتيب';

  @override
  String get common_refresh => 'تحديث';

  @override
  String get common_retry => 'إعادة المحاولة';

  @override
  String get common_loading => 'جاري التحميل...';

  @override
  String get common_confirm => 'تأكيد';

  @override
  String get common_yes => 'نعم';

  @override
  String get common_no => 'لا';

  @override
  String get common_ok => 'موافق';

  @override
  String get common_close => 'إغلاق';

  @override
  String get common_back => 'رجوع';

  @override
  String get common_next => 'التالي';

  @override
  String get common_done => 'تم';

  @override
  String get common_skip => 'تخطي';

  @override
  String get common_moreOptions => 'خيارات أخرى';

  @override
  String get common_selectAll => 'تحديد الكل';

  @override
  String get common_clearAll => 'مسح الكل';

  @override
  String get error_generic => 'حدث خطأ ما';

  @override
  String get error_network => 'لا يوجد اتصال بالإنترنت';

  @override
  String get error_server => 'خطأ في الخادم. حاول مرة أخرى لاحقًا.';

  @override
  String get error_timeout => 'انتهت مهلة الطلب';

  @override
  String get error_unknown => 'حدث خطأ غير معروف';

  @override
  String get success_saved => 'تم الحفظ بنجاح';

  @override
  String get success_deleted => 'تم الحذف بنجاح';

  @override
  String get success_updated => 'تم التحديث بنجاح';

  @override
  String get success_created => 'تم الإنشاء بنجاح';

  @override
  String get confirm_delete => 'هل أنت متأكد أنك تريد الحذف؟';

  @override
  String get confirm_deleteTitle => 'حذف';

  @override
  String get confirm_logout => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

  @override
  String get confirm_logoutTitle => 'تسجيل الخروج';

  @override
  String get confirm_discard => 'هل أنت متأكد أنك تريد تجاهل التغييرات؟';

  @override
  String get confirm_discardTitle => 'تجاهل التغييرات';

  @override
  String get logout => 'تسجيل الخروج';

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
  String get currency_mad => 'درهم';

  @override
  String itemCount(int count) {
    return '$count عناصر';
  }

  @override
  String itemCountPlural(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count عنصر',
      many: '$count عنصر',
      few: '$count عناصر',
      two: 'عنصران',
      one: 'عنصر واحد',
      zero: 'لا توجد عناصر',
    );
    return '$_temp0';
  }
}
