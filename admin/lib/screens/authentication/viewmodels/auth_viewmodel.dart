import 'package:admin/main.dart';
import 'package:admin/routes/name_router.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;
  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  bool _obscureConfirmPassword = true;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  // Get current user
  User? get currentUser => _authService.currentUser;

  // Sign in with email and password
  Future<void> signInWithEmailAndPassword() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        throw Exception('Vui lòng nhập đầy đủ thông tin');
      }

      final userCredential = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      if (userCredential.user != null) {
        navigatorKey.currentState?.pushReplacementNamed(NameRouter.dashboard);
      } else {
        throw Exception('Đăng nhập thất bại');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      final userCredential = await _authService.signInWithGoogle();
      if (userCredential.user != null) {
        navigatorKey.currentState?.pushReplacementNamed(NameRouter.dashboard);
      } else {
        throw Exception('Đăng nhập thất bại');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign in with Facebook
  // Future<void> signInWithFacebook() async {
  //   try {
  //     _isLoading = true;
  //     notifyListeners();

  //     final userCredential = await _authService.signInWithFacebook();
  //     if (userCredential.user != null) {
  //       navigatorKey.currentState?.pushReplacementNamed(NameRouter.dashboard);
  //     } else {
  //       throw Exception('Đăng nhập thất bại');
  //     }
  //   } catch (e) {
  //     rethrow;
  //   } finally {
  //     _isLoading = false;
  //     notifyListeners();
  //   }
  // }

  // Register with email and password
  Future<void> registerWithEmailAndPassword() async {
    try {
      _isLoading = true;
      notifyListeners();

      if (usernameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        throw Exception('Vui lòng nhập đầy đủ thông tin');
      }

      if (passwordController.text != confirmPasswordController.text) {
        throw Exception('Mật khẩu không khớp');
      }

      await _authService.registerWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
        usernameController.text.trim(),
      );

      navigatorKey.currentState?.pushReplacementNamed(NameRouter.dashboard);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.signOut();
      navigatorKey.currentState?.pushReplacementNamed(NameRouter.login);
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
