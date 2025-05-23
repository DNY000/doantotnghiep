import 'package:crypto/crypto.dart';
import 'dart:convert';

// VNPay Service
class VNPayService {
  static const String vnpUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  static const String vnpTmnCode = 'HAV9K10E'; // Thay bằng TMN Code của bạn
  static const String vnpHashSecret = 'GS7KJKCV25U9WKA9S0M2O75SYQ5BAHFL';
  static const String vnpReturnUrl = 'myapp://payment-result';
  static const String vnpVersion = '2.1.0';
  static const String vnpCommand = 'pay';

  static String createPaymentUrl({
    required String orderId,
    required double amount,
    required String orderInfo,
  }) {
    // Tạo parameters
    Map<String, String> vnpParams = {
      'vnp_Version': vnpVersion,
      'vnp_Command': vnpCommand,
      'vnp_TmnCode': vnpTmnCode,
      'vnp_Amount':
          (amount * 100).toInt().toString(), // VNPay yêu cầu amount * 100
      'vnp_CurrCode': 'VND',
      'vnp_TxnRef': orderId,
      'vnp_OrderInfo': orderInfo,
      'vnp_OrderType': 'other',
      'vnp_Locale': 'vn',
      'vnp_ReturnUrl': vnpReturnUrl,
      'vnp_IpAddr': '127.0.0.1',
      'vnp_CreateDate': _getCurrentTime(),
    };

    // Sắp xếp parameters theo thứ tự alphabet
    var sortedKeys = vnpParams.keys.toList()..sort();

    // Tạo query string
    List<String> queryParams = [];
    for (String key in sortedKeys) {
      queryParams.add('$key=${Uri.encodeComponent(vnpParams[key]!)}');
    }
    String queryString = queryParams.join('&');

    // Tạo secure hash
    String signData = queryString;
    String secureHash = _hmacSHA512(vnpHashSecret, signData);

    // Tạo URL cuối cùng
    String paymentUrl = '$vnpUrl?$queryString&vnp_SecureHash=$secureHash';

    return paymentUrl;
  }

  static String _getCurrentTime() {
    DateTime now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}'
        '${now.month.toString().padLeft(2, '0')}'
        '${now.day.toString().padLeft(2, '0')}'
        '${now.hour.toString().padLeft(2, '0')}'
        '${now.minute.toString().padLeft(2, '0')}'
        '${now.second.toString().padLeft(2, '0')}';
  }

  static String _hmacSHA512(String key, String data) {
    var keyBytes = utf8.encode(key);
    var dataBytes = utf8.encode(data);
    var hmacSha512 = Hmac(sha512, keyBytes);
    var digest = hmacSha512.convert(dataBytes);
    return digest.toString();
  }

  static Map<String, String> parseReturnUrl(String url) {
    Uri uri = Uri.parse(url);
    return uri.queryParameters;
  }

  static bool validateCallback(Map<String, String> params) {
    String? vnpSecureHash = params['vnp_SecureHash'];
    if (vnpSecureHash == null) return false;

    // Remove vnp_SecureHash from params
    Map<String, String> sortedParams = Map.from(params);
    sortedParams.remove('vnp_SecureHash');

    // Sort parameters
    var sortedKeys = sortedParams.keys.toList()..sort();

    // Create query string
    List<String> queryParams = [];
    for (String key in sortedKeys) {
      queryParams.add('$key=${sortedParams[key]}');
    }
    String queryString = queryParams.join('&');

    // Create secure hash
    String calculatedHash = _hmacSHA512(vnpHashSecret, queryString);

    return calculatedHash == vnpSecureHash;
  }
}

// VNPay WebView Screen
