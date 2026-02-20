/// Reusable Search Bar
///
/// Persistent search bar with debounced input.
/// Used on products, suppliers, orders screens.
library;

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hugeicons/hugeicons.dart';

import '../../core/localization/l10n_extension.dart';
import '../../core/theme/app_dimensions.dart';

class AppSearchBar extends StatefulWidget {
  final String hintText;
  final ValueChanged<String?> onSearch;
  final Duration debounceDuration;

  const AppSearchBar({
    super.key,
    required this.hintText,
    required this.onSearch,
    this.debounceDuration = const Duration(milliseconds: 400),
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  final _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      final trimmed = value.trim();
      widget.onSearch(trimmed.isEmpty ? null : trimmed);
    });
  }

  void _onClear() {
    _debounce?.cancel();
    _controller.clear();
    widget.onSearch(null);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          hintText: widget.hintText,
          prefixIcon: Padding(
            padding: const EdgeInsets.all(12),
            child: HugeIcon(
              icon: HugeIcons.strokeRoundedSearch01,
              size: 20,
              color: theme.textTheme.bodySmall?.color ?? Colors.grey,
            ),
          ),
          suffixIcon: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: HugeIcon(
                  icon: HugeIcons.strokeRoundedCancelCircle,
                  size: 20,
                  color: theme.textTheme.bodySmall?.color ?? Colors.grey,
                ),
                tooltip: context.l10n.common_clear,
                onPressed: _onClear,
              );
            },
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
          ),
        ),
      ),
    );
  }
}
