import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:foodapp/common_widget/card/t_card.dart';
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
        context.read<OrderViewModel>().getTopSellingFoodsByApp();
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
        if (_isLoadingLocation || viewModel.isLoading) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                ),
                SizedBox(height: 16),
                Text(
                  'Đang tải dữ liệu...',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        }

        if (_currentPosition == null) {
          return _buildLocationStatus();
        }

        if (viewModel.error?.isNotEmpty == true) {
          return _buildErrorView(
            message: viewModel.error ?? 'Có lỗi xảy ra',
            onRetry: () => viewModel.fetchNearbyRestaurants(
              radiusInKm: 20,
              limit: 10,
            ),
          );
        }

        if (viewModel.nearbyRestaurants.isEmpty) {
          return _buildEmptyView(
            icon: Icons.restaurant_outlined,
            title: 'Không tìm thấy nhà hàng',
            message: 'Không có nhà hàng nào trong khu vực tìm kiếm',
            buttonText: 'Mở rộng tìm kiếm',
            onButtonPressed: () => viewModel.fetchNearbyRestaurants(
              radiusInKm: 40,
              limit: 10,
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(15),
          itemCount: viewModel.nearbyRestaurants.length,
          itemBuilder: (context, index) {
            final restaurant = viewModel.nearbyRestaurants[index];
            final distanceInMeters =
                viewModel.calculateDistanceToRestaurant(restaurant);
            final formattedDistance =
                viewModel.formatDistance(distanceInMeters);

            return RepaintBoundary(
              child: Card(
                color: Colors.white,
                elevation: 0.8,
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            RestaurantDetailView(restaurant: restaurant),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Restaurant Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Hero(
                            tag: 'restaurant_${restaurant.id}',
                            child: Image.asset(
                              restaurant.mainImage,
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.restaurant,
                                    color: TColor.orange5),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                restaurant.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                restaurant.address,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: TColor.gray,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  _buildRatingInfo(restaurant.rating),
                                  const SizedBox(width: 12),
                                  _buildDistanceInfo(formattedDistance),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildBestSellerRestaurants() {
    return Consumer<OrderViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        }

        if (viewModel.error?.isNotEmpty == true) {
          return _buildErrorView(
            message: viewModel.error ?? 'Có lỗi xảy ra',
            onRetry: () => viewModel.getTopSellingFoods(),
          );
        }

        if (viewModel.topSellingFoodsByApp.isEmpty) {
          return _buildEmptyView(
            icon: Icons.trending_up,
            title: 'Chưa có món ăn bán chạy',
            message: 'Hãy quay lại sau để xem các món ăn bán chạy',
          );
        }

        return FoodListView(
          foods: viewModel.topSellingFoodsByApp,
        );
      },
    );
  }

  Widget _buildTopRatedRestaurants() {
    return Consumer<FoodViewModel>(
      builder: (context, viewModel, child) {
        if (viewModel.isLoading) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
            ),
          );
        }

        if (viewModel.error?.isNotEmpty == true) {
          return _buildErrorView(
            message: viewModel.error ?? 'Có lỗi xảy ra',
            onRetry: () => viewModel.getFoodByRate(),
          );
        }

        if (viewModel.fetchFoodsByRate.isEmpty) {
          return _buildEmptyView(
            icon: Icons.star,
            title: 'Chưa có món ăn được đánh giá',
            message: 'Hãy quay lại sau để xem các món ăn được đánh giá cao',
          );
        }

        return FoodListView(foods: viewModel.fetchFoodsByRate);
      },
    );
  }

  // Helper widgets
  Widget _buildErrorView({
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 60,
            color: TColor.orange5,
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: TColor.gray,
              ),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Thử lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.orange5,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyView({
    required IconData icon,
    required String title,
    required String message,
    String? buttonText,
    VoidCallback? onButtonPressed,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: TColor.orange5,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.grey,
              ),
            ),
          ),
          if (buttonText != null && onButtonPressed != null) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onButtonPressed,
              icon: const Icon(Icons.search),
              label: Text(buttonText),
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.orange5,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingInfo(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.star,
          size: 16,
          color: TColor.orange5,
        ),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            color: TColor.orange5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildDistanceInfo(String distance) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.location_on,
          size: 16,
          color: Colors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          distance,
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSalesInfo(int quantity) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.shopping_cart,
          size: 16,
          color: Colors.orange,
        ),
        const SizedBox(width: 4),
        Text(
          'Đã bán: $quantity',
          style: const TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
