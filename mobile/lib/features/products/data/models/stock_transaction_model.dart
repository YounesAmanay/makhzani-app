/// Stock Transaction Model
library;

import '../../domain/entities/stock_transaction.dart';

class StockTransactionModel {
  final String id;
  final String productId;
  final String type;
  final int oldQuantity;
  final int newQuantity;
  final int changeAmount;
  final String? reason;
  final String? referenceId;
  final String? referenceType;
  final DateTime createdAt;

  const StockTransactionModel({
    required this.id,
    required this.productId,
    required this.type,
    required this.oldQuantity,
    required this.newQuantity,
    required this.changeAmount,
    this.reason,
    this.referenceId,
    this.referenceType,
    required this.createdAt,
  });

  factory StockTransactionModel.fromJson(Map<String, dynamic> json) {
    return StockTransactionModel(
      id: json['id'] as String,
      productId: json['product_id'] as String,
      type: json['type'] as String,
      oldQuantity: (json['old_quantity'] as num).toInt(),
      newQuantity: (json['new_quantity'] as num).toInt(),
      changeAmount: (json['change_amount'] as num).toInt(),
      reason: json['reason'] as String?,
      referenceId: json['reference_id'] as String?,
      referenceType: json['reference_type'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  StockTransaction toEntity() => StockTransaction(
        id: id,
        productId: productId,
        type: type,
        oldQuantity: oldQuantity,
        newQuantity: newQuantity,
        changeAmount: changeAmount,
        reason: reason,
        referenceId: referenceId,
        referenceType: referenceType,
        createdAt: createdAt,
      );
}
