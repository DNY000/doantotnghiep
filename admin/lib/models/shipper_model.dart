import 'dart:convert';

class ShipperModel {
  final String id;
  final String name;
  final String phoneNumber;
  final DateTime birthDate;
  final String avatarUrl;
  final String vehicleType;
  final String email;
  final String address;
  final String status;
  final DateTime createdAt;
  ShipperModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.birthDate,
    required this.avatarUrl,
    required this.vehicleType,
    required this.email,
    required this.address,
    required this.status,
    required this.createdAt,
  });

  // Factory constructor để tạo một shipper rỗng
  factory ShipperModel.empty() {
    return ShipperModel(
      id: '',
      name: '',
      phoneNumber: '',
      birthDate: DateTime.now(),
      avatarUrl: '',
      vehicleType: '',
      email: '',
      address: '',
      status: 'inactive',
      createdAt: DateTime.now(),
    );
  }

  // Chuyển đổi model thành Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phoneNumber': phoneNumber,
      'birthDate': birthDate.millisecondsSinceEpoch,
      'avatarUrl': avatarUrl,
      'vehicleType': vehicleType,
      'email': email,
      'address': address,
      'status': status,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  // Chuyển đổi model thành JSON string
  String toJson() => json.encode(toMap());

  // Factory constructor để tạo model từ Map
  factory ShipperModel.fromMap(Map<String, dynamic> map, String id) {
    return ShipperModel(
      id: id,
      name: map['name'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      birthDate: DateTime.fromMillisecondsSinceEpoch(map['birthDate'] ?? 0),
      avatarUrl: map['avatarUrl'] ?? '',
      vehicleType: map['vehicleType'] ?? '',
      email: map['email'] ?? '',
      address: map['address'] ?? '',
      status: map['status'] ?? 'inactive',
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? 0),
    );
  }

  // Factory constructor để tạo model từ JSON string
  factory ShipperModel.fromJson(String source, String id) =>
      ShipperModel.fromMap(json.decode(source), id);
}

// Model để quản lý vị trí realtime của shipper
class ShipperLocationModel {
  final String shipperId;
  final double latitude;
  final double longitude;
  final DateTime timestamp;
  final bool isOnline;
  final String? currentOrderId; // ID của đơn hàng đang giao (nếu có)

  ShipperLocationModel({
    required this.shipperId,
    required this.latitude,
    required this.longitude,
    required this.timestamp,
    required this.isOnline,
    this.currentOrderId,
  });

  // Factory constructor để tạo location model rỗng
  factory ShipperLocationModel.empty() {
    return ShipperLocationModel(
      shipperId: '',
      latitude: 0.0,
      longitude: 0.0,
      timestamp: DateTime.now(),
      isOnline: false,
    );
  }

  // Chuyển đổi model thành Map
  Map<String, dynamic> toMap() {
    return {
      'shipperId': shipperId,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'isOnline': isOnline,
      'currentOrderId': currentOrderId,
    };
  }

  // Chuyển đổi model thành JSON string
  String toJson() => json.encode(toMap());

  // Factory constructor để tạo model từ Map
  factory ShipperLocationModel.fromMap(Map<String, dynamic> map) {
    return ShipperLocationModel(
      shipperId: map['shipperId'] ?? '',
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? 0),
      isOnline: map['isOnline'] ?? false,
      currentOrderId: map['currentOrderId'],
    );
  }

  // Factory constructor để tạo model từ JSON string
  factory ShipperLocationModel.fromJson(String source) =>
      ShipperLocationModel.fromMap(json.decode(source));

  // Tạo bản sao với các thay đổi
  ShipperLocationModel copyWith({
    String? shipperId,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    bool? isOnline,
    String? currentOrderId,
  }) {
    return ShipperLocationModel(
      shipperId: shipperId ?? this.shipperId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timestamp: timestamp ?? this.timestamp,
      isOnline: isOnline ?? this.isOnline,
      currentOrderId: currentOrderId ?? this.currentOrderId,
    );
  }
}
