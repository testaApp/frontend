import 'package:dartz/dartz.dart';

import 'package:blogapp/data/providers/productDataProvider.dart';
import '../core/failure.dart';
import 'product.dart';

class ProductRepository {
  final ProductDataProvider dataProvider = ProductDataProvider();

  ProductRepository();

  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      final products = await dataProvider.getAllProducts();
      return Right(products);
    } catch (e) {
      return Left(Failure('Failed to fetch products: $e'));
    }
  }

  Future<Either<Failure, Product>> getProductById(String productId) async {
    try {
      final product = await dataProvider.getProductById(productId);
      return Right(product);
    } catch (e) {
      return Left(Failure('Failed to fetch product: $e'));
    }
  }
}
