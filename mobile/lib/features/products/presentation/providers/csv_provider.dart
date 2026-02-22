/// CSV Import/Export Provider
///
/// Handles exporting products to CSV (share via OS share sheet)
/// and importing from a CSV file picked from device storage.
library;

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum CsvStatus { idle, loading, success, error }

class CsvState {
  final CsvStatus status;
  final String? message;
  final String? selectedFileName;
  final int? created;
  final int? skipped;

  const CsvState({
    this.status = CsvStatus.idle,
    this.message,
    this.selectedFileName,
    this.created,
    this.skipped,
  });

  CsvState copyWith({
    CsvStatus? status,
    String? message,
    String? selectedFileName,
    int? created,
    int? skipped,
  }) {
    return CsvState(
      status: status ?? this.status,
      message: message ?? this.message,
      selectedFileName: selectedFileName ?? this.selectedFileName,
      created: created ?? this.created,
      skipped: skipped ?? this.skipped,
    );
  }
}

class CsvNotifier extends StateNotifier<CsvState> {
  final ApiClient _apiClient;

  // Holds the raw CSV text of the picked file, ready for import.
  String? _pickedCsvData;

  CsvNotifier(this._apiClient) : super(const CsvState());

  void reset() {
    _pickedCsvData = null;
    state = const CsvState();
  }

  /// Fetches CSV from the server, saves it to a temp file,
  /// then opens the OS share sheet so the user can send it anywhere.
  Future<bool> exportCsv() async {
    state = state.copyWith(status: CsvStatus.loading);
    try {
      final response = await _apiClient.get(ApiEndpoints.exportCsv);
      final csv = response.data.toString();

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/products_export.csv');
      await file.writeAsString(csv);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path, mimeType: 'text/csv')],
          subject: 'Products Export',
        ),
      );

      state = state.copyWith(status: CsvStatus.success);
      return true;
    } catch (_) {
      state = state.copyWith(
        status: CsvStatus.error,
        message: 'Failed to export products',
      );
      return false;
    }
  }

  /// Opens the file picker for CSV files.
  /// Stores the file content in [_pickedCsvData] and the name in state.
  Future<bool> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result == null || result.files.isEmpty) return false;

    final file = result.files.first;
    final path = file.path;
    if (path == null) return false;

    _pickedCsvData = await File(path).readAsString();
    state = state.copyWith(selectedFileName: file.name);
    return true;
  }

  /// Sends the previously picked CSV text to the backend for import.
  Future<bool> importCsv() async {
    final csvData = _pickedCsvData;
    if (csvData == null || csvData.isEmpty) return false;

    state = state.copyWith(status: CsvStatus.loading);
    try {
      final response = await _apiClient.post(
        ApiEndpoints.importCsv,
        data: {'csv_data': csvData},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      state = state.copyWith(
        status: CsvStatus.success,
        created: data['created'] as int?,
        skipped: data['skipped'] as int?,
        message: response.data['message'] as String?,
      );
      _pickedCsvData = null;
      return true;
    } catch (_) {
      state = state.copyWith(
        status: CsvStatus.error,
        message: 'Failed to import products',
      );
      return false;
    }
  }
}

final csvProvider = StateNotifierProvider<CsvNotifier, CsvState>((ref) {
  return CsvNotifier(ref.read(apiClientProvider));
});
