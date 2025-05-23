import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:foodapp/data/models/user_model.dart';
import 'package:foodapp/routes/name_router.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/core/services/webview.dart';
import 'package:go_router/go_router.dart';
import 'package:foodapp/data/models/order_model.dart';

class OrderScreen extends StatefulWidget {
  final List<CartItemModel> cartItems;
  final String restaurantId;
  final double totalAmount;

  const OrderScreen({
    Key? key,
    required this.cartItems,
    required this.restaurantId,
    required this.totalAmount,
  }) : super(key: key);

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  PaymentMethod _selectedPaymentMethod = PaymentMethod.thanhtoankhinhanhang;

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.edgeToEdge,
      overlays: [SystemUiOverlay.top],
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    _phoneController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
      );
      return;
    }

    if (_phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cập nhật số điện thoại')),
      );
      return;
    }

    try {
      final orderViewModel = context.read<OrderViewModel>();
      final userViewModel = context.read<UserViewModel>();

      final currentUser = userViewModel.currentUser;
      if (currentUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để đặt hàng')),
        );
        return;
      }

      await orderViewModel.createOrder(
        context: context,
        userId: currentUser.id,
        restaurantId: widget.restaurantId,
        items: widget.cartItems,
        address: _addressController.text,
        paymentMethod: PaymentMethod.thanhtoankhinhanhang,
        note: _noteController.text,
        currentUser: currentUser,
      );

      if (mounted) {
        context.go(NameRouter.mainTab);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Đặt hàng thất bại: $e')),
        );
      }
    }
  }

  Future<void> _showEditAddressBottomSheet(UserModel? user) async {
    if (user == null) return;
    _addressController.text = _addressController.text.isNotEmpty
        ? _addressController.text
        : (user.defaultAddress?.street ?? '');
    _phoneController.text = _phoneController.text.isNotEmpty
        ? _phoneController.text
        : user.phoneNumber;

    final screenHeight = MediaQuery.of(context).size.height;
    final minHeight = screenHeight * 0.3; // 30% of screen height
    final maxHeight = screenHeight * 0.7; // 70% of screen height

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          constraints: BoxConstraints(
            minHeight: minHeight,
            maxHeight: maxHeight,
          ),
          width: double.infinity,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(16),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chỉnh sửa thông tin nhận hàng',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                if (user.phoneNumber.isEmpty)
                  TextField(
                    controller: _phoneController,
                    decoration: InputDecoration(
                      labelText: 'Số điện thoại',
                      hintText: 'Nhập số điện thoại',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                if (user.phoneNumber.isEmpty) const SizedBox(height: 16),
                TextField(
                  controller: _addressController,
                  decoration: InputDecoration(
                    labelText: 'Địa chỉ',
                    hintText: 'Nhập địa chỉ giao hàng',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.color3,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Lưu'),
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

  void _showNoteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ghi chú'),
        content: TextField(
          controller: _noteController,
          decoration: const InputDecoration(
            hintText: 'Nhập ghi chú cho đơn hàng',
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TColor.color3,
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
  }

  void _navigateToVNPay(BuildContext context, OrderModel order) {
    if (order.id == null) {
      print("Order ID is null. Cannot initiate payment.");
      return;
    }
    double amountInVnPayUnits = order.totalAmount * 100;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VNPayWebView(
          orderId: order.id!,
          amount: amountInVnPayUnits,
          orderInfo: 'Thanh toan don hang #${order.id}',
          onPaymentResult: (bool success, String? message) {
            if (success) {
              print("Payment successful! Message: ${message ?? 'N/A'}");
            } else {
              print("Payment failed! Message: ${message ?? 'N/A'}");
            }
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Xác nhận đơn hàng',
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
          _buildAddressSection(),
          _buildDeliveryTimeSection(),
          _buildRestaurantAndFoodSection(),
          _buildPaymentDetailsSection(),
          _buildVoucherAndNoteSection(),
          _buildPaymentSection(),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Selector<UserViewModel, UserModel?>(
      selector: (_, vm) => vm.currentUser,
      builder: (context, user, _) {
        final name = _nameController.text.isNotEmpty
            ? _nameController.text
            : (user?.name ?? "Người dùng chưa đăng nhập");
        final phone = _phoneController.text.isNotEmpty
            ? _phoneController.text
            : (user?.phoneNumber ?? "Chưa có số điện thoại");
        final address = _addressController.text.isNotEmpty
            ? _addressController.text
            : (user?.defaultAddress?.street ??
                "Vui lòng nhập địa chỉ giao hàng");

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      address.isEmpty
                          ? "Vui lòng nhập địa chỉ giao hàng"
                          : "Địa chỉ: $address",
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w500),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _showEditAddressBottomSheet(user),
                    child: Text('Chỉnh sửa',
                        style: TextStyle(color: TColor.color3)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 32),
                child: Text(
                  name.isEmpty || phone.isEmpty
                      ? "Vui lòng cập nhật thông tin người nhận"
                      : '$name | $phone',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRestaurantAndFoodSection() {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.store, color: Colors.black54),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'FoodMot - Gà Rán, Gà Luộc & Gà Ủ Muối Hoa Tiêu - Kim Mã',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.cartItems.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
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
                            Text(item.foodName,
                                style: const TextStyle(fontSize: 14)),
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
            if (widget.cartItems.length > 3)
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {},
                  child:
                      Text('Xem thêm', style: TextStyle(color: TColor.color3)),
                ),
              ),
          ],
        ),
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

  Widget _buildPaymentDetailsSection() {
    double totalFoodPrice = widget.cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    double deliveryFee = 5000 * 7.3;
    double totalPayment = totalFoodPrice + deliveryFee;

    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Chi tiết thanh toán',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildPaymentRow('Tổng giá món (${widget.cartItems.length} món)',
                '${totalFoodPrice.toStringAsFixed(0)}đ'),
            _buildPaymentRow(
                'Phí giao hàng (7.3 km)', '${deliveryFee.toStringAsFixed(0)}đ'),
            const Divider(),
            _buildPaymentRow(
                'Tổng thanh toán', '${totalPayment.toStringAsFixed(0)}đ',
                isTotal: true),
            const Text('Đã bao gồm thuế',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
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

  Widget _buildDeliveryTimeSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.black54),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Giao ngay',
                  style: TextStyle(fontWeight: FontWeight.w500)),
              Text('Tiêu chuẩn - 23:55',
                  style: TextStyle(color: TColor.color3, fontSize: 13)),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text('Đổi sang hẹn giờ',
                style: TextStyle(color: TColor.color3)),
          ),
        ],
      ),
    );
  }

  Widget _buildVoucherAndNoteSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _noteController,
        decoration: InputDecoration(
          labelText: 'Ghi chú ',
          prefixIcon: const Icon(Icons.note_outlined),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        maxLines: 2,
        onChanged: (value) {
          setState(() {
            _noteController.text = value;
          });
        },
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Phương thức thanh toán',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.thanhtoankhinhanhang,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            title: const Text('Thanh toán khi nhận'),
          ),
          RadioListTile<PaymentMethod>(
            value: PaymentMethod.qr,
            groupValue: _selectedPaymentMethod,
            onChanged: (value) {
              setState(() {
                _selectedPaymentMethod = value!;
              });
            },
            title: const Text('Thanh toán VNPay'),
          ),
          const SizedBox(height: 16),
          Consumer<OrderViewModel>(
            builder: (context, orderViewModel, _) {
              return ElevatedButton(
                  onPressed: orderViewModel.isLoading
                      ? null
                      : () async {
                          if (_selectedPaymentMethod ==
                              PaymentMethod.thanhtoankhinhanhang) {
                            await _placeOrder();
                          } else if (_selectedPaymentMethod ==
                              PaymentMethod.qr) {
                            final userViewModel = context.read<UserViewModel>();
                            final user = userViewModel.currentUser;

                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Vui lòng đăng nhập để thanh toán VNPay')),
                              );
                              return;
                            }

                            double totalAmount = widget.cartItems.fold(
                              0,
                              (sum, item) => sum + (item.price * item.quantity),
                            );
                            double deliveryFee = 5000 * 7.3;
                            totalAmount += deliveryFee;

                            // Create a temporary order ID for VNPay
                            String tempOrderId = DateTime.now()
                                .millisecondsSinceEpoch
                                .toString();

                            // Navigate to VNPay WebView
                            if (context.mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => VNPayWebView(
                                    orderId: tempOrderId,
                                    amount: totalAmount,
                                    orderInfo:
                                        'Thanh toan don hang #$tempOrderId',
                                    onPaymentResult: (success, message) async {
                                      if (success) {
                                        // If payment is successful, place the order
                                        if (context.mounted) {
                                          await _placeOrder();
                                          Navigator.pop(
                                              context); // Close VNPay WebView
                                        }
                                      } else {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(content: Text(message)),
                                          );
                                          Navigator.pop(
                                              context); // Close VNPay WebView
                                        }
                                      }
                                    },
                                  ),
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange[200],
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: orderViewModel.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Center(
                          child: Text(
                            'Đặt đơn - ${widget.totalAmount.toStringAsFixed(0)}đ',
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            textAlign: TextAlign.center,
                          ),
                        ));
            },
          ),
          const SizedBox(
            height: 60,
          )
        ],
      ),
    );
  }
}
