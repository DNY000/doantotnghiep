import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

//[VNPayHashType] List of Hash Type in VNPAY, default is HMACSHA512
enum VNPayHashType {
  SHA256,
  HMACSHA512,
}

//[BankCode] List of valid payment bank in VNPAY, if not provide, it will be manual select, default is null
enum BankCode { VNPAYQR, VNBANK, INTCARD }

//[VNPayHashTypeExt] Extension to convert from HashType Enum to valid string of VNPAY
extension VNPayHashTypeExt on VNPayHashType {
  String toValueString() {
    switch (this) {
      case VNPayHashType.SHA256:
        return 'SHA256';
      case VNPayHashType.HMACSHA512:
        return 'HmacSHA512';
    }
  }
}

//[VNPAYFlutter] instance class VNPAY Flutter
class VNPAYFlutter {
  static final VNPAYFlutter _instance = VNPAYFlutter();

  //[instance] Single Ton Init
  static VNPAYFlutter get instance => _instance;

  Map<String, dynamic> _sortParams(Map<String, dynamic> params) {
    final sortedParams = <String, dynamic>{};
    final keys = params.keys.toList()..sort();
    for (String key in keys) {
      sortedParams[key] = params[key];
    }
    return sortedParams;
  }

  //[generatePaymentUrl] Generate payment Url with input parameters
  String generatePaymentUrl({
    String url = 'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html',
    required String version,
    String command = 'pay',
    required String tmnCode,
    String locale = 'vn',
    String currencyCode = 'VND',
    required String txnRef,
    String orderInfo = 'Pay Order',
    required double amount,
    required String returnUrl,
    required String ipAdress,
    DateTime? createAt,
    required String vnpayHashKey,
    VNPayHashType vnPayHashType = VNPayHashType.HMACSHA512,
    String vnpayOrderType = 'other',
    BankCode? bankCode,
    required DateTime vnpayExpireDate,
  }) {
    final params = <String, String>{
      'vnp_Version': version,
      'vnp_Command': command,
      'vnp_TmnCode': tmnCode,
      'vnp_Locale': locale,
      'vnp_CurrCode': currencyCode,
      'vnp_TxnRef': txnRef,
      'vnp_OrderInfo': orderInfo,
      'vnp_Amount': (amount * 100).toStringAsFixed(0),
      'vnp_ReturnUrl': returnUrl,
      'vnp_IpAddr': ipAdress,
      'vnp_CreateDate': DateFormat('yyyyMMddHHmmss')
          .format(createAt ?? DateTime.now())
          .toString(),
      'vnp_OrderType': vnpayOrderType,
      'vnp_ExpireDate':
          DateFormat('yyyyMMddHHmmss').format(vnpayExpireDate).toString(),
    };
    if (bankCode != null) {
      params['vnp_BankCode'] = bankCode.name;
    }
    var sortedParam = _sortParams(params);
    final hashDataBuffer = StringBuffer();
    sortedParam.forEach((key, value) {
      hashDataBuffer.write(key);
      hashDataBuffer.write('=');
      hashDataBuffer.write(value);
      hashDataBuffer.write('&');
    });
    String hashData =
        hashDataBuffer.toString().substring(0, hashDataBuffer.length - 1);
    String query = sortedParam.entries
        .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
        .join('&');
    String vnpSecureHash = "";

    if (vnPayHashType == VNPayHashType.SHA256) {
      List<int> bytes = utf8.encode(vnpayHashKey + hashData.toString());
      vnpSecureHash = sha256.convert(bytes).toString();
    } else if (vnPayHashType == VNPayHashType.HMACSHA512) {
      vnpSecureHash = Hmac(sha512, utf8.encode(vnpayHashKey))
          .convert(utf8.encode(hashData))
          .toString();
    }
    String paymentUrl =
        "$url?$query&vnp_SecureHashType=${vnPayHashType.toValueString()}&vnp_SecureHash=$vnpSecureHash";
    debugPrint("=====>[PAYMENT URL]: $paymentUrl");
    return paymentUrl;
  }

