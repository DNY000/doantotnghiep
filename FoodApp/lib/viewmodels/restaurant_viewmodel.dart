import 'package:foodapp/data/models/restaurant_model.dart';
import 'package:foodapp/data/repositories/restaurant_repository.dart';
import 'package:geolocator/geolocator.dart';
import 'package:foodapp/data/repositories/food_repository.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/data/repositories/order_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class RestaurantViewModel extends ChangeNotifier {
  final RestaurantRepository _repository;
  final FoodRepository _foodRepository = FoodRepository();
  final OrderRepository _orderRepository = OrderRepository();
  bool _isLoading = false;
  String? _error;
  List<RestaurantModel> _restaurants = []; // danh sach nhà hàng
  RestaurantModel? _selectedRestaurant; // nhà hàng đang chọn
  List<RestaurantModel> _nearbyRestaurants = []; // danh sach nhà hàng gần đây
  List<RestaurantModel> _newRestaurants = []; // danh sach nhà hàng mới
  double _selectedRadius = 20.0; // Mặc định 10km
  List<FoodModel> _popularFoods = []; // danh sach món ăn phổ biến
  Map<String, List<FoodModel>> _foodsByCategory =
      {}; // danh sach món ăn theo danh mục
  Position? _userLocation; // vị trí người dùng

  RestaurantViewModel(RestaurantRepository restaurantRepository,
      {RestaurantRepository? repository})
      : _repository = repository ?? RestaurantRepository();

  // Getters
  List<RestaurantModel> get restaurants => _restaurants;
  List<RestaurantModel> get nearbyRestaurants => _nearbyRestaurants;
  List<RestaurantModel> get newRestaurants => _newRestaurants;
  RestaurantModel? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get selectedRadius => _selectedRadius;
  List<FoodModel> get popularFoods => _popularFoods;
  Map<String, List<FoodModel>> get foodsByCategory => _foodsByCategory;
  Position? get userLocation => _userLocation;

  void listenToRestaurants() {
    _repository.getAllRestaurants().listen((restaurants) {
      _restaurants = restaurants;
      notifyListeners();
    });
  }

  Future<void> selectRestaurant(String restaurantId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final restaurant = await _repository.getRestaurantById(restaurantId);
      _selectedRestaurant = restaurant;
    } catch (e) {
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedRestaurant() {
    _selectedRestaurant = null;
    notifyListeners();
  }

  // Lấy danh sách nhà hàng với bộ lọc
  Future<void> fetchRestaurants() async {
    try {
      // _setLoading(true);
      _restaurants = await _repository.getRestaurants();

      // Validate and set default values for images
      _restaurants = _restaurants.map((restaurant) {
        if (restaurant.images.isEmpty || restaurant.mainImage.isEmpty) {
          return restaurant.copyWith(
            images: {
              'main': 'assets/img/placeholder/restaurant.jpg',
              'gallery': ['assets/img/placeholder/restaurant.jpg']
            },
          );
        }
        return restaurant;
      }).toList();

      if (_userLocation != null) {
        _sortRestaurantsByDistance();
      }
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách nhà hàng: $e';
      debugPrint(_error);
    } finally {
      // _setLoading(false);
    }
  }

  // Lấy thông tin chi tiết nhà hàng
  Future<void> fetchRestaurantDetail(String restaurantId) async {
    try {
      // _setLoading(true);
      final restaurant = await _repository.getRestaurantById(restaurantId);
      if (restaurant!.images.isEmpty || restaurant.mainImage.isEmpty) {
        _selectedRestaurant = restaurant.copyWith(
          images: {
            'main': 'assets/img/placeholder/restaurant.jpg',
            'gallery': ['assets/img/placeholder/restaurant.jpg']
          },
        );
      } else {
        _selectedRestaurant = restaurant;
      }

      _error = null;
    } catch (e) {
      _error = 'Không thể tải thông tin nhà hàng: $e';
      debugPrint(_error);
    } finally {
      // _setLoading(false);
    }
  }

  // Lấy nhà hàng gần đây
  Future<void> fetchNearbyRestaurants({
    double radiusInKm = 20,
    int limit = 10,
  }) async {
    try {
      // _setLoading(true);
      _clearError();

      if (_userLocation == null) {
        await updateUserLocation();

        if (_userLocation == null) {
          throw Exception(
              'Không thể lấy vị trí người dùng. Vui lòng cho phép ứng dụng truy cập vị trí.');
        }
      }

      final restaurants = await _repository.getNearbyRestaurants(
        userLocation:
            GeoPoint(_userLocation!.latitude, _userLocation!.longitude),
        radiusInKm: radiusInKm,
        limit: limit,
      );

      _nearbyRestaurants = restaurants.map((restaurant) {
        if (restaurant.images.isEmpty ||
            !restaurant.images.containsKey('main') ||
            restaurant.mainImage.isEmpty) {
          return restaurant.copyWith(
            images: {
              'main': 'assets/images/placeholder_restaurant.png',
              'gallery': restaurant.images['gallery'] as List<String>? ?? [],
            },
          );
        }

        return restaurant;
      }).toList();

      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách nhà hàng gần đây: $e';
      _nearbyRestaurants = [];
    } finally {
      // _setLoading(false);
      notifyListeners(); // Đảm bảo gọi notifyListeners để cập nhật UI
    }
  }

  // Cập nhật vị trí người dùng và sắp xếp lại nhà hàng theo khoảng cách
  Future<void> updateUserLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );

      _userLocation = position;

      // Nếu đã có danh sách nhà hàng, cập nhật khoảng cách
      if (_restaurants.isNotEmpty) {
        _sortRestaurantsByDistance();
      }

      // Nếu đang ở chế độ xem nhà hàng gần đây, cập nhật lại danh sách
      if (_nearbyRestaurants.isNotEmpty) {
        await fetchNearbyRestaurants();
      }

      notifyListeners();
    } catch (e) {
      _error = 'Không thể cập nhật vị trí: $e';
      debugPrint(_error);
    }
  }

  // Sắp xếp nhà hàng theo khoảng cách
  void _sortRestaurantsByDistance() {
    if (_userLocation == null) return;

    _restaurants.sort((a, b) {
      final distanceA = _calculateDistance(a);
      final distanceB = _calculateDistance(b);
      return distanceA.compareTo(distanceB);
    });

    notifyListeners();
  }

  // Tính khoảng cách từ vị trí người dùng đến nhà hàng
  double _calculateDistance(RestaurantModel restaurant) {
    if (_userLocation == null) return double.infinity;

    final location = restaurant.location;

    return Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      location.latitude,
      location.longitude,
    );
  }

  // Lọc nhà hàng theo danh mục
  List<RestaurantModel> filterByCategory(String category) {
    return _restaurants
        .where((restaurant) => restaurant.categories.contains(category))
        .toList();
  }

  // Lọc nhà hàng theo trạng thái mở/đóng cửa
  List<RestaurantModel> filterByOpenStatus(bool isOpen) {
    return _restaurants.where((restaurant) => restaurant.isOpen).toList();
  }

  // Lọc nhà hàng theo khoảng cách
  List<RestaurantModel> filterByDistance(double maxDistance) {
    if (_userLocation == null) return [];
    return _restaurants
        .where((restaurant) => _calculateDistance(restaurant) <= maxDistance)
        .toList();
  }

  // Tìm kiếm nhà hàng theo tên
  List<RestaurantModel> searchRestaurants(String query) {
    final lowercaseQuery = query.toLowerCase();
    return _restaurants
        .where((restaurant) =>
            restaurant.name.toLowerCase().contains(lowercaseQuery) ||
            restaurant.description.toLowerCase().contains(lowercaseQuery))
        .toList();
  }

  // Lấy danh sách nhà hàng phổ biến
  List<RestaurantModel> getPopularRestaurants({int limit = 10}) {
    final sorted = List<RestaurantModel>.from(_restaurants)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  // Lấy danh sách nhà hàng mới
  Future<void> getNewRestaurants({int limit = 10}) async {
    try {
      _isLoading = true;
      notifyListeners();
      final restaurant = await _repository.getNewRestaurants(limit: limit);
      _newRestaurants = restaurant;
    } catch (e) {
      throw Exception(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSelectedRestaurant(RestaurantModel restaurant) {
    _selectedRestaurant = restaurant;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Lấy nhà hàng theo danh mục
  Future<List<RestaurantModel>> getRestaurantsByCategory(
      String category) async {
    try {
      // _setLoading(true);
      final restaurants = await _repository.getRestaurantsByCategory(category);

      // Ensure proper image handling
      final processedRestaurants = restaurants.map((restaurant) {
        if (restaurant.images.isEmpty ||
            !restaurant.images.containsKey('main') ||
            restaurant.mainImage.isEmpty) {
          return restaurant.copyWith(
            images: {
              'main': 'assets/images/placeholder_restaurant.png',
              'gallery': restaurant.images['gallery'] as List<String>? ?? [],
            },
          );
        }
        return restaurant;
      }).toList();

      _error = null;
      return processedRestaurants;
    } catch (e) {
      _error = 'Không thể tải nhà hàng theo danh mục: $e';
      if (kDebugMode) {
        print(_error);
      }
      return [];
    } finally {
      // _setLoading(false);
    }
  }

  // Lọc nhà hàng theo trạng thái mở cửa
  List<RestaurantModel> getOpenRestaurants() {
    return _restaurants.where((restaurant) => restaurant.isOpen).toList();
  }

  // Lọc nhà hàng theo xác thực
  List<RestaurantModel> getVerifiedRestaurants() {
    return _restaurants.where((restaurant) => restaurant.isVerified).toList();
  }

  // Lọc và sắp xếp nhà hàng theo đánh giá
  List<RestaurantModel> getTopRatedRestaurants({int limit = 10}) {
    var sorted = List<RestaurantModel>.from(_restaurants)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }

  // Tính khoảng cách từ vị trí người dùng đến nhà hàng
  double calculateDistanceToRestaurant(RestaurantModel restaurant) {
    if (_userLocation == null) return double.infinity;

    final location = restaurant.location;

    return Geolocator.distanceBetween(
      _userLocation!.latitude,
      _userLocation!.longitude,
      location.latitude,
      location.longitude,
    );
  }

  // Format khoảng cách
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)}m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)}km';
    }
  }

  // Phương thức để thay đổi bán kính tìm kiếm
  void updateSearchRadius(double newRadius) {
    _selectedRadius = newRadius;
    notifyListeners();
  }

  // Thêm phương thức để lấy món ăn phổ biến
  Future<void> fetchPopularFoods(String restaurantId) async {
    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      _popularFoods = await _orderRepository.getTopSellingFoods(
        restaurantId: restaurantId,
      );
      _error = '';
    } catch (e) {
      _error = e.toString();
      _popularFoods = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Thêm phương thức để lấy món ăn theo category
  List<FoodModel> getFoodsByCategory(String category) {
    return _foodsByCategory[category] ?? [];
  }

  // Thêm phương thức để fetch tất cả món ăn của nhà hàng và phân loại theo category
  Future<void> fetchFoodsByRestaurant(String restaurantId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Reset map
      _foodsByCategory.clear();

      // Lấy tất cả món ăn của nhà hàng
      final foods = await _foodRepository.getFoodsByRestaurant(restaurantId);

      // Phân loại món ăn theo category
      for (var food in foods) {
        if (!_foodsByCategory.containsKey(food.category.name)) {
          _foodsByCategory[food.category.name] = [];
        }
        _foodsByCategory[food.category.name]!.add(food);
      }

      _error = '';
    } catch (e) {
      _error = e.toString();
      _foodsByCategory.clear();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Lấy số lượng đã bán của một món ăn
  int getFoodSoldCount(String foodId) {
    try {
      final index = _popularFoods.indexWhere((item) => item.id == foodId);
      if (index == -1) return 0;
      return _popularFoods[index].soldCount;
    } catch (e) {
      return 0;
    }
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}
