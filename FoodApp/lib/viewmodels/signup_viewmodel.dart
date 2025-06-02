import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/ultils/exception/firebase_exception.dart';
import '../data/models/user_model.dart';
import '../data/repositories/user_repository.dart';

class SignupViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  bool _isLoading = false;
  String? _error;

  SignupViewModel(this._userRepository);

  bool get isLoading => _isLoading;
  String? get error => _error;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setError(String? value) {
    _error = value;
    notifyListeners();
  }

  Future<bool> signUp({
    required String email,
    required String password,
    required String firstname,
    required String lastname,
    String? phone,
  }) async {
    _setLoading(true);
    _setError(null);

    try {
      // Create user with Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      if (userCredential.user == null) {
        throw TFirebaseException('user-creation-failed');
      }

      // Create UserModel
      final user = UserModel(
        id: userCredential.user!.uid,
        name: '$firstname $lastname',
        gender: '',
        avatarUrl: '',
        profilePicture: '',
        email: email,
        phoneNumber: phone ?? '',
        addresses: [],
        favorites: [],
        token: userCredential.user!.uid,
        role: Role.user,
        createdAt: DateTime.now(),
        dateOfBirth: DateTime.now(),
        lastUpdated: DateTime.now(),
      );

      // Save user to Firestore
      await _userRepository.saveUser(user);

      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      _setLoading(false);
      return false;
    } catch (e) {
      _setError(e.toString());
      _setLoading(false);
      return false;
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email đã được sử dụng bởi tài khoản khác';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'operation-not-allowed':
        return 'Đăng ký bằng email và mật khẩu không được kích hoạt';
      case 'weak-password':
        return 'Mật khẩu không đủ mạnh';
      default:
        return 'Đã xảy ra lỗi không xác định';
    }
  }
}
