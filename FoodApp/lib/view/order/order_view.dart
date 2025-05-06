import 'package:flutter/material.dart';
import 'package:foodapp/data/models/order_model.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/common_widget/grid/food_grid_item.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

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
    _tabController = TabController(length: 4, vsync: this);

    // Tải dữ liệu đơn hàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderViewModel = context.read<OrderViewModel>();
      final userViewModel = context.read<UserViewModel>();

      // Tải danh sách món ăn được đề xuất
      orderViewModel.loadRecommendedFoods();
      orderViewModel.loadUserOrders(userViewModel.currentUser!.id);
      // Nếu người dùng đã đăng nhập, tải đơn hàng
      if (userViewModel.currentUser != null) {
        try {
          print(
              "Bắt đầu tải đơn hàng cho user: ${userViewModel.currentUser!.id}");
          // Sử dụng phương thức Future để lấy tất cả đơn hàng
          orderViewModel.loadUserOrders(userViewModel.currentUser!.id);
        } catch (e) {
          print("Lỗi khi tải đơn hàng: $e");
        }
      } else {
        print("Chưa đăng nhập, không thể tải đơn hàng");
      }
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
            Tab(text: "Đánh giá"),
            Tab(text: "Đơn nháp"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildOngoingOrdersView(),
          _buildOrderHistoryView(),
          _buildEmptyOrderView(),
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
        .where((order) =>
            order.status != OrderState.delivered &&
            order.status != OrderState.cancelled)
        .toList();

    if (ongoingOrders.isEmpty) {
      return _buildEmptyOrderView();
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
    orderViewModel.orders.forEach((order) {
      print("Đơn hàng ${order.id}: trạng thái ${order.status}");
    });

    // Lọc đơn hàng đã hoàn thành - kiểm tra cả enum và chuỗi
    final completedOrders = orderViewModel.orders
        .where((order) =>
            order.status == OrderState.delivered ||
            order.status.toString().toLowerCase() == "delivered")
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

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
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
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    "Bạn sẽ nhìn thấy các món đang được chuẩn bị hoặc giao đi tại đây để kiểm tra đơn hàng nhanh hơn!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
        _buildRecommendationSection(orderViewModel),
      ],
    );
  }

  Widget _buildRecommendationSection(OrderViewModel orderViewModel) {
    return Column(
      mainAxisSize: MainAxisSize.min,
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
        SizedBox(
          height: 230,
          child: orderViewModel.isLoading
              ? const Center(child: CircularProgressIndicator())
              : orderViewModel.recommendedFoods.isEmpty
                  ? const Center(
                      child: Text(
                        "Không có món ăn nào được đề xuất",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      scrollDirection: Axis.horizontal,
                      itemCount: orderViewModel.recommendedFoods.length,
                      itemBuilder: (context, index) {
                        final food = orderViewModel.recommendedFoods[index];
                        return Padding(
                          padding: const EdgeInsets.only(right: 15),
                          child: FoodGridItem(
                            food: food,
                            showButtonAddToCart: true,
                          ),
                        );
                      },
                    ),
        ),
      ],
    );
  }
}
