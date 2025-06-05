import 'package:crypto/crypto.dart';
import 'dart:convert';

class VNPayService {
  static const String vnpUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String vnpTmnCode = 'YPEANKRO';
  static const String vnpHashSecret = 'M7PDEW01CNMWRB89HIPP9CE094J4IP2K';
  static const String vnpReturnUrl =
      'myapp://payment-result'; // hoặc 'https://yourapp.com/payment-result'
  static const String vnpVersion = '2.1.0';
  static const String vnpCommand = 'pay';

  static String createPaymentUrl({
    required String orderId,
    required double amount,
    required String orderInfo,
  }) {
    Map<String, String> vnpParams = {
      'vnp_Version': vnpVersion,
      'vnp_Command': vnpCommand,
      'vnp_TmnCode': vnpTmnCode,
      'vnp_Amount': (amount * 100)
          .toInt()
          .toString(), // VNPay yêu cầu đơn vị là đồng × 100
      'vnp_CurrCode': 'VND',
      'vnp_TxnRef': orderId,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'other',
      'vnp_Locale': 'vn',
      'vnp_ReturnUrl': vnpReturnUrl,
      'vnp_IpAddr': '127.0.0.1',
      'vnp_CreateDate': _getCurrentTime(),
    };

    // URL-encode vnp_ReturnUrl and vnp_OrderInfo before creating signData
    vnpParams['vnp_ReturnUrl'] =
        Uri.encodeComponent(vnpParams['vnp_ReturnUrl']!);
    vnpParams['vnp_OrderInfo'] =
        Uri.encodeComponent(vnpParams['vnp_OrderInfo']!);

    // 1. Sort keys
    final sortedKeys = vnpParams.keys.toList()..sort();

    // 2. Build signData (not URI encoded)
    final signData =
        sortedKeys.map((key) => '$key=${vnpParams[key]}').join('&');

    // 3. Generate secure hash
    final secureHash = _hmacSHA512(vnpHashSecret, signData);

    // 4. Encode for URL
    final encodedParams = sortedKeys
        .map((key) => '$key=${Uri.encodeComponent(vnpParams[key]!)}')
        .join('&');

    // 5. Final URL
    final paymentUrl = '$vnpUrl?$encodedParams&vnp_SecureHash=$secureHash';
    return paymentUrl;
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
    return digest.toString();
  }

  static Map<String, String> parseReturnUrl(String url) {
    final uri = Uri.parse(url);
    return uri.queryParameters;
  }

  static bool validateCallback(Map<String, String> params) {
    final receivedHash = params['vnp_SecureHash'];
    if (receivedHash == null) return false;

    // Remove secure hash
    final filteredParams = Map<String, String>.from(params)
      ..remove('vnp_SecureHash');

    final sortedKeys = filteredParams.keys.toList()..sort();
    final signData = sortedKeys.map((k) => '$k=${filteredParams[k]}').join('&');
    final expectedHash = _hmacSHA512(vnpHashSecret, signData);

    return expectedHash == receivedHash;
  }
}
