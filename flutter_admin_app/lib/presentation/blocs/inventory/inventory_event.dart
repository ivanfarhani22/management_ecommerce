part of 'inventory_bloc.dart';

abstract class InventoryEvent {}

class FetchInventoryRequested extends InventoryEvent {}

class AddProductRequested extends InventoryEvent {
  final Product product;

  AddProductRequested({required this.product});
}

class UpdateProductRequested extends InventoryEvent {
  final Product product;

  UpdateProductRequested({required this.product});
}

class DeleteProductRequested extends InventoryEvent {
  final int productId;

  DeleteProductRequested({required this.productId});
}