import 'package:cloud_firestore/cloud_firestore.dart';

class ShipperModel {
  final String id;
  final Map<String, String> profile; // Thông tin cá nhân
  final Map<String, dynamic> vehicle; // Thông tin phương tiện
  final Map<String, dynamic> stats; // Thống kê
  final Map<String, dynamic> location; // Vị trí
  final Map<String, dynamic> metadata; // Thông tin bổ sung

  // Getters cho profile
  String get userId => profile['userId'] ?? '';
  String get name => profile['name'] ?? '';
  String get phoneNumber => profile['phoneNumber'] ?? '';
  String get avatarUrl => profile['avatarUrl'] ?? '';

  // Getters cho vehicle
  String get vehicleType => vehicle['type'] ?? '';
  String get licensePlate => vehicle['licensePlate'] ?? '';

  // Getters cho stats
  double get rating => (stats['rating'] ?? 0).toDouble();
  int get totalDeliveries => stats['totalDeliveries'] ?? 0;
  bool get isAvailable => stats['isAvailable'] ?? false;

  // Getters cho location
  double? get currentLatitude => location['latitude']?.toDouble();
  double? get currentLongitude => location['longitude']?.toDouble();
  GeoPoint? get currentLocation =>
      currentLatitude != null && currentLongitude != null
          ? GeoPoint(currentLatitude!, currentLongitude!)
          : null;

  // Getters cho metadata
  DateTime get createdAt =>
      (metadata['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
  DateTime? get lastUpdated =>
      (metadata['lastUpdated'] as Timestamp?)?.toDate();
  bool get isActive => metadata['isActive'] ?? true;

  const ShipperModel({
    required this.id,
    required this.profile,
    required this.vehicle,
    required this.stats,
    required this.location,
    required this.metadata,
  });

  factory ShipperModel.fromMap(Map<String, dynamic> data, String id) {
    return ShipperModel(
      id: id,
      profile: Map<String, String>.from(data['profile'] ??
          {
            'userId': '',
            'name': '',
            'phoneNumber': '',
            'avatarUrl': '',
          }),
      vehicle: Map<String, dynamic>.from(data['vehicle'] ??
          {
            'type': '',
            'licensePlate': '',
          }),
      stats: Map<String, dynamic>.from(data['stats'] ??
          {
            'rating': 0.0,
            'totalDeliveries': 0,
            'isAvailable': false,
          }),
      location: Map<String, dynamic>.from(data['location'] ?? {}),
      metadata: Map<String, dynamic>.from(data['metadata'] ??
          {
            'createdAt': Timestamp.now(),
            'lastUpdated': Timestamp.now(),
            'isActive': true,
          }),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'profile': profile,
      'vehicle': vehicle,
      'stats': stats,
      'location': {
        ...location,
        'latitude': currentLatitude,
        'longitude': currentLongitude,
        'lastUpdated': Timestamp.now(),
      },
      'metadata': {
        ...metadata,
        'lastUpdated': Timestamp.now(),
      },
    };
  }

  // Helper method cho hiển thị trong danh sách
  Map<String, dynamic> toListView() {
    return {
      'id': id,
      'name': name,
      'avatar': avatarUrl,
      'rating': rating,
      'isAvailable': isAvailable,
      'totalDeliveries': totalDeliveries,
      'vehicleInfo': '$vehicleType - $licensePlate',
    };
  }

  // Helper method cho hiển thị chi tiết
  Map<String, dynamic> toDetailView() {
    return {
      'id': id,
      'profile': {
        'name': name,
        'phone': phoneNumber,
        'avatar': avatarUrl,
      },
      'vehicle': {
        'type': vehicleType,
        'licensePlate': licensePlate,
      },
      'stats': {
        'rating': rating,
        'totalDeliveries': totalDeliveries,
        'isAvailable': isAvailable,
      },
      'location': currentLocation != null
          ? {
              'latitude': currentLatitude,
              'longitude': currentLongitude,
              'lastUpdated': metadata['lastUpdated'],
            }
          : null,
    };
  }

  factory ShipperModel.empty() => ShipperModel(
        id: '',
        profile: {
          'userId': '',
          'name': '',
          'phoneNumber': '',
          'avatarUrl': '',
        },
        vehicle: {
          'type': '',
          'licensePlate': '',
        },
        stats: {
          'rating': 0.0,
          'totalDeliveries': 0,
          'isAvailable': false,
        },
        location: {},
        metadata: {
          'createdAt': Timestamp.now(),
          'lastUpdated': Timestamp.now(),
          'isActive': true,
        },
      );
}
