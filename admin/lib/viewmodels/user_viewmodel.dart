import 'package:admin/data/repositories/user_repository.dart';
import 'package:admin/models/user_model.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:flutter/foundation.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  List<UserModel> _users = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<UserModel> get users => _users;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Get all users
  Future<void> getAllUsers() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _users = await _userRepository.getAllUsers();
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error getting users: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get users by role
  Future<void> getUsersByRole(Role role) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _users = await _userRepository.queryUsers(role: role.name);
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error getting users by role: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new user
  Future<bool> addUser(UserModel user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userRepository.saveUser(user);
      await getAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error adding user: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user
  Future<bool> updateUser(UserModel user) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userRepository.updateUser(user);
      await getAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating user: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userRepository.deleteUser(userId);
      await getAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error deleting user: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final user = await _userRepository.getUserById(userId);
      return user;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error getting user by ID: $e');
      }
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user avatar
  Future<bool> updateUserAvatar(String userId, String avatarUrl) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userRepository.updateAvatar(userId, avatarUrl);
      await getAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error updating user avatar: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add to favorites
  Future<bool> addToFavorites(String userId, String foodId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userRepository.addToFavorites(userId, foodId);
      await getAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error adding to favorites: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove from favorites
  Future<bool> removeFromFavorites(String userId, String foodId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _userRepository.removeFromFavorites(userId, foodId);
      await getAllUsers(); // Refresh the list
      return true;
    } catch (e) {
      _error = e.toString();
      if (kDebugMode) {
        print('Error removing from favorites: $e');
      }
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
