/// Category Picker Sheet
///
/// Searchable bottom sheet for selecting a product category.
/// Shows a color dot per category, supports "None" option,
/// and offers a one-tap seed button when the list is empty.
library;

import 'package:flutter/material.dart';

import '../../core/localization/l10n_extension.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';
import '../../features/products/domain/entities/category.dart';

/// Client-side translation map.
/// Key = French name stored in the DB (from the seed).
/// Values = Arabic and English equivalents.
/// Categories created manually by the merchant (not in this map)
/// are shown as-is in all locales.
const _translations = <String, ({String en, String ar})>{
  'Épicerie & Conserves':       (en: 'Grocery & Canned Goods',   ar: 'بقالة ومعلبات'),
  'Boissons & Eau':             (en: 'Beverages & Water',         ar: 'مشروبات ومياه'),
  'Produits Laitiers':          (en: 'Dairy Products',            ar: 'منتجات الألبان'),
  'Boulangerie & Pâtisserie':   (en: 'Bakery & Pastry',           ar: 'مخبزة وحلويات'),
  'Huiles & Graisses':          (en: 'Oils & Fats',               ar: 'زيوت ودهون'),
  'Légumineuses & Céréales':    (en: 'Legumes & Cereals',         ar: 'بقوليات وحبوب'),
  'Sucre, Sel & Épices':        (en: 'Sugar, Salt & Spices',      ar: 'سكر وملح وتوابل'),
  'Café, Thé & Infusions':      (en: 'Coffee, Tea & Infusions',   ar: 'قهوة وشاي وأعشاب'),
  'Snacks & Confiseries':       (en: 'Snacks & Sweets',           ar: 'وجبات خفيفة وحلوى'),
  'Fruits & Légumes':           (en: 'Fruits & Vegetables',       ar: 'فواكه وخضروات'),
  'Viande & Volaille':          (en: 'Meat & Poultry',            ar: 'لحوم ودواجن'),
  'Poisson & Fruits de Mer':    (en: 'Fish & Seafood',            ar: 'أسماك ومأكولات بحرية'),
  'Surgelés':                   (en: 'Frozen Foods',              ar: 'أغذية مجمدة'),
  'Hygiène & Beauté':           (en: 'Hygiene & Beauty',          ar: 'نظافة وتجميل'),
  'Produits Ménagers':          (en: 'Household Products',        ar: 'منتجات منزلية'),
  'Lessive & Entretien':        (en: 'Laundry & Cleaning',        ar: 'غسيل وتنظيف'),
  'Bébé & Puériculture':        (en: 'Baby & Childcare',          ar: 'منتجات الأطفال'),
  'Articles Ménagers':          (en: 'Household Items',           ar: 'أدوات منزلية'),
  'Tabac & Accessoires':        (en: 'Tobacco & Accessories',     ar: 'تبغ وإكسسوارات'),
  'Recharge & Télécom':         (en: 'Top-up & Telecom',          ar: 'شحن واتصالات'),
  'Papeterie & Scolaire':       (en: 'Stationery & School',       ar: 'قرطاسية ومستلزمات مدرسية'),
  'Autres':                     (en: 'Other',                     ar: 'أخرى'),
};

/// Returns the localized display name for a category.
/// Falls back to the stored name when no translation exists.
String localizedCategoryName(BuildContext context, Category cat) {
  final locale = Localizations.localeOf(context).languageCode;
  final t = _translations[cat.name];
  if (t == null) return cat.name;
  if (locale == 'ar') return t.ar;
  if (locale == 'en') return t.en;
  return cat.name; // 'fr' → stored name IS the French name
}

class CategoryPickerSheet extends StatefulWidget {
  final List<Category> categories;
  final String? selectedId;
  final VoidCallback? onSeedDefaults;

  const CategoryPickerSheet({
    super.key,
    required this.categories,
    this.selectedId,
    this.onSeedDefaults,
  });

