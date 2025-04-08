import 'package:json_annotation/json_annotation.dart';

part 'receipt.g.dart';

@JsonSerializable()
class Receipt {
  final int? id;
  final String? receiptNumber;
  final DateTime receiptDate;
  final double totalAmount;
  final String? supplierName;
  final String? notes;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Receipt({
    this.id,
    this.receiptNumber,
    required this.receiptDate,
    required this.totalAmount,
    this.supplierName,
    this.notes,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) => _$ReceiptFromJson(json);
  
  Map<String, dynamic> toJson() => _$ReceiptToJson(this);
}