class MarketplaceOrder {
  final String? id;
  final String parentId;
  final String parentName;
  final String email;
  final String phone;
  final String deliveryAddress;
  final List<Map<String, dynamic>> items;
  final double subtotal;
  final DateTime createdAt;
  final String status;

  const MarketplaceOrder({
    this.id,
    required this.parentId,
    required this.parentName,
    required this.email,
    required this.phone,
    required this.deliveryAddress,
    required this.items,
    required this.subtotal,
    required this.createdAt,
    this.status = 'pending',
  });

  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'parentName': parentName,
      'email': email,
      'phone': phone,
      'deliveryAddress': deliveryAddress,
      'items': items,
      'subtotal': subtotal,
      'createdAt': createdAt.toIso8601String(),
      'status': status,
    };
  }
}
