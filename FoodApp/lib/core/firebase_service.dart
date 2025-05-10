import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/data/models/category_model.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/data/models/notification_model.dart';
import 'package:foodapp/data/models/order_model.dart';
import 'package:foodapp/data/models/payment_model.dart';

import 'package:foodapp/data/models/restaurant_model.dart';
import 'package:foodapp/data/models/review_model.dart';

import 'package:foodapp/data/models/user_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Users
  Future<void> createUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.id).set(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Restaurants
  Future<void> createRestaurant(RestaurantModel restaurant) async {
    try {
      await _firestore
          .collection('restaurants')
          .doc(restaurant.id)
          .set(restaurant.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Foods
  Future<void> createFood(FoodModel food) async {
    try {
      await _firestore.collection('foods').doc(food.id).set(food.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Orders
  Future<void> createOrder(OrderModel order) async {
    try {
      final orderMap = order.toMap();
      await _firestore.collection('orders').doc(order.id).set(orderMap);
    } catch (e) {
      rethrow;
    }
  }

  // Categories
  Future<void> createCategory(CategoryModel category) async {
    try {
      await _firestore
          .collection('categories')
          .doc(category.id)
          .set(category.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Promotions

  // Reviews
  Future<void> createReview(ReviewModel review) async {
    try {
      final reviewMap = review.toMap();
      // Đảm bảo createdAt là Timestamp
      if (reviewMap['createdAt'] is DateTime) {
        reviewMap['createdAt'] = Timestamp.fromDate(reviewMap['createdAt']);
      }
      await _firestore.collection('reviews').doc(review.id).set(reviewMap);
    } catch (e) {
      rethrow;
    }
  }

  // Notifications
  Future<void> createNotification(NotificationModel notification) async {
    try {
      final notificationMap = notification.toMap();
      // Đảm bảo createdAt là Timestamp
      if (notificationMap['createdAt'] is DateTime) {
        notificationMap['createdAt'] =
            Timestamp.fromDate(notificationMap['createdAt']);
      }
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .set(notificationMap);
    } catch (e) {
      rethrow;
    }
  }

  // Addresses
  // Future<void> createAddress(AddressModel address) async {
  //   try {
  //     await _firestore
  //         .collection('addresses')
  //         .doc(address.id)
  //         .set(address.toMap());
  //   } catch (e) {
  //     rethrow;
  //   }
  // }

  // Payments
  Future<void> createPayment(PaymentModel payment) async {
    try {
      final paymentMap = payment.toMap();
      // Đảm bảo paymentTime là Timestamp
      if (paymentMap['paymentTime'] is DateTime) {
        paymentMap['paymentTime'] =
            Timestamp.fromDate(paymentMap['paymentTime']);
      }
      await _firestore.collection('payments').doc(payment.id).set(paymentMap);
    } catch (e) {
      rethrow;
    }
  }

  // Search History

  // Favorites

  // Carts
  Future<void> createCart(String id, Map<String, dynamic> cartData) async {
    try {
      // Đảm bảo updatedAt là Timestamp
      if (cartData['updatedAt'] is DateTime) {
        cartData['updatedAt'] = Timestamp.fromDate(cartData['updatedAt']);
      }
      await _firestore.collection('carts').doc(id).set(cartData);
    } catch (e) {
      rethrow;
    }
  }

  // Clear all collections
  Future<void> clearAllCollections() async {
    try {
      final collections = [
        'users',
        'restaurants',
        'foods',
        'orders',
        'categories',
        'reviews',
        'shippers',
        'notifications',
        'addresses',
        'payments',
        'carts'
      ];

      for (var collection in collections) {
        var snapshot = await _firestore.collection(collection).get();
        for (var doc in snapshot.docs) {
          await doc.reference.delete();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Batch operations for better performance
  Future<void> createBatch<T>({
    required String collection,
    required List<T> items,
    required String Function(T) getId,
    required Map<String, dynamic> Function(T) toMap,
  }) async {
    try {
      final batch = _firestore.batch();
      // int count = 0;
      int batchSize = 0;

      for (var item in items) {
        final ref = _firestore.collection(collection).doc(getId(item));
        batch.set(ref, toMap(item));
        batchSize++;

        // Firestore chỉ cho phép tối đa 500 operations trong 1 batch
        if (batchSize >= 400) {
          await batch.commit();
          // count += batchSize;

          batchSize = 0;
        }
      }

      // Commit batch cuối cùng nếu còn
      if (batchSize > 0) {
        await batch.commit();
        // count += batchSize;
      }
    } catch (e) {
      rethrow;
    }
  }

  // Get methods
  Future<List<T>> getCollection<T>({
    required String collection,
    required T Function(Map<String, dynamic>, String) fromMap,
    Query? query,
  }) async {
    try {
      final snapshot = query != null
          ? await query.get()
          : await _firestore.collection(collection).get();

      return snapshot.docs.map((doc) {
        try {
          return fromMap(doc.data() as Map<String, dynamic>, doc.id);
        } catch (e) {
          rethrow;
        }
      }).toList();
    } catch (e) {
      rethrow;
    }
  }

  // Update methods
  Future<void> updateDocument({
    required String collection,
    required String id,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).update(data);
    } catch (e) {
      rethrow;
    }
  }

  // Delete methods
  Future<void> deleteDocument({
    required String collection,
    required String id,
  }) async {
    try {
      await _firestore.collection(collection).doc(id).delete();
    } catch (e) {
      rethrow;
    }
  }

  // Thêm method để lưu shippers
  Future<void> createShipper(Map<String, dynamic> shipper) async {
    try {
      String id = shipper['id'] as String;
      await _firestore.collection('shippers').doc(id).set(shipper);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> testFirestore() async {
    try {
      await _firestore.collection('test').doc('test').set({
        'message': 'Test document',
        'timestamp': FieldValue.serverTimestamp()
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
