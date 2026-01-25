import 'package:equatable/equatable.dart';
import '../../domain/product/product.dart';

enum ProductRequestStatus {
  unknown,
  requestInProgress,
  requestSuccess,
  requestFailure,
}

class ProductState extends Equatable {
  const ProductState({
    this.productRequestStatus = ProductRequestStatus.unknown,
    this.products = const [],
    this.selectedProduct,
    this.cart = const {},
    this.error,
  });

  final ProductRequestStatus productRequestStatus;
  final List<Product> products;
  final Product? selectedProduct;
  final Map<String, int> cart;
  final String? error;

  @override
  List<Object?> get props =>
      [productRequestStatus, products, selectedProduct, cart, error];

  ProductState copyWith({
    ProductRequestStatus? productRequestStatus,
    List<Product>? products,
    Product? selectedProduct,
    Map<String, int>? cart,
    String? error,
  }) =>
      ProductState(
        productRequestStatus: productRequestStatus ?? this.productRequestStatus,
        products: products ?? this.products,
        selectedProduct: selectedProduct ?? this.selectedProduct,
        cart: cart ?? this.cart,
        error: error ?? this.error,
      );

  bool get isLoading =>
      productRequestStatus == ProductRequestStatus.requestInProgress;
  bool get isSuccess =>
      productRequestStatus == ProductRequestStatus.requestSuccess;
  bool get isFailure =>
      productRequestStatus == ProductRequestStatus.requestFailure;

  int get cartItemCount => cart.values.fold(0, (sum, count) => sum + count);
}
