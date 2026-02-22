/// CSV Import / Export Screen
///
/// Export: generates CSV on server → OS share sheet (WhatsApp, Drive, email…)
/// Import: file picker → reads CSV file → sends to backend
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/l10n_extension.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimensions.dart';
import '../providers/csv_provider.dart';
import '../providers/products_provider.dart';

class CsvScreen extends ConsumerWidget {
  const CsvScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            _ExportCard(isLoading: isLoading),
            const SizedBox(height: AppDimensions.marginMedium),
            _ImportCard(isLoading: isLoading, state: csvState),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Export card
// ---------------------------------------------------------------------------

class _ExportCard extends ConsumerWidget {
  final bool isLoading;

  const _ExportCard({required this.isLoading});

  Future<void> _onExport(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(csvProvider.notifier).exportCsv();
    if (!context.mounted) return;
    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.error_generic),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Card(
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
                onPressed: isLoading ? null : () => _onExport(context, ref),
                icon: isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(Icons.share_outlined),
                label: Text(context.l10n.csv_export),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Import card
// ---------------------------------------------------------------------------

class _ImportCard extends ConsumerWidget {
  final bool isLoading;
  final CsvState state;

  const _ImportCard({required this.isLoading, required this.state});

  Future<void> _onPickFile(BuildContext context, WidgetRef ref) async {
    await ref.read(csvProvider.notifier).pickFile();
  }

  Future<void> _onImport(BuildContext context, WidgetRef ref) async {
    final success = await ref.read(csvProvider.notifier).importCsv();
    if (!context.mounted) return;

    if (success) {
      final s = ref.read(csvProvider);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          context.l10n.csv_importResult(s.created ?? 0, s.skipped ?? 0),
        ),
        backgroundColor: AppColors.success,
      ));
      ref.read(productsProvider.notifier).refresh();
      ref.read(csvProvider.notifier).reset();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(context.l10n.error_generic),
        backgroundColor: AppColors.error,
      ));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fileName = state.selectedFileName;

    return Card(
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
            const SizedBox(height: AppDimensions.marginMedium),

            // Pick file button
            SizedBox(
              width: double.infinity,
              height: AppDimensions.buttonHeightMedium,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : () => _onPickFile(context, ref),
                icon: const Icon(Icons.folder_open_outlined),
                label: Text(context.l10n.csv_pickFile),
              ),
            ),

            // Selected file name
            if (fileName != null) ...[
              const SizedBox(height: AppDimensions.marginSmall),
              Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 16,
                    color: AppColors.success,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      context.l10n.csv_fileSelected(fileName),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.marginMedium),

              // Import button — only shown after file is picked
              SizedBox(
                width: double.infinity,
                height: AppDimensions.buttonHeightMedium,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : () => _onImport(context, ref),
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
                  label: Text(context.l10n.csv_importButton),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
