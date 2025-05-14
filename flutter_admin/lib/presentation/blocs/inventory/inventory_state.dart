part of 'inventory_bloc.dart';

enum InventoryStatus { initial, loading, loaded, error }

class InventoryState {
  final InventoryStatus status;
  final List<Product> products;
  final String? errorMessage;

  const InventoryState({
    this.status = InventoryStatus.initial,
    this.products = const [],
    this.errorMessage,
  });

  InventoryState copyWith({
    InventoryStatus? status,
    List<Product>? products,
    String? errorMessage,
  }) {
    return InventoryState(
      status: status ?? this.status,
      products: products ?? this.products,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}