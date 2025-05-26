import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class VNPayWebViewScreen extends StatefulWidget {
  final String paymentUrl;
  final String shipperId;
  final Function(bool success, String? responseCode) onComplete;

  const VNPayWebViewScreen({
    super.key,
    required this.paymentUrl,
    required this.shipperId,
    required this.onComplete,
  });

  @override
  State<VNPayWebViewScreen> createState() => _VNPayWebViewScreenState();
}

class _VNPayWebViewScreenState extends State<VNPayWebViewScreen> {
  late WebViewController _controller;
  bool _isLoading = true;
  Timer? _timeoutTimer;
  static const String _returnUrlScheme = 'shipper-vnpay-return://vnpay-return';

  @override
  void initState() {
    super.initState();
    _timeoutTimer = Timer(const Duration(minutes: 15), () {
      if (mounted) {
        widget.onComplete(false, '99');
        Navigator.of(context).pop();
      }
    });
    _initWebViewController();
  }

  void _initWebViewController() {
    _controller =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (url) {
                if (mounted) setState(() => _isLoading = true);
                _checkReturnUrl(url);
              },
              onPageFinished: (url) {
                if (mounted) setState(() => _isLoading = false);
                _checkReturnUrl(url);
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
    if (url.startsWith(_returnUrlScheme) || url.contains('vnp_ResponseCode=')) {
      try {
        final uri = Uri.parse(url);
        final params = uri.queryParameters;
        final responseCode = params['vnp_ResponseCode'];

        if (responseCode != null) {
          _timeoutTimer?.cancel();
          if (mounted) {
            Navigator.of(context).pop();
            widget.onComplete(responseCode == '00', responseCode);
          }
        }
      } catch (e) {}
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
