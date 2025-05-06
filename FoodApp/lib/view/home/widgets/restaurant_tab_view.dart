import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/view/restaurant/restaurant_detail_view.dart';
import 'package:foodapp/view/restaurant/single_food_detail.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../../ultils/const/color_extension.dart';
import '../../../viewmodels/restaurant_viewmodel.dart';
import '../../../core/location_service.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class RestaurantTabView extends StatefulWidget {
  const RestaurantTabView({super.key});

  @override
  State<RestaurantTabView> createState() => _RestaurantTabViewState();
}

class _RestaurantTabViewState extends State<RestaurantTabView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Position? _currentPosition;
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    Future.microtask(() {
      if (mounted) {
        _initializeLocation();
        final viewModel = context.read<RestaurantViewModel>();
        viewModel.fetchRestaurants();
        context.read<OrderViewModel>().getTopSellingFoods();
        context.read<FoodViewModel>().getFoodByRate();
      }
    });
  }

  Future<void> _initializeLocation() async {
    await _getCurrentLocation();
    // Set up periodic location updates
    Timer.periodic(const Duration(minutes: 5), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    if (_isLoadingLocation) return;

    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final position = await LocationService.getCurrentLocation(context);
      if (position != null && mounted) {
        setState(() {
          _currentPosition = position;
          _isLoadingLocation = false;
        });

        // Fetch restaurants with location
        await context.read<RestaurantViewModel>().fetchNearbyRestaurants(
              radiusInKm: 20,
              limit: 10,
            );
      } else {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lấy vị trí: $e'),
            action: SnackBarAction(
              label: 'Thử lại',
              onPressed: _getCurrentLocation,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              indicatorColor: Colors.orange,
              labelColor: Colors.orange,
              unselectedLabelColor: TColor.gray,
              tabs: const [
                Tab(
                  icon: Icon(Icons.location_on),
                  text: "Gần tôi",
                ),
                Tab(
                  icon: Icon(Icons.trending_up),
                  text: "Bán chạy",
                ),
                Tab(
                  icon: Icon(Icons.star),
                  text: "Đánh giá",
                ),
              ],
            ),
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildNearbyRestaurants(),
            _buildBestSellerRestaurants(),
            _buildTopRatedRestaurants(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationStatus() {
    if (_isLoadingLocation) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Đang lấy vị trí...',
            style: TextStyle(
              fontSize: 16,
              color: TColor.text,
            ),
          ),
        ],
      );
    }

    if (_currentPosition == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                Icons.location_off,
                size: 60,
                color: TColor.color3,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Không thể lấy vị trí',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: TColor.text,
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Vui lòng bật GPS và cho phép ứng dụng truy cập vị trí để tìm nhà hàng gần bạn',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: TColor.gray,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: _getCurrentLocation,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.color3,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildNearbyRestaurants() {
    return Consumer<RestaurantViewModel>(
      builder: (context, viewModel, child) {
        // Hiển thị loading
        if (_isLoadingLocation || viewModel.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text(
                  _isLoadingLocation
                      ? 'Đang lấy vị trí...'
                      : 'Đang tải danh sách nhà hàng...',
                  style: TextStyle(
                    fontSize: 16,
                    color: TColor.text,
                  ),
                ),
              ],
            ),
          );
        }

        // Kiểm tra vị trí
        if (_currentPosition == null) {
          return _buildLocationStatus();
        }

        // Hiển thị lỗi
        if (viewModel.error?.isNotEmpty == true) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 60,
                  color: TColor.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: TColor.text,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  viewModel.error ?? '',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: TColor.gray,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => viewModel.fetchNearbyRestaurants(
                    radiusInKm: 20,
                    limit: 10,
                  ),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // Không tìm thấy nhà hàng
        if (viewModel.nearbyRestaurants.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.restaurant_outlined,
                  size: 60,
                  color: TColor.primary,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không tìm thấy nhà hàng',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Không có nhà hàng nào trong khu vực tìm kiếm',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => viewModel.fetchNearbyRestaurants(
                    radiusInKm: 40, // Tăng gấp đôi bán kính tìm kiếm
                    limit: 10,
                  ),
                  icon: const Icon(Icons.search),
                  label: const Text('Mở rộng tìm kiếm'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          );
        }

        // Hiển thị danh sách nhà hàng
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(15),
                itemCount: viewModel.nearbyRestaurants.length,
                itemBuilder: (context, index) {
                  final restaurant = viewModel.nearbyRestaurants[index];
                  final distanceInMeters =
                      viewModel.calculateDistanceToRestaurant(restaurant);
                  final formattedDistance =
                      viewModel.formatDistance(distanceInMeters);

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RestaurantDetailView(restaurant: restaurant)),
                      );
                    },
                    child: Card(
                      color: Colors.white,
                      elevation: 0.8,
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.asset(
                            restaurant.mainImage,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.restaurant),
                            ),
                          ),
                        ),
                        title: Text(
                          restaurant.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(restaurant.address),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                Text(
                                  ' ${restaurant.rating}',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(
                                  Icons.location_on,
                                  size: 16,
                                  color: Colors.orange,
                                ),
                                Text(
                                  ' $formattedDistance',
                                  style: const TextStyle(
                                    color: Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBestSellerRestaurants() {
    return Consumer<OrderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error?.isNotEmpty == true) {
          return Center(
            child: Text('Lỗi: ${viewModel.error}'),
          );
        }

        if (viewModel.topSellingFoods.isEmpty) {
          return const Center(
            child: Text('Chưa có món ăn bán chạy'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: viewModel.topSellingFoods.length,
          itemBuilder: (context, index) {
            final food = viewModel.topSellingFoods[index];
            final foodModel = FoodModel.fromMap(food);
            return Card(
              color: Colors.white,
              elevation: 0.8,
              margin: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SingleFoodDetail(foodItem: foodModel)),
                  );
                },
                child: ListTile(
                  contentPadding: const EdgeInsets.all(8),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: food['images'] != null &&
                            (food['images'] as List).isNotEmpty
                        ? Image.network(
                            food['images'][0],
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.fastfood),
                            ),
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey[300],
                            child: const Icon(Icons.fastfood),
                          ),
                  ),
                  title: Text(
                    food['name'] ?? 'Không có tên',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Danh mục: ${food['category'] ?? 'Chưa phân loại'}'),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(
                            Icons.shopping_cart,
                            size: 16,
                            color: Colors.orange,
                          ),
                          Text(
                            ' Đã bán: ${food['quantity'] ?? 0}',
                            style: const TextStyle(
                              color: Colors.orange,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.orange,
                          ),
                          Text(
                            ' ${food['rating']?.toStringAsFixed(1) ?? 'N/A'}',
                            style: const TextStyle(
                              color: Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Doanh thu: ${(food['totalRevenue'] as double).toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildTopRatedRestaurants() {
    return Consumer<FoodViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (viewModel.error?.isNotEmpty == true) {
          return Center(
            child: Text('Lỗi: ${viewModel.error}'),
          );
        }

        if (viewModel.fetchFoodsByRate.isEmpty) {
          return const Center(
            child: Text('Chưa có nhà hàng được đánh giá'),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: viewModel.fetchFoodsByRate.length,
          itemBuilder: (context, index) {
            final food = viewModel.fetchFoodsByRate[index];

            return GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            SingleFoodDetail(foodItem: food)));
              },
              child: Card(
                color: Colors.white,
                elevation: 0.8,
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ảnh món ăn với kích thước nhỏ gọn và bo viền
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          food.images.isNotEmpty
                              ? food.images.first
                              : 'assets/img/placeholder.png',
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            width: 80,
                            height: 80,
                            color: Colors.grey[200],
                            child: Icon(Icons.fastfood, color: TColor.primary),
                          ),
                        ),
                      ),

                      // Khoảng cách giữa ảnh và thông tin
                      const SizedBox(width: 12),

                      // Thông tin món ăn
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Tên món ăn
                            Text(
                              food.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            // Đánh giá
                            Row(
                              children: [
                                Text(
                                  food.rating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: TColor.text,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                // Rating stars
                                SizedBox(
                                  height: 16,
                                  child: RatingBarIndicator(
                                    rating: food.rating,
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 14,
                                    direction: Axis.horizontal,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 4),

                            // Mô tả món ăn
                            Text(
                              food.description,
                              style: TextStyle(
                                fontSize: 13,
                                color: TColor.gray,
                                height: 1.3,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),

                            const SizedBox(height: 4),

                            // Giá và nhà hàng
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Giá
                                Text(
                                  '${food.price.toStringAsFixed(0)}đ',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: TColor.color3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
