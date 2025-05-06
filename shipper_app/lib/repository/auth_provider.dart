import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:shipper_app/ultils/exception/firebase_auth_exception.dart';
import 'package:shipper_app/ultils/exception/firebase_exception.dart';
import 'package:shipper_app/ultils/exception/format_exception.dart';
import 'package:shipper_app/ultils/exception/platform_exception.dart';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get userAuth => _auth.currentUser;

  // Đăng ký tài khoản mới với email và mật khẩu
  Future<UserCredential> registerEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      // Tạo tài khoản mới trong Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Gửi email xác thực nếu cần
      await userCredential.user?.sendEmailVerification();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  // Gửi email xác thực
  Future<void> sendEmailVerification() async {
    try {
      User? user = _auth.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
      } else {
        throw TPlatformException('operation-not-allowed');
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  // Đăng nhập với email và mật khẩu
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } on FormatException catch (e) {
      throw TFormatException(e.message);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  // Đặt lại mật khẩu
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  // Đăng xuất
  Future<void> logout() async {
    try {
      await _auth.signOut();
      // Đăng xuất khỏi Google nếu đã đăng nhập
      // await GoogleSignIn().signOut();
      // // Đăng xuất khỏi Facebook nếu đã đăng nhập
      // await FacebookAuth.instance.logOut();
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  // Kiểm tra trạng thái đăng nhập
  bool isLoggedIn() {
    return _auth.currentUser != null;
  }

  // Trả về UID của người dùng hiện tại nếu đã đăng nhập
  String? getCurrentUserId() {
    return _auth.currentUser?.uid;
  }

  // Lấy thông tin người dùng hiện tại từ Firebase Auth
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  // Cập nhật mật khẩu cho người dùng đã đăng nhập
  Future<void> updatePassword(String newPassword) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
      } else {
        throw TPlatformException('sign_in_required');
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  // Xác thực lại người dùng (cần thiết cho các thao tác nhạy cảm)
  Future<UserCredential> reauthenticateUser(
    String email,
    String password,
  ) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        return await user.reauthenticateWithCredential(credential);
      } else {
        throw TPlatformException('sign_in_required');
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  // Xóa tài khoản người dùng
  Future<void> deleteAccount() async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      } else {
        throw TPlatformException('sign_in_required');
      }
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }
}
