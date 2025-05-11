import 'package:flutter/material.dart';
import 'package:foodapp/data/models/order_model.dart';
import 'package:foodapp/data/models/draft_order_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/viewmodels/cart_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';
import 'dart:convert';
import 'package:foodapp/view/order/order_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  final String userId;

  const OrderHistoryScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<DraftOrderModel> draftOrders = [];
  final _storage = TLocalStorage.instance();

  @override
  void initState() {
    super.initState();
    _loadDraftOrders();
    // Fetch orders when screen loads
    Future.microtask(
        () => context.read<OrderViewModel>().loadUserOrders(widget.userId));
  }

  void _loadDraftOrders() {
    final draftOrdersJson = _storage.readData<String>('draft_orders') ?? '[]';
    final List<dynamic> draftOrdersList = json.decode(draftOrdersJson);
    setState(() {
      draftOrders = draftOrdersList
          .map((json) => DraftOrderModel.fromJson(json))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Lịch sử đơn hàng',
              style: TextStyle(color: Colors.black)),
          backgroundColor: Colors.white,
          elevation: 0.5,
          iconTheme: const IconThemeData(color: Colors.black),
          bottom: const TabBar(
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            tabs: [
              Tab(text: 'Đơn hàng'),
              Tab(text: 'Đơn nháp'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildOrderList(),
            _buildDraftOrderList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDraftOrderList() {
    if (draftOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.drafts_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Không có đơn hàng nháp',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: draftOrders.length,
      itemBuilder: (context, index) {
        final draftOrder = draftOrders[index];
        return _buildDraftOrderCard(draftOrder);
      },
    );
  }

  Widget _buildDraftOrderCard(DraftOrderModel draftOrder) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn nháp #${draftOrder.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Đơn nháp',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Thời gian tạo: ${DateFormat('dd/MM/yyyy HH:mm').format(draftOrder.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ...draftOrder.items.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${item.foodName} x ${item.quantity}',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                      Text(
                        '${(item.price * item.quantity).toStringAsFixed(0)}đ',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${draftOrder.totalAmount.toStringAsFixed(0)}đ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: TColor.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _deleteDraftOrder(draftOrder.id),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Xóa'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _continueDraftOrder(draftOrder),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Tiếp tục'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deleteDraftOrder(String orderId) {
    setState(() {
      draftOrders.removeWhere((order) => order.id == orderId);
      _storage.saveData(
        'draft_orders',
        json.encode(draftOrders.map((order) => order.toJson()).toList()),
      );
    });
  }

  void _continueDraftOrder(DraftOrderModel draftOrder) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Provider.of<OrderViewModel>(context, listen: false),
            ),
            ChangeNotifierProvider.value(
              value: Provider.of<CartViewModel>(context, listen: false),
            ),
          ],
          child: OrderScreen(
            cartItems: draftOrder.items,
            restaurantId: draftOrder.restaurantId,
            totalAmount: draftOrder.totalAmount,
          ),
        ),
      ),
    ).then((_) {
      // Reload draft orders after returning from order screen
      _loadDraftOrders();
    });
  }

  Widget _buildOrderList() {
    return Consumer<OrderViewModel>(
      builder: (context, orderViewModel, child) {
        if (orderViewModel.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (orderViewModel.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: TColor.primary),
                const SizedBox(height: 16),
                Text(
                  'Lỗi: ${orderViewModel.error}',
                  style: const TextStyle(color: Colors.red),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => orderViewModel.loadUserOrders(widget.userId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TColor.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (orderViewModel.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Bạn chưa có đơn hàng nào',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderViewModel.orders.length,
          itemBuilder: (context, index) {
            final order = orderViewModel.orders[index];
            return _buildOrderCard(order);
          },
        );
      },
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Đơn hàng #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                _buildStatusChip(order.status),
              ],
            ),
            const Divider(height: 24),
            Text(
              'Thời gian đặt: ${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Địa chỉ: ${order.address}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 8),
            Text(
              'Phương thức thanh toán: ${_getPaymentMethodName(order.paymentMethod)}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (order.note != null && order.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Ghi chú: ${order.note}',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Tổng tiền:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${order.totalAmount.toStringAsFixed(0)}đ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: TColor.primary,
                  ),
                ),
              ],
            ),
            if (order.status == OrderState.pending) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _showCancelDialog(order.id),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Hủy đơn'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(OrderState status) {
    Color color;
    String text;

    switch (status) {
      case OrderState.pending:
        color = Colors.blue;
        text = 'Đang xử lý';
        break;
      case OrderState.confirmed:
        color = Colors.orange;
        text = 'Đã xác nhận';
        break;
      case OrderState.preparing:
        color = Colors.purple;
        text = 'Đang chuẩn bị';
        break;
      case OrderState.delivering:
        color = Colors.amber;
        text = 'Đang giao';
        break;
      case OrderState.delivered:
        color = Colors.green;
        text = 'Đã giao';
        break;
      case OrderState.cancelled:
        color = Colors.red;
        text = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        text = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.qr:
        return 'Thanh toán QR';
      case PaymentMethod.banking:
        return 'Chuyển khoản ngân hàng';
      case PaymentMethod.momo:
        return 'Ví MoMo';
      case PaymentMethod.zalopay:
        return 'ZaloPay';
      case PaymentMethod.thanhtoankhinhanhang:
        return 'Thanh toán khi nhận hàng';
      default:
        return 'Phương thức thanh toán không xác định';
    }
  }

  Future<void> _showCancelDialog(String orderId) async {
    final reasonController = TextEditingController();
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy đơn hàng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Bạn có chắc chắn muốn hủy đơn hàng này?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Lý do hủy đơn',
                hintText: 'Vui lòng nhập lý do hủy đơn',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Hủy đơn'),
          ),
        ],
      ),
    );

    if (result == true && mounted) {
      try {
        await context
            .read<OrderViewModel>()
            .cancelOrder(orderId, reasonController.text);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đã hủy đơn hàng')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Không thể hủy đơn hàng: $e')),
          );
        }
      }
    }
  }
}
