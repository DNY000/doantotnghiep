import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/card/t_card.dart';
import 'package:foodapp/viewmodels/category_viewmodel.dart';
import 'package:foodapp/viewmodels/food_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:provider/provider.dart';

class ListFoodByCategory extends StatefulWidget {
  final String category;
  final String? initialCategoryId;
  const ListFoodByCategory({
    Key? key,
    required this.category,
    this.initialCategoryId,
  }) : super(key: key);

  @override
  State<ListFoodByCategory> createState() => _ListFoodByCategoryState();
}

class _ListFoodByCategoryState extends State<ListFoodByCategory>
    with SingleTickerProviderStateMixin {
  late FoodViewModel _foodViewModel;
  late CategoryViewModel _categoryViewModel;

  String _selectedCategoryId = '';
  static const String ALL_CATEGORIES_MARKER = 'ALL_FOODS';

  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    _foodViewModel = Provider.of<FoodViewModel>(context, listen: false);
    _categoryViewModel = Provider.of<CategoryViewModel>(context, listen: false);

    _selectedCategoryId = widget.initialCategoryId ?? ALL_CATEGORIES_MARKER;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  Future<void> _loadInitialData() async {
    try {
      await _categoryViewModel.loadCategories();

      if (mounted) {
        setState(() {
          _tabController = TabController(
            length: _categoryViewModel.categories.length + 1,
            vsync: this,
          );

          // Set initial tab index based on initialCategoryId
          if (widget.initialCategoryId != null) {
            final index = _categoryViewModel.categories
                .indexWhere((cat) => cat.id == widget.initialCategoryId);
            if (index != -1) {
              _tabController?.index =
                  index + 1; // +1 because first tab is "All"
            }
          }
        });
      }

      await _foodViewModel.loadFoods();

      if (widget.initialCategoryId != null) {
        await _foodViewModel.fetchFoodsByCategory(widget.initialCategoryId!);
      } else {
        await _foodViewModel
            .fetchFoodsByCategory(widget.category.toUpperCase());
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi tải dữ liệu ban đầu: $e')),
        );
      }
    }
  }

  void _onTabSelected(int index) {
    if (!mounted) return;

    String newlySelectedCategoryId;
    if (index == 0) {
      newlySelectedCategoryId = ALL_CATEGORIES_MARKER;
    } else {
      if (index - 1 < _categoryViewModel.categories.length) {
        newlySelectedCategoryId = _categoryViewModel.categories[index - 1].id;
      } else {
        newlySelectedCategoryId = ALL_CATEGORIES_MARKER;
      }
    }

    setState(() {
      _selectedCategoryId = newlySelectedCategoryId;
    });

    final foodViewModel = context.read<FoodViewModel>();

    if (_selectedCategoryId == ALL_CATEGORIES_MARKER) {
      foodViewModel.loadFoods();
    } else {
      foodViewModel.fetchFoodsByCategory(_selectedCategoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.bg,
      appBar: AppBar(
        title: Text(
          _selectedCategoryId == ALL_CATEGORIES_MARKER
              ? 'Tất cả món ăn'
              : 'Danh mục ${widget.category}',
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
              if (categoryViewModel.isLoading || _tabController == null) {
                return const SizedBox(
                  height: 48,
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (categoryViewModel.categories.isEmpty &&
                  !categoryViewModel.isLoading) {
                return const SizedBox(
                  height: 48,
                  child: Center(child: Text('Không có danh mục')),
                );
              }

              return TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: TColor.orange5,
                unselectedLabelColor: TColor.gray,
                indicatorColor: TColor.orange5,
                tabs: [
                  const Tab(text: 'Tất cả'),
                  ...categoryViewModel.categories
                      .map((category) => Tab(text: category.name))
                      .toList(),
                ],
                onTap: _onTabSelected,
              );
            },
          ),
          Expanded(
            child: Consumer<FoodViewModel>(
              builder: (context, foodViewModel, _) {
                final foods = (_selectedCategoryId == ALL_CATEGORIES_MARKER)
                    ? foodViewModel.foods
                    : foodViewModel.categoryFoods[_selectedCategoryId] ?? [];

                if (foodViewModel.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (foodViewModel.error?.isNotEmpty ?? false) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline,
                            size: 48, color: TColor.orange5),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi tải món ăn: ${foodViewModel.error ?? 'Đã xảy ra lỗi'}',
                          style: TextStyle(color: TColor.text),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedCategoryId == ALL_CATEGORIES_MARKER) {
                              foodViewModel.loadFoods();
                            } else {
                              foodViewModel
                                  .fetchFoodsByCategory(_selectedCategoryId);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.orange5,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                bool hasLoadedCategories =
                    _categoryViewModel.categories.isNotEmpty;
                bool isEmptyAfterLoadAttempt = foods.isEmpty &&
                    !foodViewModel.isLoading &&
                    !(foodViewModel.error?.isNotEmpty ?? false);

                if (isEmptyAfterLoadAttempt &&
                    (_selectedCategoryId == ALL_CATEGORIES_MARKER ||
                        hasLoadedCategories)) {
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

                if (!foodViewModel.isLoading &&
                    !(foodViewModel.error?.isNotEmpty ?? false) &&
                    foods.isNotEmpty) {
                  return FoodListView(foods: foods);
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }
}
