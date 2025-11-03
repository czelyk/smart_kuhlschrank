class Product {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String shelfId;
  final DateTime expiryDate;

  Product({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.shelfId,
    required this.expiryDate,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      quantity: json['quantity'],
      unit: json['unit'],
      shelfId: json['shelf_id'],
      expiryDate: DateTime.parse(json['expiry_date']),
    );
  }
}
