import 'package:cloud_firestore/cloud_firestore.dart';

class ShipperModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String avatarUrl;
  final String address;
  final String email;
  final double ratting;
  final DateTime createdAt;
  bool isActive;
  final Map<String, dynamic> location; // Vị trí
  final bool isAuthenticated;

  ShipperModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.avatarUrl,
    required this.address,
    required this.email,
    required this.ratting,
    required this.createdAt,
    required this.isActive,
    required this.location,
    required this.isAuthenticated,
  });

  ShipperModel.empty()
    : id = '',
      name = '',
      phoneNumber = '',
      avatarUrl = '',
      address = '',
      email = '',
      ratting = 0.0,
      createdAt = DateTime.now(),
      isActive = false,
      location = {},
      isAuthenticated = false;

  factory ShipperModel.fromMap(Map<String, dynamic> map, String docId) {
    return ShipperModel(
      id: docId,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      avatarUrl: map['avatarUrl'] ?? '',
      address: map['address'] ?? '',
      email: map['email'] ?? '',
      ratting: (map['ratting'] ?? 0.0).toDouble(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
      location: Map<String, dynamic>.from(map['location'] ?? {}),
      isAuthenticated: map['isAuthenticated'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'address': address,
      'email': email,
      'ratting': ratting,
      'createdAt': createdAt,
      'isActive': isActive,
      'location': location,
      'isAuthenticated': isAuthenticated,
    };
  }

  ShipperModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? avatarUrl,
    String? address,
    String? email,
    double? ratting,
    DateTime? createdAt,
    bool? isActive,
    Map<String, dynamic>? location,
    bool? isAuthenticated,
  }) {
    return ShipperModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      address: address ?? this.address,
      email: email ?? this.email,
      ratting: ratting ?? this.ratting,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      location: location ?? this.location,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}
