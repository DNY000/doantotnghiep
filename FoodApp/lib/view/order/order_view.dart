import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/card/t_card.dart';
import 'package:foodapp/data/models/order_model.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/view/order/order_screen.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'dart:convert';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';
import 'package:foodapp/view/order/order_detail_screen.dart';

class OrderView extends StatefulWidget {
  const OrderView({super.key});

  @override
  State<OrderView> createState() => _OrderViewState();
}

class _OrderViewState extends State<OrderView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeTabController();
  }

  void _initializeTabController() {
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
    _isControllerInitialized = true;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final userViewModel = context.read<UserViewModel>();
      final orderViewModel = context.read<OrderViewModel>();

      // Đảm bảo user đã load xong
      if (userViewModel.currentUser == null) {
        await userViewModel.loadCurrentUser();
      }
      if (userViewModel.currentUser != null) {
        orderViewModel.loadUserOrders(userViewModel.currentUser!.id);
      }
      orderViewModel.loadRecommendedFoods();
    });
  }

  @override
  void dispose() {
    if (_isControllerInitialized) {
      _tabController.removeListener(() {});
      _tabController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isControllerInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Đơn hàng",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
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
    Future.delayed(Duration(seconds: 3));
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

    // Lọc đơn hàng đã hoàn thành - kiểm tra cả enum và chuỗi
    final completedOrders = orderViewModel.orders
        .where((order) => order.status == OrderState.delivered)
        .toList();

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
              "Hiện tại bạn chưa có đơn hàng nào đã hoàn thành.",
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
      // padding: const EdgeInsets.all(16),
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
        "Nhà hàng #${order.restaurantName}"; // Có thể thay bằng tên thật từ DB

    // Tạo mô tả các món trong đơn hàng
    final itemsDescription = order.items.isNotEmpty
        ? "${order.items.first.foodName} ${order.items.length > 1 ? 'và ${order.items.length - 1} món khác' : ''}"
        : "Không có món";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(
              order: order,
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 8, left: 12, right: 12, top: 8),
        color: Colors.white,
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    restaurantName,
                    style: const TextStyle(
                      fontWeight: FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(order.status),
                ],
              ),
              // const Divider(height: 1),
              Row(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                      flex: 2,
                      child: order.items.isNotEmpty
                          ? ClipRRect(
                              borderRadius:
                                  const BorderRadius.all(Radius.circular(4)),
                              child: Image.asset(
                                (order.items.first.image != null &&
                                        order.items.first.image.isNotEmpty)
                                    ? order.items.first.image
                                    : 'assets/img/placeholder.png',
                                fit: BoxFit.cover,
                              ),
                            )
                          : Container(
                              width: 60,
                              height: 60,
                              color: Colors.grey[300],
                              child: const Icon(Icons.fastfood),
                            )),
                  const SizedBox(width: 24),
                  Expanded(
                      flex: 5,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
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
                        ],
                      ))
                ],
              ),
              // const SizedBox(height: 12),
              // if (order.status == OrderState.delivered ||
              //     order.status.toString().toLowerCase() == "delivered")
              //   TextButton(
              //     onPressed: () {
              //       // Xử lý đánh giá đơn hàng
              //     },
              //     child: const Text("Đánh giá đơn hàng",
              //         style: TextStyle(color: Colors.black)),
              //   ),
            ],
          ),
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
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
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
                        final totalAmount = items.fold<double>(
                            0, (sum, item) => sum + item.price * item.quantity);

                        return Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => OrderScreen(
                                      restaurantId: restaurantId,
                                      cartItems: items,
                                      totalAmount: totalAmount,
                                    ),
                                  ),
                                );
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(12),
                                child: Row(
                                  children: [
                                    // Phần ảnh
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Stack(
                                        children: [
                                          Image.asset(
                                            (items.isNotEmpty &&
                                                    items.first.image != null &&
                                                    items
                                                        .first.image.isNotEmpty)
                                                ? items.first.image
                                                : 'assets/img/placeholder.png',
                                            width: 80,
                                            height: 80,
                                            fit: BoxFit.cover,
                                          ),
                                          if (items.length > 1)
                                            Positioned(
                                              right: 0,
                                              bottom: 0,
                                              child: Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 6,
                                                  vertical: 2,
                                                ),
                                                decoration: const BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft: Radius.circular(8),
                                                  ),
                                                ),
                                                child: Text(
                                                  '+${items.length - 1}',
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    // Phần thông tin
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            ' Nhà hàng $restaurantId',
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${items.length} món',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            items
                                                .map((item) =>
                                                    '${item.foodName} x${item.quantity}')
                                                .join(', '),
                                            style: const TextStyle(
                                              fontSize: 13,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Phần giá
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${totalAmount.toInt()}đ',
                                          style: TextStyle(
                                            color: Colors.orange[700],
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.orange,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                          child: const Text(
                                            'Tiếp tục',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }
                  return const Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(children: [
                      Icon(
                        Icons.restaurant,
                        size: 80,
                      ),
                      Text(
                        'Giỏ hàng trống',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                    ]),
                  );
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
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(Icons.restaurant_menu, size: 20, color: Colors.grey[700]),
              const SizedBox(width: 8),
              Text(
                "Có thể bạn cũng thích",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[700],
                ),
              ),
            ],
          ),
        ),
        orderViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : orderViewModel.recommendedFoods.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      child: Text(
                        "Không có món ăn nào được đề xuất",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  )
                : FoodListView(
                    foods: orderViewModel.recommendedFoods,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                  )
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
