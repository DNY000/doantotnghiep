import 'package:flutter/material.dart';
import '../data/models/review_model.dart';
import '../data/repositories/review_repository.dart';

class ReviewViewModel extends ChangeNotifier {
  final ReviewRepository _repository = ReviewRepository();
  List<ReviewModel> _reviews = [];
  bool _isLoading = false;
  String? _error;
  String? _currentTargetId;
  String? _currentTargetType;

  List<ReviewModel> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get currentTargetId => _currentTargetId;
  String? get currentTargetType => _currentTargetType;

  Future<void> loadReviews(String foodId, String restaurantId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _reviews = await _repository.getReviewsByFood(foodId, restaurantId);
    } catch (e) {
      _error = 'Không thể tải đánh giá: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> canUserReview(String foodId, String userId) async {
    try {
      return await _repository.checkReviewExists(foodId, userId);
    } catch (e) {
      _error = 'Không thể kiểm tra quyền đánh giá: $e';
      notifyListeners();
      return false;
    }
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      await _repository.addReview(review);
      if (review.foodId == _currentTargetId ||
          review.restaurantId == _currentTargetId) {
        _reviews.insert(0, review);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Không thể thêm đánh giá: $e';
      notifyListeners();
    }
  }

  Future<void> updateReview(String reviewId, Map<String, dynamic> data) async {
    try {
      await _repository.updateReview(reviewId, data);
      final index = _reviews.indexWhere((r) => r.id == reviewId);
      if (index != -1) {
        _reviews[index] = ReviewModel.fromMap(
            {..._reviews[index].toMap(), ...data}, reviewId);
        notifyListeners();
      }
    } catch (e) {
      _error = 'Không thể cập nhật đánh giá: $e';
      notifyListeners();
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _repository.deleteReview(reviewId);
      _reviews.removeWhere((r) => r.id == reviewId);
      notifyListeners();
    } catch (e) {
      _error = 'Không thể xóa đánh giá: $e';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearReviews() {
    _reviews = [];
    _currentTargetId = null;
    _currentTargetType = null;
    notifyListeners();
  }
}
