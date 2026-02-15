/// Navigation Provider
///
/// Riverpod provider for bottom navigation state.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Current bottom navigation tab index
final bottomNavIndexProvider = StateProvider<int>((ref) => 0);

/// Whether to apply low stock filter when navigating to products
final productsLowStockFilterProvider = StateProvider<bool>((ref) => false);
