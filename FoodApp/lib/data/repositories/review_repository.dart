import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'reviews';

  Future<List<ReviewModel>> getReviewsByFood(
      String foodId, String restaurantId) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('foodId', isEqualTo: foodId)
          // .where('restaurantId', isEqualTo: restaurantId)
          // .orderBy('createdAt', descending: true)
          .get();
      List<ReviewModel> listReview = snapshot.docs
          .map((doc) => ReviewModel.fromMap(doc.data(), doc.id))
          .toList();
      listReview.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return listReview;
    } catch (e) {
      return [];
    }
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestore.collection(_collection).add(review.toMap());
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> updateReview(String reviewId, Map<String, dynamic> data) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).update(data);
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.collection(_collection).doc(reviewId).delete();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<bool> checkReviewExists(String foodId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      // Lọc các đơn hàng thành công và kiểm tra foodId trong items
      for (var doc in snapshot.docs) {
        final data = doc.data();
        // Kiểm tra status trước
        if (data['status'] != 'delivered') continue;

        final items = data['items'] as List<dynamic>;
        final hasFood = items.any((item) => item['foodId'] == foodId);
        if (hasFood) {
          return true;
        }
      }
      return false;
    } catch (e) {
      throw Exception(e);
    }
  }
}
