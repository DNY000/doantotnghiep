import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/grid/food_grid_item.dart';
import 'package:foodapp/common_widget/selection_text_view.dart';
import 'package:foodapp/view/restaurant/single_food_detail.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:provider/provider.dart';

class ListFoodYouMaybeLike extends StatelessWidget {
  const ListFoodYouMaybeLike({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(0),
          child: SelectionTextView(
            title: "Có thể bạn sẽ thích",
            onSeeAllTap: () {},
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 164,
          child: Consumer<FoodViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading && viewModel.foods.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                );
              }

              if (viewModel.error?.isNotEmpty ?? false) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Error: ${viewModel.error ?? 'Đã xảy ra lỗi'}',
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => viewModel.loadFoods(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Thử lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                );
              }

              final foods = viewModel.fetchFoodsForYou;
              if (foods.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.no_food,
                        size: 48,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Không có món ăn',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.hardEdge,
                cacheExtent: 1000, // Cache more items for smoother scrolling
                padding: const EdgeInsets.symmetric(horizontal: 7),
                itemCount: foods.length,
                itemBuilder: (context, index) {
                  final food = foods[index];
                  return RepaintBoundary(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Hero(
                        tag: 'food_${food.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SingleFoodDetail(
                                    foodItem: food,
                                    restaurantId: food.restaurantId,
                                  ),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: FoodGridItem(food: food),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
