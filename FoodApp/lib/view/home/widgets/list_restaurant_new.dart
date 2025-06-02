import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/grid/grid_view.dart';
import 'package:foodapp/common_widget/grid/restaurant_grid_item.dart';
import 'package:foodapp/data/models/restaurant_model.dart';
import 'package:foodapp/view/restaurant/restaurant_detail_view.dart';
import 'package:foodapp/viewmodels/restaurant_viewmodel.dart';
import 'package:provider/provider.dart';

class ListRestaurantNew extends StatefulWidget {
  const ListRestaurantNew({super.key});

  @override
  State<ListRestaurantNew> createState() => _ListRestaurantNewState();
}

class _ListRestaurantNewState extends State<ListRestaurantNew> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _fetchData();
      }
    });
  }

  Future<void> _fetchData() async {
    if (!mounted) return;
    try {
      context.read<RestaurantViewModel>().getNewRestaurants();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeContainer = MediaQuery.of(context).size.width * 0.4;
    return SizedBox(
      height: sizeContainer,
      child: Consumer<RestaurantViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 8),
                  Text('Đang tải danh sách nhà hàng...'),
                ],
              ),
            );
          }

          if (viewModel.error?.isNotEmpty == true) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi: ${viewModel.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _fetchData,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final restaurants = viewModel.newRestaurants;
          if (restaurants.isEmpty) {
            return const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.restaurant_menu, size: 48, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Không có nhà hàng mới',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return TGrid<RestaurantModel>(
            items: restaurants,
            crossAxisCount: 1,
            // childAspectRatio: 1.4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            showHeight: true,
            shrinkWrap: true,
            scrollable: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemBuilder: (restaurant) {
              return RestaurantGridItem(
                restaurant: restaurant,
                showNewBadge: true,
              );
            },
            onTap: (restaurant) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RestaurantDetailView(
                    restaurant: restaurant,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
