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
      // Add AppBar for mobile view with menu icon
      appBar: Responsive.isMobile(context)
          ? AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu), // Menu icon
                  onPressed: () {
                    Scaffold.of(context).openDrawer(); // Open the drawer
                  },
                ),
              ),
              title: Text('Quản lý Nhà hàng',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)), // Title
              backgroundColor: Theme.of(context)
                  .scaffoldBackgroundColor, // Match background color
              elevation: 0, // Remove shadow
            )
          : null, // No AppBar on desktop
      // Use SideMenu as a drawer on mobile
      drawer: Responsive.isMobile(context) ? const SideMenu() : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // SideMenu is only shown directly in the Row on desktop
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
        // Header section - Adjusted for mobile
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hide the title on mobile because it's in the AppBar
            if (!Responsive.isMobile(context))
              Text(
                'Quản lý Nhà hàng',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium, // Changed style for consistency
              ),
            // Keep spacing between title/add button, adjust based on mobile/desktop
            SizedBox(
                width: Responsive.isMobile(context)
                    ? 0
                    : 16), // Reduced spacing on mobile
            ElevatedButton.icon(
              onPressed: () {
                _showAddRestaurantDialog(context);
              },
              icon: const Icon(Icons.add),
              label: const Text('Thêm Nhà hàng'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24), // Spacing after header row

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
          DataColumn(label: Text('Ảnh')),
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
                  padding: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal:
                          8), // Adjusted horizontal padding for better look
                  decoration: BoxDecoration(
                    color: restaurant.isActive ? Colors.green : Colors.grey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    restaurant.isActive ? 'Đang hoạt động' : 'Ngừng hoạt động',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12), // Adjusted font size slightly
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
            margin: const EdgeInsets.only(
                bottom: 16), // Keep bottom margin for spacing between cards
            child: Padding(
              padding: const EdgeInsets.all(12), // Adjusted padding inside card
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                fontSize: 17, // Adjusted font size slightly
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(restaurant.address,
                                maxLines: 2, overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                      height: 12), // Adjusted spacing after image/name row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10, // Adjusted horizontal padding
                          vertical: 5, // Adjusted vertical padding
                        ),
                        decoration: BoxDecoration(
                          color:
                              restaurant.isActive ? Colors.green : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          restaurant.isActive
                              ? 'Đang hoạt động'
                              : 'Ngừng hoạt động',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11, // Adjusted font size
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
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width * 0.9
                    : MediaQuery.of(context).size.width *
                        0.7, // Adjusted width for mobile
                height: MediaQuery.of(context).size.height * 0.8,
                padding: const EdgeInsets.all(20), // Adjusted padding
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Use min size
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align content to start
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
                        normalTextStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white60), // Adjusted style
                        highlightedTextStyle: const TextStyle(
                            fontSize: 22,
                            color: Colors.blueAccent), // Adjusted style
                        spacing: 30,
                        itemHeight: 40,
                        isForce2Digits: true,
                        time: DateTime(0, 0, 0, openTime.hour,
                            openTime.minute), // Corrected time initialization
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
                        normalTextStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white60), // Adjusted style
                        highlightedTextStyle: const TextStyle(
                            fontSize: 22,
                            color: Colors.blueAccent), // Adjusted style
                        spacing: 30,
                        itemHeight: 40,
                        isForce2Digits: true,
                        time: DateTime(0, 0, 0, closeTime.hour,
                            closeTime.minute), // Corrected time initialization
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
                                openTime.format(
                                    context), // Pass formatted time string
                                closeTime.format(
                                    context), // Pass formatted time string
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
    TimeOfDay openTime =
        _parseTimeOfDay(restaurant.operatingHours['openTime'] ?? '00:00');
    TimeOfDay closeTime =
        _parseTimeOfDay(restaurant.operatingHours['closeTime'] ?? '00:00');

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
                height: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.height * 0.7
                    : MediaQuery.of(context).size.height *
                        0.6, // Adjusted height for mobile
                width: Responsive.isMobile(context)
                    ? MediaQuery.of(context).size.width * 0.9
                    : MediaQuery.of(context).size.width *
                        0.5, // Adjusted width for mobile
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Use min size
                    crossAxisAlignment:
                        CrossAxisAlignment.start, // Align content to start
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Chỉnh sửa Nhà Hàng',
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
                        normalTextStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white60), // Adjusted style
                        highlightedTextStyle: const TextStyle(
                            fontSize: 22,
                            color: Colors.blueAccent), // Adjusted style
                        spacing: 30,
                        itemHeight: 40,
                        isForce2Digits: true,
                        time: DateTime(0, 0, 0, openTime.hour,
                            openTime.minute), // Corrected time initialization
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
                        normalTextStyle: TextStyle(
                            fontSize: 18,
                            color: Colors.white60), // Adjusted style
                        highlightedTextStyle: const TextStyle(
                            fontSize: 22,
                            color: Colors.blueAccent), // Adjusted style
                        spacing: 30,
                        itemHeight: 40,
                        isForce2Digits: true,
                        time: DateTime(0, 0, 0, closeTime.hour,
                            closeTime.minute), // Corrected time initialization
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
                                restaurant.images['main'],
                                openTime.format(
                                    context), // Pass formatted time string
                                closeTime.format(
                                    context), // Pass formatted time string
                              );
                            },
                            child: const Text('Cập nhật nhà hàng'),
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
    // Add basic error handling for parsing
    try {
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      // Print error and return a default value
      debugPrint('Error parsing time string: $time, $e');
      return TimeOfDay.now(); // Or TimeOfDay(0, 0) as a default
    }
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
