import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter/material.dart';

class LocationService {
  static Position? _lastKnownPosition;
  static DateTime? _lastUpdateTime;
  static const Duration _cacheTimeout = Duration(minutes: 5);
  static const int _maxRetries = 3;
  static const Duration _timeout = Duration(seconds: 10);

  static Future<Position?> getCurrentLocation(BuildContext context) async {
    try {
      // Check if we have a recent cached position
      if (_lastKnownPosition != null && _lastUpdateTime != null) {
        final timeDiff = DateTime.now().difference(_lastUpdateTime!);
        if (timeDiff < _cacheTimeout) {
          return _lastKnownPosition;
        }
      }

      bool serviceEnabled;
      LocationPermission permission;

      // Check if location services are enabled
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (context.mounted) {
          _showLocationServiceDialog(context);
        }
        return null;
      }

      // Check location permission
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (context.mounted) {
            _showSnackBar(context, 'Quyền truy cập vị trí bị từ chối');
          }
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (context.mounted) {
          _showPermissionBlockedDialog(context);
        }
        return null;
      }

      // Try to get location with retries
      Position? position;
      int retryCount = 0;

      while (position == null && retryCount < _maxRetries) {
        try {
          position = await Geolocator.getCurrentPosition(
            // ignore: deprecated_member_use
            desiredAccuracy: LocationAccuracy.high,
            // ignore: deprecated_member_use
            timeLimit: _timeout,
          );
        } catch (e) {
          retryCount++;
          if (retryCount == _maxRetries) {
            if (context.mounted) {
              _showSnackBar(
                  context, 'Không thể lấy vị trí sau $retryCount lần thử');
            }
            return null;
          }
          await Future.delayed(Duration(seconds: retryCount));
        }
      }

      if (position != null) {
        _lastKnownPosition = position;
        _lastUpdateTime = DateTime.now();
      }

      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      if (context.mounted) {
        _showSnackBar(context, 'Có lỗi khi lấy vị trí: $e');
      }
      return null;
    }
  }

  static void _showLocationServiceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Dịch vụ vị trí bị tắt'),
          content: const Text(
            'Để tìm nhà hàng gần bạn, vui lòng bật dịch vụ vị trí trong cài đặt thiết bị.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Đóng'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Mở Cài đặt'),
              onPressed: () => Geolocator.openLocationSettings(),
            ),
          ],
        );
      },
    );
  }

  static void _showPermissionBlockedDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quyền truy cập vị trí bị chặn'),
          content: const Text(
            'Bạn đã chặn quyền truy cập vị trí. Vui lòng vào cài đặt để cho phép ứng dụng truy cập vị trí.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Đóng'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text('Mở Cài đặt'),
              onPressed: () => Geolocator.openAppSettings(),
            ),
          ],
        );
      },
    );
  }

  static void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  static double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  static void clearCache() {
    _lastKnownPosition = null;
    _lastUpdateTime = null;
  }

  /// Chuyển đổi từ vị trí (Position) thành địa chỉ (String)
  static Future<String?> getAddressFromPosition(Position position) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String address = [
          place.street,
          // place.subLocality,
          // place.thoroughfare,
          // place.locality,
          // place.subAdministrativeArea,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        if (place.administrativeArea == 'Ha Noi') {
          address = address.replaceAll('Ha Noi', 'Hà Nội');
        }
        return address;
      }
      return null;
    } catch (e) {
      debugPrint('Error converting position to address: $e');
      return null;
    }
  }
}
