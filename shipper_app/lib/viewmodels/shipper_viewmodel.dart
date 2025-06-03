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

      // 2. Tạo shipper model mới với isAuthenticated = false
      final newShipper = ShipperModel(
        id: uid,
        name: name,
        phoneNumber: phoneNumber,
        avatarUrl: '',
        address: address,
        email: email,
        ratting: 0.0,
        createdAt: DateTime.now(),
        isActive: true,
        location: {},
        isAuthenticated: false, // Mặc định là false khi đăng ký
      );

      // 3. Lưu vào Firestore
      await _firestore.collection('users').doc(uid).set(newShipper.toJson());

      // 4. Đăng xuất sau khi đăng ký thành công
      await _authProvider.logout();

      // 5. Thông báo cho người dùng
      _error =
          'Đăng ký thành công. Vui lòng đợi admin xác thực tài khoản của bạn.';
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

      // 4. Kiểm tra trạng thái xác thực và hoạt động
      if (!_currentShipper!.isActive) {
        throw 'Tài khoản không hoạt động';
      }

      if (!_currentShipper!.isAuthenticated) {
        // Đăng xuất nếu chưa được xác thực
        await _authProvider.logout();
        _currentShipper = null;
        throw 'Tài khoản của bạn chưa được xác thực. Vui lòng đợi admin xác thực.';
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

      // Tạo ShipperModel mới với thông tin đã cập nhật
      final updatedShipper = _currentShipper!.copyWith(
        name: name,
        phoneNumber: phoneNumber,
        address: address,
        avatarUrl: avatarUrl,
      );

      // Cập nhật lên Firestore
      await _firestore
          .collection('shippers')
          .doc(_currentShipper!.id)
          .update(updatedShipper.toJson());

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
}
