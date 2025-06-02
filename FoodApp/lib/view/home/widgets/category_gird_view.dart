import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/view/home/widgets/list_food_by_category.dart';
import 'package:foodapp/data/models/category_model.dart';

class CategoryGridItem extends StatelessWidget {
  final CategoryModel category;

  const CategoryGridItem({
    super.key,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    // Lấy kích thước màn hình
    final screenWidth = MediaQuery.of(context).size.width;

    // Tính toán kích thước theo tỷ lệ màn hình
    final itemSize = screenWidth * 0.15; // Giảm kích thước từ 18% xuống 15%

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ListFoodByCategory(
              category: category.id,
              initialCategoryId: category.id,
            ),
          ),
        );
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: itemSize,
            height: itemSize,
            decoration: BoxDecoration(
              color: Colors.transparent,
              // color: _getRandomPastelColor(),
              borderRadius: BorderRadius.circular(
                  45), // Giảm border radius từ 18 xuống 14
              // boxShadow: const [
              //   BoxShadow(
              //     color: Colors.black.withOpacity(0.1),
              //     blurRadius: 6, // Giảm blur từ 10 xuống 6
              //     offset: Offset(0, 2), // Giảm offset từ (0,3) xuống (0,2)
              //   ),
              // ],
            ),
            child: Image.asset(
              category.image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Center(
                child: Icon(
                  Icons.restaurant,
                  size: itemSize * 0.5,
                  color: TColor.orange5,
                ),
              ),
            ),
          ),

          // Khoảng cách
          const SizedBox(height: 4), // Giảm khoảng cách từ 8 xuống 4

          // Text tên danh mục
          Text(
            category.name,
            style: TextStyle(
              fontSize: 12, // Giảm font size từ 13 xuống 12
              fontWeight: FontWeight.w500,
              color: TColor.text,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
