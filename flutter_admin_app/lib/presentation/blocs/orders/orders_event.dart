part of 'orders_bloc.dart';

abstract class OrdersEvent {
  const OrdersEvent();
}

class FetchOrdersRequested extends OrdersEvent {}

class CreateOrderRequested extends OrdersEvent {
  final Order order;

  const CreateOrderRequested(this.order);
}

class FilterOrdersRequested extends OrdersEvent {
  final String? status;
  final DateTime? startDate;
  final DateTime? endDate;

  const FilterOrdersRequested({
    this.status,
    this.startDate,
    this.endDate,
  });
}