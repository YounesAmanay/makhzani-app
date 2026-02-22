/// Reorder Suggestions Provider
///
/// Fetches low-stock products grouped by their last-ordered supplier.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/reorder_suggestion.dart';
import 'orders_provider.dart';

enum ReorderSuggestionsStatus { initial, loading, loaded, error }

class ReorderSuggestionsState {
  final ReorderSuggestionsStatus status;
  final ReorderSuggestionsResult? result;
  final String? errorMessage;

  const ReorderSuggestionsState({
    this.status = ReorderSuggestionsStatus.initial,
    this.result,
    this.errorMessage,
  });

  ReorderSuggestionsState copyWith({
    ReorderSuggestionsStatus? status,
    ReorderSuggestionsResult? result,
    String? errorMessage,
  }) {
    return ReorderSuggestionsState(
      status: status ?? this.status,
      result: result ?? this.result,
      errorMessage: errorMessage,
    );
  }
}

class ReorderSuggestionsNotifier
    extends StateNotifier<ReorderSuggestionsState> {
  final Ref _ref;

  ReorderSuggestionsNotifier(this._ref)
      : super(const ReorderSuggestionsState());

  Future<void> load() async {
    state = state.copyWith(
      status: ReorderSuggestionsStatus.loading,
      errorMessage: null,
    );

    try {
      final repository = _ref.read(ordersRepositoryProvider);
      final result = await repository.getReorderSuggestions();
      state = state.copyWith(
        status: ReorderSuggestionsStatus.loaded,
        result: result,
      );
    } catch (_) {
      state = state.copyWith(
        status: ReorderSuggestionsStatus.error,
        errorMessage: 'Failed to load reorder suggestions',
      );
    }
  }
}

final reorderSuggestionsProvider = StateNotifierProvider<
    ReorderSuggestionsNotifier, ReorderSuggestionsState>((ref) {
  return ReorderSuggestionsNotifier(ref);
});
