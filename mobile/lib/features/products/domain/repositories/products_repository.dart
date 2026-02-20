/// Products Repository Interface
library;

import '../entities/barcode_result.dart';
import '../entities/product.dart';
import '../entities/pagination.dart';

abstract class ProductsRepository {
  Future<({List<Product> products, Pagination pagination})> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? lowStock,
  });

  Future<Product> getProductById(String id);

  Future<Product> createProduct({
    required String name,
    required int currentStock,
    required int reorderThreshold,
    required String unit,
    String? barcode,
    double? price,
  });

  Future<Product> updateProduct({
    required String id,
    String? name,
    int? currentStock,
    int? reorderThreshold,
    String? unit,
    String? barcode,
    double? price,
  });

  Future<void> deleteProduct(String id);

  Future<int> adjustStock({
    required String id,
    required int adjustment,
    String? reason,
  });

  Future<ProductImage> uploadProductImage(String id, String filePath);

  Future<void> deleteProductImage(String productId, String imageId);

  Future<BarcodeResult?> lookupBarcode(String barcode);
}
