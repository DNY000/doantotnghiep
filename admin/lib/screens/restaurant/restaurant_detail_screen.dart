import 'package:flutter/material.dart';

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
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Tổng quan'),
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
          // FoodByRestaurantScreen(
          //   restaurantId: widget.restaurantId,
          // ),
          const OrderByRestaurantScreem(),
          const DoanhThuByRestaurantScreen(),
        ],
      ),
    );
  }
}

class OrderByRestaurantScreem extends StatelessWidget {
  const OrderByRestaurantScreem({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Danh sách đơn hàng')),
    );
  }
}

class DoanhThuByRestaurantScreen extends StatelessWidget {
  const DoanhThuByRestaurantScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Thống kê doanh thu')),
    );
  }
}
