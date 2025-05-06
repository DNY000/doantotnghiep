import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/common_widget/tabbar/list_food_by_category.dart';
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
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: 4), // Giảm margin từ 6 xuống 4
        width: itemSize + 16, // Giảm width từ +20 xuống +16
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Container hình ảnh
            Container(
              width: itemSize,
              height: itemSize,
              decoration: BoxDecoration(
                color: _getRandomPastelColor(),
                borderRadius: BorderRadius.circular(
                    14), // Giảm border radius từ 18 xuống 14
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6, // Giảm blur từ 10 xuống 6
                    offset:
                        const Offset(0, 2), // Giảm offset từ (0,3) xuống (0,2)
                  ),
                ],
              ),
              child: ClipRRect(
                // Bỏ padding 2.0 bên ngoài để ảnh lớn hơn
                borderRadius: BorderRadius.circular(
                    14), // Giảm border radius từ 16 xuống 14
                child: Image.asset(
                  category.image,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Center(
                    child: Icon(
                      Icons.restaurant,
                      size: itemSize * 0.5,
                      color: TColor.primary,
                    ),
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
      ),
    );
  }

  // Hàm tạo màu pastel ngẫu nhiên nhưng có kiểm soát
  Color _getRandomPastelColor() {
    // Tính toán màu dựa trên ID của danh mục để đảm bảo tính nhất quán
    final int seed = category.id.hashCode;

    // Danh sách các màu pastel nhẹ
    final List<Color> pastelColors = [
      TColor.primary.withOpacity(0.15),
      TColor.color2.withOpacity(0.15),
      TColor.rating.withOpacity(0.15),
      TColor.color1.withOpacity(0.15),
      const Color(0xFFE0F7FA).withOpacity(0.6), // Mint pastel
      const Color(0xFFF8BBD0).withOpacity(0.4), // Pink pastel
      const Color(0xFFFFCCBC).withOpacity(0.4), // Peach pastel
      const Color(0xFFDCEDC8).withOpacity(0.6), // Light green pastel
    ];

    // Chọn màu dựa trên seed
    return pastelColors[seed % pastelColors.length];
  }
}
