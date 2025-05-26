import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:foodapp/data/models/user_model.dart';
import 'package:foodapp/ultils/exception/firebase_exception.dart';
import 'package:foodapp/ultils/exception/format_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String _collection = 'users';

  Future<void> saveUser(UserModel user) async {
    try {
      if (kDebugMode) {
        print("Gọi đến Firestore để lưu user: ${user.id}");
      }

      Map<String, dynamic> userData = user.toMap();

      // Kiểm tra và đảm bảo không có giá trị null trong userData
      userData.forEach((key, value) {
        if (value == null) {
          if (kDebugMode) {
            print("Cảnh báo: Trường '$key' có giá trị null");
          }
          if (key == 'addresses') {
            userData[key] = [];
          }
        }
      });

      if (kDebugMode) {
        print("Dữ liệu sẽ lưu vào Firestore: $userData");
      }

      await _firestore
          .collection(_collection)
          .doc(user.id)
          .set(userData, SetOptions(merge: true));

      if (kDebugMode) {
        print("Đã lưu dữ liệu user thành công!");
        final docSnapshot =
            await _firestore.collection(_collection).doc(user.id).get();
        print("User tồn tại trong database: ${docSnapshot.exists}");
        if (docSnapshot.exists) {
          print("Dữ liệu user hiện tại: ${docSnapshot.data()}");
        }
      }
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("FirebaseException khi lưu user: ${e.code} - ${e.message}");
      }
      throw TFirebaseException(e.code);
    } catch (e) {
      if (kDebugMode) {
        print("Lỗi không xác định khi lưu user: $e");
      }
      throw TFormatException('Lỗi khi lưu thông tin người dùng: $e');
    }
  }

  Future<void> updateUser(UserModel user, String userId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update(user.toMap());

      // Kiểm tra sau khi cập nhật
    } catch (e) {
      throw TFormatException('Lỗi khi cập nhật thông tin người dùng: $e');
    }
  }

  Future<void> addToFavorites(String userId, String foodId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'preferences.favorites': FieldValue.arrayUnion([foodId]),
        'metadata.lastUpdated': Timestamp.now(),
      });
    } catch (e) {
      throw TFormatException('Lỗi khi thêm vào danh sách yêu thích: $e');
    }
  }

  Future<void> removeFromFavorites(String userId, String foodId) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'preferences.favorites': FieldValue.arrayRemove([foodId]),
        'metadata.lastUpdated': Timestamp.now(),
      });
    } catch (e) {
      throw TFormatException('Lỗi khi xóa khỏi danh sách yêu thích: $e');
    }
  }

  Future<UserModel> getUser(String id) async {
    try {
      final snapshot = await _firestore.collection(_collection).doc(id).get();

      if (!snapshot.exists) {
        throw TFirebaseException('not-found');
      }

      return UserModel.fromMap(snapshot.data() ?? {}, snapshot.id);
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TFormatException('Lỗi khi lấy thông tin người dùng: $e');
    }
  }

  Future<bool> checkUserExists(String id) async {
    try {
      final snapshot = await _firestore.collection(_collection).doc(id).get();
      return snapshot.exists;
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TFormatException('Lỗi khi kiểm tra người dùng: $e');
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TFormatException('Lỗi khi xóa thông tin người dùng: $e');
    }
  }

  Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      return snapshot.docs
          .map((doc) => UserModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw TFirebaseException(e.code);
    } catch (e) {
      throw TFormatException('Lỗi khi lấy danh sách người dùng: $e');
    }
  }

  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc =
            await _firestore.collection(_collection).doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        }
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<UserModel>> queryUsers({
    String? role,
    bool? isActive,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (role != null) {
        query = query.where('metadata.role', isEqualTo: role);
      }

      if (isActive != null) {
        query = query.where('metadata.isActive', isEqualTo: isActive);
      }

      query = query.limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              UserModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw TFormatException('Lỗi khi query users: $e');
    }
  }

  Future<void> updateAvatar(String userId, String avatarUrl) async {
    try {
      await _firestore.collection(_collection).doc(userId).update({
        'avatarUrl': avatarUrl,
      });
    } catch (e) {
      throw TFormatException('Lỗi khi cập nhật ảnh đại diện: $e');
    }
  }
}
