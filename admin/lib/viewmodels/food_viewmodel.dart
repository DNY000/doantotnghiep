import 'package:admin/data/repositories/food_repository.dart';
import 'package:admin/models/food_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FoodViewModel extends ChangeNotifier {
  final FoodRepository _repository;
  List<FoodModel> _foods = [];
  List<FoodModel> _recommendedFoods = [];
  List<FoodModel> _searchResults = [];
  FoodModel? _selectedFood;
  bool _isLoading = false;
  String? _error;
  Map<String, List<FoodModel>> _categoryFoods = {};
  List<FoodModel> _foodsByRate = [];

  FoodViewModel(this._repository);

  // Getters
  List<FoodModel> get foods => _foods;
  List<FoodModel> get recommendedFoods => _recommendedFoods;
  List<FoodModel> get searchResults => _searchResults;
  FoodModel? get selectedFood => _selectedFood;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, List<FoodModel>> get categoryFoods => _categoryFoods;
  List<FoodModel> get fetchFoodsByRate => _foodsByRate;

  // Getter cho món ăn được đề xuất cho người dùng
  List<FoodModel> get fetchFoodsForYou {
    // Lọc và sắp xếp món ăn theo rating cao và có sẵn
    return _foods.where((food) => food.isAvailable).toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));
  }

  // Lấy danh sách món ăn
  Future<void> loadFoods({
    int limit = 10,
    DocumentSnapshot? startAfter,
    bool? isAvailable,
  }) async {
    try {
      _setLoading(true);
      _foods = await _repository.getFoods(
        limit: limit,
        startAfter: startAfter,
        isAvailable: isAvailable,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách món ăn: $e';
      if (kDebugMode) {
        print(_error!);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy món ăn theo danh mục
  Future<List<FoodModel>> getFoodsByCategory(
    String category, {
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      final foods = await _repository.getFoodsByCategory(
        category,
        limit: limit,
      );
      _error = null;
      return foods;
    } catch (e) {
      _error = 'Không thể tải món ăn theo danh mục: $e';
      if (kDebugMode) {
        print(_error!);
      }
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Lấy món ăn của nhà hàng
  Future<List<FoodModel>> getFoodsByRestaurant(
    String restaurantId, {
    String? category,
    bool? isAvailable,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      final foods = await _repository.getFoodsByRestaurant(
        restaurantId,
        category: category,
        isAvailable: isAvailable,
        limit: limit,
      );
      _error = null;
      return foods;
    } catch (e) {
      _error = 'Không thể tải món ăn của nhà hàng: $e';
      if (kDebugMode) {
        print(_error!);
      }
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Lấy món ăn theo đánh giá
  Future<void> loadRecommendedFoods({
    double minRating = 4.0,
    int limit = 5,
  }) async {
    try {
      _setLoading(true);
      _recommendedFoods = await _repository.getFoodsByRating(
        minRating: minRating,
        onlyAvailable: true,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải món ăn đề xuất: $e';
      if (kDebugMode) {
        print(_error!);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Search foods
  Future<void> searchFoods(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _searchResults = await _repository.searchFoods(query);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setSelectedFood(FoodModel food) {
    _selectedFood = food;
    notifyListeners();
  }

  void clearSelectedFood() {
    _selectedFood = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }

  // Lọc món ăn theo giá
  List<FoodModel> filterByPriceRange(double minPrice, double maxPrice) {
    return _foods
        .where((food) => food.price >= minPrice && food.price <= maxPrice)
        .toList();
  }

  // Lọc món ăn có sẵn
  List<FoodModel> getAvailableFoods() {
    return _foods.where((food) => food.isAvailable).toList();
  }

  // Sắp xếp theo giá
  void sortByPrice({bool ascending = true}) {
    _foods.sort(
      (a, b) =>
          ascending ? a.price.compareTo(b.price) : b.price.compareTo(a.price),
    );
    notifyListeners();
  }

  // Sắp xếp theo đánh giá
  void sortByRating() {
    _foods.sort((a, b) => b.rating.compareTo(a.rating));
    notifyListeners();
  }

  // Lấy danh sách món ăn theo nhà hàng
  Future<void> fetchFoodsByRestaurant(String restaurantId) async {
    try {
      _setLoading(true);
      _foods = await _repository.getFoodsByRestaurant(restaurantId);
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách món ăn: $e';
      _foods = [];
    } finally {
      _setLoading(false);
    }
  }

  // Lấy danh sách món ăn theo danh mục và nhà hàng
  Future<void> fetchFoodsByCategoryAndRestaurant(
    String restaurantId,
    String category,
  ) async {
    try {
      _setLoading(true);
      final foods = await _repository.getFoodsByCategory(category);
      _categoryFoods[category] = foods;
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách món ăn theo danh mục: $e';
      _categoryFoods[category] = [];
    } finally {
      _setLoading(false);
    }
  }

  // Lấy danh sách món ăn theo đánh giá
  Future<void> getFoodByRate({double minRating = 4.0, int limit = 10}) async {
    try {
      _setLoading(true);
      _foodsByRate = await _repository.getFoodsByRating(
        minRating: minRating,
        onlyAvailable: true,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải món ăn theo đánh giá: $e';
      _foodsByRate = [];
      if (kDebugMode) {
        print(_error!);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy danh sách món ăn theo danh mục
  Future<void> fetchFoodsByCategory(String category) async {
    try {
      _setLoading(true);
      final foods = await _repository.getFoodsByCategory(category);
      _categoryFoods[category] = foods;
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách món ăn theo danh mục: $e';
      _categoryFoods[category] = [];
      if (kDebugMode) {
        print(_error!);
      }
    } finally {
      _setLoading(false);
    }
  }
}