  // Thêm hàm test dữ liệu mẫu VNPay
  static void testVNPaySignatureSample() {
    // Dữ liệu mẫu từ tài liệu VNPay
    final params = <String, String>{
      'vnp_Version': '2.1.0',
      'vnp_Command': 'pay',
      'vnp_TmnCode': '8MRHANO6',
      'vnp_Amount': '8650000',
      'vnp_CurrCode': 'VND',
      'vnp_TxnRef': '1750411947252',
      'vnp_OrderInfo': 'Thanh toan don hang 1750411947252',
      'vnp_OrderType': 'other',
      'vnp_Locale': 'vn',
      'vnp_ReturnUrl': 'myapp://payment-result',
      'vnp_IpAddr': '127.0.0.1',
      'vnp_CreateDate': '20250620163227',
      'vnp_ExpireDate': '20250620164727',
    };
    final sortedKeys = params.keys.toList()..sort();
    final signData = sortedKeys.map((k) => '$k=${params[k]}').join('&');
    final hash = Hmac(sha512, utf8.encode('T4BUJ05OXQAOJU2VTKCZINPR1Z1TJYBO'))
        .convert(utf8.encode(signData))
        .toString()
        .toUpperCase();
    // Hash mẫu lấy từ log thực tế
    final sampleHash =
        'C55FED9C831F6B3831C8198E96A7988D96C387D87DD645AAB64503D743243D94B2CEFDA06FDB9BBBF009F6FFF05111CB4DC7F665F1D406E14477FF23F6356083';
    debugPrint('--- VNPay Signature Sample Test ---');
    debugPrint('SignData: $signData');
    debugPrint('Generated Hash: $hash');
    debugPrint('Sample Hash:    $sampleHash');
    debugPrint('Match: ${hash == sampleHash}');
  }
}

class VNPayWebView extends StatefulWidget {
  final String orderId;
  final double amount;
  final String orderInfo;
  final Function(bool isSuccess, String message) onPaymentResult;

  const VNPayWebView({
    Key? key,
    required this.orderId,
    required this.amount,
    required this.orderInfo,
    required this.onPaymentResult,
  }) : super(key: key);

  @override
  State<VNPayWebView> createState() => _VNPayWebViewState();
}

class _VNPayWebViewState extends State<VNPayWebView> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress == 100) {
              setState(() {
                isLoading = false;
              });
            }
          },
          onPageStarted: (String url) {
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.contains('myapp://payment-result')) {
              _handlePaymentResult(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    // Load VNPay payment URL
    String paymentUrl = VNPAYFlutter.instance.generatePaymentUrl(
      version: '2.1.0',
      tmnCode: '8MRHANO6',
      txnRef: widget.orderId,
      amount: widget.amount,
      orderInfo: widget.orderInfo,
      returnUrl: 'myapp://payment-result',
      ipAdress: '127.0.0.1',
      vnpayHashKey: 'T4BUJ05OXQAOJU2VTKCZINPR1Z1TJYBO',
      vnpayExpireDate: DateTime.now().add(const Duration(minutes: 15)),
      createAt: DateTime.now(),
    );
    controller.loadRequest(Uri.parse(paymentUrl));
  }

  void _handlePaymentResult(String url) {
    final params = Uri.parse(url).queryParameters;
    bool isValid = _validateCallback(params);
    String responseCode = params['vnp_ResponseCode'] ?? '';
    if (isValid && responseCode == '00') {
      widget.onPaymentResult(true, 'Thanh toán thành công');
    } else {
      widget.onPaymentResult(false, _getErrorMessage(responseCode));
    }
    Navigator.of(context).pop();
  }

  bool _validateCallback(Map<String, String> params) {
    String? secureHash = params['vnp_SecureHash'];
    if (secureHash == null) return false;
    final filtered = Map<String, String>.from(params)
      ..remove('vnp_SecureHash')
      ..remove('vnp_SecureHashType');
    final sortedKeys = filtered.keys.toList()..sort();
    final hashData = sortedKeys.map((k) => '$k=${filtered[k]}').join('&');
    String hash = Hmac(sha512, utf8.encode('T4BUJ05OXQAOJU2VTKCZINPR1Z1TJYBO'))
        .convert(utf8.encode(hashData))
        .toString();
    return hash.toUpperCase() == secureHash.toUpperCase();
  }

  String _getErrorMessage(String responseCode) {
    switch (responseCode) {
      case '07':
        return 'Trừ tiền thành công. Giao dịch bị nghi ngờ.';
      case '09':
        return 'Thẻ chưa đăng ký InternetBanking.';
      case '10':
        return 'Xác thực thông tin không đúng quá 3 lần.';
      case '11':
        return 'Đã hết hạn chờ thanh toán.';
      case '12':
        return 'Thẻ/Tài khoản bị khóa.';
      case '13':
        return 'Mật khẩu OTP không đúng.';
      case '24':
        return 'Khách hàng hủy giao dịch.';
      case '51':
        return 'Tài khoản không đủ số dư.';
      case '65':
        return 'Tài khoản vượt quá hạn mức giao dịch.';
      default:
        return 'Giao dịch không thành công. Mã lỗi: $responseCode';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thanh toán VNPay'),
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: controller),
          if (isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: Colors.orange,
              ),
            ),
        ],
      ),
    );
  }
}
