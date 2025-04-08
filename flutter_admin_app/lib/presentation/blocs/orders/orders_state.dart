part of 'orders_bloc.dart';

enum OrdersStatus { initial, loading, loaded, error }

class OrdersState {
  final OrdersStatus status;
  final List<Order> orders;
  final List<Order> filteredOrders;
  final String? errorMessage;

  const OrdersState({
    this.status = OrdersStatus.initial,
    this.orders = const [],
    this.filteredOrders = const [],
    this.errorMessage,
  });

  OrdersState copyWith({
    OrdersStatus? status,
    List<Order>? orders,
    List<Order>? filteredOrders,
    String? errorMessage,
  }) {
    return OrdersState(
      status: status ?? this.status,
      orders: orders ?? this.orders,
      filteredOrders: filteredOrders ?? this.filteredOrders,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}