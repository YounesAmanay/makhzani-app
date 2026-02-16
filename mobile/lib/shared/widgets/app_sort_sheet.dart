/// Reusable Sort Bottom Sheet
///
/// Shows sort options in a bottom sheet with radio selection.
library;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimensions.dart';

class SortOption<T> {
  final T value;
  final String label;
  final IconData? icon;

  const SortOption({
    required this.value,
    required this.label,
    this.icon,
  });
}

class AppSortSheet<T> extends StatelessWidget {
  final String title;
  final List<SortOption<T>> options;
  final T currentValue;
  final ValueChanged<T> onSelected;

  const AppSortSheet({
    super.key,
    required this.title,
    required this.options,
    required this.currentValue,
    required this.onSelected,
  });

  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<SortOption<T>> options,
    required T currentValue,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLarge),
        ),
      ),
      builder: (context) => AppSortSheet<T>(
        title: title,
        options: options,
        currentValue: currentValue,
        onSelected: (value) => Navigator.of(context).pop(value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppDimensions.paddingMedium),
            child: Column(
              children: [
                // Drag handle
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

                // Title
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                  ),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.marginSmall),
              ],
            ),
          ),

          // Scrollable options
          Flexible(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ...options.map((option) {
                    final isSelected = option.value == currentValue;
                    return ListTile(
                      leading: option.icon != null
                          ? Icon(
                              option.icon,
                              color: isSelected ? AppColors.primary : null,
                            )
                          : null,
                      title: Text(
                        option.label,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: isSelected ? AppColors.primary : null,
                          fontWeight: isSelected ? FontWeight.w600 : null,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(Icons.check, color: AppColors.primary)
                          : null,
                      onTap: () => onSelected(option.value),
                    );
                  }),
                  const SizedBox(height: AppDimensions.marginSmall),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
