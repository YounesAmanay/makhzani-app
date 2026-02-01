/// Pagination Entity
library;

class Pagination {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int perPage;

  const Pagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.perPage,
  });

  const Pagination.initial()
      : currentPage = 1,
        totalPages = 1,
        totalItems = 0,
        hasNextPage = false,
        hasPrevPage = false,
        perPage = 20;
}
