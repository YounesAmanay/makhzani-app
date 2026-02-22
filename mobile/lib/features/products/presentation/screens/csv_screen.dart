/// CSV Import / Export Screen
///
/// Allows merchants to:
/// - Export their products as a CSV file (shown for copy / share)
/// - Import products from a CSV string
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/csv_provider.dart';
import '../providers/products_provider.dart';

class CsvScreen extends ConsumerStatefulWidget {
  const CsvScreen({super.key});

  @override
  ConsumerState<CsvScreen> createState() => _CsvScreenState();
}

class _CsvScreenState extends ConsumerState<CsvScreen> {
  final _importController = TextEditingController();

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  Future<void> _export() async {
    final csv = await ref.read(csvProvider.notifier).exportCsv();
    if (csv == null || !mounted) return;
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(context.l10n.csv_exportedCopied),
        backgroundColor: AppColors.success,
      ),
    );
  }

  Future<void> _import() async {
    final csvData = _importController.text.trim();
    if (csvData.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.csv_pasteFirst),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(csvProvider.notifier).importCsv(csvData);
    if (!mounted) return;

    if (success) {
      final state = ref.read(csvProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            context.l10n.csv_importResult(state.created ?? 0, state.skipped ?? 0),
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _importController.clear();
      ref.read(productsProvider.notifier).refresh();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.l10n.error_generic),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final csvState = ref.watch(csvProvider);
    final isLoading = csvState.status == CsvStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.csv_title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Export section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.csv_exportTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      context.l10n.csv_exportDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeightMedium,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _export,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(Icons.download_outlined),
                        label: Text(context.l10n.csv_export),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppDimensions.marginMedium),

            // Import section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppDimensions.paddingMedium),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.l10n.csv_importTitle,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      context.l10n.csv_importDescription,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginSmall),
                    Text(
                      context.l10n.csv_formatHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textTertiary,
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    TextFormField(
                      controller: _importController,
                      decoration: InputDecoration(
                        labelText: context.l10n.csv_pasteLabel,
                        hintText: context.l10n.csv_pasteHint,
                        alignLabelWithHint: true,
                      ),
                      maxLines: 8,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontFamily: 'monospace',
                      ),
                    ),
                    const SizedBox(height: AppDimensions.marginMedium),
                    SizedBox(
                      width: double.infinity,
                      height: AppDimensions.buttonHeightMedium,
                      child: ElevatedButton.icon(
                        onPressed: isLoading ? null : _import,
                        icon: isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.white,
                                ),
                              )
                            : const Icon(Icons.upload_outlined),
                        label: Text(context.l10n.csv_import),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
