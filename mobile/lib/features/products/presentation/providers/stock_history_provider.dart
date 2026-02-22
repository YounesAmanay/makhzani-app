/// Stock History Provider
///
/// Manages fetching paginated stock transaction history for a product.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/stock_transaction_model.dart';
import '../../domain/entities/stock_transaction.dart';

enum StockHistoryStatus { initial, loading, loaded, error }

class StockHistoryState {
  final List<StockTransaction> transactions;
  final StockHistoryStatus status;
  final String? errorMessage;

  const StockHistoryState({
    this.transactions = const [],
    this.status = StockHistoryStatus.initial,
    this.errorMessage,
  });

  StockHistoryState copyWith({
    List<StockTransaction>? transactions,
    StockHistoryStatus? status,
    String? errorMessage,
  }) {
    return StockHistoryState(
      transactions: transactions ?? this.transactions,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class StockHistoryNotifier extends StateNotifier<StockHistoryState> {
  final ApiClient _apiClient;
  final String productId;

  StockHistoryNotifier(this._apiClient, this.productId)
      : super(const StockHistoryState());

  Future<void> loadHistory() async {
    state = state.copyWith(status: StockHistoryStatus.loading);
    try {
      final response = await _apiClient.get(
        ApiEndpoints.stockHistory(productId),
        queryParameters: {'limit': '20'},
      );
      final data = response.data['data'] as Map<String, dynamic>;
      final list = (data['transactions'] as List)
          .map((e) => StockTransactionModel.fromJson(e as Map<String, dynamic>)
              .toEntity())
          .toList();
      state = state.copyWith(
        status: StockHistoryStatus.loaded,
        transactions: list,
      );
    } catch (e) {
      state = state.copyWith(
        status: StockHistoryStatus.error,
        errorMessage: e.toString(),
      );
    }
  }
}

final stockHistoryProvider = StateNotifierProvider.family<StockHistoryNotifier,
    StockHistoryState, String>((ref, productId) {
  return StockHistoryNotifier(ref.read(apiClientProvider), productId);
});
