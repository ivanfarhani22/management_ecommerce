// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Receipt _$ReceiptFromJson(Map<String, dynamic> json) => Receipt(
  id: (json['id'] as num?)?.toInt(),
  receiptNumber: json['receiptNumber'] as String?,
  receiptDate: DateTime.parse(json['receiptDate'] as String),
  totalAmount: (json['totalAmount'] as num).toDouble(),
  supplierName: json['supplierName'] as String?,
  notes: json['notes'] as String?,
  imageUrl: json['imageUrl'] as String?,
  createdAt:
      json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
  updatedAt:
      json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReceiptToJson(Receipt instance) => <String, dynamic>{
  'id': instance.id,
  'receiptNumber': instance.receiptNumber,
  'receiptDate': instance.receiptDate.toIso8601String(),
  'totalAmount': instance.totalAmount,
  'supplierName': instance.supplierName,
  'notes': instance.notes,
  'imageUrl': instance.imageUrl,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};
