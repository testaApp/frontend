import 'dart:convert';

import 'package:http/http.dart' as http;

import '../domain/product/product.dart';
import '../util/baseUrl.dart';

class ProductDataProvider {
  static String baseUrl = '${BaseUrl().url}/api';

  Future<List<Product>> getAllProducts() async {
    final url = Uri.parse('$baseUrl/products');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body) as List<dynamic>;
      //print(jsonData);
      final products = jsonData
          .map((data) => Product.fromJson(data as Map<String, dynamic>))
          .toList();

      //print(products);

      return products;
    } else {
      throw Exception('Failed to fetch products');
    }
  }

  Future<Product> getProductById(String productId) async {
    final url = Uri.parse('$baseUrl/products/$productId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return Product.fromJson(jsonData as Map<String, dynamic>);
    } else {
      throw Exception('Failed to fetch product');
    }
  }
}
