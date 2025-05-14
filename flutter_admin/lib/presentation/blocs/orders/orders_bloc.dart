import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../data/repositories/order_repository.dart';
import '../../../data/models/order.dart';

part 'orders_event.dart';
part 'orders_state.dart';

class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  final OrderRepository orderRepository;

  OrdersBloc({required this.orderRepository}) : super(const OrdersState()) {
    on<FetchOrdersRequested>(_onFetchOrdersRequested);
    on<CreateOrderRequested>(_onCreateOrderRequested);
    on<FilterOrdersRequested>(_onFilterOrdersRequested);
  }

  Future<void> _onFetchOrdersRequested(
    FetchOrdersRequested event,
    Emitter<OrdersState> emit,
  ) async {
    emit(state.copyWith(status: OrdersStatus.loading));
    try {
      final orders = await orderRepository.getAllOrders();
      emit(state.copyWith(
        status: OrdersStatus.loaded,
        orders: orders,
        filteredOrders: orders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrdersStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateOrderRequested(
    CreateOrderRequested event,
    Emitter<OrdersState> emit,
  ) async {
    try {
      final newOrder = await orderRepository.createOrder(event.order);
      final updatedOrders = List<Order>.from(state.orders)..add(newOrder);
      emit(state.copyWith(
        status: OrdersStatus.loaded,
        orders: updatedOrders,
        filteredOrders: updatedOrders,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: OrdersStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFilterOrdersRequested(
    FilterOrdersRequested event,
    Emitter<OrdersState> emit,
  ) async {
    List<Order> filtered = List.from(state.orders);

    if (event.status != null) {
      filtered = filtered.where((order) => order.status == event.status).toList();
    }

    if (event.startDate != null) {
      filtered = filtered.where((order) => 
        order.createdAt != null && 
        (order.createdAt!.isAfter(event.startDate!) || 
         order.createdAt!.isAtSameMomentAs(event.startDate!))
      ).toList();
    }

    if (event.endDate != null) {
      filtered = filtered.where((order) => 
        order.createdAt != null && 
        (order.createdAt!.isBefore(event.endDate!) || 
         order.createdAt!.isAtSameMomentAs(event.endDate!))
      ).toList();
    }

    emit(state.copyWith(
      status: OrdersStatus.loaded,
      filteredOrders: filtered,
    ));
  }
}