import 'package:foodapp/data/models/user_model.dart';
import 'package:foodapp/data/repositories/user_repository.dart';
import 'package:foodapp/ultils/exception/firebase_exception.dart';
import 'package:foodapp/ultils/exception/format_exception.dart';
import 'package:flutter/foundation.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _repository;
  UserModel? _currentUser;
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  UserViewModel(this._repository);

  // Getters
  UserModel? get currentUser => _currentUser;
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isLoggedIn => _currentUser != null;

  // Lấy thông tin người dùng
  Future<void> fetchUser(String userId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      _currentUser = await _repository.getUserById(userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lưu thông tin người dùng
  Future<void> saveUser(UserModel user) async {
    try {
      _setLoading(true);
      await _repository.saveUser(user);
      _currentUser = user;
      _error = null;
    } on TFirebaseException catch (e) {
      _error = 'Lỗi Firebase: ${e.message}';
      if (kDebugMode) {
        print(_error);
      }
      rethrow;
    } on TFormatException catch (e) {
      _error = 'Lỗi định dạng: ${e.message}';
      if (kDebugMode) {
        print(_error);
      }
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // Cập nhật thông tin cá nhân
  Future<void> updateUser(UserModel user) async {
    try {
      _setLoading(true);
      await _repository.updateUser(user);
      _currentUser = user;
      _error = null;
    } catch (e) {
      _error = 'Không thể cập nhật thông tin người dùng: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Thêm món ăn vào danh sách yêu thích
  Future<void> addToFavorites(String userId, String foodId) async {
    try {
      _setLoading(true);
      await _repository.addToFavorites(userId, foodId);
      if (_currentUser?.id == userId) {
        _currentUser = await _repository.getUser(userId);
      }
      _error = null;
    } catch (e) {
      _error = 'Không thể thêm vào danh sách yêu thích: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Xóa món ăn khỏi danh sách yêu thích
  Future<void> removeFromFavorites(String userId, String foodId) async {
    try {
      _setLoading(true);
      await _repository.removeFromFavorites(userId, foodId);
      if (_currentUser?.id == userId) {
        _currentUser = await _repository.getUser(userId);
      }
      _error = null;
    } catch (e) {
      _error = 'Không thể xóa khỏi danh sách yêu thích: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy thông tin người dùng hiện tại
  Future<void> loadCurrentUser() async {
    try {
      _setLoading(true);
      _currentUser = await _repository.getCurrentUser();
      _error = null;
    } catch (e) {
      _error = 'Không thể tải thông tin người dùng hiện tại: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy thông tin người dùng theo ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      _setLoading(true);
      final user = await _repository.getUserById(userId);
      _error = null;
      return user;
    } catch (e) {
      _error = 'Không thể tải thông tin người dùng: $e';
      if (kDebugMode) {
        print(_error);
      }
      return null;
    } finally {
      _setLoading(false);
    }
  }

  // Lấy danh sách người dùng theo điều kiện
  Future<void> queryUsers({
    String? role,
    bool? isActive,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      _users = await _repository.queryUsers(
        role: role,
        isActive: isActive,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách người dùng: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  // Kiểm tra người dùng có trong danh sách yêu thích không
  bool isFavorite(String foodId) {
    return _currentUser?.favorites.contains(foodId) ?? false;
  }

  // Lọc người dùng theo vai trò
  List<UserModel> filterByRole(String role) {
    return _users.where((user) => user.role == role).toList();
  }

  // Lọc người dùng theo trạng thái
  // List<UserModel> filterByStatus(bool isActive) {
  //   return _users
  //       .where((user) => user.isActive == isActive)
  //       .toList();
  // }

  // Sắp xếp theo ngày tạo
  void sortByCreatedDate({bool ascending = false}) {
    _users.sort((a, b) => ascending
        ? a.createdAt.compareTo(b.createdAt)
        : b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> updateAvatar(String userId, String avatarUrl) async {
    try {
      await _repository.updateAvatar(userId, avatarUrl);
      _currentUser = await _repository.getUser(userId);
      _error = null;
    } catch (e) {
      _error = 'Không thể cập nhật ảnh đại diện: $e';
      if (kDebugMode) {
        print(_error);
      }
    }
  }
}
