class Product {
  String id;
  String productName;
  String description;
  double price;
  List<String> Images;
  bool availability;

  Product({
    required this.id,
    required this.productName,
    required this.description,
    required this.price,
    required this.Images,
    required this.availability,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['_id'] as String,
      productName: json['productName'] as String,
      description: json['description'] as String,
      price: json['price'].toDouble() as double,
      Images: List<String>.from(json['Images'] as List<dynamic>),
      availability: json['availability'] as bool,
    );
  }
}
