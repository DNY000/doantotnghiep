// import 'package:flutter/material.dart';
// import 'package:foodapp/core/services/payment_service.dart';
// import 'package:webview_flutter/webview_flutter.dart';

// class VNPayWebView extends StatefulWidget {
//   final String orderId;
//   final double amount;
//   final String orderInfo;
//   final Function(bool isSuccess, String message) onPaymentResult;

//   const VNPayWebView({
//     Key? key,
//     required this.orderId,
//     required this.amount,
//     required this.orderInfo,
//     required this.onPaymentResult,
//   }) : super(key: key);

//   @override
//   State<VNPayWebView> createState() => _VNPayWebViewState();
// }

// class _VNPayWebViewState extends State<VNPayWebView> {
//   late final WebViewController controller;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();

//     controller = WebViewController()
//       ..setJavaScriptMode(JavaScriptMode.unrestricted)
//       ..setNavigationDelegate(
//         NavigationDelegate(
//           onProgress: (int progress) {
//             if (progress == 100) {
//               setState(() {
//                 isLoading = false;
//               });
//             }
//           },
//           onPageStarted: (String url) {
//             setState(() {
//               isLoading = true;
//             });
//           },
//           onPageFinished: (String url) {
//             setState(() {
//               isLoading = false;
//             });
//           },
//           onNavigationRequest: (NavigationRequest request) {
//             // Kiểm tra nếu là return URL
//             if (request.url.contains('myapp://payment-result')) {
//               _handlePaymentResult(request.url);
//               return NavigationDecision.prevent;
//             }
//             return NavigationDecision.navigate;
//           },
//         ),
//       );

//     // Load VNPay payment URL
//     String paymentUrl = VNPayService.generatePaymentUrl(
//       txnRef: widget.orderId,
//       amount: widget.amount,
//       orderInfo: widget.orderInfo,
//       // Có thể truyền thêm các param khác nếu cần
//     );
//     controller.loadRequest(Uri.parse(paymentUrl));
//   }

//   void _handlePaymentResult(String url) {
//     Map<String, String> params = VNPayService.parseReturnUrl(url);
//     bool isValidCallback = VNPayService.validateCallback(params);
//     String responseCode = params['vnp_ResponseCode'] ?? '';

//     if (isValidCallback && responseCode == '00') {
//       widget.onPaymentResult(true, 'Thanh toán thành công');
//     } else {
//       String errorMessage = _getErrorMessage(responseCode);
//       widget.onPaymentResult(false, errorMessage);
//     }
//     Navigator.of(context).pop();
//   }

//   String _getErrorMessage(String responseCode) {
//     switch (responseCode) {
//       case '07':
//         return 'Trừ tiền thành công. Giao dịch bị nghi ngờ.';
//       case '09':
//         return 'Thẻ chưa đăng ký InternetBanking.';
//       case '10':
//         return 'Xác thực thông tin không đúng quá 3 lần.';
//       case '11':
//         return 'Đã hết hạn chờ thanh toán.';
//       case '12':
//         return 'Thẻ/Tài khoản bị khóa.';
//       case '13':
//         return 'Mật khẩu OTP không đúng.';
//       case '24':
//         return 'Khách hàng hủy giao dịch.';
//       case '51':
//         return 'Tài khoản không đủ số dư.';
//       case '65':
//         return 'Tài khoản vượt quá hạn mức giao dịch.';
//       default:
//         return 'Giao dịch không thành công. Mã lỗi: $responseCode';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Thanh toán VNPay'),
//         backgroundColor: Colors.orange,
//         foregroundColor: Colors.white,
//       ),
//       body: Stack(
//         children: [
//           WebViewWidget(controller: controller),
//           if (isLoading)
//             const Center(
//               child: CircularProgressIndicator(
//                 color: Colors.orange,
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
