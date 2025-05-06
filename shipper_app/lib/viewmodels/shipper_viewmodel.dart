import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shipper_app/repository/auth_provider.dart';
import '../models/shipper_model.dart';

class ShipperViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthenticationRepository _authProvider = AuthenticationRepository();

  ShipperModel? _currentShipper;
  bool _isLoading = false;
  String? _error;

  ShipperModel? get currentShipper => _currentShipper;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // ShipperViewModel(this._authProvider) {
  //   // Lắng nghe sự thay đổi từ AuthProvider
  //   _authProvider.addListener(_checkAuthState);
  // }

  // void _checkAuthState() {
  //   // Nếu đăng xuất, xóa thông tin shipper
  //   if (!_authProvider.isLoggedIn && _currentShipper != null) {
  //     _currentShipper = null;
  //     notifyListeners();
  //   }
  // }

  // Đăng ký tài khoản mới
  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phoneNumber,
    required String address,
  }) async {
    try {
      _setLoading(true);
      _error = null;

      // 1. Tạo tài khoản Firebase Auth
      final credential = await _authProvider.registerEmailAndPassword(
        email,
        password,
      );

      final uid = credential.user!.uid;

      // 2. Tạo shipper model mới
      final newShipper = ShipperModel(
        id: uid,
        profile: {
          'userId': uid,
          'name': name,
          'phoneNumber': phoneNumber,
          'avatarUrl': '',
          'address': address,
          'email': email,
          'role': 'shipper',
        },
        vehicle: {'type': '', 'licensePlate': ''},
        stats: {'rating': 0.0, 'totalDeliveries': 0, 'isAvailable': false},
        location: {},
        metadata: {
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
          'isActive': true,
        },
      );

      // 3. Lưu vào Firestore sử dụng toMap()
      await _firestore.collection('shippers').doc(uid).set(newShipper.toMap());

      // 4. Đăng xuất sau khi đăng ký thành công
      await _authProvider.logout();
    } catch (e) {
      _error = 'Lỗi đăng ký: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Đăng nhập
  Future<void> login({required String email, required String password}) async {
    try {
      _setLoading(true);
      _error = null;

      // 1. Đăng nhập với Firebase Auth
      final credential = await _authProvider.signInWithEmailAndPassword(
        email,
        password,
      );

      // 2. Lấy thông tin shipper từ Firestore
      final doc =
          await _firestore
              .collection('shippers')
              .doc(credential.user!.uid)
              .get();

      if (!doc.exists) {
        throw 'Không tìm thấy thông tin shipper';
      }

      // 3. Chuyển đổi dữ liệu thành ShipperModel
      _currentShipper = ShipperModel.fromMap(doc.data()!, doc.id);

      // Kiểm tra role
      if (_currentShipper!.profile['role'] != 'shipper') {
        throw 'Tài khoản không phải là shipper';
      }
    } catch (e) {
      _error = 'Lỗi đăng nhập: $e';
      await _authProvider.logout();
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      _setLoading(true);
      await _authProvider.logout();
      _currentShipper = null;
      _error = null;
    } catch (e) {
      _error = 'Lỗi đăng xuất: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Cập nhật thông tin shipper
  Future<void> updateProfile({
    String? name,
    String? phoneNumber,
    String? address,
    String? avatarUrl,
  }) async {
    if (!_authProvider.isLoggedIn() || _currentShipper == null) {
      throw 'Chưa đăng nhập';
    }

    try {
      _setLoading(true);

      // Tạo bản sao của profile hiện tại và cập nhật các trường mới
      final updatedProfile = Map<String, String>.from(_currentShipper!.profile);
      if (name != null) updatedProfile['name'] = name;
      if (phoneNumber != null) updatedProfile['phoneNumber'] = phoneNumber;
      if (address != null) updatedProfile['address'] = address;
      if (avatarUrl != null) updatedProfile['avatarUrl'] = avatarUrl;

      // Tạo ShipperModel mới với thông tin đã cập nhật
      final updatedShipper = ShipperModel(
        id: _currentShipper!.id,
        profile: updatedProfile,
        vehicle: _currentShipper!.vehicle,
        stats: _currentShipper!.stats,
        location: _currentShipper!.location,
        metadata: {
          ..._currentShipper!.metadata,
          'lastUpdated': FieldValue.serverTimestamp(),
        },
      );

      // Cập nhật lên Firestore
      await _firestore
          .collection('shippers')
          .doc(_currentShipper!.id)
          .update(updatedShipper.toMap());

      // Cập nhật state
      _currentShipper = updatedShipper;
      notifyListeners();
    } catch (e) {
      _error = 'Lỗi cập nhật thông tin: $e';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}
