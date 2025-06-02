import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/category_viewmodel.dart';
import 'package:admin/models/category_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Responsive.isDesktop(context))
            const Expanded(flex: 1, child: SideMenu()),
          const Expanded(
            flex: 5,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CategoryContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryContent extends StatefulWidget {
  const CategoryContent({super.key});

  @override
  State<CategoryContent> createState() => _CategoryContentState();
}

class _CategoryContentState extends State<CategoryContent> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<CategoryViewModel>().loadCategories());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Quản lý Danh mục',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showCategoryDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Danh mục'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Search section
        TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Tìm kiếm danh mục...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: (value) => setState(() {}),
        ),
        const SizedBox(height: 24),

        // Category list
        Expanded(
          child: Consumer<CategoryViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(viewModel.error!),
                      ElevatedButton(
                        onPressed: () => viewModel.loadCategories(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              var filteredCategories = viewModel.categories;

              // Apply search filter
              if (_searchController.text.isNotEmpty) {
                filteredCategories = filteredCategories
                    .where(
                      (category) => category.name.toLowerCase().contains(
                            _searchController.text.toLowerCase(),
                          ),
                    )
                    .toList();
              }

              if (filteredCategories.isEmpty) {
                return const Center(child: Text('Không tìm thấy danh mục nào'));
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredCategories, viewModel)
                  : _buildMobileView(filteredCategories, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(
    List<CategoryModel> categories,
    CategoryViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Hình ảnh')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: categories.map((category) {
          return DataRow(
            cells: [
              DataCell(
                category.image.isNotEmpty
                    ? Image.network(
                        category.image,
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image_not_supported),
              ),
              DataCell(Text(category.name)),
              DataCell(
                category.isActive
                    ? const Text('Hoạt động',
                        style: TextStyle(color: Colors.green))
                    : const Text('Ẩn', style: TextStyle(color: Colors.red)),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showCategoryDialog(context, category);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text(
                              'Bạn có chắc muốn xóa danh mục ${category.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await viewModel.deleteCategory(category.id);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileView(
    List<CategoryModel> categories,
    CategoryViewModel viewModel,
  ) {
    return ListView.builder(
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (category.image.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          category.image,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.image_not_supported,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showCategoryDialog(context, category);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text(
                              'Bạn có chắc muốn xóa danh mục ${category.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await viewModel.deleteCategory(category.id);
                        }
                      },
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

  void _showCategoryDialog(BuildContext context, [CategoryModel? category]) {
    final viewModel = Provider.of<CategoryViewModel>(context, listen: false);
    final TextEditingController nameController =
        TextEditingController(text: category?.name ?? '');
    final TextEditingController imageController =
        TextEditingController(text: category?.image ?? '');
    bool isActive = category?.isActive ?? true;
    String? errorText;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(category == null ? 'Thêm Danh mục' : 'Sửa Danh mục'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Tên Danh mục',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: 'URL Hình ảnh',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Text('Trạng thái hoạt động:'),
                        const SizedBox(width: 8),
                        Switch(
                          value: isActive,
                          onChanged: (value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
                    ),
                    if (errorText != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          errorText!,
                          style:
                              const TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: viewModel.isLoading
                      ? null
                      : () async {
                          setState(() {
                            errorText = null;
                          });

                          if (nameController.text.isEmpty) {
                            setState(() {
                              errorText = 'Tên danh mục không được để trống';
                            });
                            return;
                          }

                          final newCategory = CategoryModel(
                            id: category?.id ?? '', // Use existing ID for edit
                            name: nameController.text,
                            image: imageController.text,
                            isActive: isActive,
                          );

                          try {
                            if (category == null) {
                              // Tạo mới với thời gian tạo hiện tại
                              // final categoryToAdd = newCategory.copyWith(
                              //   createdAt: DateTime.now(),
                              // );
                              // await viewModel.addCategory(categoryToAdd);
                              // debugPrint(
                              //     'Added category: ${categoryToAdd.name}');
                            } else {
                              // Cập nhật, giữ nguyên thời gian tạo
                              await viewModel.updateCategory(
                                  category.id, newCategory);
                              debugPrint(
                                  'Updated category: ${newCategory.name}');
                            }
                            if (context.mounted) {
                              Navigator.pop(
                                  context); // Đóng dialog sau khi thành công
                            }
                          } catch (e) {
                            debugPrint('Dialog action error: $e');
                            setState(() {
                              errorText = e.toString();
                            });
                          }
                        },
                  child: viewModel.isLoading
                      ? const CircularProgressIndicator()
                      : Text(category == null ? 'Thêm' : 'Lưu'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
