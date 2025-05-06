import 'package:flutter/material.dart';
import 'package:foodapp/viewmodels/category_viewmodel.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:provider/provider.dart';

class ListFoodByCategory extends StatefulWidget {
  final String category;
  const ListFoodByCategory({
    Key? key,
    required this.category,
  }) : super(key: key);

  @override
  State<ListFoodByCategory> createState() => _ListFoodByCategoryState();
}

class _ListFoodByCategoryState extends State<ListFoodByCategory>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late FoodViewModel _foodViewModel;
  late CategoryViewModel _categoryViewModel;

  @override
  void initState() {
    super.initState();
    _foodViewModel = Provider.of<FoodViewModel>(context, listen: false);
    _categoryViewModel = Provider.of<CategoryViewModel>(context, listen: false);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      await _categoryViewModel.loadCategories();

      setState(() {
        _tabController = TabController(
          length: _categoryViewModel.categories.length + 1,
          vsync: this,
        );
      });

      final category = widget.category.toUpperCase();
      await _foodViewModel.fetchFoodsByCategory(category);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Danh mục ${widget.category}',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Consumer<CategoryViewModel>(
            builder: (context, categoryViewModel, _) {
              if (categoryViewModel.isLoading) {
                return const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (categoryViewModel.categories.isEmpty) {
                return const SizedBox(
                  height: 48,
                  child: Center(child: Text('Không có danh mục')),
                );
              }

              return TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: TColor.primary,
                unselectedLabelColor: TColor.gray,
                indicatorColor: TColor.primary,
                tabs: [
                  const Tab(text: 'Tất cả'),
                  ...categoryViewModel.categories
                      .map((category) => Tab(text: category.name))
                      .toList(),
                ],
                onTap: (index) {
                  if (index == 0) {
                    _foodViewModel
                        .fetchFoodsByCategory(widget.category.toUpperCase());
                  } else {
                    final selectedCategory =
                        categoryViewModel.categories[index - 1];
                    _foodViewModel.fetchFoodsByCategory(selectedCategory.id);
                  }
                },
              );
            },
          ),
          Expanded(
            child: Consumer<FoodViewModel>(
              builder: (context, foodViewModel, _) {
                if (foodViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (foodViewModel.error?.isNotEmpty ?? false) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: TColor.primary),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${foodViewModel.error ?? 'Đã xảy ra lỗi'}',
                          style: TextStyle(color: TColor.text),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.primary,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                final foods = foodViewModel
                        .categoryFoods[widget.category.toUpperCase()] ??
                    [];

                if (foods.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.no_meals, size: 64, color: TColor.gray),
                        const SizedBox(height: 16),
                        Text(
                          'Không có món ăn nào trong danh mục này',
                          style: TextStyle(color: TColor.gray),
                        ),
                      ],
                    ),
                  );
                }

                return TabBarView(
                  controller: _tabController,
                  children: [
                    _buildFoodList(foods),
                    ...foodViewModel.categoryFoods.values
                        .map(_buildFoodList)
                        .toList(),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodList(List<dynamic> foods) {
    if (foods.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.no_meals, size: 48, color: TColor.gray),
            const SizedBox(height: 16),
            Text(
              'Không có món ăn nào trong danh mục này',
              style: TextStyle(color: TColor.gray),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: foods.length,
      itemBuilder: (context, index) {
        final food = foods[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            contentPadding: const EdgeInsets.all(12),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                food.images.first,
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: Icon(Icons.fastfood, color: TColor.primary),
                ),
              ),
            ),
            title: Text(
              food.name,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  food.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: TColor.gray),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${food.price.toStringAsFixed(0)}đ',
                      style: TextStyle(
                        color: TColor.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.star, size: 16, color: TColor.primary),
                    const SizedBox(width: 4),
                    Text(
                      food.rating.toStringAsFixed(1),
                      style: TextStyle(color: TColor.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
