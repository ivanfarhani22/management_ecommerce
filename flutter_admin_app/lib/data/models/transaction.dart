import 'package:json_annotation/json_annotation.dart';

// This line is required for the code generation to work
part 'transaction.g.dart';

// Custom JSON converter for safely handling amount values that may be strings
class AmountConverter implements JsonConverter<double, dynamic> {
  const AmountConverter();

  @override
  double fromJson(dynamic json) {
    if (json is String) {
      return double.tryParse(json) ?? 0.0;
    } else if (json is num) {
      return json.toDouble();
    }
    return 0.0;
  }

  @override
  dynamic toJson(double value) {
    return value.toString(); // Convert back to String when sending to API
  }
}

// Add the JsonSerializable annotation to enable code generation
@JsonSerializable()
class Transaction {
  final int id;
  
  @JsonKey(name: 'order_id')
  final int orderId;
  
  @AmountConverter()
  final double amount;
  
  @JsonKey(name: 'payment_method')
  final String paymentMethod;
  
  final String status;
  
  @JsonKey(name: 'transaction_id')
  final String? transactionId;
  
  @JsonKey(name: 'created_at')
  final DateTime? transactionDate;
  
  final String? reference;
  
  @JsonKey(name: 'stripe_token', includeIfNull: false)
  final String? stripeToken; // Added for Stripe payments
  
  Transaction({
    required this.id,
    required this.amount,
    required this.paymentMethod,
    required this.status,
    required this.orderId,
    this.transactionId,
    this.transactionDate,
    this.reference,
    this.stripeToken,
  });
  
  // Create from JSON using generated code
  factory Transaction.fromJson(Map<String, dynamic> json) => _$TransactionFromJson(json);
  
  // Convert to JSON using generated code
  Map<String, dynamic> toJson() => _$TransactionToJson(this);
  
  // Create a copy with modified fields
  Transaction copyWith({
    int? id,
    double? amount,
    String? paymentMethod,
    String? status,
    int? orderId,
    String? transactionId,
    DateTime? transactionDate,
    String? reference,
    String? stripeToken,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      orderId: orderId ?? this.orderId,
      transactionId: transactionId ?? this.transactionId,
      transactionDate: transactionDate ?? this.transactionDate,
      reference: reference ?? this.reference,
      stripeToken: stripeToken ?? this.stripeToken,
    );
  }
}