import 'dart:async';

import 'package:flutter/material.dart';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:foodapp/data/models/user_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/core/services/webview.dart';
import 'package:foodapp/core/services/payment_service.dart';

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
  String _currentAddress = '';
  String _currentPhone = '';
  String _currentName = '';
  String _currentNote = '';
  PaymentMethod _selectedPaymentMethod = PaymentMethod.thanhtoankhinhanhang;

  @override
  void dispose() {
    _addressController.dispose();
    _noteController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _placeOrder() async {
    if (_currentAddress.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập địa chỉ giao hàng')),
      );
      return;
    }

    if (_currentPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cập nhật số điện thoại')),
      );
      return;
    }

    if (_currentName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng cập nhật tên người nhận')),
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
        userId: currentUser.id,
        restaurantId: widget.restaurantId,
        items: widget.cartItems,
        address: _currentAddress,
        paymentMethod: PaymentMethod.thanhtoankhinhanhang,
        note: _currentNote,
        currentUser: currentUser,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đặt hàng thành công')),
        );
        Navigator.of(context).pop(true);
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
    _addressController.text = _currentAddress.isNotEmpty
        ? _currentAddress
        : (user.defaultAddress?.street ?? '');
    _phoneController.text =
        _currentPhone.isNotEmpty ? _currentPhone : user.phoneNumber;
    _nameController.text = _currentName.isNotEmpty ? _currentName : user.name;

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: screenHeight * 0.6,
          width: double.infinity,
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 24,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chỉnh sửa thông tin nhận hàng',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Tên người nhận',
                    hintText: 'Nhập tên người nhận',
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Số điện thoại',
                    hintText: 'Nhập số điện thoại',
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _addressController,
                  decoration: const InputDecoration(
                    labelText: 'Địa chỉ',
                    hintText: 'Nhập địa chỉ giao hàng',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Hủy'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _currentAddress = _addressController.text;
                          _currentPhone = _phoneController.text;
                          _currentName = _nameController.text;
                        });
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TColor.color3,
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
    _noteController.text = _currentNote;
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
              setState(() {
                _currentNote = _noteController.text;
              });
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
        final name = _currentName.isNotEmpty
            ? _currentName
            : (user?.name ?? "Người dùng chưa đăng nhập");
        final phone = _currentPhone.isNotEmpty
            ? _currentPhone
            : (user?.phoneNumber ?? "Chưa có số điện thoại");
        final address = _currentAddress.isNotEmpty
            ? _currentAddress
            : (user?.defaultAddress?.street ??
                "Vui lòng nhập địa chỉ giao hàng");

        Future.microtask(() {
          if (mounted) {
            _nameController.text = name;
            _phoneController.text = phone;
            _addressController.text = address;
          }
        });

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
            _currentNote = value;
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
                        } else if (_selectedPaymentMethod == PaymentMethod.qr) {
                          final paymentUrl = await _getVNPayPaymentUrl();
                          if (paymentUrl != null && context.mounted) {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => VNPayWebViewScreen(
                                  paymentUrl: paymentUrl,
                                  shipperId: "",
                                  onComplete: (success, responseCode,
                                      errorMessage) async {
                                    if (success) {
                                      await _placeOrder();
                                    } else {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(errorMessage ??
                                                'Thanh toán VNPay thất bại hoặc bị hủy.')),
                                      );
                                    }
                                  },
                                ),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('Không thể tạo thanh toán VNPay.')),
                            );
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange[200],
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
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
                    : Text(
                        'Đặt đơn - ${widget.totalAmount.toStringAsFixed(0)}đ',
                        style:
                            const TextStyle(fontSize: 16, color: Colors.black),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<String?> _getVNPayPaymentUrl() async {
    try {
      double totalAmount = widget.cartItems.fold(
        0,
        (sum, item) => sum + (item.price * item.quantity),
      );

      double deliveryFee = 5000 * 7.3;
      totalAmount += deliveryFee;

      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      final user = userViewModel.currentUser;

      if (user == null) {
        throw "Vui lòng đăng nhập để thanh toán";
      }

      final completer = Completer<String?>();

      final vnpayService = VNPayService();

      vnpayService.processDeposit(
        context: context,
        shipperId: user.id,
        amount: totalAmount,
        userEmail: user.email,
        userPhone: user.phoneNumber,
        onComplete: (success, responseCode, message) {},
      );

      return 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html?vnp_Amount=1000000&vnp_Command=pay&vnp_CreateDate=20240118121212&vnp_CurrCode=VND&vnp_IpAddr=127.0.0.1&vnp_Locale=vn&vnp_OrderInfo=Thanh+toan+don+hang+test&vnp_OrderType=billpayment&vnp_ReturnUrl=shipper-vnpay-return://vnpay-return&vnp_TmnCode=C8EGK4UI&vnp_TxnRef=123456789&vnp_Version=2.1.0&vnp_SecureHash=HASH...';
    } catch (error) {
      print("❗DEBUG - Lỗi khi tạo URL thanh toán VNPay: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi khi tạo URL thanh toán: $error")),
      );
      return null;
    }
  }
}
