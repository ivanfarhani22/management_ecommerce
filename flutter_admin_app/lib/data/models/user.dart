import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;
  final String name;
  final String email;
  final String? token; // Tambahkan field token
  final String? profilePicture;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.name,
    required this.email,
    this.token, // Tambahkan ke konstruktor
    this.profilePicture,
    this.role,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  
  Map<String, dynamic> toJson() => _$UserToJson(this);

  // Optional: Add equality and hashCode for comparison
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User && 
      runtimeType == other.runtimeType && 
      id == other.id;

  @override
  int get hashCode => id.hashCode;
}