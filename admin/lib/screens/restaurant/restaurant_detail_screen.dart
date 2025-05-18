import 'package:admin/screens/restaurant/widget/food_by_restaurant.dart';
import 'package:admin/screens/restaurant/widget/order_by_restaurant.dart';
import 'package:admin/screens/restaurant/widget/thong_ke.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final String restaurantId;
  const RestaurantDetailScreen({super.key, required this.restaurantId});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết nhà hàng'),
        leading: IconButton(
          onPressed: () {
            context.go('/restaurant');
          },
          icon: const Icon(Icons.arrow_back),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Món ăn'),
            Tab(text: 'Đơn hàng'),
            Tab(text: 'Doanh thu'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // RestaurantView(),
          FoodByRestaurantScreen(
            restaurantId: widget.restaurantId,
          ),
          OrderByRestaurantScreem(restaurantId: widget.restaurantId),
          DoanhThuByRestaurantScreen(restaurantId: widget.restaurantId),
        ],
      ),
    );
  }
}
