import 'package:geocoding/geocoding.dart';

class AddressModel {
  String street;
  Map<double, double>? location;
  bool isDefault;
  AddressModel({
    required this.street,
    this.location,
    this.isDefault = false,
  });

  // Factory method to create an empty address
  factory AddressModel.empty() {
    return AddressModel(
      street: '',
      location: {},
      isDefault: false,
    );
  }

  factory AddressModel.fromMap(Map<String, dynamic> data, String id) {
    Map<double, double> locationMap = {};

    // Xử lý location nếu có
    if (data['location'] != null) {
      try {
        locationMap = Map<double, double>.from(data['location']);
      } catch (e) {
        print('Lỗi chuyển đổi location: $e');
        // Trong trường hợp lỗi, giữ nguyên map rỗng
      }
    }

    return AddressModel(
      street: data['street'] ?? '',
      location: locationMap,
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'street': street,
      'location': location ?? {},
      'isDefault': isDefault,
    };
  }

  static Future<Map<double, double>?> getLocationFromAddress(
      String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return {location.latitude: location.longitude};
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get location from address: $e');
    }
  }

  Future<bool> updateLocationFromFullAddress() async {
    try {
      final newLocation = await AddressModel.getLocationFromAddress(street);
      if (newLocation != null) {
        location = newLocation;
        return true;
      }
    } catch (e) {
      throw Exception('Failed to update location: $e');
    }
    return false;
  }
}
