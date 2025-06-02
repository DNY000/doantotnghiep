import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/data/models/restaurant_model.dart';
import 'dart:math';
import 'package:flutter/foundation.dart';

class RestaurantRepository {
  final FirebaseFirestore _firestore;

  RestaurantRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final String _collection = 'restaurants';

  // Lấy danh sách restaurant
  Future<List<RestaurantModel>> getRestaurants() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách nhà hàng: $e');
    }
  }

  // Lấy restaurant theo id
  Future<RestaurantModel?> getRestaurantById(String restaurantId) async {
    try {
      final doc =
          await _firestore.collection('restaurants').doc(restaurantId).get();
      if (!doc.exists) return null;

      return RestaurantModel.fromMap(
          doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Không thể lấy nhà hàng theo id: $e');
    }
  }

  // Lấy restaurant theo danh mục
  Future<List<RestaurantModel>> getRestaurantsByCategory(
      String category) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where("categories", arrayContains: category)
          .where("metadata.isActive", isEqualTo: true)
          .get();
      return snapshot.docs
          .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy nhà hàng theo danh mục: $e');
    }
  }

  // Lấy nhà hàng mới
  Future<List<RestaurantModel>> getNewRestaurants({int limit = 10}) async {
    try {
      final query = _firestore
          .collection(_collection)
          .orderBy("createdAt", descending: true)
          .limit(limit);

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        debugPrint('No restaurants found');
        return [];
      }

      final restaurants = snapshot.docs.map((doc) {
        try {
          return RestaurantModel.fromMap(doc.data(), doc.id);
        } catch (e) {
          rethrow;
        }
      }).toList();

      return restaurants;
    } catch (e) {
      if (e.toString().contains('failed-precondition')) {}
      throw Exception('Không thể lấy danh sách nhà hàng mới: $e');
    }
  }

  // Lấy nhà hàng gần đây
  Future<List<RestaurantModel>> getNearbyRestaurants({
    required GeoPoint userLocation,
    required double radiusInKm,
    int limit = 10,
  }) async {
    try {
      debugPrint(
          'User location: ${userLocation.latitude}, ${userLocation.longitude}, radius: ${radiusInKm}km');

      // Calculate bounding box
      final double latChange =
          radiusInKm / 111.32; // 1 degree latitude ≈ 111.32 km
      final double lonChange =
          radiusInKm / (111.32 * cos(userLocation.latitude * pi / 180));

      final double minLat = userLocation.latitude - latChange;
      final double maxLat = userLocation.latitude + latChange;
      final double minLon = userLocation.longitude - lonChange;
      final double maxLon = userLocation.longitude + lonChange;

      // Query restaurants
      final querySnapshot = await _firestore.collection('restaurants').get();

      // Filter restaurants within bounding box and calculate distances
      final List<MapEntry<RestaurantModel, double>> restaurantsWithDistances =
          [];
      int invalidLocationCount = 0;
      int outsideBoundingBoxCount = 0;
      int outsideRadiusCount = 0;

      for (final doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          final rawLocation = data['location'];

          // Debug log for location data

          // Convert location to proper format
          final location = _ensureGeoPoint(rawLocation);

          if (location != null) {
            if (location.latitude >= minLat &&
                location.latitude <= maxLat &&
                location.longitude >= minLon &&
                location.longitude <= maxLon) {
              final distance = _calculateDistance(
                userLocation.latitude,
                userLocation.longitude,
                location.latitude,
                location.longitude,
              );

              if (distance <= radiusInKm) {
                final restaurant = RestaurantModel.fromMap(data, doc.id);
                restaurantsWithDistances.add(MapEntry(restaurant, distance));
              } else {
                outsideRadiusCount++;
              }
            } else {
              outsideBoundingBoxCount++;
            }
          } else {
            invalidLocationCount++;
          }
        } catch (e) {
          debugPrint('Error processing restaurant: ${doc.id}, error: $e');
          continue;
        }
      }

      // Sort by distance and take limit
      restaurantsWithDistances.sort((a, b) => a.value.compareTo(b.value));
      final limitedRestaurants = restaurantsWithDistances.take(limit);

      return limitedRestaurants.map((entry) => entry.key).toList();
    } catch (e) {
      debugPrint('Error in getNearbyRestaurants: $e');
      rethrow;
    }
  }

  // Parse location string to proper coordinate
  double _parseCoordinate(String coordinateStr) {
    try {
      // Remove degree symbol and direction indicators
      String cleanStr = coordinateStr
          .replaceAll('°', '')
          .replaceAll('N', '')
          .replaceAll('E', '')
          .replaceAll('S', '')
          .replaceAll('W', '')
          .trim();
      return double.parse(cleanStr);
    } catch (e) {
      debugPrint('Invalid coordinate format: $coordinateStr');
      throw Exception('Invalid coordinate format: $coordinateStr');
    }
  }

  // Convert location if needed
  GeoPoint? _ensureGeoPoint(dynamic location) {
    if (location == null) {
      debugPrint('Location is null');
      return null;
    }

    if (location is GeoPoint) {
      return location;
    }

    if (location is Map<String, dynamic>) {
      try {
        // Check if latitude and longitude exist
        if (!location.containsKey('latitude') ||
            !location.containsKey('longitude')) {
          debugPrint('Location missing latitude or longitude: $location');
          return null;
        }

        double lat;
        if (location['latitude'] is String) {
          lat = _parseCoordinate(location['latitude']);
        } else if (location['latitude'] is num) {
          lat = location['latitude'].toDouble();
        } else {
          debugPrint(
              'Invalid latitude type: ${location['latitude'].runtimeType}');
          return null;
        }

        double lng;
        if (location['longitude'] is String) {
          lng = _parseCoordinate(location['longitude']);
        } else if (location['longitude'] is num) {
          lng = location['longitude'].toDouble();
        } else {
          debugPrint(
              'Invalid longitude type: ${location['longitude'].runtimeType}');
          return null;
        }

        // Validate coordinates
        if (lat < -90 || lat > 90 || lng < -180 || lng > 180) {
          debugPrint('Coordinates out of range: lat=$lat, lng=$lng');
          return null;
        }

        return GeoPoint(lat, lng);
      } catch (e) {
        debugPrint('Error converting location: $e');
        return null;
      }
    }

    debugPrint('Unsupported location type: ${location.runtimeType}');
    return null;
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert to radians
    final double phi1 = _toRadians(lat1);
    final double phi2 = _toRadians(lat2);
    final double deltaPhi = _toRadians(lat2 - lat1);
    final double deltaLambda = _toRadians(lon2 - lon1);

    final double a = sin(deltaPhi / 2) * sin(deltaPhi / 2) +
        cos(phi1) * cos(phi2) * sin(deltaLambda / 2) * sin(deltaLambda / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  Stream<List<RestaurantModel>> getAllRestaurants() {
    return _firestore.collection('restaurants').snapshots().map((snapshot) =>
        snapshot.docs
            .map((doc) => RestaurantModel.fromMap(doc.data(), doc.id))
            .toList());
  }
}
