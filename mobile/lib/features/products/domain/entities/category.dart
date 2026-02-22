/// Category Entity
library;

class Category {
  final String id;
  final String name;
  final String? color;
  final String? icon;
  final int sortOrder;

  const Category({
    required this.id,
    required this.name,
    this.color,
    this.icon,
    required this.sortOrder,
  });
}
