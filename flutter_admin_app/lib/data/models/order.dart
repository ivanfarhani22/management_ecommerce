import 'package:json_annotation/json_annotation.dart';
import 'product.dart';
import 'user.dart';

part 'order.g.dart';

@JsonSerializable()
class Order {
  final int? id;
  final int? userId;
  final User? user;
  final List<OrderItem> items;
  final double totalAmount;
  final String status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Order({
    this.id,
    this.userId,
    this.user,
    required this.items,
    required this.totalAmount,
    this.status = 'pending',
    this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) => _$OrderFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrderToJson(this);

  // Helper methods
  int get totalQuantity => 
    items.fold(0, (total, item) => total + item.quantity);
}

@JsonSerializable()
class OrderItem {
  final int? id;
  final int? orderId;
  final int productId;
  final Product? product;
  final int quantity;
  final double price;

  OrderItem({
    this.id,
    this.orderId,
    required this.productId,
    this.product,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) => _$OrderItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$OrderItemToJson(this);

  double get subtotal => quantity * price;
}