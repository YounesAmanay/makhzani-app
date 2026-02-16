/// Pagination Model
library;

import '../../domain/entities/pagination.dart';

class OrderPaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalOrders;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int perPage;

  OrderPaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalOrders,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.perPage,
  });

  factory OrderPaginationModel.fromJson(Map<String, dynamic> json) {
    return OrderPaginationModel(
      currentPage: json['current_page'] as int,
      totalPages: json['total_pages'] as int,
      totalOrders: json['total_orders'] as int,
      hasNextPage: json['has_next_page'] as bool,
      hasPrevPage: json['has_prev_page'] as bool,
      perPage: json['per_page'] as int,
    );
  }

  OrderPagination toEntity() {
    return OrderPagination(
      currentPage: currentPage,
      totalPages: totalPages,
      totalOrders: totalOrders,
      hasNextPage: hasNextPage,
      hasPrevPage: hasPrevPage,
      perPage: perPage,
    );
  }
}
