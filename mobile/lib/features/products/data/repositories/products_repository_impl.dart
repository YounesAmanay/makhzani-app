/// Products Repository Implementation
library;

import '../../domain/entities/barcode_result.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/pagination.dart';
import '../../domain/repositories/products_repository.dart';
import '../datasources/products_remote_datasource.dart';

class ProductsRepositoryImpl implements ProductsRepository {
  final ProductsRemoteDataSource _remoteDataSource;

  ProductsRepositoryImpl(this._remoteDataSource);

  @override
  Future<({List<Product> products, Pagination pagination})> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    bool? lowStock,
  }) async {
    final result = await _remoteDataSource.getProducts(
      page: page,
      limit: limit,
      search: search,
      lowStock: lowStock,
    );

    return (
      products: result.products.map((m) => m.toEntity()).toList(),
      pagination: result.pagination.toEntity(),
    );
  }

  @override
  Future<Product> getProductById(String id) async {
    final model = await _remoteDataSource.getProductById(id);
    return model.toEntity();
  }

  @override
  Future<Product> createProduct({
    required String name,
    required int currentStock,
    required int reorderThreshold,
    required String unit,
    String? barcode,
    double? price,
    String? categoryId,
  }) async {
    final model = await _remoteDataSource.createProduct({
      'name': name,
      'current_stock': currentStock,
      'reorder_threshold': reorderThreshold,
      'unit': unit,
      if (barcode != null) 'barcode': barcode,
      if (price != null) 'price': price,
      if (categoryId != null) 'category_id': categoryId,
    });
    return model.toEntity();
  }

  @override
  Future<Product> updateProduct({
    required String id,
    String? name,
    int? currentStock,
    int? reorderThreshold,
    String? unit,
    String? barcode,
    double? price,
    String? categoryId,
  }) async {
    final data = <String, dynamic>{};
    if (name != null) data['name'] = name;
    if (currentStock != null) data['current_stock'] = currentStock;
    if (reorderThreshold != null) data['reorder_threshold'] = reorderThreshold;
    if (unit != null) data['unit'] = unit;
    if (barcode != null) data['barcode'] = barcode;
    if (price != null) data['price'] = price;
    if (categoryId != null) data['category_id'] = categoryId;

    final model = await _remoteDataSource.updateProduct(id, data);
    return model.toEntity();
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _remoteDataSource.deleteProduct(id);
  }

  @override
  Future<int> adjustStock({
    required String id,
    required int adjustment,
    String? reason,
  }) async {
    return await _remoteDataSource.adjustStock(id, adjustment, reason);
  }

  @override
  Future<ProductImage> uploadProductImage(String id, String filePath) async {
    final model = await _remoteDataSource.uploadProductImage(id, filePath);
    return model.toEntity();
  }

  @override
  Future<void> deleteProductImage(String productId, String imageId) async {
    await _remoteDataSource.deleteProductImage(productId, imageId);
  }

  @override
  Future<BarcodeResult?> lookupBarcode(String barcode) async {
    final model = await _remoteDataSource.lookupBarcode(barcode);
    return model?.toEntity();
  }
}
