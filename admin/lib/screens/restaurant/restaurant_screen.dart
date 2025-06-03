import 'package:flutter/material.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/restaurant_viewmodel.dart';
import 'package:admin/models/restaurant_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:admin/screens/restaurant/restaurant_detail_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:typed_data';

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
  Uint8List? imageBytes;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context.read<RestaurantViewModel>().loadRestaurants();
      },
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
                _showAddRestaurantDialog(context);
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
                  margin: const EdgeInsets.symmetric(
                    vertical: 8,
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 1),
                  decoration: BoxDecoration(
                    color: restaurant.isActive ? Colors.green : Colors.grey,
                    // ,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    restaurant.isActive ? 'Đang hoạt động' : 'Ngừng hoạt động',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                    textAlign: TextAlign.center,
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
                        _showEditRestaurantDialog(context, restaurant);
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

                        if (confirmed == true) {
                          await viewModel.deleteRestaurant(restaurant.id);
                          await viewModel.loadRestaurants();
                        }
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
                          color:
                              restaurant.isActive ? Colors.green : Colors.grey,
                          // restaurant.isActive ? Colors.green : Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurant.isActive
                              ? 'Đang hoạt động'
                              : 'Ngừng hoạt động',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditRestaurantDialog(context, restaurant);
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

                              if (confirmed == true) {
                                await viewModel.deleteRestaurant(restaurant.id);
                                await viewModel.loadRestaurants();
                              }
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

  void _showAddRestaurantDialog(BuildContext context) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final descriptionController = TextEditingController();
    TimeOfDay openTime = const TimeOfDay(hour: 0, minute: 0);
    TimeOfDay closeTime = const TimeOfDay(hour: 0, minute: 0);

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
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.height * 0.8,
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
                            'Thêm Nhà Hàng Mới',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Tên nhà hàng
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên nhà hàng *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Địa chỉ
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ *',
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
                      // Ảnh
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
                            label: const Text('Chọn ảnh'),
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
                      // Giờ mở cửa
                      const Text('Giờ mở cửa',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TimePickerSpinner(
                        is24HourMode: true,
                        normalTextStyle:
                            TextStyle(fontSize: 18, color: Colors.white60),
                        highlightedTextStyle: const TextStyle(
                            fontSize: 22, color: Colors.blueAccent),
                        spacing: 30,
                        itemHeight: 40,
                        isForce2Digits: true,
                        time: DateTime(0, 0, 0, openTime.hour, openTime.minute),
                        onTimeChange: (time) {
                          setState(() {
                            openTime =
                                TimeOfDay(hour: time.hour, minute: time.minute);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Giờ đóng cửa
                      const Text('Giờ đóng cửa',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TimePickerSpinner(
                        is24HourMode: true,
                        normalTextStyle:
                            TextStyle(fontSize: 18, color: Colors.white60),
                        highlightedTextStyle: const TextStyle(
                            fontSize: 22, color: Colors.blueAccent),
                        spacing: 30,
                        itemHeight: 40,
                        isForce2Digits: true,
                        time:
                            DateTime(0, 0, 0, closeTime.hour, closeTime.minute),
                        onTimeChange: (time) {
                          setState(() {
                            closeTime =
                                TimeOfDay(hour: time.hour, minute: time.minute);
                          });
                        },
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
                            onPressed: () {
                              _addRestaurant(
                                context,
                                nameController.text,
                                addressController.text,
                                descriptionController.text,
                                imageBytes,
                                openTime.format(context),
                                closeTime.format(context),
                              );
                            },
                            child: const Text('Thêm nhà hàng'),
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

  void _addRestaurant(
    BuildContext context,
    String name,
    String address,
    String description,
    Uint8List? imageBytes,
    String openTime,
    String closeTime,
  ) async {
    if (name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin bắt buộc')),
      );
      return;
    }

    final viewModel = Provider.of<RestaurantViewModel>(context, listen: false);
    String imageUrl = '';
    // Nếu bạn muốn upload ảnh lên server, hãy upload ở đây và lấy URL
    // imageUrl = await uploadImageToServer(imageBytes);

    final newRestaurant = RestaurantModel(
      id: '',
      name: name,
      description: description,
      address: address,
      location: const GeoPoint(0, 0),
      operatingHours: {
        'openTime': openTime,
        'closeTime': closeTime,
      },
      rating: 0.0,
      images: {
        'main': imageUrl,
        'gallery': [],
      },
      status: 'open',
      minOrderAmount: 0.0,
      createdAt: DateTime.now(),
      categories: [],
      metadata: {
        'isActive': true,
        'isVerified': false,
        'lastUpdated': Timestamp.now(),
      },
    );

    try {
      await viewModel.addRestaurant(newRestaurant);
      await viewModel.loadRestaurants();
      if (context.mounted) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thêm nhà hàng thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  void _showEditRestaurantDialog(
      BuildContext context, RestaurantModel restaurant) {
    final nameController = TextEditingController(text: restaurant.name);
    final addressController = TextEditingController(text: restaurant.address);
    final descriptionController =
        TextEditingController(text: restaurant.description);
    Uint8List? imageBytes;
    String? imageUrl = restaurant.mainImage;
    TimeOfDay openTime = _parseTimeOfDay(restaurant.openTime);
    TimeOfDay closeTime = _parseTimeOfDay(restaurant.closeTime);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.6,
                width: MediaQuery.of(context).size.width * 0.5,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Sửa Nhà Hàng',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Tên nhà hàng
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Tên nhà hàng *',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Địa chỉ
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Địa chỉ *',
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
                      // Ảnh
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
                                  imageUrl = null;
                                });
                              }
                            },
                            icon: const Icon(Icons.image),
                            label: const Text('Chọn ảnh'),
                          ),
                          const SizedBox(width: 12),
                          imageBytes != null
                              ? Image.memory(
                                  imageBytes!,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                )
                              : (imageUrl != null && imageUrl!.isNotEmpty)
                                  ? Image.network(
                                      imageUrl!,
                                      width: 60,
                                      height: 60,
                                      fit: BoxFit.cover,
                                    )
                                  : const Text('Chưa chọn ảnh'),
                        ],
                      ),
                      const SizedBox(height: 16),
                      // Giờ mở cửa
                      const Text('Giờ mở cửa',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TimePickerSpinner(
                        is24HourMode: true,
                        normalTextStyle:
                            TextStyle(fontSize: 18, color: Colors.white60),
                        highlightedTextStyle: const TextStyle(
                            fontSize: 22, color: Colors.blueAccent),
                        spacing: 30,
                        itemHeight: 40,
                        isForce2Digits: true,
                        time: DateTime(0, 0, 0, openTime.hour, openTime.minute),
                        onTimeChange: (time) {
                          setState(() {
                            openTime =
                                TimeOfDay(hour: time.hour, minute: time.minute);
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      // Giờ đóng cửa
                      const Text('Giờ đóng cửa',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                      TimePickerSpinner(
                        is24HourMode: true,
                        normalTextStyle:
                            TextStyle(fontSize: 18, color: Colors.white60),
                        highlightedTextStyle: const TextStyle(
                            fontSize: 22, color: Colors.blueAccent),
                        spacing: 30,
                        itemHeight: 40,
                        isForce2Digits: true,
                        time:
                            DateTime(0, 0, 0, closeTime.hour, closeTime.minute),
                        onTimeChange: (time) {
                          setState(() {
                            closeTime =
                                TimeOfDay(hour: time.hour, minute: time.minute);
                          });
                        },
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
                            onPressed: () {
                              _updateRestaurant(
                                context,
                                restaurant,
                                nameController.text,
                                addressController.text,
                                descriptionController.text,
                                imageBytes,
                                imageUrl,
                                openTime.format(context),
                                closeTime.format(context),
                              );
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

  TimeOfDay _parseTimeOfDay(String time) {
    final parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  void _updateRestaurant(
    BuildContext context,
    RestaurantModel oldRestaurant,
    String name,
    String address,
    String description,
    Uint8List? imageBytes,
    String? imageUrl,
    String openTime,
    String closeTime,
  ) async {
    if (name.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Vui lòng điền đầy đủ thông tin bắt buộc')),
      );
      return;
    }

    final viewModel = Provider.of<RestaurantViewModel>(context, listen: false);
    String mainImage = imageUrl ?? oldRestaurant.mainImage;
    // Nếu bạn muốn upload ảnh lên server, hãy upload ở đây và lấy URL
    // mainImage = await uploadImageToServer(imageBytes);

    final updatedRestaurant = oldRestaurant.copyWith(
      name: name,
      address: address,
      description: description,
      images: {
        ...oldRestaurant.images,
        'main': mainImage,
      },
      operatingHours: {
        'openTime': openTime,
        'closeTime': closeTime,
      },
    );

    try {
      await viewModel.updateRestaurant(updatedRestaurant);
      await viewModel.loadRestaurants();
      if (context.mounted) {
        Navigator.pop(context);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cập nhật nhà hàng thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }
}
