import 'package:admin/data/repositories/user_repository.dart';
import 'package:admin/main.dart';
import 'package:admin/models/user_model.dart';
import 'package:admin/routes/name_router.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'package:go_router/go_router.dart';

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
  Future<String?> signInWithEmailAndPassword(BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        return 'Vui lòng nhập đầy đủ thông tin';
      }

      final userCredential = await _authService.signInWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
      );

      if (userCredential.user != null) {
        GoRouter.of(context).go(NameRouter.dashboard);
        return null; // Thành công
      } else {
        return 'Đăng nhập thất bại';
      }
    } catch (e) {
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register with email and password
  Future<void> registerWithEmailAndPassword(BuildContext context) async {
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

      final userCredential = await _authService.registerWithEmailAndPassword(
        emailController.text.trim(),
        passwordController.text,
        usernameController.text.trim(),
      );
      if (userCredential.user != null) {
        final user = UserModel(
          id: userCredential.user!.uid,
          email: emailController.text.trim(),
          name: usernameController.text.trim(),
          avatarUrl: '',
          createdAt: DateTime.now(),
          dateOfBirth: null,
          gender: '',
          favorites: [],
          role: Role.admin,
          phoneNumber: '',
          profilePicture: '',
          token: userCredential.user!.uid,
          addresses: [],
        );
        await UserRepository().saveUser(user);
        GoRouter.of(context).go(NameRouter.dashboard);
      } else {
        throw Exception('Đăng ký thất bại');
      }
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
