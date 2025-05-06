import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/common_widget/grid/grid_view.dart';
import 'package:foodapp/data/models/category_model.dart';
import 'package:foodapp/view/home/widgets/category_gird_view.dart';
import 'package:foodapp/viewmodels/category_viewmodel.dart';
import 'package:provider/provider.dart';

class ListCategory extends StatelessWidget {
  const ListCategory({super.key});

  @override
  Widget build(BuildContext context) {
    final mediaSize = MediaQuery.of(context).size;

    return Container(
      padding: const EdgeInsets.only(top: 4, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Danh mục món ăn",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: TColor.text,
                    letterSpacing: 0.2,
                  ),
                ),
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Xem tất cả",
                    style: TextStyle(
                      fontSize: 12,
                      color: TColor.color3,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Categories content
          Consumer<CategoryViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return SizedBox(
                  height: mediaSize.width * 0.25,
                  child: Center(
                    child: CircularProgressIndicator(color: TColor.color3),
                  ),
                );
              }

              if (viewModel.error != null) {
                return Container(
                  height: mediaSize.width * 0.25,
                  // margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 35,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Không thể tải danh mục',
                          style: TextStyle(
                              color: TColor.text, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 6),
                        ElevatedButton.icon(
                          onPressed: () => viewModel.loadCategories(),
                          icon: const Icon(Icons.refresh, size: 20),
                          label: const Text('Thử lại'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TColor.color3,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 6),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (viewModel.categories.isEmpty) {
                return Container(
                  height: mediaSize.width * 0.25,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'Chưa có danh mục',
                      style: TextStyle(color: TColor.gray, fontSize: 14),
                    ),
                  ),
                );
              }

              return SizedBox(
                height: mediaSize.width * 0.25,
                child: TGrid<CategoryModel>(
                  items: viewModel.categories,
                  crossAxisCount: 1,
                  childAspectRatio: 0.9,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 0,
                  shrinkWrap: true,
                  scrollable: true,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemBuilder: (category) =>
                      CategoryGridItem(category: category),
                  onTap: (category) {
                    if (kDebugMode) {
                      print('Selected category: ${category.name}');
                    }
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
