import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/restaurant_viewmodel.dart';
import 'package:admin/models/restaurant_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:admin/screens/restaurant/restaurant_detail_screen.dart';

class RestaurantScreen extends StatelessWidget {
  const RestaurantScreen({super.key});

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
                child: RestaurantContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RestaurantContent extends StatefulWidget {
  const RestaurantContent({super.key});

  @override
  State<RestaurantContent> createState() => _RestaurantContentState();
}

class _RestaurantContentState extends State<RestaurantContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<RestaurantViewModel>().loadRestaurants(),
    );
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
              'Quản lý Nhà hàng',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to add restaurant screen
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Nhà hàng'),
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
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm nhà hàng...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            // Có thể thêm filter theo danh mục ở đây nếu muốn
          ],
        ),
        const SizedBox(height: 24),

        // Restaurant list
        Expanded(
          child: Consumer<RestaurantViewModel>(
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
                        onPressed: () => viewModel.loadRestaurants(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              var filteredRestaurants = viewModel.restaurants;

              // Apply search filter
              if (_searchController.text.isNotEmpty) {
                filteredRestaurants = viewModel.searchRestaurants(
                  _searchController.text,
                );
              }

              if (filteredRestaurants.isEmpty) {
                return const Center(child: Text('Không tìm thấy nhà hàng nào'));
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredRestaurants, viewModel)
                  : _buildMobileView(filteredRestaurants, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(
    List<RestaurantModel> restaurants,
    RestaurantViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Ảnh')), // Main image
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Địa chỉ')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: restaurants.map((restaurant) {
          return DataRow(
            cells: [
              DataCell(
                CircleAvatar(
                  backgroundImage: restaurant.mainImage.isNotEmpty
                      ? NetworkImage(restaurant.mainImage)
                      : null,
                  child: restaurant.mainImage.isEmpty
                      ? const Icon(Icons.restaurant)
                      : null,
                ),
              ),
              DataCell(Text(restaurant.name)),
              DataCell(Text(restaurant.address)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: restaurant.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    restaurant.isActive ? 'Đang hoạt động' : 'Ngừng hoạt động',
                    style: TextStyle(
                      color: restaurant.isActive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // TODO: Navigate to edit screen
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
                              'Bạn có chắc muốn xóa nhà hàng ${restaurant.name}?',
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
                        // TODO: Xử lý xóa nhà hàng nếu cần
                      },
                    ),
                  ],
                ),
              ),
            ],
            onSelectChanged: (selected) {
              if (selected == true) {
                context.go('/restaurant/${restaurant.id}');
              }
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileView(
    List<RestaurantModel> restaurants,
    RestaurantViewModel viewModel,
  ) {
    return ListView.builder(
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RestaurantDetailScreen(restaurantId: restaurant.id),
              ),
            );
          },
          child: Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: restaurant.mainImage.isNotEmpty
                            ? NetworkImage(restaurant.mainImage)
                            : null,
                        child: restaurant.mainImage.isEmpty
                            ? const Icon(Icons.restaurant)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              restaurant.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(restaurant.address),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: restaurant.isActive
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurant.isActive
                              ? 'Đang hoạt động'
                              : 'Ngừng hoạt động',
                          style: TextStyle(
                            color:
                                restaurant.isActive ? Colors.green : Colors.red,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // TODO: Navigate to edit screen
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
                                    'Bạn có chắc muốn xóa nhà hàng ${restaurant.name}?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, false),
                                      child: const Text('Hủy'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, true),
                                      child: const Text('Xóa'),
                                    ),
                                  ],
                                ),
                              );
                              // TODO: Xử lý xóa nhà hàng nếu cần
                            },
                          ),
                        ],
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
  }
}
