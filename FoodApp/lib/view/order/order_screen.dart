import 'package:flutter/material.dart';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
  String _currentAddress = '';
  String _currentPhone = '';
  String _currentName = '';
  String _currentNote = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    try {
      setState(() {
        _isLoading = true;
      });

      print("Đang tải thông tin người dùng...");

      // Lấy đối tượng UserViewModel từ Provider để truy cập dữ liệu người dùng
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);

      // Kiểm tra xem đã có thông tin người dùng hiện tại trong UserViewModel chưa
      if (userViewModel.currentUser != null) {
        print("Đã có thông tin người dùng hiện tại trong UserViewModel");
        if (mounted) {
          setState(() {
            // Lấy thông tin từ đối tượng currentUser trong UserViewModel
            _currentName = userViewModel.currentUser?.name ?? 'Chưa có tên';
            _currentPhone = userViewModel.currentUser?.phoneNumber ??
                'Chưa có số điện thoại';
            _currentAddress =
                userViewModel.currentUser?.defaultAddress?.street ??
                    'Chưa có địa chỉ';
            _nameController.text = _currentName;
            _phoneController.text = _currentPhone;
            _addressController.text = _currentAddress;
            _isLoading = false;
          });
        }
        return;
      }

      // Nếu chưa có thông tin trong ViewModel, lấy ID người dùng hiện tại từ Firebase
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        // Sử dụng microtask để đảm bảo không chặn UI thread
        await Future.microtask(() async {
          // Gọi hàm fetchUser để lấy thông tin người dùng từ Firestore
          await userViewModel.fetchUser(userId);
          if (mounted) {
            setState(() {
              // Lấy thông tin người dùng sau khi đã fetch từ Firestore
              _currentName = userViewModel.currentUser?.name ?? 'Chưa có tên';
              _currentPhone = userViewModel.currentUser?.phoneNumber ??
                  'Chưa có số điện thoại';
              _currentAddress =
                  userViewModel.currentUser?.defaultAddress?.street ??
                      'Chưa có địa chỉ';
              _nameController.text = _currentName;
              _phoneController.text = _currentPhone;
              _addressController.text = _currentAddress;
              _isLoading = false;
            });
          }
        });
      } else {
        // Nếu không có người dùng đăng nhập, hiển thị thông tin mặc định
        if (mounted) {
          setState(() {
            _currentName = "Người dùng chưa đăng nhập";
            _currentPhone = "Chưa có số điện thoại";
            _currentAddress = "Vui lòng nhập địa chỉ giao hàng";
            _nameController.text = _currentName;
            _phoneController.text = _currentPhone;
            _addressController.text = _currentAddress;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print("Lỗi khi tải thông tin người dùng: $e");
      if (mounted) {
        setState(() {
          _currentName = "Người dùng";
          _currentPhone = "Chưa có số điện thoại";
          _currentAddress = "Vui lòng nhập địa chỉ giao hàng";
          _nameController.text = _currentName;
          _phoneController.text = _currentPhone;
          _addressController.text = _currentAddress;
          _isLoading = false;
        });
      }
    }
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
        paymentMethod: _selectedPaymentMethod,
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

  Future<void> _showEditAddressDialog() async {
    _addressController.text = _currentAddress;
    _phoneController.text = _currentPhone;
    _nameController.text = _currentName;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chỉnh sửa địa chỉ'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên người nhận',
                  hintText: 'Nhập tên người nhận',
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Số điện thoại',
                  hintText: 'Nhập số điện thoại',
                ),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ',
                  hintText: 'Nhập địa chỉ giao hàng',
                ),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
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
    );
  }

  void _showPaymentMethodSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Chọn phương thức thanh toán',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              ...PaymentMethod.values.map(
                (method) => RadioListTile<PaymentMethod>(
                  value: method,
                  groupValue: _selectedPaymentMethod,
                  onChanged: (value) {
                    setState(() => _selectedPaymentMethod = value!);
                    this.setState(() {});
                    Navigator.pop(context);
                  },
                  title: Text(_getPaymentMethodName(method)),
                  activeColor: TColor.color3,
                ),
              ),
            ],
          ),
        ),
      ),
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
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Xác nhận đơn hàng',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // Địa chỉ giao hàng
                _buildAddressSection(),

                // Thời gian giao hàng
                _buildDeliveryTimeSection(),

                // Thông tin nhà hàng và món ăn
                _buildRestaurantAndFoodSection(),

                // Chi tiết thanh toán
                _buildPaymentDetailsSection(),

                // Voucher và các tùy chọn
                _buildVoucherAndOptionsSection(),

                // Khoảng trống để không bị che bởi nút đặt hàng
                const SizedBox(height: 80),
              ],
            ),
          ),

          // Nút đặt hàng cố định ở dưới cùng
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildOrderButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        color: Colors.black54),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _currentAddress.isEmpty
                            ? "Vui lòng nhập địa chỉ giao hàng"
                            : _currentAddress,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    TextButton(
                      onPressed: _showEditAddressDialog,
                      child: Text(
                        'Chỉnh sửa',
                        style: TextStyle(color: TColor.color3),
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 32),
                  child: Text(
                    _currentName.isEmpty || _currentPhone.isEmpty
                        ? "Vui lòng cập nhật thông tin người nhận"
                        : '$_currentName | $_currentPhone',
                    style: const TextStyle(color: Colors.black54, fontSize: 13),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildDeliveryTimeSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        children: [
          const Icon(Icons.access_time, color: Colors.black54),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Giao ngay'),
              Text(
                'Tiêu chuẩn - 23:55',
                style: TextStyle(color: TColor.color3, fontSize: 13),
              ),
            ],
          ),
          const Spacer(),
          TextButton(
            onPressed: () {},
            child: Text(
              'Đổi sang hẹn giờ',
              style: TextStyle(color: TColor.color3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantAndFoodSection() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
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
          // Danh sách món ăn
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.cartItems.length,
            itemBuilder: (context, index) {
              final item = widget.cartItems[index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item.image,
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
                      ),
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
          widget.cartItems.length > 3
              ? TextButton(
                  onPressed: () {},
                  child: Text(
                    'Xem thêm',
                    style: TextStyle(color: TColor.color3),
                  ),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailsSection() {
    // Calculate the total food price based on cart items
    double totalFoodPrice = widget.cartItems.fold(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );

    // Calculate delivery fee based on distance (5000đ per km)
    double deliveryFee = 5000 * 7.3;

    // Calculate total
    double totalPayment = totalFoodPrice + deliveryFee;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiết thanh toán',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildPaymentRow('Tổng giá món (${widget.cartItems.length} món)',
              '${totalFoodPrice.toStringAsFixed(0)}đ'),
          _buildPaymentRow(
              'Phí giao hàng (7.3 km)', '${deliveryFee.toStringAsFixed(0)}đ'),
          const Divider(),
          _buildPaymentRow(
            'Tổng thanh toán',
            '${totalPayment.toStringAsFixed(0)}đ',
            isTotal: true,
          ),
          const Text(
            'Đã bao gồm thuế',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
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

  Widget _buildVoucherAndOptionsSection() {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Voucher
          ListTile(
            leading: Icon(Icons.local_offer_outlined, color: TColor.color3),
            title: const Text('Thêm voucher'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {},
          ),
          const Divider(height: 1),

          // Ghi chú
          ListTile(
            leading: Icon(Icons.note_outlined, color: TColor.color3),
            title: const Text('Ghi chú'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _currentNote.isEmpty ? 'Không có' : _currentNote,
                  style: TextStyle(
                    color: _currentNote.isEmpty ? Colors.grey : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right),
              ],
            ),
            onTap: _showNoteDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildOrderButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _showPaymentMethodSheet,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.payment, color: TColor.color3, size: 20),
                      const SizedBox(width: 8),
                      Text(_getPaymentMethodName(_selectedPaymentMethod)),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  const Text(
                    'Phương thức thanh toán khác',
                    style: TextStyle(color: Colors.blue, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          Consumer<OrderViewModel>(
            builder: (context, orderViewModel, _) {
              return ElevatedButton(
                onPressed: orderViewModel.isLoading ? null : _placeOrder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: TColor.color3,
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
                        style: const TextStyle(fontSize: 16),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }

  String _getPaymentMethodName(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.thanhtoankhinhanhang:
        return 'Tiền mặt';
      case PaymentMethod.qr:
        return 'Quét mã Qr';
      default:
        return 'Không xác định';
    }
  }
}
