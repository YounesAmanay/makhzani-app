/// CSV Import/Export Provider
///
/// Handles exporting products to CSV and importing from CSV string.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

enum CsvStatus { idle, loading, success, error }

class CsvState {
  final CsvStatus status;
  final String? message;
  final String? csvData;
  final int? created;
  final int? skipped;

  const CsvState({
    this.status = CsvStatus.idle,
    this.message,
    this.csvData,
    this.created,
    this.skipped,
  });

  CsvState copyWith({
    CsvStatus? status,
    String? message,
    String? csvData,
    int? created,
    int? skipped,
  }) {
    return CsvState(
      status: status ?? this.status,
      message: message ?? this.message,
      csvData: csvData ?? this.csvData,
      created: created ?? this.created,
      skipped: skipped ?? this.skipped,
    );
  }
}

class CsvNotifier extends StateNotifier<CsvState> {
  final ApiClient _apiClient;

  CsvNotifier(this._apiClient) : super(const CsvState());

  void reset() => state = const CsvState();

  Future<String?> exportCsv() async {
    state = state.copyWith(status: CsvStatus.loading);
    try {
      final response = await _apiClient.get(ApiEndpoints.exportCsv);
      // Response data is raw CSV text
      final csv = response.data.toString();
      state = state.copyWith(status: CsvStatus.success, csvData: csv);
      return csv;
    } catch (e) {
      state = state.copyWith(
        status: CsvStatus.error,
        message: 'Failed to export products',
      );
      return null;
    }
  }

  Future<bool> importCsv(String csvData) async {
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
      return true;
    } catch (e) {
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
