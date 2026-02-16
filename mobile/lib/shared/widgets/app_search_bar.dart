/// Reusable Search Bar
///
/// Persistent search bar with debounced input.
/// Used on products, suppliers, orders screens.
library;

import 'package:flutter/material.dart';

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
  String _lastSearch = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    final trimmed = value.trim();
    Future.delayed(widget.debounceDuration, () {
      if (_controller.text.trim() == trimmed && trimmed != _lastSearch) {
        _lastSearch = trimmed;
        widget.onSearch(trimmed.isEmpty ? null : trimmed);
      }
    });
  }

  void _onClear() {
    _controller.clear();
    _lastSearch = '';
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
          prefixIcon: Icon(
            Icons.search,
            color: theme.textTheme.bodySmall?.color,
          ),
          suffixIcon: ListenableBuilder(
            listenable: _controller,
            builder: (context, _) {
              if (_controller.text.isEmpty) return const SizedBox.shrink();
              return IconButton(
                icon: const Icon(Icons.close, size: 20),
                tooltip: context.l10n.common_clear,
                onPressed: _onClear,
              );
            },
          ),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: AppDimensions.paddingSmall,
          ),
        ),
      ),
    );
  }
}
