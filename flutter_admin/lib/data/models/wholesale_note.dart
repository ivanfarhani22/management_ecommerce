import 'package:json_annotation/json_annotation.dart';
import 'product.dart';
import 'receipt.dart';

part 'wholesale_note.g.dart';

@JsonSerializable()
class WholesaleNote {
  final int? id;
  final String? noteNumber;
  final DateTime noteDate;
  final String supplierName;
  final String? description;
  final double totalAmount;
  final String status;
  final List<WholesaleNoteItem> items;
  final Receipt? associatedReceipt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WholesaleNote({
    this.id,
    this.noteNumber,
    required this.noteDate,
    required this.supplierName,
    this.description,
    required this.totalAmount,
    this.status = 'pending',
    required this.items,
    this.associatedReceipt,
    this.createdAt,
    this.updatedAt,
  });

  factory WholesaleNote.fromJson(Map<String, dynamic> json) => _$WholesaleNoteFromJson(json);
  
  Map<String, dynamic> toJson() => _$WholesaleNoteToJson(this);

  // Helper methods
  int get totalQuantity => 
    items.fold(0, (total, item) => total + item.quantity);

  bool get isPaid => status.toLowerCase() == 'paid';
  bool get isPending => status.toLowerCase() == 'pending';
}

@JsonSerializable()
class WholesaleNoteItem {
  final int? id;
  final int? wholesaleNoteId;
  final int productId;
  final Product? product;
  final int quantity;
  final double unitPrice;
  final double totalPrice;

  WholesaleNoteItem({
    this.id,
    this.wholesaleNoteId,
    required this.productId,
    this.product,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
  });

  factory WholesaleNoteItem.fromJson(Map<String, dynamic> json) => _$WholesaleNoteItemFromJson(json);
  
  Map<String, dynamic> toJson() => _$WholesaleNoteItemToJson(this);

  // Computed properties
  double get subtotal => quantity * unitPrice;
}