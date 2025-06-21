import 'package:crypto/crypto.dart';
import 'dart:convert';

class VNPayService {
  static const String vnpUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String vnpTmnCode = '8MRHANO6';
  static const String vnpHashSecret = 'T4BUJ05OXQAOJU2VTKCZINPR1Z1TJYBO';
  static const String vnpReturnUrl = 'myapp://payment-result';
  static const String vnpVersion = '2.1.0';
  static const String vnpCommand = 'pay';
  static const String vnpCurrCode = 'VND';
  static const String vnpOrderType = 'other';
  static const String vnpLocale = 'vn';
  static const String vnpIpAddr = '127.0.0.1';

  static String createPaymentUrl({
    required String orderId,
    required int amount,
    required String orderInfo,
  }) {
    final Map<String, String> vnpParams = {
      'vnp_Version': vnpVersion,
      'vnp_Command': vnpCommand,
      'vnp_TmnCode': vnpTmnCode,
      'vnp_Amount': (amount * 100).toString(),
      'vnp_CurrCode': vnpCurrCode,
      'vnp_TxnRef': DateTime.now().millisecondsSinceEpoch.toString(),
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': vnpOrderType,
      'vnp_Locale': vnpLocale,
      'vnp_ReturnUrl': vnpReturnUrl,
      'vnp_IpAddr': vnpIpAddr,
      'vnp_CreateDate': _getCurrentTime(),
    };

    final sortedKeys = vnpParams.keys.toList()..sort();
    final signData = sortedKeys
        .map((key) => '$key=${vnpParams[key] ?? ''}')
        .join('&');
    final secureHash = _hmacSHA512(vnpHashSecret, signData);
    vnpParams['vnp_SecureHash'] = secureHash;

    final encodedParams = vnpParams.entries
        .map((entry) => '${entry.key}=${Uri.encodeComponent(entry.value)}')
        .join('&');

    return '$vnpUrl?$encodedParams';
  }

  static String _getCurrentTime() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
  }

  static String _hmacSHA512(String key, String data) {
    final hmac = Hmac(sha512, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(data));
    return digest.toString().toUpperCase();
  }

  static bool validateCallback(Map<String, String> params) {
    final secureHash = params['vnp_SecureHash'];
    if (secureHash == null) return false;

    final filtered =
        Map<String, String>.from(params)
          ..remove('vnp_SecureHash')
          ..remove('vnp_SecureHashType');

    final sortedKeys = filtered.keys.toList()..sort();
    final signData = sortedKeys.map((k) => '$k=${filtered[k] ?? ''}').join('&');
    final hash = _hmacSHA512(vnpHashSecret, signData);
    return hash == secureHash;
  }
}
