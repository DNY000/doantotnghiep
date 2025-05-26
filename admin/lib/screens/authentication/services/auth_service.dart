import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // final FacebookAuth _facebookAuth = FacebookAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      throw Exception('Đăng nhập thất bại: $e');
    }
  }

  // Sign in with Facebook
  // Future<UserCredential> signInWithFacebook() async {
  //   try {
  //     // Trigger the sign-in flow
  //     final LoginResult result = await _facebookAuth.login();

  //     if (result.status != LoginStatus.success) {
  //       throw Exception('Đăng nhập Facebook bị hủy');
  //     }

  //     // Create a credential from the access token
  //     final OAuthCredential credential = FacebookAuthProvider.credential(
  //       result.accessToken!.token,
  //     );

  //     // Sign in to Firebase with the Facebook credential
  //     final userCredential = await _auth.signInWithCredential(credential);

  //     // Get user data from Facebook
  //     final userData = await _facebookAuth.getUserData();

  //     // Check if user document exists
  //     final userDoc =
  //         await _firestore
  //             .collection('users')
  //             .doc(userCredential.user!.uid)
  //             .get();

  //     if (!userDoc.exists) {
  //       // Create user document if it doesn't exist
  //       await _firestore.collection('users').doc(userCredential.user!.uid).set({
  //         'name': userData['name'],
  //         'email': userData['email'],
  //         'photoURL': userData['picture']?['data']?['url'],
  //         'role': 'admin',
  //         'createdAt': FieldValue.serverTimestamp(),
  //         'provider': 'facebook',
  //       });
  //     }

  //     return userCredential;
  //   } catch (e) {
  //     throw Exception('Đăng nhập Facebook thất bại: $e');
  //   }
  // }

  // Register with email and password
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      // Create user with email and password
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Create user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'name': name,
        'email': email,
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'provider': 'email',
      });

      return userCredential;
    } catch (e) {
      throw Exception('Đăng ký thất bại: $e');
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Đăng xuất thất bại: $e');
    }
  }
}
