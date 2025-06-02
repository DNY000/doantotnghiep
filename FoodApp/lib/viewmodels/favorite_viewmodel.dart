import 'package:flutter/foundation.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/data/repositories/favorite_repository.dart';
import 'package:foodapp/data/repositories/user_repository.dart';

class FavoriteViewModel extends ChangeNotifier {
  final FavoriteRepository _favoriteRepository;
  final UserRepository _userRepository;
  List<FoodModel> _favorites = [];
  bool _isLoading = false;

  FavoriteViewModel({
    FavoriteRepository? favoriteRepository,
    UserRepository? userRepository,
  })  : _favoriteRepository = favoriteRepository ?? FavoriteRepository(),
        _userRepository = userRepository ?? UserRepository();

  List<FoodModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  Future<void> loadFavorites() async {
    _isLoading = true;
    notifyListeners();

    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser != null) {
        _favorites = await _favoriteRepository.getFavorites(currentUser.id);
      }
    } catch (e) {
      debugPrint('Error loading favorites: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> toggleFavorite(String foodId) async {
    try {
      final currentUser = await _userRepository.getCurrentUser();
      if (currentUser != null) {
        if (_favorites.any((food) => food.id == foodId)) {
          await _favoriteRepository.removeFromFavorites(currentUser.id, foodId);
          _favorites.removeWhere((food) => food.id == foodId);
        } else {
          await _favoriteRepository.addToFavorites(currentUser.id, foodId);
          final newFood = await _favoriteRepository.getFoodById(foodId);
          if (newFood != null) {
            _favorites.add(newFood);
          }
        }
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error toggling favorite: $e');
    }
  }

  bool isFavorite(String foodId) {
    return _favorites.any((food) => food.id == foodId);
  }
}
