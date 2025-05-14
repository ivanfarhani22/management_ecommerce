// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wholesale_note.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WholesaleNote _$WholesaleNoteFromJson(Map<String, dynamic> json) =>
    WholesaleNote(
      id: (json['id'] as num?)?.toInt(),
      noteNumber: json['noteNumber'] as String?,
      noteDate: DateTime.parse(json['noteDate'] as String),
      supplierName: json['supplierName'] as String,
      description: json['description'] as String?,
      totalAmount: (json['totalAmount'] as num).toDouble(),
      status: json['status'] as String? ?? 'pending',
      items:
          (json['items'] as List<dynamic>)
              .map((e) => WholesaleNoteItem.fromJson(e as Map<String, dynamic>))
              .toList(),
      associatedReceipt:
          json['associatedReceipt'] == null
              ? null
              : Receipt.fromJson(
                json['associatedReceipt'] as Map<String, dynamic>,
              ),
      createdAt:
          json['createdAt'] == null
              ? null
              : DateTime.parse(json['createdAt'] as String),
      updatedAt:
          json['updatedAt'] == null
              ? null
              : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$WholesaleNoteToJson(WholesaleNote instance) =>
    <String, dynamic>{
      'id': instance.id,
      'noteNumber': instance.noteNumber,
      'noteDate': instance.noteDate.toIso8601String(),
      'supplierName': instance.supplierName,
      'description': instance.description,
      'totalAmount': instance.totalAmount,
      'status': instance.status,
      'items': instance.items,
      'associatedReceipt': instance.associatedReceipt,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

WholesaleNoteItem _$WholesaleNoteItemFromJson(Map<String, dynamic> json) =>
    WholesaleNoteItem(
      id: (json['id'] as num?)?.toInt(),
      wholesaleNoteId: (json['wholesaleNoteId'] as num?)?.toInt(),
      productId: (json['productId'] as num).toInt(),
      product:
          json['product'] == null
              ? null
              : Product.fromJson(json['product'] as Map<String, dynamic>),
      quantity: (json['quantity'] as num).toInt(),
      unitPrice: (json['unitPrice'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
    );

Map<String, dynamic> _$WholesaleNoteItemToJson(WholesaleNoteItem instance) =>
    <String, dynamic>{
      'id': instance.id,
      'wholesaleNoteId': instance.wholesaleNoteId,
      'productId': instance.productId,
      'product': instance.product,
      'quantity': instance.quantity,
      'unitPrice': instance.unitPrice,
      'totalPrice': instance.totalPrice,
    };
