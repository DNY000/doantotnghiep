import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VNPayWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String shipperId;
  final Function(bool success, String? responseCode, String? errorMessage)
      onComplete;

  const VNPayWebViewScreen({
    Key? key,
    required this.paymentUrl,
    required this.shipperId,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<VNPayWebViewScreen> createState() => _VNPayWebViewScreenState();
}

class _VNPayWebViewScreenState extends State<VNPayWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  Timer? _timeoutTimer;
  static const String _returnUrlScheme = 'shipper-vnpay-return://vnpay-return';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    try {
      print(
          "❗DEBUG - Khởi tạo WebView VNPay với URL: ${widget.paymentUrl.substring(0, 50)}...");
      _timeoutTimer = Timer(const Duration(minutes: 15), () {
        if (mounted) {
          widget.onComplete(false, null, '99');
          Navigator.of(context).pop();
        }
      });
      _initWebViewController();
    } catch (e) {
      print("❗DEBUG - Lỗi khởi tạo WebView: $e");
      _errorMessage = "Lỗi khởi tạo WebView: $e";
      if (mounted) {
        widget.onComplete(false, null, '99');
        Navigator.of(context).pop();
      }
    }
  }

  void _initWebViewController() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            try {
              print("❗DEBUG - WebView bắt đầu tải URL: $url");
              if (mounted) setState(() => _isLoading = true);
              _checkReturnUrl(url);
            } catch (e) {
              print("❗DEBUG - Lỗi khi bắt đầu tải trang: $e");
            }
          },
          onPageFinished: (url) {
            try {
              print("❗DEBUG - WebView đã tải xong URL: $url");
              if (mounted) setState(() => _isLoading = false);
              _checkReturnUrl(url);

              // Kiểm tra URL lỗi VNPay
              if (url.contains('Payment/Error.html')) {
                final uri = Uri.parse(url);
                final errorCode = uri.queryParameters['code'];
                print(
                    "❗DEBUG - Phát hiện trang lỗi của VNPay với mã: $errorCode");
                String errorMessage = 'Giao dịch không thành công';

                switch (errorCode) {
                  // ... existing code ...
                }
              }
            } catch (e) {
              print("❗DEBUG - Lỗi khi kết thúc tải trang: $e");
            }
          },
          onNavigationRequest: (request) {
            _checkReturnUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));
  }

  void _checkReturnUrl(String url) {
    try {
      print("❗DEBUG - Kiểm tra URL VNPay: $url");
      if (url.startsWith(_returnUrlScheme) ||
          url.contains('vnp_ResponseCode=')) {
        final uri = Uri.parse(url);
        final params = uri.queryParameters;
        final responseCode = params['vnp_ResponseCode'];

        if (responseCode != null) {
          _timeoutTimer?.cancel();
          print("❗DEBUG - Nhận được responseCode từ VNPay: $responseCode");
          if (mounted) {
            Navigator.of(context).pop();
            widget.onComplete(responseCode == '00', responseCode, null);
          }
        }
      }
    } catch (e) {
      print("❗DEBUG - Lỗi khi xử lý URL trả về: $e");
      if (mounted) {
        widget.onComplete(false, null, '99');
        Navigator.of(context).pop();
      }
    }
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thanh toán VNPay'), elevation: 0),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
