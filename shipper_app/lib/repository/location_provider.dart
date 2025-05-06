import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationProvider with ChangeNotifier {
  Position? _currentLocation;
  StreamSubscription<Position>? _locationSubscription;
  bool _isLoading = false;

  Position? get currentLocation => _currentLocation;
  bool get isLoading => _isLoading;

  Future<void> initLocation(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    // Yêu cầu quyền truy cập vị trí
    final hasPermission = await LocationService.requestLocationPermission(
      context,
    );
    if (!hasPermission) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    // Lấy vị trí hiện tại
    _currentLocation = await LocationService.getCurrentLocation();
    _isLoading = false;
    notifyListeners();

    // Lắng nghe cập nhật vị trí
    _locationSubscription?.cancel();
    _locationSubscription = LocationService.getLocationStream().listen((
      position,
    ) {
      _currentLocation = position;
      notifyListeners();
    });
  }

  void stopLocationUpdates() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  @override
  void dispose() {
    stopLocationUpdates();
    super.dispose();
  }
}
