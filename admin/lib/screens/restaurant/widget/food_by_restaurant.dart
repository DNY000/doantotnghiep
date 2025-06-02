import 'package:admin/viewmodels/food_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FoodByRestaurantScreen extends StatefulWidget {
  final String restaurantId;
  const FoodByRestaurantScreen({super.key, required this.restaurantId});

  @override
  State<FoodByRestaurantScreen> createState() => _FoodByRestaurantScreenState();
}

class _FoodByRestaurantScreenState extends State<FoodByRestaurantScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi fetchFoodsByRestaurant khi widget được tạo
    Future.microtask(() => context
        .read<FoodViewModel>()
        .fetchFoodsByRestaurant(widget.restaurantId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        icon: const Icon(Icons.add),
        label: const Text('Thêm món ăn'),
      ),
      body: Consumer<FoodViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (viewModel.error != null) {
            return Center(child: Text(viewModel.error!));
          }
          final foods = viewModel.foods;
          if (foods.isEmpty) {
            return const Center(child: Text('Không có món ăn nào'));
          }
          return ListView.builder(
            itemCount: foods.length,
            itemBuilder: (context, index) {
              final food = foods[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: food.images.isNotEmpty
                      ? Image.network(food.images[0],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : const Icon(Icons.fastfood),
                  title: Text(food.name),
                  subtitle: Text('Giá: ${food.price} VNĐ'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Xác nhận xóa'),
                              content: Text(
                                  'Bạn có chắc muốn xóa món ${food.name}?'),
                              actions: [
                                TextButton(
                                  onPressed: () =>
                                      Navigator.pop(context, false),
                                  child: const Text('Hủy'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Xóa'),
                                ),
                              ],
                            ),
                          );
                          if (confirm == true) {
                            // Gọi hàm xóa món ăn trong viewModel (bạn cần cài đặt hàm này trong FoodViewModel)
                            // await viewModel.deleteFood(food.id);
                          }
                        },
                      ),
                    ],
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
