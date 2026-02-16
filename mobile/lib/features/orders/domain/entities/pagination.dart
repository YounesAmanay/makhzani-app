/// Pagination Entity
///
/// Pagination metadata for orders list.
library;

class OrderPagination {
  final int currentPage;
  final int totalPages;
  final int totalOrders;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int perPage;

  const OrderPagination({
    required this.currentPage,
    required this.totalPages,
    required this.totalOrders,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.perPage,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderPagination &&
          runtimeType == other.runtimeType &&
          currentPage == other.currentPage &&
          totalPages == other.totalPages &&
          totalOrders == other.totalOrders &&
          hasNextPage == other.hasNextPage &&
          hasPrevPage == other.hasPrevPage &&
          perPage == other.perPage;

  @override
  int get hashCode => Object.hash(
        currentPage,
        totalPages,
        totalOrders,
        hasNextPage,
        hasPrevPage,
        perPage,
      );
}
