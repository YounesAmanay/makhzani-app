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
  String get validation_phoneFormat =>
      'تنسيق هاتف مغربي غير صحيح (+212XXXXXXXXX)';

  @override
  String get validation_emailFormat => 'تنسيق بريد إلكتروني غير صحيح';

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
  String get dashboard_allStocked => 'جميع المنتجات مخزنة بشكل جيد';

  @override
  String dashboard_seeAllItems(int count) {
    return 'عرض جميع العناصر ($count)';
  }

  @override
  String get dashboard_noOrders => 'لا توجد طلبات بعد';

  @override
  String get dashboard_seeAllOrders => 'عرض جميع الطلبات';

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
  String get products_searchHint => 'البحث عن المنتجات...';

  @override
  String get products_noResults => 'لم يتم العثور على منتجات';

  @override
  String get products_adjustFilters => 'جرب تعديل البحث أو الفلاتر';

  @override
  String get products_currentStock => 'المخزون الحالي';

  @override
  String get products_reorderThreshold => 'حد إعادة الطلب';

  @override
  String get products_barcode => 'الباركود';

  @override
  String get products_unit => 'الوحدة';

  @override
  String get products_details => 'التفاصيل';

  @override
  String get products_adjustStock => 'تعديل المخزون';

  @override
  String get products_stockAdjusted => 'تم تعديل المخزون بنجاح';

  @override
  String get products_created => 'تم إنشاء المنتج بنجاح';

  @override
  String get products_updated => 'تم تحديث المنتج بنجاح';

  @override
  String get products_deleted => 'تم حذف المنتج بنجاح';

  @override
  String get products_deleteConfirm => 'هل أنت متأكد أنك تريد حذف هذا المنتج؟';

  @override
  String get products_lowStockOnly => 'المخزون المنخفض فقط';

  @override
  String get products_newStock => 'المخزون الجديد';

  @override
  String get products_stockNegativeError => 'لا يمكن أن يكون المخزون سالبًا';

  @override
  String get products_reason => 'السبب (اختياري)';

  @override
  String get products_adjustment => 'التعديل';

  @override
  String get products_adjustmentHint => '+10 أو -5';

  @override
  String get products_adjustmentHelper => 'استخدم + لإضافة مخزون، - للإزالة';

  @override
  String get products_photos => 'الصور';

  @override
  String get products_addPhoto => 'إضافة صورة';

  @override
  String get products_deletePhoto => 'حذف الصورة';

  @override
  String get products_maxPhotos => 'الحد الأقصى 5 صور';

  @override
  String get products_scanBarcode => 'مسح الباركود';

  @override
  String get products_scanSubtitle => 'ملء تفاصيل المنتج تلقائياً';

  @override
  String get products_lookingUp => 'جاري البحث عن المنتج...';

  @override
  String get products_toggleTorch => 'تشغيل/إيقاف الضوء';

  @override
  String get products_rescan => 'إعادة المسح';

  @override
  String get products_notFound => 'المنتج غير موجود';

  @override
  String get products_notFoundMessage =>
      'هذا الباركود غير موجود في قاعدة بياناتنا. يمكنك ملء التفاصيل يدوياً.';

  @override
  String get products_enterManually => 'إدخال يدوي';

  @override
  String get products_scanAgain => 'مسح مرة أخرى';

  @override
  String products_autoFilled(String source) {
    return 'بيانات من $source';
  }

  @override
  String get products_stockSection => 'معلومات المخزون';

  @override
  String get products_pricingSection => 'التسعير';

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
  String get suppliers_unknown => 'مورد غير معروف';

  @override
  String get suppliers_searchHint => 'البحث عن الموردين...';

  @override
  String get suppliers_noResults => 'لم يتم العثور على موردين';

  @override
  String get suppliers_adjustFilters => 'جرب تعديل البحث';

  @override
  String get suppliers_businessName => 'اسم النشاط التجاري';

  @override
  String suppliers_totalOrders(int count) {
    return '$count طلبات';
  }

  @override
  String get suppliers_contactInfo => 'معلومات الاتصال';

  @override
  String get suppliers_relationship => 'العلاقة';

  @override
  String get suppliers_preferredContact => 'طريقة الاتصال المفضلة';

  @override
  String get suppliers_paymentTerms => 'شروط الدفع';

  @override
  String get suppliers_linkedSince => 'مرتبط منذ';

  @override
  String get suppliers_lastOrder => 'آخر طلب';

  @override
  String get suppliers_recentOrders => 'الطلبات الأخيرة';

  @override
  String get suppliers_noOrders => 'لا توجد طلبات مع هذا المورد بعد';

  @override
  String get suppliers_deleted => 'تم إزالة المورد بنجاح';

  @override
  String get suppliers_deleteConfirm =>
      'هل أنت متأكد أنك تريد إزالة هذا المورد؟';

  @override
  String get suppliers_deleteBlockedOrders => 'لا يمكن إزالة مورد لديه طلبات';

  @override
  String get suppliers_contactWhatsApp => 'واتساب';

  @override
  String get suppliers_contactPhone => 'هاتف';

  @override
  String get suppliers_contactEmail => 'بريد إلكتروني';

  @override
  String get suppliers_orderPdf => 'PDF';

  @override
  String get suppliers_orderSent => 'مُرسل';

  @override
  String get suppliers_created => 'تم إضافة المورد بنجاح';

  @override
  String get suppliers_updated => 'تم تحديث المورد بنجاح';

  @override
  String get suppliers_phoneHelper =>
      'التنسيق: +212XXXXXXXXX (9 أرقام بعد +212)';

  @override
  String get suppliers_filterAllCities => 'كل المدن';

  @override
  String get suppliers_citySelect => 'اختر المدينة';

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
  String get profile_editProfile => 'تعديل الملف الشخصي';

  @override
  String get profile_shopName => 'اسم المتجر';

  @override
  String get profile_address => 'العنوان';

  @override
  String get profile_updated => 'تم تحديث الملف الشخصي بنجاح';

  @override
  String get profile_selectRegion => 'اختر المنطقة';

  @override
  String get profile_logout => 'تسجيل الخروج';

  @override
  String get profile_logoutTitle => 'تسجيل الخروج';

  @override
  String get profile_logoutConfirm => 'هل أنت متأكد أنك تريد تسجيل الخروج؟';

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
  String get common_clear => 'مسح';

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
  String get common_today => 'اليوم';

  @override
  String get common_yesterday => 'أمس';

  @override
  String common_daysAgo(int count) {
    return 'منذ $count أيام';
  }

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
  String get theme_light => 'الوضع الفاتح';

  @override
  String get theme_dark => 'الوضع الداكن';

  @override
  String get language_switchToArabic => 'العربية';

  @override
  String get language_switchToEnglish => 'English';

  @override
  String get nav_dashboard => 'لوحة التحكم';

  @override
  String get nav_products => 'المنتجات';

  @override
  String get nav_suppliers => 'الموردون';

  @override
  String get nav_orders => 'الطلبات';

  @override
  String get comingSoon => 'قريبًا';

  @override
  String get comingSoon_description => 'هذه الميزة قيد التطوير';

  @override
  String get sort_nameAsc => 'الاسم أ→ي';

  @override
  String get sort_nameDesc => 'الاسم ي→أ';

  @override
  String get sort_stockLow => 'المخزون: الأقل أولاً';

  @override
  String get sort_stockHigh => 'المخزون: الأكثر أولاً';

  @override
  String get sort_priceLow => 'السعر: الأقل أولاً';

  @override
  String get sort_priceHigh => 'السعر: الأكثر أولاً';

  @override
  String get sort_newest => 'الأحدث أولاً';

  @override
  String products_resultsCount(int count) {
    return '$count منتج';
  }

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

  @override
  String get orders => 'الطلبات';

  @override
  String get orders_title => 'أوامر الشراء';

  @override
  String get orders_searchHint => 'البحث برقم الطلب أو المورد...';

  @override
  String get orders_empty => 'لا توجد أوامر بعد';

  @override
  String get orders_emptyDescription => 'قم بإنشاء أول أمر شراء لتتبع المخزون';

  @override
  String get orders_add => 'أمر جديد';

  @override
  String get orders_orderNumber => 'رقم الأمر';

  @override
  String get orders_supplier => 'المورد';

  @override
  String get orders_totalItems => 'إجمالي العناصر';

  @override
  String get orders_totalValue => 'القيمة الإجمالية';

  @override
  String get orders_notes => 'ملاحظات';

  @override
  String get orders_status => 'الحالة';

  @override
  String get orders_statusDraft => 'مسودة';

  @override
  String get orders_statusGenerated => 'جاهز';

  @override
  String get orders_statusSent => 'مرسل';

  @override
  String get orders_filterSupplier => 'تصفية حسب المورد';

  @override
  String get orders_filterStatus => 'تصفية حسب الحالة';

  @override
  String get orders_filterAll => 'جميع الأوامر';

  @override
  String get orders_filterAllSuppliers => 'جميع الموردين';

  @override
  String get orders_createdAt => 'تم الإنشاء';

  @override
  String get orders_sentAt => 'تم الإرسال';

  @override
  String get orders_items => 'عناصر';

  @override
  String get orders_item => 'عنصر';

  @override
  String get orders_createTitle => 'إنشاء أمر شراء';

  @override
  String get orders_selectSupplier => 'اختر المورد';

  @override
  String get orders_supplierRequired => 'المورد مطلوب';

  @override
  String get orders_products => 'المنتجات';

  @override
  String get orders_addProduct => 'إضافة منتج';

  @override
  String get orders_selectProduct => 'اختر منتج';

  @override
  String get orders_quantity => 'الكمية';

  @override
  String get orders_unitPrice => 'السعر للوحدة';

  @override
  String get orders_itemTotal => 'المجموع';

  @override
  String get orders_remove => 'إزالة';

  @override
  String get orders_grandTotal => 'المجموع الكلي';

  @override
  String get orders_notesOptional => 'ملاحظات (اختياري)';

  @override
  String get orders_notesPlaceholder => 'أضف تعليمات التسليم أو الملاحظات';

  @override
  String get orders_createButton => 'إنشاء الأمر';

  @override
  String get orders_atLeastOneProduct => 'أضف منتجاً واحداً على الأقل';

  @override
  String get orders_quantityRequired => 'الكمية مطلوبة';

  @override
  String get orders_quantityMin => 'يجب أن تكون الكمية أكبر من 0';

  @override
  String get orders_priceMin => 'يجب أن يكون السعر 0 أو أكثر';

  @override
  String get orders_noSuppliersAvailable => 'لا يوجد موردون متاحون';

  @override
  String get orders_addSupplierFirst => 'تحتاج إلى إضافة مورد أولاً';

  @override
  String get orders_noProductsAvailable => 'لا توجد منتجات متاحة';

  @override
  String get orders_addProductFirst => 'تحتاج إلى إضافة منتجات أولاً';

  @override
  String get orders_productAlreadyAdded => 'تم إضافة هذا المنتج بالفعل';

  @override
  String get orders_orderCreated => 'تم إنشاء الأمر بنجاح';

  @override
  String get orders_errorSupplierNotFound => 'المورد غير موجود';

  @override
  String get orders_errorProductsNotFound => 'منتج واحد أو أكثر غير موجود';

  @override
  String get orders_orderDetails => 'تفاصيل الطلب';

  @override
  String get orders_orderNotFound => 'الطلب غير موجود';

  @override
  String get orders_totalQuantity => 'الكمية الإجمالية';

  @override
  String get orders_generatePdf => 'إنشاء PDF';

  @override
  String get orders_downloadPdf => 'تحميل PDF';

  @override
  String get orders_markAsSent => 'وضع علامة كمرسل';

  @override
  String get orders_pdfGenerated => 'تم إنشاء PDF بنجاح';

  @override
  String get orders_markedAsSent => 'تم وضع علامة على الطلب كمرسل';

  @override
  String get orders_pdfNotAvailable => 'PDF غير متاح';

  @override
  String get orders_downloadingPdf => 'فتح PDF...';

  @override
  String get orders_markSentTitle => 'كيف تم إرسال الطلب؟';

  @override
  String get orders_markSentDescription =>
      'اختر الطريقة المستخدمة لإرسال الطلب';

  @override
  String get orders_sentViaWhatsApp => 'واتساب';

  @override
  String get orders_sentViaEmail => 'البريد الإلكتروني';

  @override
  String get orders_sentViaPhone => 'مكالمة هاتفية';

  @override
  String get orders_sentViaInPerson => 'شخصياً';

  @override
  String get orders_sendViaWhatsApp => 'إرسال عبر واتساب';

  @override
  String get orders_generateAndOpen => 'إنشاء PDF';

  @override
  String get orders_noWhatsapp => 'واتساب غير مثبت';

  @override
  String get orders_pdfError => 'فشل إنشاء PDF. يرجى المحاولة مرة أخرى.';

  @override
  String get orders_whatsappSent => 'تم إرسال الطلب عبر واتساب';

  @override
  String get orders_newOrderTitle => 'طلب جديد';

  @override
  String get orders_selectSupplierHint => 'البحث عن موردين...';

  @override
  String get orders_selectSupplierPrompt => 'اختر موردًا لبدء إنشاء طلبك';

  @override
  String get orders_changeSupplier => 'تغيير المورد';

  @override
  String get orders_selectSupplierAction => 'اختر موردًا';

  @override
  String get orders_recentSuppliers => 'الأخيرون';

  @override
  String get orders_allSuppliers => 'جميع الموردين';

  @override
  String orders_buildOrderTitle(String supplierName) {
    return 'طلب $supplierName';
  }

  @override
  String get orders_searchProducts => 'البحث عن منتجات...';

  @override
  String get orders_addToOrder => 'إضافة';

  @override
  String get orders_reviewTitle => 'مراجعة الطلب';

  @override
  String get orders_saveAsDraft => 'حفظ كمسودة';

  @override
  String get orders_draftSaved => 'تم حفظ الطلب كمسودة';

  @override
  String get orders_callSupplier => 'الاتصال بالمورد';

  @override
  String orders_itemsSummary(int count, String total) {
    return '$count منتجات · $total درهم';
  }

  @override
  String get orders_reviewOrder => 'مراجعة الطلب';

  @override
  String get orders_outOfStock => 'نفد المخزون';

  @override
  String orders_stockLabel(int count, String unit) {
    return 'المخزون: $count $unit';
  }

  @override
  String common_minutesAgo(int count) {
    return 'منذ $count دقيقة';
  }

  @override
  String common_hoursAgo(int count) {
    return 'منذ $count ساعة';
  }

  @override
  String get common_seeAll => 'عرض الكل';
}
