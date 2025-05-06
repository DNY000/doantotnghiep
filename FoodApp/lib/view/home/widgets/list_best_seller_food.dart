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
    final sizeContainer = MediaQuery.of(context).size.width * 0.45;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: SelectionTextView(
            title: "Có thể bạn sẽ thích",
            onSeeAllTap: () {},
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: sizeContainer, // Tăng chiều cao
          child: Consumer<FoodViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              if (viewModel.error?.isNotEmpty ?? false) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Error: ${viewModel.error ?? 'Đã xảy ra lỗi'}',
                        style: const TextStyle(color: Colors.red),
                      ),
                      ElevatedButton(
                        onPressed: () => viewModel.loadFoods(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              if (viewModel.foods.isEmpty) {
                return const Center(
                  child: Text('Không có món ăn '),
                );
              }

              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 7),
                itemCount: viewModel.fetchFoodsForYou.length,
                itemBuilder: (context, index) {
                  final food = viewModel.fetchFoodsForYou[index];

                  return GestureDetector(
                    onTap: () {
                      // Sửa lại phần navigation để truyền restaurantId
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SingleFoodDetail(
                            foodItem: food,
                            restaurantId:
                                food.restaurantId, // Thêm restaurantId vào đây
                          ),
                        ),
                      );
                    },
                    child: FoodGridItem(food: food),
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
