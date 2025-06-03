import 'dart:typed_data';

import 'package:admin/models/food_model.dart';
import 'package:admin/viewmodels/food_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/ultils/const/enum.dart';
import 'package:file_picker/file_picker.dart';

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

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FoodViewModel>().fetchFoodsByRestaurant(widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddFoodDialog(context, widget.restaurantId);
        },
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
                        onPressed: () {
                          _showEditFoodDialog(
                              context, food, widget.restaurantId);
                        },
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
                            // Gọi hàm xóa món ăn trong viewModel
                            try {
                              if (food.id.isNotEmpty) {
                                final viewModel = Provider.of<FoodViewModel>(
                                    context,
                                    listen: false);
                                await viewModel.deleteFood(food.id);
                                // Cập nhật danh sách món ăn sau khi xóa thành công
                                await viewModel.fetchFoodsByRestaurant(
                                    widget.restaurantId);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Đã xóa món ăn ${food.name}')),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Lỗi: ID món ăn không hợp lệ.')),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text(
                                        'Lỗi khi xóa món ăn: ${e.toString()}')),
                              );
                            }
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

  void _showAddFoodDialog(BuildContext context, String restaurantId) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final priceController = TextEditingController();
    final discountPriceController = TextEditingController();
    final ingredientsController = TextEditingController();
    final categoryController =
        TextEditingController(); // Assuming category is a String for now
    Uint8List? imageBytes;
    bool isAvailable = true;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.7, // Adjust width as needed
                height: MediaQuery.of(context).size.height *
                    0.8, // Adjust height as needed
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Thêm Món Ăn Mới',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Tên món ăn
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên món ăn *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mô tả
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Giá
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Giá giảm giá (tùy chọn)
                      TextField(
                        controller: discountPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá giảm giá (tùy chọn)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hình ảnh
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                withData: true,
                              );
                              if (result != null &&
                                  result.files.single.bytes != null) {
                                setState(() {
                                  imageBytes = result.files.single.bytes;
                                });
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh chính'),
                          ),
                          const SizedBox(width: 12),
                          imageBytes != null
                              ? Image.memory(
                                  imageBytes!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : const Text('Chưa chọn ảnh'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Nguyên liệu (tạm thời là chuỗi)
                      TextField(
                        controller: ingredientsController,
                        decoration: const InputDecoration(
                          labelText: 'Nguyên liệu (phân tách bằng dấu phẩy)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Danh mục
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Danh mục *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Trạng thái khả dụng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Khả dụng'),
                          Switch(
                            value: isAvailable,
                            onChanged: (value) {
                              setState(() {
                                isAvailable = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              // Make onPressed async
                              // TODO: Implement add food logic properly
                              // Validate required fields
                              if (nameController.text.isEmpty ||
                                  priceController.text.isEmpty ||
                                  categoryController.text.isEmpty) {
                                // Show an error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Vui lòng điền đầy đủ thông tin bắt buộc')),
                                );
                                return;
                              }

                              // Parse price and discountPrice
                              final double price =
                                  double.tryParse(priceController.text) ?? 0.0;
                              final double? discountPrice =
                                  double.tryParse(discountPriceController.text);

                              // Parse ingredients (simple split by comma)
                              final List<String> ingredients =
                                  ingredientsController.text
                                      .split(', ')
                                      .map((e) => e.trim())
                                      .toList();

                              // TODO: Implement image upload and get URL
                              String imageUrl =
                                  ''; // Placeholder for uploaded image URL
                              // if (imageBytes != null) {
                              //   imageUrl = await uploadImage(imageBytes); // Implement uploadImage function
                              // }
                              final docRef = FirebaseFirestore.instance
                                  .collection('foods')
                                  .doc(); // <-- Tạo doc với id tự động
                              final foodId = docRef.id;
                              final newFood = FoodModel(
                                id: foodId,
                                name: nameController.text,
                                description: descriptionController.text,
                                price: price,
                                discountPrice: discountPrice,
                                images: imageUrl.isNotEmpty ? [imageUrl] : [],
                                ingredients: ingredients,
                                category: CategoryFood.values.firstWhere(
                                  (e) =>
                                      e.name.toLowerCase() ==
                                      categoryController.text
                                          .trim()
                                          .toLowerCase(),
                                  orElse: () => CategoryFood.other,
                                ),
                                restaurantId: restaurantId,
                                isAvailable: isAvailable,
                                rating: 0.0, // Default rating
                                soldCount: 0, // Default sold count
                                createdAt: Timestamp.now(),
                              );

                              try {
                                final viewModel = Provider.of<FoodViewModel>(
                                    context,
                                    listen: false);
                                await viewModel.addFood(newFood);
                                await viewModel.fetchFoodsByRestaurant(
                                    widget.restaurantId); // Refresh list
                                if (context.mounted) {
                                  Navigator.pop(
                                      context); // Close dialog on success
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('Thêm món ăn thành công')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Lỗi khi thêm món ăn: ${e.toString()}')),
                                );
                              }
                            },
                            child: const Text('Thêm món ăn'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showEditFoodDialog(
      BuildContext context, FoodModel food, String restaurantId) {
    final nameController = TextEditingController(text: food.name);
    final descriptionController = TextEditingController(text: food.description);
    final priceController = TextEditingController(text: food.price.toString());
    final discountPriceController =
        TextEditingController(text: food.discountPrice?.toString());
    final ingredientsController =
        TextEditingController(text: food.ingredients.join(', '));
    final categoryController = TextEditingController(
        text: food.category.name); // Assuming category is String
    Uint8List? imageBytes; // To hold new image bytes
    String? imageUrl = food.images.isNotEmpty
        ? food.images[0]
        : null; // To hold existing image URL
    bool isAvailable = food.isAvailable;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Container(
                width: MediaQuery.of(context).size.width *
                    0.7, // Adjust width as needed
                height: MediaQuery.of(context).size.height *
                    0.8, // Adjust height as needed
                padding: const EdgeInsets.all(20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sửa Món Ăn',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Tên món ăn
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên món ăn *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Mô tả
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Mô tả',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Giá
                      TextField(
                        controller: priceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Giá giảm giá (tùy chọn)
                      TextField(
                        controller: discountPriceController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Giá giảm giá (tùy chọn)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Hình ảnh
                      Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Implement image picking
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.image,
                                withData: true,
                              );
                              if (result != null &&
                                  result.files.single.bytes != null) {
                                setState(() {
                                  imageBytes = result.files.single.bytes;
                                  imageUrl =
                                      null; // Clear existing URL if new image is picked
                                });
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh chính'),
                          ),
                          const SizedBox(width: 12),
                          if (imageBytes != null)
                            Image.memory(
                              imageBytes!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          else if (imageUrl != null)
                            Image.asset(
                              imageUrl!,
                              width: 60,
                              height: 60,
                              fit: BoxFit.cover,
                            )
                          else
                            const Text('Chưa chọn ảnh'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Nguyên liệu (tạm thời là chuỗi)
                      TextField(
                        controller: ingredientsController,
                        decoration: const InputDecoration(
                          labelText: 'Nguyên liệu (phân tách bằng dấu phẩy)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Danh mục
                      TextField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Danh mục *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Trạng thái khả dụng
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Khả dụng'),
                          Switch(
                            value: isAvailable,
                            onChanged: (value) {
                              setState(() {
                                isAvailable = value;
                              });
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Hủy'),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton(
                            onPressed: () async {
                              // Make onPressed async
                              // TODO: Implement update food logic properly
                              // Validate required fields
                              if (nameController.text.isEmpty ||
                                  priceController.text.isEmpty ||
                                  categoryController.text.isEmpty) {
                                // Show an error message
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Vui lòng điền đầy đủ thông tin bắt buộc')),
                                );
                                return;
                              }

                              // Parse price and discountPrice
                              final double price =
                                  double.tryParse(priceController.text) ?? 0.0;
                              final double? discountPrice =
                                  double.tryParse(discountPriceController.text);

                              // Parse ingredients (simple split by comma)
                              final List<String> ingredients =
                                  ingredientsController.text
                                      .split(', ')
                                      .map((e) => e.trim())
                                      .toList();

                              // TODO: Upload new image if selected and get URL
                              String finalImageUrl = imageUrl ??
                                  ''; // Use existing URL if no new image
                              // if (imageBytes != null) {
                              //   finalImageUrl = await uploadImage(imageBytes); // Implement uploadImage function
                              // }

                              final updatedFood = food.copyWith(
                                name: nameController.text,
                                description: descriptionController.text,
                                price: price,
                                discountPrice: discountPrice,
                                images: finalImageUrl.isNotEmpty
                                    ? [finalImageUrl]
                                    : [],
                                ingredients: ingredients,
                                category: CategoryFood.values.firstWhere(
                                  // Convert String to CategoryFood enum
                                  (e) =>
                                      e.name.toLowerCase() ==
                                      categoryController.text
                                          .trim()
                                          .toLowerCase(),
                                  orElse: () => CategoryFood.other,
                                ),
                                isAvailable: isAvailable,
                                // Keep other fields as is
                              );

                              try {
                                final viewModel = Provider.of<FoodViewModel>(
                                    context,
                                    listen: false);
                                await viewModel.updateFood(updatedFood,
                                    food.id); // Pass food ID for update
                                await viewModel.fetchFoodsByRestaurant(
                                    widget.restaurantId); // Refresh list
                                if (context.mounted) {
                                  Navigator.pop(
                                      context); // Close dialog on success
                                }
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content:
                                          Text('Cập nhật món ăn thành công')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Lỗi khi cập nhật món ăn: ${e.toString()}')),
                                );
                              }
                            },
                            child: const Text('Cập nhật'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
