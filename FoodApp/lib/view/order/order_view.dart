import 'package:flutter/material.dart';
import 'package:foodapp/data/models/order_model.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/view/restaurant/single_food_detail.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/common_widget/grid/food_grid_item.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'dart:convert';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userViewModel = context.read<UserViewModel>();
      final orderViewModel = context.read<OrderViewModel>();

      // Đảm bảo user đã load xong
      if (userViewModel.currentUser == null) {
        await userViewModel.loadCurrentUser();
      }
      if (userViewModel.currentUser != null) {
        print(
            "Bắt đầu tải đơn hàng cho user: ${userViewModel.currentUser!.id}");
        orderViewModel.loadUserOrders(userViewModel.currentUser!.id);
      } else {
        print("Chưa đăng nhập, không thể tải đơn hàng");
      }
      orderViewModel.loadRecommendedFoods();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đơn hàng",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {},
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: TColor.color3,
          labelColor: TColor.color3,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold),
          tabs: const [
            Tab(text: "Đang đến"),
            Tab(text: "Lịch sử"),
            // Tab(text: "Đánh giá"),
            Tab(text: "Đơn nháp"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOngoingOrdersView(),
          _buildOrderHistoryView(),
          // _buildEmptyOrderView(),
          _buildEmptyOrderView(),
        ],
      ),
    );
  }

  // Hiển thị đơn hàng đang giao
  Widget _buildOngoingOrdersView() {
    final orderViewModel = context.watch<OrderViewModel>();

    // Lọc các đơn hàng đang giao (chưa hoàn thành)
    final ongoingOrders = orderViewModel.orders
        .where((order) => order.status != OrderState.delivered)
        .toList();
    print("Đơn hàng đang giao: ${ongoingOrders.length}");
    for (var order in ongoingOrders) {
      print("Đơn hàng ${order.id}:");
      print("  - Thời gian: ${order.createdAt}");
      print("  - Trạng thái: ${order.status}");
      print("  - Tổng tiền: ${order.totalAmount}đ");
      print("  - Món:");
    }
    if (ongoingOrders.isEmpty) {
      return SingleChildScrollView(
        child: Column(
          children: [
            Icon(
              Icons.receipt_long,
              size: 120,
              color: TColor.color3,
            ),
            const SizedBox(height: 20),
            const Text(
              "Chưa có đơn hàng nào đang giao",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildRecommendationSection(orderViewModel),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: ongoingOrders.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = ongoingOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  // Hiển thị lịch sử đơn hàng đã hoàn thành
  Widget _buildOrderHistoryView() {
    final orderViewModel = context.watch<OrderViewModel>();

    if (orderViewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // In log để debug
    print("Tổng số đơn hàng: ${orderViewModel.orders.length}");
    for (var order in orderViewModel.orders) {
      print("Đơn hàng ${order.id}: trạng thái ${order.status}");
    }

    // Lọc đơn hàng đã hoàn thành - kiểm tra cả enum và chuỗi
    final completedOrders = orderViewModel.orders
        .where((order) => order.status == OrderState.delivered)
        .toList();

    print("Số đơn hàng đã hoàn thành: ${completedOrders.length}");

    if (completedOrders.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            "Chưa có lịch sử đơn hàng",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 10),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Các đơn hàng đã hoàn thành sẽ hiển thị ở đây. Hiện tại bạn chưa có đơn hàng nào đã hoàn thành.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: completedOrders.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final order = completedOrders[index];
        return _buildOrderCard(order);
      },
    );
  }

  // Widget để hiển thị thông tin một đơn hàng
  Widget _buildOrderCard(OrderModel order) {
    // Lấy thông tin nhà hàng từ đơn hàng
    final restaurantName =
        "Nhà hàng #${order.restaurantId}"; // Có thể thay bằng tên thật từ DB

    // Tạo mô tả các món trong đơn hàng
    final itemsDescription = order.items.isNotEmpty
        ? "${order.items.first.foodName} ${order.items.length > 1 ? 'và ${order.items.length - 1} món khác' : ''}"
        : "Không có món";

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: Colors.white,
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  restaurantName,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              "Món: $itemsDescription",
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              "Tổng tiền: ${order.totalAmount.toStringAsFixed(0)}đ",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Ngày đặt: ${_formatDateTime(order.createdAt)}",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            if (order.status == OrderState.delivered ||
                order.status.toString().toLowerCase() == "delivered")
              OutlinedButton(
                onPressed: () {
                  // Xử lý đánh giá đơn hàng
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: TColor.color3,
                ),
                child: const Text("Đánh giá đơn hàng"),
              ),
          ],
        ),
      ),
    );
  }

  // Hiển thị trạng thái đơn hàng
  Widget _buildStatusChip(dynamic status) {
    Color color;
    String label;

    // Chuyển đổi status về string để xử lý đồng nhất
    String statusStr = status.toString().toLowerCase();

    if (statusStr.contains("pending") || statusStr == "pending") {
      color = Colors.orange;
      label = "Đang xử lý";
    } else if (statusStr.contains("confirmed") || statusStr == "confirmed") {
      color = Colors.blue;
      label = "Đã xác nhận";
    } else if (statusStr.contains("preparing") || statusStr == "preparing") {
      color = Colors.amber;
      label = "Đang chuẩn bị";
    } else if (statusStr.contains("ready") || statusStr == "ready") {
      color = Colors.cyan;
      label = "Sẵn sàng giao";
    } else if (statusStr.contains("delivering") || statusStr == "delivering") {
      color = Colors.indigo;
      label = "Đang giao";
    } else if (statusStr.contains("delivered") || statusStr == "delivered") {
      color = Colors.orange;
      label = "Đã giao";
    } else if (statusStr.contains("cancelled") || statusStr == "cancelled") {
      color = Colors.red;
      label = "Đã hủy";
    } else {
      color = Colors.grey;
      label = "Không xác định";
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Định dạng thời gian
  String _formatDateTime(DateTime dateTime) {
    return "${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute}";
  }

  Widget _buildEmptyOrderView() {
    final orderViewModel = context.watch<OrderViewModel>();

    return SingleChildScrollView(
      child: Column(
        children: [
          FutureBuilder<List<String>>(
            future: getDraftOrderIds(),
            builder: (context, idSnapshot) {
              if (!idSnapshot.hasData) {
                return Column(
                  children: [
                    Icon(
                      Icons.receipt_long,
                      size: 120,
                      color: TColor.color3,
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      "Quên chưa đặt món rồi nè bạn ơi?",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                );
              }
              final ids = idSnapshot.data!;
              return FutureBuilder<Map<String, List<CartItemModel>>>(
                future: loadAllDraftOrders(ids),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (snapshot.hasData &&
                      snapshot.data!.values.any((list) => list.isNotEmpty)) {
                    return Column(
                      children: snapshot.data!.entries
                          .where((entry) => entry.value.isNotEmpty)
                          .map((entry) {
                        final restaurantId = entry.key;
                        final items = entry.value;
                        return Card(
                          child: ListTile(
                            title: Text('Đơn nháp nhà hàng $restaurantId'),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: items
                                  .map((item) => Text(
                                      '${item.foodName} x${item.quantity}'))
                                  .toList(),
                            ),
                            trailing: Text(
                              '${items.fold<double>(0, (sum, item) => sum + item.price * item.quantity).toInt()}đ',
                              style: TextStyle(color: Colors.orange),
                            ),
                            onTap: () {
                              // Xử lý: load lại đơn nháp này vào giỏ hàng để tiếp tục đặt
                            },
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const Text('Không có đơn nháp nào');
                },
              );
            },
          ),
          _buildRecommendationSection(orderViewModel),
        ],
      ),
    );
  }

  Widget _buildRecommendationSection(OrderViewModel orderViewModel) {
    return Column(
      children: [
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text(
            "Có thể bạn cũng thích",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
        orderViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderViewModel.recommendedFoods.isEmpty
                ? const Center(
                    child: Text(
                      "Không có món ăn nào được đề xuất",
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    scrollDirection: Axis.vertical,
                    // physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: orderViewModel.recommendedFoods.length,
                    itemBuilder: (context, index) {
                      final food = orderViewModel.recommendedFoods[index];
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SingleFoodDetail(
                                foodItem: food,
                                restaurantId: food.restaurantId,
                              ),
                            ),
                          );
                        },
                        child: FoodListItem(
                          food: food,
                          showButtonAddToCart: true,
                        ),
                      );
                    },
                  ),
      ],
    );
  }

  Future<List<String>> getDraftOrderIds() async {
    final storage = TLocalStorage.instance();
    return storage.readData<List<dynamic>>('cart_backup_ids')?.cast<String>() ??
        [];
  }

  Future<Map<String, List<CartItemModel>>> loadAllDraftOrders(
      List<String> restaurantIds) async {
    final storage = TLocalStorage.instance();
    Map<String, List<CartItemModel>> draftOrders = {};

    for (final id in restaurantIds) {
      final cartJson = storage.readData('cart_backup_$id');
      if (cartJson != null) {
        List<dynamic> cartList;
        if (cartJson is String) {
          cartList = jsonDecode(cartJson);
        } else if (cartJson is List) {
          cartList = cartJson;
        } else {
          continue;
        }
        draftOrders[id] =
            cartList.map((e) => CartItemModel.fromMap(e)).toList();
      }
    }
    return draftOrders;
  }
}
