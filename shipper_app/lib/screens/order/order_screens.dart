import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shipper_app/screens/map/map_screen.dart';
import 'package:shipper_app/screens/order/chat_screen.dart';
import 'package:shipper_app/ultils/const/enum.dart';
import 'package:shipper_app/viewmodels/order_viewmodel.dart';
import 'package:shipper_app/models/order_model.dart';
import 'package:shipper_app/models/cart_item_model.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderViewModel>().checkOrder();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đơn hàng')),
      body: Selector<OrderViewModel, bool>(
        selector: (context, viewModel) => viewModel.isOrder,
        builder: (context, isOrder, child) {
          return isOrder ? const OrderListScreen() : const MapScreen();
        },
      ),
    );
  }
}

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderViewModel>().getShipperOrders(
      FirebaseAuth.instance.currentUser?.uid ?? '',
    );
  }

  @override
  Widget build(BuildContext context) {
    final orders =
        context
            .watch<OrderViewModel>()
            .shipperOrders
            .where((order) => order.idShipper.isNotEmpty)
            .toList();

    if (orders.isEmpty) {
      return const Center(child: Text('Chưa có đơn nào được nhận'));
    }

    return ListView.builder(
      itemCount: orders.length,
      itemBuilder: (context, index) {
        final order = orders[index];
        // Giả sử bạn có các trường: orderTime, address, delivery['address'], totalAmount, phí ship, v.v.
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: Lấy hàng
                Row(
                  children: [
                    const Icon(Icons.store, color: Colors.orange, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Nhà hàng: ${order.restaurantId}   Mã: ${order.id.substring(0, 8)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    'Địa chỉ: ${order.address}',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 8),
                // Giao khách hàng
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 20,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Giao đến',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    order.delivery?['name'] ?? 'User',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    order.delivery?['numberPhone'] ?? '0378635548',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 26),
                  child: Text(
                    order.delivery?['address'] ?? 'Địa chỉ giao hàng',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
                const SizedBox(height: 8),
                // Thời gian còn lại (giả lập)
                Row(
                  children: [
                    const Icon(Icons.timer, color: Colors.blue, size: 18),
                    const SizedBox(width: 4),
                    Text(
                      'còn 33 phút để giao',
                      style: const TextStyle(color: Colors.blue),
                    ),
                  ],
                ),
                const Divider(height: 20),
                // Chi tiết đơn
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Chi tiết đơn',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    TextButton(onPressed: () {}, child: const Text('Xem thêm')),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tổng tiền:',
                      style: TextStyle(color: Colors.black54),
                    ),
                    Text(
                      '${order.totalAmount.toStringAsFixed(0)}đ',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Phí ship (7.1km):',
                      style: TextStyle(color: Colors.black54),
                    ),
                    const Text(
                      '32,500đ',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Nút chuyển bước
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => OrderDetailScreen(order: order),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "ĐẾN BƯỚC HIỆN TẠI",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(
                          vertical: 14,
                          horizontal: 18,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        "Từ chối",
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
}

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;
  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool isdelivered = false;

  @override
  Widget build(BuildContext context) {
    final items = widget.order.items;
    final sweetItems =
        items.where((item) => item.foodName.contains('ngọt')).toList();
    final saltyItems =
        items.where((item) => item.foodName.contains('mặn')).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết đơn hàng'),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Loại đơn, mã đơn, tên quán, địa chỉ, trạng thái, hệ thống nhận đơn
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Delivery - Quán',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.order.id.substring(0, 8),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Text(
                        'Khách hàng',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.order.address,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Text('Trả: 0đ  •  Lấy ngay  •  '),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Quán Tools',
                          style: TextStyle(color: Colors.black87, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            // Ghi chú khách hàng
            if (widget.order.note != null && widget.order.note!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: Colors.orange),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Khách hàng ghi chú\n${widget.order.note}',
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Thời gian còn lại
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Text(
                  'còn 25 phút để giao',
                  style: TextStyle(color: Colors.blue),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Chi tiết đơn hàng
            const Text(
              'Chi tiết đơn hàng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Số lượng: ${items.length}'),
            const SizedBox(height: 8),
            const Text(
              '#Tên món',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            // Món hiện có
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Món hiện có',
                style: TextStyle(color: Colors.orange),
              ),
            ),
            const SizedBox(height: 8),
            // Danh sách món ngọt
            if (sweetItems.isNotEmpty) ...[
              const Text(
                'Xôi ngọt',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...sweetItems.map((item) => _buildItemRow(item)),
            ],
            // Danh sách món mặn
            if (saltyItems.isNotEmpty) ...[
              const Text(
                'Xôi mặn',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              ...saltyItems.map((item) => _buildItemRow(item)),
            ],
            const SizedBox(height: 8),
            // Nút sửa đơn
            Row(
              children: [
                Icon(Icons.edit, color: Colors.orange[700]),
                const SizedBox(width: 6),
                const Text(
                  'Sửa đơn',
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  '(hết món, chỉnh sửa giá)',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Hóa đơn quán
            const Text(
              'Hóa đơn quán',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            _buildBillRow(
              'Tổng đơn hàng',
              '${widget.order.totalAmount.toStringAsFixed(0)}đ',
            ),
            _buildBillRow('Tổng phí ship', '32,500đ'),
            const Divider(height: 24),
            // Nút chức năng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    Icon(Icons.phone, color: Colors.orange[700]),
                    const SizedBox(height: 4),
                    const Text('Điện thoại'),
                  ],
                ),
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => ChatScreen(
                                  orderId: widget.order.id,
                                  recipientId: widget.order.idShipper,
                                ),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Icon(Icons.chat_bubble, color: Colors.orange[700]),
                          const SizedBox(height: 4),
                          const Text('Chat'),
                        ],
                      ),
                    ),
                    // Badge số tin nhắn
                    Positioned(
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '1',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.cancel, color: Colors.grey[700]),
                    const SizedBox(height: 4),
                    const Text('Từ chối'),
                  ],
                ),
                Column(
                  children: [
                    Icon(Icons.info, color: Colors.grey[700]),
                    const SizedBox(height: 4),
                    const Text('Trạng thái'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Nút đã lấy hàng
            SizedBox(
              width: double.infinity,
              child:
                  isdelivered
                      ? ElevatedButton(
                        onPressed: () {
                          context.read<OrderViewModel>().updateOrderStatus(
                            widget.order.id,
                            OrderState.delivering,
                          );
                          setState(() {
                            isdelivered = true;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isdelivered ? Colors.green : Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Đã lấy hàng',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      )
                      : ElevatedButton(
                        onPressed: () {
                          context.read<OrderViewModel>().updateOrderStatus(
                            widget.order.id,
                            OrderState.delivered,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isdelivered ? Colors.green : Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          'Đã giao hàng',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(CartItemModel item) {
    return Row(
      children: [
        Checkbox(value: false, onChanged: (_) {}),
        Expanded(child: Text(item.foodName)),
        Text('${item.quantity}'),
        const SizedBox(width: 8),
        Text('${item.price.toStringAsFixed(0)}đ'),
      ],
    );
  }

  Widget _buildBillRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.black54)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
