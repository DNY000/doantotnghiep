import 'package:flutter/material.dart';
import 'package:foodapp/data/models/address_model.dart';
import 'package:foodapp/data/models/user_model.dart';
import 'package:foodapp/ultils/validators.dart';
import 'package:foodapp/view/authentication/repository/authentication_repository.dart';
import 'package:foodapp/ultils/exception/firebase_auth_exception.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/data/repositories/user_repository.dart';

class SignUpViewModel extends ChangeNotifier {
  final TextEditingController txtEmail = TextEditingController();
  final TextEditingController txtPassword = TextEditingController();
  final TextEditingController txtConfirmPassword = TextEditingController();
  final TextEditingController txtUserName = TextEditingController();
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String _error = '';
  bool _isSuccess = false;

  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isSuccess => _isSuccess;

  final AuthenticationRepository _authenticationRepository =
      AuthenticationRepository();
  final UserViewModel _userViewModel = UserViewModel(UserRepository());

  // Sử dụng validators từ class Validators
  String? validateEmail(String? value) => Validators.validateEmail(value);
  String? validateUserName(String? value) => Validators.validateName(value);
  String? validatePassword(String? value) => Validators.validatePassword(value);
  String? validateConfirmPassword(String? value) =>
      Validators.validateConfirmPassword(value, txtPassword.text);

  bool get isFormValid {
    return validateEmail(txtEmail.text) == null &&
        validatePassword(txtPassword.text) == null &&
        validateConfirmPassword(txtConfirmPassword.text) == null;
  }

  Future<bool> signUpWithEmailAndPassword() async {
    if (!formKey.currentState!.validate()) return false;

    try {
      _isLoading = true;
      _error = '';
      _isSuccess = false;
      notifyListeners();

      // Đăng ký tài khoản mới
      final userCredential =
          await _authenticationRepository.registerEmailAndPassword(
        txtEmail.text.trim(),
        txtPassword.text,
      );

      // Kiểm tra nếu đăng ký thành công
      if (userCredential.user != null) {
        try {
          // Tạo địa chỉ trống ban đầu
          final emptyAddress = AddressModel.empty();

          // Tạo đối tượng UserModel từ thông tin người dùng nhập
          final userModel = UserModel(
            id: userCredential.user!.uid,
            name: txtUserName.text.trim(),
            gender: 'Nam',
            avatarUrl: userCredential.user!.photoURL ?? '',
            profilePicture: '',
            email: txtEmail.text.trim(),
            phoneNumber: '',
            addresses: [emptyAddress], // Đặt vào trong List
            favorites: [],
            token: userCredential.user!.uid,
            role: Role.user,
            createdAt: DateTime.now(),
            dateOfBirth: DateTime.now(),
          );

          // Lưu thông tin người dùng vào Firestore
          await _userViewModel.saveUser(userModel);

          // Đánh dấu đăng ký thành công
          _isSuccess = true;

          // Xóa form sau khi đăng ký thành công
          clearForm();
        } catch (e) {
          _error = 'Lỗi khi lưu thông tin người dùng: $e';
          return false;
        }
      }

      return _isSuccess;
    } on TFirebaseAuthException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = 'Đăng ký thất bại: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Xóa form
  void clearForm() {
    txtEmail.clear();
    txtPassword.clear();
    txtConfirmPassword.clear();

    notifyListeners();
  }

  @override
  void dispose() {
    txtEmail.dispose();
    txtPassword.dispose();
    txtConfirmPassword.dispose();

    super.dispose();
  }
}
