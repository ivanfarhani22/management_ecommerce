import 'package:json_annotation/json_annotation.dart';
import 'order.dart';
import 'user.dart';

part 'transaction.g.dart';

@JsonSerializable()
class Transaction {
  final int? id;
  final int? userId;
  final User? user;
  final int? orderId;
  final Order? order;
  final double amount;
  final String paymentMethod;
  final String status;
  final DateTime? transactionDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Transaction({
    this.id,
    this.userId,
    this.user,
    this.orderId,
    this.order,
    required this.amount,
    required this.paymentMethod,
    this.status = 'pending',
    this.transactionDate,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  
  Map<String, dynamic> toJson() => _$TransactionToJson(this);

  // Helper methods for transaction status
  bool get isSuccessful => status.toLowerCase() == 'success';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isFailed => status.toLowerCase() == 'failed';
}