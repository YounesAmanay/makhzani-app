/// Category Model
library;

import '../../domain/entities/category.dart';

class CategoryModel {
  final String id;
  final String name;
  final String? color;
  final String? icon;
  final int sortOrder;

  const CategoryModel({
    required this.id,
    required this.name,
    this.color,
    this.icon,
    required this.sortOrder,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      if (color != null) 'color': color,
      if (icon != null) 'icon': icon,
      'sort_order': sortOrder,
    };
  }

  Category toEntity() => Category(
        id: id,
        name: name,
        color: color,
        icon: icon,
        sortOrder: sortOrder,
      );
}
