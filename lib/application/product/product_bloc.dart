import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/product/productRepository.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(const ProductState()) {
    on<FetchProductsEvent>(_onFetchProducts);
    on<GetProductByIdEvent>(_onGetProductById);
    on<AddToCartEvent>(_onAddToCart);
    on<RemoveFromCartEvent>(_onRemoveFromCart);
  }

  Future<void> _onFetchProducts(
      FetchProductsEvent event, Emitter<ProductState> emit) async {
    emit(state.copyWith(
        productRequestStatus: ProductRequestStatus.requestInProgress));
    try {
      final products = await repository.getAllProducts();
      products.fold(
        (failure) => emit(state.copyWith(
          productRequestStatus: ProductRequestStatus.requestFailure,
          error: failure.toString(),
        )),
        (productList) => emit(state.copyWith(
          productRequestStatus: ProductRequestStatus.requestSuccess,
          products: productList,
        )),
      );
    } catch (e) {
      emit(state.copyWith(
        productRequestStatus: ProductRequestStatus.requestFailure,
        error: e.toString(),
      ));
    }
  }

  Future<void> _onGetProductById(
      GetProductByIdEvent event, Emitter<ProductState> emit) async {
    emit(state.copyWith(selectedProduct: null));
    try {
      final productResult = await repository.getProductById(event.productId);
      productResult.fold(
        (failure) => emit(state.copyWith(error: failure.toString())),
        (product) => emit(state.copyWith(selectedProduct: product)),
      );
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onAddToCart(AddToCartEvent event, Emitter<ProductState> emit) {
    final updatedCart = Map<String, int>.from(state.cart);
    updatedCart.update(
      event.productId,
      (value) => value + 1,
      ifAbsent: () => 1,
    );
    emit(state.copyWith(cart: updatedCart));
  }

  void _onRemoveFromCart(
      RemoveFromCartEvent event, Emitter<ProductState> emit) {
    final updatedCart = Map<String, int>.from(state.cart);
    if (updatedCart.containsKey(event.productId)) {
      if (updatedCart[event.productId]! > 1) {
        updatedCart[event.productId] = updatedCart[event.productId]! - 1;
      } else {
        updatedCart.remove(event.productId);
      }
    }
    emit(state.copyWith(cart: updatedCart));
  }
}
