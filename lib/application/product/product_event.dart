abstract class ProductEvent {}

class FetchProductsEvent extends ProductEvent {}

class GetProductByIdEvent extends ProductEvent {
  final String productId;

  GetProductByIdEvent(this.productId);
}

class AddToCartEvent extends ProductEvent {
  final String productId;

  AddToCartEvent(this.productId);
}

class RemoveFromCartEvent extends ProductEvent {
  final String productId;

  RemoveFromCartEvent(this.productId);
}
