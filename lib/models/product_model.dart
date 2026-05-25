class ProductModel {
  final String id;
  final String name;
  final String subtitle;
  final String description;
  final double price;
  final String category;
  final double rating;

  const ProductModel({
    required this.id,
    required this.name,
    required this.subtitle,
    required this.description,
    required this.price,
    required this.category,
    required this.rating,
  });

  String get priceDisplay => '\$${price.toStringAsFixed(2)}';

  factory ProductModel.fromMap(Map<String, dynamic> map, String documentId) {
    return ProductModel(
      id: documentId,
      name: map['name'] ?? '',
      subtitle: map['subtitle'] ?? '',
      description: map['description'] ?? map['subtitle'] ?? '',
      price: (map['price'] is num) ? (map['price'] as num).toDouble() : 0,
      category: map['category'] ?? 'Supplies',
      rating: (map['rating'] is num) ? (map['rating'] as num).toDouble() : 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'subtitle': subtitle,
      'description': description,
      'price': price,
      'category': category,
      'rating': rating,
    };
  }
}
