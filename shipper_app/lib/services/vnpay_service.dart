import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:package_info_plus/package_info_plus.dart';
import '../models/wallet_model.dart';
import '../screens/wallet/vnpay_webview_screen.dart';

class VNPayService {
  // Cấu hình VNPAY
  final String _tmnCode = 'W9Y3DFBX';
  final String _hashKey = 'S2YML0C7SVD2I90RXU8ABVS78WPNBELK';
  final String _paymentUrl =
      'https://sandbox.vnpayment.vn/paymentv2/vpcpay.html';
  final String _returnUrl = 'shipper-vnpay-return://vnpay-return';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
      final txnRef = _generateTxnRef();
      String appVersion = '';

      try {
        final PackageInfo packageInfo = await PackageInfo.fromPlatform();
        appVersion = packageInfo.version;
      } catch (_) {}

      // Tạo tham số thanh toán
      final Map<String, String> vnpParams = {
        'vnp_Version': '2.1.0',
        'vnp_Command': 'pay',
        'vnp_TmnCode': _tmnCode,
        'vnp_Amount': (amount * 100).round().toString(),
        'vnp_CreateDate': _formatDate(DateTime.now()),
        'vnp_CurrCode': 'VND',
        'vnp_IpAddr': userIp.isEmpty ? '127.0.0.1' : userIp,
        'vnp_Locale': 'vn',
        'vnp_OrderInfo': 'Nap tien vao vi: $txnRef',
        'vnp_OrderType': 'billpayment',
        'vnp_ReturnUrl': _returnUrl,
        'vnp_TxnRef': txnRef,
        'vnp_ExpireDate': _formatDate(
          DateTime.now().add(Duration(minutes: 15)),
        ),
      };

      // Thêm thông tin tùy chọn
      if (userEmail?.isNotEmpty == true)
        vnpParams['vnp_Bill_Email'] = userEmail!;
      if (userPhone?.isNotEmpty == true)
        vnpParams['vnp_Bill_Mobile'] = userPhone!;
      if (appVersion.isNotEmpty) vnpParams['vnp_App_Version'] = appVersion;

      // Tạo chữ ký
      final sortedParams = _sortParams(vnpParams);
      final signData = _buildQueryString(sortedParams);
      final secureHash = _createHmacSha512Signature(signData, _hashKey);
      sortedParams['vnp_SecureHash'] = secureHash;

      // Tạo URL thanh toán
      final encodedParams = sortedParams.entries
          .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
          .join('&');
      final paymentUrl = '$_paymentUrl?$encodedParams';

      // Mở WebView thanh toán
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder:
              (_) => VNPayWebViewScreen(
                paymentUrl: paymentUrl,
                shipperId: shipperId,
                onComplete: (success, responseCode) async {
                  if (success) {
                    await _createAndSaveTransaction(
                      shipperId: shipperId,
                      txnRef: txnRef,
                      amount: amount,
                      paymentId:
                          DateTime.now().millisecondsSinceEpoch.toString(),
                      bankCode: 'VNPAY',
                    );
                    onComplete(true, responseCode, 'Nạp tiền thành công');
                  } else {
                    onComplete(
                      false,
                      responseCode,
                      'Giao dịch không thành công',
                    );
                  }
                },
              ),
        ),
      );
    } catch (e) {
      throw "Lỗi khi kết nối: $e";
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
      // Chuyển đổi dữ liệu và key thành bytes
      final dataBytes = utf8.encode(data);
      final keyBytes = utf8.encode(key);

      // Tạo HMAC với SHA512
      final hmac = Hmac(sha512, keyBytes);

      // Tạo chữ ký
      final digest = hmac.convert(dataBytes);

      // Chuyển đổi thành hex và viết HOA
      final hexSignature =
          digest.bytes
              .map((byte) => byte.toRadixString(16).padLeft(2, '0'))
              .join('')
              .toUpperCase();

      return hexSignature;
    } catch (e) {
      throw "Lỗi khi tạo chữ ký HMAC SHA512: $e";
    }
  }

  Future<void> _createAndSaveTransaction({
    required String shipperId,
    required String txnRef,
    required double amount,
    required String paymentId,
    required String bankCode,
  }) async {
    final double safeAmount = amount.toDouble();
    final tx = TransactionModel(
      id: txnRef,
      type: 'deposit',
      amount: safeAmount,
      date: DateTime.now(),
      description: 'Nạp tiền qua VNPAY',
      status: 'completed',
      paymentMethod: 'vnpay',
      paymentId: paymentId,
      bankCode: bankCode,
    );

    await _firestore.collection('transactions').doc(txnRef).set(tx.toMap());

    final wallets =
        await _firestore
            .collection('wallets')
            .where('shipperId', isEqualTo: shipperId)
            .get();

    if (wallets.docs.isNotEmpty) {
      final doc = wallets.docs.first;
      final wallet = WalletModel.fromMap(doc.data(), doc.id);
      final newBalance = (wallet.balance + safeAmount).toDouble();

      await _firestore.collection('wallets').doc(doc.id).update({
        'balance': newBalance,
        'transactions': FieldValue.arrayUnion([tx.toMap()]),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } else {
      await _firestore.collection('wallets').doc(shipperId).set({
        'balance': safeAmount,
        'shipperId': shipperId,
        'transactions': [tx.toMap()],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
  }
}
