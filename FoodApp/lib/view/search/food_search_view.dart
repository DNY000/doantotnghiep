import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/card/t_card.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

class FoodSearchView extends StatefulWidget {
  const FoodSearchView({Key? key}) : super(key: key);

  @override
  State<FoodSearchView> createState() => _FoodSearchViewState();
}

class _FoodSearchViewState extends State<FoodSearchView> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        context.read<FoodViewModel>().searchFoods(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: TextField(
          controller: _searchController,
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm món ăn...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: TColor.gray),
            suffixIcon: IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                context.read<FoodViewModel>().clearSearchResults();
              },
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: Colors.black,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<FoodViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error?.isNotEmpty == true) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: TColor.color3),
                  const SizedBox(height: 16),
                  Text(
                    viewModel.error!,
                    style: TextStyle(color: TColor.text),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          final searchResults = viewModel.searchResults;
          if (_searchController.text.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search, size: 48, color: TColor.gray),
                  const SizedBox(height: 16),
                  Text(
                    'Nhập tên món ăn để tìm kiếm',
                    style: TextStyle(color: TColor.gray),
                  ),
                ],
              ),
            );
          }

          if (searchResults.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.no_meals, size: 48, color: TColor.gray),
                  const SizedBox(height: 16),
                  Text(
                    'Không tìm thấy món ăn nào',
                    style: TextStyle(color: TColor.gray),
                  ),
                ],
              ),
            );
          }

          return FoodListView(
            foods: searchResults,
            physics: const BouncingScrollPhysics(),
          );
          // ListView.builder(
          //   padding: const EdgeInsets.all(16),
          //   itemCount: searchResults.length,
          //   itemBuilder: (context, index) {
          //     final food = searchResults[index];
          //     return _buildFoodItem(food);
          //   },
          // );
        },
      ),
    );
  }

//   Widget _buildFoodItem(FoodModel food) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 12),
//       color: Colors.white,
//       elevation: 1,
//       child: InkWell(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) => SingleFoodDetail(
//                 foodItem: food,
//                 restaurantId: food.restaurantId,
//               ),
//             ),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Row(
//             children: [
//               // Food Image
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(8),
//                 child: Image.asset(
//                   food.images.first,
//                   width: 80,
//                   height: 80,
//                   fit: BoxFit.cover,
//                   errorBuilder: (context, error, stackTrace) => Container(
//                     width: 80,
//                     height: 80,
//                     color: Colors.grey[200],
//                     child: Icon(Icons.fastfood, color: TColor.color3),
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               // Food Details
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       food.name,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Text(
//                       food.description,
//                       style: TextStyle(
//                         color: TColor.gray,
//                         fontSize: 14,
//                       ),
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         Text(
//                           '${food.price.toStringAsFixed(0)}đ',
//                           style: TextStyle(
//                             color: TColor.color3,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const Spacer(),
//                         Icon(Icons.star, size: 16, color: TColor.orange5),
//                         const SizedBox(width: 4),
//                         Text(
//                           food.rating.toStringAsFixed(1),
//                           style: TextStyle(color: TColor.color3),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
}
