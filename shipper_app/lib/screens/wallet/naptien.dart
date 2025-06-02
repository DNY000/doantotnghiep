import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/vnpay_service.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DepositScreen extends StatefulWidget {
  final String shipperId;

  const DepositScreen({super.key, required this.shipperId});

  @override
  _DepositScreenState createState() => _DepositScreenState();
}

class _DepositScreenState extends State<DepositScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  bool _isLoading = false;
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  String _responseMessage = '';
  bool _showResponseMessage = false;
  bool _isSuccess = false;
  bool _showDebugInfo = false;
  late VNPayService _vnpayService;
  bool _isProcessing = false;
  double _currentBalance = 0;
  bool _isLoadingBalance = true;

  // Danh sách các mệnh giá phổ biến
  final List<double> _predefinedAmounts = [
    20000,
    50000,
    100000,
    200000,
    500000,
  ];

  @override
  void initState() {
    super.initState();
    _vnpayService = VNPayService();
    _loadWalletBalance();
  }

  Future<void> _loadWalletBalance() async {
    try {
      final walletDoc =
          await FirebaseFirestore.instance
              .collection('wallets')
              .doc(widget.shipperId)
              .get();

      if (mounted) {
        setState(() {
          _currentBalance = (walletDoc.data()?['balance'] ?? 0).toDouble();
          _isLoadingBalance = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingBalance = false;
        });
      }
    }
  }

  String _getErrorMessage(String? code) {
    if (code == null) {
      return 'Lỗi không xác định. Vui lòng thử lại sau hoặc liên hệ hỗ trợ.';
    }

    switch (code) {
      case '99':
        return 'Lỗi kết nối đến cổng thanh toán. Vui lòng kiểm tra kết nối mạng và thử lại.';
      case '07':
        return 'Giao dịch bị nghi ngờ gian lận. Vui lòng thử lại sau.';
      case '09':
        return 'Thẻ/Tài khoản không hợp lệ. Vui lòng kiểm tra lại thông tin.';
      case '10':
        return 'Hết hạn thanh toán. Vui lòng thực hiện giao dịch mới.';
      case '11':
        return 'Giao dịch không thành công do: Thẻ/Tài khoản bị khóa.';
      case '12':
        return 'Thẻ/Tài khoản chưa đăng ký dịch vụ InternetBanking.';
      case '13':
        return 'Giao dịch không thành công do quý khách nhập sai mật khẩu xác thực.';
      case '24':
        return 'Giao dịch không thành công do: Khách hàng hủy giao dịch.';
      case '51':
        return 'Số dư không đủ để thực hiện giao dịch.';
      case '65':
        return 'Tài khoản của quý khách đã vượt quá hạn mức giao dịch trong ngày.';
      case '75':
        return 'Ngân hàng thanh toán đang bảo trì.';
      case '79':
        return 'KH nhập sai mật khẩu thanh toán quá số lần quy định.';
      default:
        return 'Lỗi không xác định. Vui lòng thử lại sau hoặc liên hệ hỗ trợ.';
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  /// Xử lý quá trình nạp tiền qua VNPay
  Future<void> _processDeposit() async {
    if (_isProcessing) {
      Fluttertoast.showToast(
        msg: "Đang xử lý giao dịch, vui lòng đợi...",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _showResponseMessage = false;
      _isProcessing = true;
    });

    try {
      // Lấy số tiền từ controller và xử lý
      String numericText = _amountController.text.replaceAll(
        RegExp(r'[^\d]'),
        '',
      );

      if (numericText.isEmpty) {
        throw Exception("Vui lòng nhập số tiền");
      }

      double amount = double.parse(numericText);

      // Kiểm tra giới hạn số tiền
      if (amount < 10000 || amount > 100000000) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _showResponseMessage = true;
          _isSuccess = false;
          _responseMessage = 'Số tiền phải từ 10,000đ đến 100,000,000đ';
          _isProcessing = false;
        });
        return;
      }

      // Kiểm tra ví tồn tại trước khi thanh toán
      try {
        final walletRef = FirebaseFirestore.instance
            .collection('wallets')
            .doc(widget.shipperId);
        final walletDoc = await walletRef.get();

        if (!walletDoc.exists) {
          // Tạo ví mới nếu chưa tồn tại
          await walletRef.set({
            'balance': 0.0, // Đảm bảo số dư là double
            'shipperId': widget.shipperId,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
          _showResponseMessage = true;
          _isSuccess = false;
          _responseMessage = 'Không thể khởi tạo ví. Vui lòng thử lại sau.';
          _isProcessing = false;
        });
        return;
      }

      await _vnpayService.processDeposit(
        context: context,
        shipperId: widget.shipperId,
        amount: amount,
        onComplete: (success, responseCode, message) {
          if (!mounted) return;

          setState(() {
            _isLoading = false;
            _showResponseMessage = true;
            _isSuccess = success;
            _responseMessage =
                success
                    ? 'Nạp tiền thành công!'
                    : _getErrorMessage(responseCode);
            _isProcessing = false;

            if (success) {
              _loadWalletBalance(); // Cập nhật số dư sau khi nạp tiền thành công
              Future.delayed(const Duration(seconds: 2), () {
                if (!mounted) return;
                Navigator.pop(context, true);
              });
            }
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _showResponseMessage = true;
        _isSuccess = false;
        _responseMessage = 'Đã xảy ra lỗi: $e';
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nạp tiền vào ví'),
        actions: [
          IconButton(
            icon: Icon(
              _showDebugInfo ? Icons.visibility_off : Icons.info_outline,
            ),
            onPressed: () {
              setState(() {
                _showDebugInfo = !_showDebugInfo;
              });
            },
            tooltip: 'Hiển thị thông tin debug',
          ),
        ],
      ),
      body:
          _isLoading
              ? _buildLoadingView()
              : RefreshIndicator(
                onRefresh: _loadWalletBalance,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBalanceCard(),
                        const SizedBox(height: 16),

                        if (_showResponseMessage) _buildResponseMessage(),

                        const Text(
                          'Chọn số tiền muốn nạp:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),

                        _buildAmountGrid(),

                        const SizedBox(height: 24),

                        const Text(
                          'Hoặc nhập số tiền khác:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),

                        _buildAmountInput(),

                        const SizedBox(height: 24),

                        _buildPaymentButton(),

                        const SizedBox(height: 16),

                        _buildNotesCard(),

                        if (_showDebugInfo) _buildDebugInfo(),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang xử lý thanh toán...', style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildBalanceCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.account_balance_wallet,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Số dư hiện tại:',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoadingBalance
                ? const Center(child: CircularProgressIndicator())
                : Text(
                  currencyFormat.format(_currentBalance),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseMessage() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: _isSuccess ? Colors.green[100] : Colors.red[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: _isSuccess ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isSuccess ? Icons.check_circle : Icons.error,
                color: _isSuccess ? Colors.green[800] : Colors.red[800],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _responseMessage,
                  style: TextStyle(
                    color: _isSuccess ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (!_isSuccess) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _showResponseMessage = false;
                    });
                  },
                  child: const Text('Đóng'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _processDeposit,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAmountGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _predefinedAmounts.length,
      itemBuilder: (context, index) {
        return InkWell(
          onTap: () {
            setState(() {
              _amountController.text = currencyFormat.format(
                _predefinedAmounts[index],
              );
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).primaryColor),
              borderRadius: BorderRadius.circular(8),
              color:
                  _amountController.text ==
                          currencyFormat.format(_predefinedAmounts[index])
                      ? Theme.of(context).primaryColor
                      : Colors.white,
            ),
            alignment: Alignment.center,
            child: Text(
              currencyFormat.format(_predefinedAmounts[index]),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
    );
  }

  Widget _buildAmountInput() {
    return TextFormField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: 'Số tiền',
        hintText: 'Nhập số tiền cần nạp',
        border: const OutlineInputBorder(),
        prefixIcon: const Icon(Icons.monetization_on),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _amountController.clear();
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Vui lòng nhập số tiền';
        }

        final amount = double.tryParse(value.replaceAll(RegExp(r'[^\d]'), ''));
        if (amount == null || amount < 10000) {
          return 'Số tiền tối thiểu là 10,000 VND';
        }
        if (amount > 100000000) {
          return 'Số tiền tối đa là 100,000,000 VND';
        }

        return null;
      },
      onChanged: (value) {
        if (value.isNotEmpty) {
          final numericValue = value.replaceAll(RegExp(r'[^\d]'), '');
          if (numericValue.isNotEmpty) {
            final amount = double.parse(numericValue);
            _amountController.value = TextEditingValue(
              text: currencyFormat.format(amount),
              selection: TextSelection.collapsed(
                offset: currencyFormat.format(amount).length,
              ),
            );
          }
        }
      },
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _isProcessing ? null : _processDeposit,
        icon:
            _isProcessing
                ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                : const Icon(Icons.payment),
        label: Text(
          _isProcessing ? 'Đang xử lý...' : 'Nạp tiền qua VNPAY',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          disabledBackgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Lưu ý:',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('• Số tiền tối thiểu mỗi lần nạp là 10,000đ'),
            const Text('• Số tiền tối đa mỗi lần nạp là 100,000,000đ'),
            const Text(
              '• Bạn có thể thanh toán bằng thẻ ATM, Visa, MasterCard qua VNPAY',
            ),
            const Text(
              '• Số tiền sẽ được cập nhật vào ví của bạn ngay sau khi giao dịch thành công',
            ),
            const Text(
              '• Nếu gặp lỗi, vui lòng kiểm tra lại kết nối mạng và thử lại',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDebugInfo() {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[400]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin debug:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Shipper ID: ${widget.shipperId}'),
          Text('Số tiền hiện tại: ${_amountController.text}'),
          const Text('Phương thức thanh toán: VNPAY'),
          const Text('Môi trường: SANDBOX'),
          const SizedBox(height: 8),
          const Text('Return URL: shipper-vnpay-return://vnpay-return'),
          const SizedBox(height: 16),
          const Text(
            'Quy trình tạo chữ ký:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const Text('1. Sắp xếp tham số theo alphabet'),
          const Text('2. Tạo chuỗi query không encode'),
          const Text('3. Tạo chữ ký bằng HMAC-SHA512'),
          const Text('4. Chữ ký phải viết HOA'),
        ],
      ),
    );
  }
}
