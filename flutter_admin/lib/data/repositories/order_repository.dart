import '../api/order_api.dart';
import '../local/database_helper.dart';
import '../models/order.dart';

class OrderRepository {
  final OrderService orderService;
  final DatabaseHelper databaseHelper;

  OrderRepository({
    required this.orderService,
    required this.databaseHelper,
  });

  Future<List<Order>> getAllOrders() async {
    try {
      // Fetch from API
      final apiOrders = await orderService.getAllOrders();
      
      // Cache orders in local database
      for (var order in apiOrders) {
        await databaseHelper.insert('orders', order.toJson());
      }
      
      return apiOrders;
    } catch (e) {
      // Fallback to local database
      final localOrders = await databaseHelper.query('orders');
      return localOrders.map((json) => Order.fromJson(json)).toList();
    }
  }

  Future<Order> getOrderById(String orderId) async {
    try {
      // Try to fetch from API first
      final orderDetails = await orderService.getOrderDetails(orderId);
      return Order.fromJson(orderDetails);
    } catch (e) {
      // Fallback to local database
      final localOrder = await databaseHelper.query(
        'orders', 
        where: 'id = ?', 
        whereArgs: [orderId]
      );
      
      if (localOrder.isNotEmpty) {
        return Order.fromJson(localOrder.first);
      }
      
      rethrow;
    }
  }

  Future<Order> createOrder(Order order) async {
    try {
      final createdOrder = await orderService.createOrder(order);
      
      // Cache in local database
      await databaseHelper.insert('orders', createdOrder.toJson());
      
      return createdOrder;
    } catch (e) {
      rethrow;
    }
  }
}