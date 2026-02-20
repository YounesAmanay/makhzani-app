/// Barcode Result Model
library;

import '../../domain/entities/barcode_result.dart';

class BarcodeResultModel {
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

  const BarcodeResultModel({
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

  factory BarcodeResultModel.fromJson(Map<String, dynamic> json) {
    return BarcodeResultModel(
      barcode: json['barcode'] as String,
      name: json['name'] as String,
      brand: json['brand'] as String?,
      quantity: json['quantity'] as String?,
      unit: _mapUnit(json['unit'] as String?),
      unitValue: json['unit_value'] != null
          ? (json['unit_value'] as num).toDouble()
          : null,
      category: json['category'] as String?,
      imageUrl: json['image_url'] as String?,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      source: json['source'] as String? ?? 'unknown',
      confidence: json['confidence'] as String? ?? 'low',
    );
  }

  /// Maps API unit strings to the app's valid product unit values.
  /// Backend units: g, kg, ml, l, cl, oz, lb, piece
  /// App units: piece, kg, liter, box, carton, bottle
  static String _mapUnit(String? apiUnit) {
    switch (apiUnit?.toLowerCase()) {
      case 'kg':
      case 'g':
      case 'lb':
      case 'oz':
        return 'kg';
      case 'l':
      case 'ml':
      case 'cl':
        return 'liter';
      case 'bottle':
        return 'bottle';
      case 'box':
        return 'box';
      case 'carton':
        return 'carton';
      default:
        return 'piece';
    }
  }

  BarcodeResult toEntity() => BarcodeResult(
        barcode: barcode,
        name: name,
        brand: brand,
        quantity: quantity,
        unit: unit,
        unitValue: unitValue,
        category: category,
        imageUrl: imageUrl,
        images: images,
        source: source,
        confidence: confidence,
      );
}
