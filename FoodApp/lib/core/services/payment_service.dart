import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:foodapp/core/services/webview.dart';

class VNPayService {
  final String _tmnCode = 'C8EGK4UI';
  final String _hashKey = '8DMZTJX8SF7FH565TCMU0WMQUTMAVYLR';
  final String _paymentUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  final String _returnUrl = 'shipper-vnpay-return://vnpay-return';

  VNPayService();

  Future<void> processDeposit({
    required BuildContext context,
    required String shipperId,
    required double amount,
    String? userEmail,
    String? userPhone,
    String userIp = '',
    required Function(bool success, String? responseCode, String message)
        onComplete,
  }) async {
    try {
      if (amount <= 0 || shipperId.isEmpty) throw "Dữ liệu không hợp lệ";

      final testAmount = 10000.0;

      final paymentUrl = await createPaymentUrl(
        orderId: _generateTxnRef(),
        amount: testAmount,
        userEmail: userEmail,
        userPhone: userPhone,
        userIp: userIp,
      );

      try {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => VNPayWebViewScreen(
              paymentUrl: paymentUrl,
              shipperId: shipperId,
              onComplete: (success, responseCode, errorMessage) async {
                try {
                  if (success) {
                    print(
                        "❗DEBUG - Thanh toán VNPAY thành công: $responseCode");
                    onComplete(true, responseCode, 'Nạp tiền thành công');
                  } else {
                    String errorMsg = 'Giao dịch không thành công';
                    if (responseCode != null) {
                      switch (responseCode) {
                        case '24':
                          errorMsg = 'Khách hàng hủy giao dịch';
                          break;
                        case '51':
                          errorMsg = 'Tài khoản không đủ số dư';
                          break;
                        case '65':
                          errorMsg = 'Tài khoản đã vượt quá hạn mức giao dịch';
                          break;
                        case '75':
                          errorMsg = 'Ngân hàng đang bảo trì';
                          break;
                        case '79':
                          errorMsg = 'Khách hàng nhập sai mật khẩu thanh toán';
                          break;
                        case '99':
                          errorMsg = 'Lỗi không xác định từ VNPAY';
                          break;
                      }
                    }

                    if (errorMessage != null && errorMessage.isNotEmpty) {
                      errorMsg = '$errorMsg: $errorMessage';
                    }

                    print(
                        "❗DEBUG - Thanh toán VNPAY thất bại: $responseCode - $errorMsg");
                    onComplete(false, responseCode, errorMsg);
                  }
                } catch (e) {
                  print("❗DEBUG - Lỗi xử lý kết quả thanh toán: $e");
                  onComplete(false, responseCode,
                      'Lỗi khi xử lý kết quả thanh toán: $e');
                }
              },
            ),
          ),
        );
      } catch (e) {
        print("❗DEBUG - Lỗi khi mở WebView: $e");
        throw "Lỗi khi mở trang thanh toán: $e";
      }
    } catch (e) {
      print("❗DEBUG - Lỗi trong processDeposit: $e");
      onComplete(false, null, e.toString());
    }
  }

  /// Dùng riêng để tạo link không cần WebView (nếu server-side hoặc API)
  Future<String> createPaymentUrl({
    required String orderId,
    required double amount,
    String? userEmail,
    String? userPhone,
    String userIp = '',
  }) async {
    try {
      final txnRef = orderId.isNotEmpty ? orderId : _generateTxnRef();
      final DateTime now = DateTime.now();

      print("❗DEBUG - Năm hiện tại thực: ${now.year}");

      final Map<String, String> vnpParams = {
        'vnp_Version': '2.1.0',
        'vnp_Command': 'pay',
        'vnp_TmnCode': _tmnCode,
        'vnp_Amount': (amount * 100).round().toString(),
        'vnp_CreateDate': _formatDate(now),
        'vnp_CurrCode': 'VND',
        'vnp_IpAddr': userIp.isEmpty ? '127.0.0.1' : userIp,
        'vnp_Locale': 'vn',
        'vnp_OrderInfo': 'Thanh toan don hang: $txnRef',
        'vnp_OrderType': 'billpayment',
        'vnp_ReturnUrl': _returnUrl,
        'vnp_TxnRef': txnRef,
        'vnp_ExpireDate': _formatDate(now.add(const Duration(minutes: 15))),
      };

      if (userEmail?.isNotEmpty == true)
        vnpParams['vnp_Bill_Email'] = userEmail!;
      if (userPhone?.isNotEmpty == true)
        vnpParams['vnp_Bill_Mobile'] = userPhone!;

      final sortedParams = _sortParams(vnpParams);

      final signData = _buildQueryString(sortedParams);
      print("❗DEBUG - Chuỗi dữ liệu để tạo chữ ký VNPAY: $signData");

      final secureHash = _createHmacSha512Signature(signData, _hashKey);
      sortedParams['vnp_SecureHash'] = secureHash;

      final encodedParams = sortedParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final paymentUrl = '$_paymentUrl?$encodedParams';

      print("❗DEBUG - URL thanh toán VNPAY đầy đủ: $paymentUrl");
      final debugUrl = paymentUrl.replaceAll(
          RegExp(r'vnp_SecureHash=\w{20}.*?(&|$)'),
          'vnp_SecureHash=HASH_REMOVED...');
      print("❗DEBUG - URL thanh toán VNPAY: $debugUrl");

      return paymentUrl;
    } catch (e) {
      print("❗DEBUG - Lỗi khi tạo URL thanh toán: $e");
      throw "Lỗi khi tạo URL thanh toán: $e";
    }
  }

  String _generateTxnRef() {
    final now = DateTime.now().millisecondsSinceEpoch.toString();
    final rand = Random().nextInt(9000) + 1000;
    return '${now.substring(0, 10)}$rand';
  }

  String _formatDate(DateTime dt) {
    return '${dt.year.toString().padLeft(4, '0')}${_pad(dt.month)}${_pad(dt.day)}${_pad(dt.hour)}${_pad(dt.minute)}${_pad(dt.second)}';
  }

  String _pad(int val) => val.toString().padLeft(2, '0');

  Map<String, String> _sortParams(Map<String, String> params) {
    final sortedParams = <String, String>{};
    final sortedKeys = params.keys.toList()..sort();
    for (final key in sortedKeys) {
      final value = params[key];
      if (value != null && value.isNotEmpty) {
        sortedParams[key] = value;
      }
    }
    return sortedParams;
  }

  String _buildQueryString(Map<String, String> params) {
    return params.entries.map((e) => '${e.key}=${e.value}').join('&');
  }

  String _createHmacSha512Signature(String data, String key) {
    try {
      final dataBytes = utf8.encode(data);
      final keyBytes = utf8.encode(key);

      print("❗DEBUG - Dữ liệu gốc để ký: $data");
      print("❗DEBUG - Khóa sử dụng để ký: $key");

      final hmac = Hmac(sha512, keyBytes);
      final digest = hmac.convert(dataBytes);
      final hexSignature = digest.bytes
          .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
          .join('')
          .toUpperCase();

      print("❗DEBUG - Chữ ký tạo ra: $hexSignature");
      return hexSignature;
    } catch (e) {
      print("❗DEBUG - Lỗi khi tạo chữ ký HMAC SHA512: $e");
      throw "Lỗi khi tạo chữ ký HMAC SHA512: $e";
    }
  }
}