  /// Sentinel returned when "None" is explicitly selected.
  static const String kNone = '\x00none';

  /// Show the picker and return:
  ///   - a category id String → category was selected
  ///   - [kNone]              → "None" was explicitly tapped
  ///   - null                 → sheet was dismissed without a selection (back gesture)
  static Future<String?> show({
    required BuildContext context,
    required List<Category> categories,
    String? selectedId,
    VoidCallback? onSeedDefaults,
  }) {
    return showModalBottomSheet<String?>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (_) => CategoryPickerSheet(
        categories: categories,
        selectedId: selectedId,
        onSeedDefaults: onSeedDefaults,
      ),
    );
  }

  @override
  State<CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<CategoryPickerSheet> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Category> get _filtered {
    if (_query.isEmpty) return widget.categories;
    final q = _query.toLowerCase();
    return widget.categories.where((c) {
      // Search both stored name and localized name
      final localized = localizedCategoryName(context, c).toLowerCase();
      return c.name.toLowerCase().contains(q) || localized.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final filtered = _filtered;
    final isEmpty = widget.categories.isEmpty;

    return Padding(
      // Push sheet up when keyboard is visible
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Handle + title ─────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppDimensions.paddingMedium,
              AppDimensions.paddingMedium,
              AppDimensions.paddingMedium,
              AppDimensions.marginSmall,
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginMedium),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    l10n.products_category,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),

          // ── Search field ───────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingMedium,
            ),
            child: TextField(
              controller: _searchController,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: l10n.categories_searchHint,
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        tooltip: l10n.common_clear,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
                isDense: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.paddingMedium,
                  vertical: AppDimensions.paddingSmall + 2,
                ),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
          ),
          const SizedBox(height: AppDimensions.marginSmall),

          // ── List ───────────────────────────────────────────────
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.55,
            ),
            child: isEmpty
                ? _buildEmptyState(context, l10n)
                : filtered.isEmpty
                    ? _buildNoResults(context, l10n)
                    : ListView(
                        shrinkWrap: true,
                        children: [
                          // "None" option at the top
                          _buildTile(
                            context: context,
                            id: CategoryPickerSheet.kNone,
                            label: l10n.categories_none,
                            color: null,
                          ),
                          const Divider(height: 1),
                          ...filtered.map((cat) => _buildTile(
                                context: context,
                                id: cat.id,
                                label: localizedCategoryName(context, cat),
                                color: cat.color,
                              )),
                          const SizedBox(height: AppDimensions.marginSmall),
                        ],
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTile({
    required BuildContext context,
    required String? id,
    required String label,
    required String? color,
  }) {
    final theme = Theme.of(context);
    final isSelected = id == CategoryPickerSheet.kNone
        ? widget.selectedId == null
        : id == widget.selectedId;
    Color? dotColor;
    if (color != null) {
      try {
        dotColor = Color(
          int.parse(color.replaceFirst('#', '0xFF')),
        );
      } catch (_) {}
    }

    return ListTile(
      leading: dotColor != null
          ? Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
            )
          : const SizedBox(width: 14),
      title: Text(
        label,
        style: theme.textTheme.bodyLarge?.copyWith(
          color: isSelected ? AppColors.primary : null,
          fontWeight: isSelected ? FontWeight.w600 : null,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: AppColors.primary, size: 20)
          : null,
      onTap: () => Navigator.of(context).pop(id),
    );
  }

  Widget _buildEmptyState(BuildContext context, dynamic l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.categories_empty,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppDimensions.marginMedium),
          if (widget.onSeedDefaults != null)
            OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                widget.onSeedDefaults!();
              },
              icon: const Icon(Icons.auto_awesome_outlined, size: 16),
              label: Text(l10n.categories_loadDefaults),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResults(BuildContext context, dynamic l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.paddingLarge),
      child: Text(
        l10n.products_noResults,
        style: Theme.of(context).textTheme.bodyLarge,
        textAlign: TextAlign.center,
      ),
    );
  }
}
