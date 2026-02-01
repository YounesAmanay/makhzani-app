/// Pagination Model
library;

import '../../domain/entities/pagination.dart';

class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int perPage;

  const PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.perPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['current_page'] ?? 1,
      totalPages: json['total_pages'] ?? 1,
      totalItems: json['total_products'] ?? json['total_items'] ?? 0,
      hasNextPage: json['has_next_page'] ?? false,
      hasPrevPage: json['has_prev_page'] ?? false,
      perPage: json['per_page'] ?? 20,
    );
  }

  Pagination toEntity() => Pagination(
    currentPage: currentPage,
    totalPages: totalPages,
    totalItems: totalItems,
    hasNextPage: hasNextPage,
    hasPrevPage: hasPrevPage,
    perPage: perPage,
  );
}
