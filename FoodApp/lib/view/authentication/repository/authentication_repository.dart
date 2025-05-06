import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:foodapp/ultils/exception/firebase_auth_exception.dart';
import 'package:foodapp/ultils/exception/firebase_exception.dart';
import 'package:foodapp/ultils/exception/format_exception.dart';
import 'package:foodapp/ultils/exception/platform_exception.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:async';

class AuthenticationRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get userAuth => _auth.currentUser;
  String? _verificationId;
  int? _resendToken;

  // Đăng ký tài khoản mới với email và mật khẩu
  Future<UserCredential> registerEmailAndPassword(
      String email, String password) async {
    try {
      // Tạo tài khoản mới trong Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);

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
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

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
      String email, String password) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        AuthCredential credential =
            EmailAuthProvider.credential(email: email, password: password);
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

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Đăng xuất trước để đảm bảo hiển thị dialog chọn tài khoản
      await GoogleSignIn().signOut();

      // Khởi tạo GoogleSignIn với các scopes cần thiết
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: [
          'email',
          'https://www.googleapis.com/auth/userinfo.profile',
        ],
      );

      // Hiển thị màn hình chọn tài khoản
      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      // Người dùng hủy đăng nhập
      if (googleSignInAccount == null) {
        throw TPlatformException('sign_in_canceled');
      }

      // Lấy thông tin xác thực tài khoản
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      // Tạo credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      // Đăng nhập với Firebase
      return await _auth.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  Future<UserCredential?> signInWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();
      final OAuthCredential credential =
          FacebookAuthProvider.credential(result.accessToken!.token);
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw TFirebaseAuthException(e.code);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  /// Gửi mã OTP tới số điện thoại
  /// Hỗ trợ cả phương thức cũ và mới
  Future<void> sendOTP({
    required String phoneNumber,
    Function(String verificationId, int? resendToken)? onCodeSent,
    Function(AuthCredential credential)? onVerificationCompleted,
    Function(FirebaseAuthException e)? onVerificationFailed,
    // Tham số cho phương thức cũ
    Function(String)? onSuccess,
    Function(String)? onError,
    bool forceResend = false,
    int? resendToken,
  }) async {
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (AuthCredential credential) {
          if (onVerificationCompleted != null) {
            onVerificationCompleted(credential);
          }
          // Hỗ trợ callback cũ
          if (onSuccess != null) {
            onSuccess('Xác thực tự động thành công');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          if (onVerificationFailed != null) {
            onVerificationFailed(e);
          }
          // Hỗ trợ callback cũ
          if (onError != null) {
            onError(TFirebaseAuthException(e.code).message);
          }
        },
        codeSent: (String verificationId, int? resendTokenValue) {
          // Lưu trữ ID xác thực để sử dụng sau này nếu cần
          _verificationId = verificationId;
          _resendToken = resendTokenValue;

          // Gọi callback mới
          if (onCodeSent != null) {
            onCodeSent(verificationId, resendTokenValue);
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
        forceResendingToken: resendToken ?? _resendToken,
      );
    } catch (e) {
      // Hỗ trợ callback cũ
      if (onError != null) {
        onError('Lỗi không xác định: $e');
      } else {
        rethrow;
      }
    }
  }

  // Gửi lại mã OTP
  Future<void> resendOTP({
    required String phoneNumber,
    Function(String)? onSuccess,
    Function(String)? onError,
    Function(String, int?)? onCodeSent,
  }) async {
    try {
      // Gọi lại sendOTP với resendToken
      await sendOTP(
        phoneNumber: phoneNumber,
        onSuccess: onSuccess,
        onError: onError,
        onCodeSent: onCodeSent,
      );
    } catch (e) {
      if (onError != null) {
        onError('Lỗi khi gửi lại mã OTP: $e');
      } else {
        throw 'Lỗi khi gửi lại mã OTP: $e';
      }
    }
  }

  Future<bool> setPassword(String password) async {
    try {
      if (_auth.currentUser == null) {
        throw TPlatformException('sign_in_required');
      }

      // Cập nhật mật khẩu cho tài khoản
      await _auth.currentUser!.updatePassword(password);

      return true;
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }

  // Kiểm tra tính hợp lệ của token
  Future<bool> verifyToken(String token) async {
    try {
      // Kiểm tra token dựa vào trạng thái đăng nhập hiện tại
      // Nếu người dùng đã đăng nhập, token vẫn có hiệu lực
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null) {
        // Nếu người dùng đã đăng nhập, token hợp lệ
        return true;
      }

      // Nếu chưa đăng nhập, token không hợp lệ
      return false;
    } catch (e) {
      throw TPlatformException('unknown');
    }
  }
}
