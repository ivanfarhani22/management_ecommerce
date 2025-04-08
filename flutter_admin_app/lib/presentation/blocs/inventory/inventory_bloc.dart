import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/product_repository.dart';
import '../../../data/models/product.dart';

part 'inventory_event.dart';
part 'inventory_state.dart';

class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final ProductRepository productRepository;

  InventoryBloc({required this.productRepository}) : super(const InventoryState()) {
    on<FetchInventoryRequested>(_onFetchInventoryRequested);
    on<AddProductRequested>(_onAddProductRequested);
    on<UpdateProductRequested>(_onUpdateProductRequested);
    on<DeleteProductRequested>(_onDeleteProductRequested);
  }

  Future<void> _onFetchInventoryRequested(
    FetchInventoryRequested event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(status: InventoryStatus.loading));
    try {
      final products = await productRepository.getAllProducts();
      emit(state.copyWith(
        status: InventoryStatus.loaded,
        products: products,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onAddProductRequested(
    AddProductRequested event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final newProduct = await productRepository.createProduct(event.product);
      final updatedProducts = List<Product>.from(state.products)..add(newProduct);
      emit(state.copyWith(
        status: InventoryStatus.loaded,
        products: updatedProducts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateProductRequested(
    UpdateProductRequested event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      final updatedProduct = await productRepository.updateProduct(event.product);
      final updatedProducts = state.products.map((product) {
        return product.id == updatedProduct.id ? updatedProduct : product;
      }).toList();
      emit(state.copyWith(
        status: InventoryStatus.loaded,
        products: updatedProducts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteProductRequested(
    DeleteProductRequested event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      await productRepository.deleteProduct(event.productId);
      final updatedProducts = state.products
          .where((product) => product.id != event.productId)
          .toList();
      emit(state.copyWith(
        status: InventoryStatus.loaded,
        products: updatedProducts,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: InventoryStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }
}