import '../models/order.dart';
import 'api_client.dart';

class OrderApi {
  final ApiClient apiClient;

  OrderApi(this.apiClient);

  Future<List<Order>> getAllOrders() async {
    try {
      final response = await apiClient.get('/v1/orders');
      return (response as List)
        .map((orderJson) => Order.fromJson(orderJson))
        .toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Order> getOrderById(int orderId) async {
    try {
      final response = await apiClient.get('/v1/orders/$orderId');
      return Order.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Order> createOrder(Order order) async {
    try {
      final response = await apiClient.post('/v1/orders', body: order.toJson());
      return Order.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }
}