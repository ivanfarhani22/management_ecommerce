// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Transaction _$TransactionFromJson(Map<String, dynamic> json) => Transaction(
      id: (json['id'] as num).toInt(),
      orderId: (json['order_id'] as num).toInt(),
      amount: const AmountConverter().fromJson(json['amount']),
      status: json['status'] as String? ?? 'unknown',
      paymentMethod: json['payment_method'] as String? ?? 'unknown',
      transactionDate: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      reference: json['reference'] as String?,
      transactionId: json['transaction_id'] as String?,
    );

Map<String, dynamic> _$TransactionToJson(Transaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'order_id': instance.orderId,
      'payment_method': instance.paymentMethod,
      'amount': const AmountConverter().toJson(instance.amount),
      'status': instance.status,
      'transaction_id': instance.transactionId,
      'created_at': instance.transactionDate?.toIso8601String(),
      'reference': instance.reference,
    };