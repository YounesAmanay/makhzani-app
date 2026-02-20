/// Barcode Lookup Result Entity
library;

class BarcodeResult {
  final String barcode;
  final String name;
  final String? brand;
  final String? quantity;
  final String? unit;
  final double? unitValue;
  final String? category;
  final String? imageUrl;
  final List<String> images;
  final String source;
  final String confidence;

  const BarcodeResult({
    required this.barcode,
    required this.name,
    this.brand,
    this.quantity,
    this.unit,
    this.unitValue,
    this.category,
    this.imageUrl,
    required this.images,
    required this.source,
    required this.confidence,
  });

  bool get isHighConfidence => confidence == 'high';

  String get sourceLabel {
    switch (source) {
      case 'openfoodfacts':
        return 'Open Food Facts';
      case 'upcitemdb':
        return 'UPC Database';
      default:
        return source;
    }
  }
}
