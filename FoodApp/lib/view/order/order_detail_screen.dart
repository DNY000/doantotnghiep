import 'package:flutter/material.dart';
import 'package:foodapp/data/models/order_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderModel order;

  const OrderDetailScreen({
    Key? key,
    required this.order,
  }) : super(key: key);

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late OrderModel _currentOrder;

  @override
  void initState() {
    super.initState();
    _currentOrder = widget.order;
    // Bắt đầu lắng nghe thay đổi trạng thái đơn hàng
    context.read<OrderViewModel>().listenToOrderStatus(widget.order.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Chi tiết đơn hàng',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: const Color(0xFFED9121),
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 20),
        children: [
          _buildOrderStatusSection(),
          _buildDeliveryInfoSection(),
          _buildRestaurantAndFoodSection(),
          _buildPaymentDetailsSection(),
          if (widget.order.note?.isNotEmpty ?? false) _buildNoteSection(),
          if (widget.order.cancelReason?.isNotEmpty ?? false)
            _buildCancelReasonSection(),
          if (widget.order.status == OrderState.delivered)
            ElevatedButton(
                onPressed: () {}, child: const Text('đánh giá sản phẩm '))
        ],
      ),
    );
  }

  Widget _buildOrderStatusSection() {
    late Color statusColor;
    late String statusText;

    switch (widget.order.status) {
      case OrderState.pending:
        statusColor = Colors.orange;
        statusText = 'Chờ xác nhận';
        break;
      case OrderState.confirmed:
        statusColor = Colors.blue;
        statusText = 'Đã xác nhận';
        break;
      case OrderState.preparing:
        statusColor = Colors.purple;
        statusText = 'Đang chuẩn bị';
        break;
      case OrderState.waitingForShipper:
        statusColor = Colors.indigo;
        statusText = 'Chờ shipper nhận';
        break;
      case OrderState.shipperAssigned:
        statusColor = Colors.amber;
        statusText = 'Shipper đã nhận đơn';
        break;
      case OrderState.delivering:
        statusColor = Colors.amber;
        statusText = 'Đang giao hàng';
        break;
      case OrderState.delivered:
        statusColor = Colors.green;
        statusText = 'Đã giao hàng';
        break;
      case OrderState.cancelled:
        statusColor = Colors.red;
        statusText = 'Đã hủy';
        break;
      case OrderState.ready:
        statusColor = Colors.cyan;
        statusText = 'Sẵn sàng giao hàng';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: statusColor),
              const SizedBox(width: 8),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Đơn hàng #${widget.order.id.substring(0, 8)}',
            style: const TextStyle(color: Colors.black54),
          ),
          Text(
            'Đặt lúc: ${DateFormat('HH:mm dd/MM/yyyy').format(widget.order.createdAt)}',
            style: const TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfoSection() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.location_on_outlined, color: Colors.black54),
              SizedBox(width: 8),
              Text(
                'Thông tin giao hàng',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            widget.order.address,
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 8),
          const Divider(),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payment_outlined, color: Colors.black54),
              const SizedBox(width: 8),
              Text(
                'Thanh toán: ${_getPaymentMethodText(widget.order.paymentMethod)}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantAndFoodSection() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Icon(Icons.store, color: Colors.black54),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.order.restaurantName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.order.items.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = widget.order.items[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: _buildFoodImage(item.image),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.foodName,
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${item.price.toStringAsFixed(0)}đ',
                              style: TextStyle(
                                color: TColor.color3,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Text('x${item.quantity}'),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentDetailsSection() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Chi tiết thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildPaymentRow(
              'Tổng giá món (${widget.order.items.length} món)',
              '${widget.order.totalPrice.toStringAsFixed(0)}đ',
            ),
            _buildPaymentRow(
              'Phí giao hàng',
              '${(widget.order.totalAmount - widget.order.totalPrice).toStringAsFixed(0)}đ',
            ),
            const Divider(),
            _buildPaymentRow(
              'Tổng thanh toán',
              '${widget.order.totalAmount.toStringAsFixed(0)}đ',
              isTotal: true,
            ),
            const Text(
              'Đã bao gồm thuế',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.note_outlined, color: Colors.black54),
                SizedBox(width: 8),
                Text(
                  'Ghi chú',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.order.note!,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelReasonSection() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.cancel_outlined, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Lý do hủy đơn',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.order.cancelReason!,
              style: const TextStyle(fontSize: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String title, String amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: isTotal ? Colors.black : Colors.grey[600],
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              color: isTotal ? TColor.color3 : Colors.black,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodImage(String imageUrl) {
    if (imageUrl.startsWith('assets/') ||
        imageUrl.startsWith('file:///assets/')) {
      final assetPath = imageUrl.replaceFirst('file:///', '');
      return Image.asset(
        assetPath,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    } else {
      return Image.network(
        imageUrl,
        width: 60,
        height: 60,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            width: 60,
            height: 60,
            color: Colors.grey[300],
            child: const Icon(Icons.error),
          );
        },
      );
    }
  }

  String _getPaymentMethodText(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.thanhtoankhinhanhang:
        return 'Thanh toán khi nhận hàng';
      case PaymentMethod.qr:
        return 'Thanh toán VNPay';
      default:
        return 'Không xác định';
    }
  }
}
