// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:foodapp/common/color_extension.dart';
// import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
// import 'package:provider/provider.dart';

// class OtpVerificationView extends StatefulWidget {
//   final String phoneNumber;
//   final VoidCallback? onVerificationSuccess;

//   const OtpVerificationView({
//     Key? key,
//     required this.phoneNumber,
//     this.onVerificationSuccess,
//   }) : super(key: key);

//   @override
//   State<OtpVerificationView> createState() => _OtpVerificationViewState();
// }

// class _OtpVerificationViewState extends State<OtpVerificationView> {
//   // Các biến để quản lý mã OTP
//   final List<TextEditingController> _controllers = List.generate(
//     6,
//     (index) => TextEditingController(),
//   );
//   final List<FocusNode> _focusNodes = List.generate(
//     6,
//     (index) => FocusNode(),
//   );

//   // Countdown timer
//   int _countdown = 60;
//   Timer? _timer;

//   @override
//   void initState() {
//     super.initState();
//     _startCountdown();
//   }

//   @override
//   void dispose() {
//     // Giải phóng controllers và focus nodes
//     for (var controller in _controllers) {
//       controller.dispose();
//     }
//     for (var node in _focusNodes) {
//       node.dispose();
//     }
//     _timer?.cancel();
//     super.dispose();
//   }

//   // Bắt đầu đếm ngược
//   void _startCountdown() {
//     _countdown = 60;
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       if (_countdown > 0) {
//         setState(() {
//           _countdown--;
//         });
//       } else {
//         timer.cancel();
//       }
//     });
//   }

//   // Xử lý khi nhấn nút xác thực
//   void _verifyOtp() async {
//     // Kết hợp các số OTP
//     String otp = _controllers.map((controller) => controller.text).join();

//     // Kiểm tra nếu OTP không đủ 6 số
//     if (otp.length != 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Vui lòng nhập đủ 6 số OTP'),
//           backgroundColor: Colors.red,
//         ),
//       );
//       return;
//     }

//     // Lấy viewModel từ Provider
//     final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

//     // Set OTP vào controller của ViewModel
//     loginViewModel.otpController.text = otp;

//     // Xác thực OTP
//     final success = await loginViewModel.verifyOTP(otp);

//     if (success && mounted) {
//       if (widget.onVerificationSuccess != null) {
//         widget.onVerificationSuccess!();
//       }
//     }
//   }

//   // Gửi lại mã OTP
//   void _resendOtp() async {
//     if (_countdown > 0) return;

//     // Lấy viewModel từ Provider
//     final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

//     // Gửi lại OTP
//     await loginViewModel.sendOTP();

//     // Bắt đầu đếm ngược lại nếu không có lỗi
//     if (loginViewModel.error.isEmpty && mounted) {
//       _startCountdown();

//       // Xóa các trường OTP
//       for (var controller in _controllers) {
//         controller.clear();
//       }
//       // Focus vào ô đầu tiên
//       _focusNodes.first.requestFocus();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Mã OTP đã được gửi lại'),
//           backgroundColor: Colors.green,
//         ),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Xác thực OTP',
//           style: TextStyle(color: Colors.black87),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black87),
//       ),
//       body: Consumer<LoginViewModel>(
//         builder: (context, loginViewModel, child) {
//           return SingleChildScrollView(
//             padding: const EdgeInsets.all(20.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const SizedBox(height: 20),

//                 Text(
//                   'Xác thực số điện thoại',
//                   style: TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.bold,
//                     color: TColor.text,
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 Text(
//                   'Mã xác thực đã được gửi tới',
//                   style: TextStyle(
//                     fontSize: 16,
//                     color: TColor.gray,
//                   ),
//                 ),

//                 const SizedBox(height: 8),

//                 Text(
//                   widget.phoneNumber,
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: TColor.text,
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // OTP input fields
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: List.generate(
//                     6,
//                     (index) => _buildOtpField(index),
//                   ),
//                 ),

//                 const SizedBox(height: 16),

//                 // Error message
//                 if (loginViewModel.error.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.only(bottom: 8.0),
//                     child: Text(
//                       loginViewModel.error,
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),

//                 const SizedBox(height: 24),

//                 // Verify Button
//                 SizedBox(
//                   width: double.infinity,
//                   child: ElevatedButton(
//                     onPressed: loginViewModel.isLoading ? null : _verifyOtp,
//                     style: ElevatedButton.styleFrom(
//                       backgroundColor: TColor.primary,
//                       padding: const EdgeInsets.symmetric(vertical: 15),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                     child: loginViewModel.isLoading
//                         ? const SizedBox(
//                             width: 20,
//                             height: 20,
//                             child: CircularProgressIndicator(
//                               strokeWidth: 2,
//                               valueColor:
//                                   AlwaysStoppedAnimation<Color>(Colors.white),
//                             ),
//                           )
//                         : const Text(
//                             'Xác thực',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                   ),
//                 ),

//                 const SizedBox(height: 40),

//                 // Resend OTP button
//                 Center(
//                   child: TextButton(
//                     onPressed: _countdown > 0 || loginViewModel.isLoading
//                         ? null
//                         : _resendOtp,
//                     child: RichText(
//                       text: TextSpan(
//                         text: 'Không nhận được mã? ',
//                         style: TextStyle(
//                           color: TColor.gray,
//                           fontSize: 14,
//                         ),
//                         children: [
//                           TextSpan(
//                             text: _countdown > 0
//                                 ? 'Gửi lại sau $_countdown giây'
//                                 : 'Gửi lại',
//                             style: TextStyle(
//                               color: _countdown > 0 || loginViewModel.isLoading
//                                   ? TColor.gray.withOpacity(0.5)
//                                   : TColor.primary,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // Widget cho từng ô nhập OTP
//   Widget _buildOtpField(int index) {
//     return SizedBox(
//       width: 50,
//       height: 60,
//       child: TextField(
//         controller: _controllers[index],
//         focusNode: _focusNodes[index],
//         keyboardType: TextInputType.number,
//         textAlign: TextAlign.center,
//         maxLength: 1,
//         style: TextStyle(
//           fontSize: 20,
//           fontWeight: FontWeight.bold,
//           color: TColor.text,
//         ),
//         decoration: InputDecoration(
//           counterText: '',
//           contentPadding: EdgeInsets.zero,
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: TColor.gray),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(8),
//             borderSide: BorderSide(color: TColor.primary, width: 2),
//           ),
//         ),
//         inputFormatters: [
//           FilteringTextInputFormatter.digitsOnly,
//           LengthLimitingTextInputFormatter(1),
//         ],
//         onChanged: (value) {
//           if (value.length == 1) {
//             // Tự động chuyển đến ô tiếp theo
//             if (index < 5) {
//               _focusNodes[index + 1].requestFocus();
//             } else {
//               // Khi nhập xong ô cuối cùng, ẩn bàn phím
//               _focusNodes[index].unfocus();

//               // Tự động xác thực khi nhập đủ 6 số
//               WidgetsBinding.instance.addPostFrameCallback((_) {
//                 _verifyOtp();
//               });
//             }
//           } else if (value.isEmpty && index > 0) {
//             // Nếu xóa, quay lại ô trước đó
//             _focusNodes[index - 1].requestFocus();
//           }
//         },
//       ),
//     );
//   }
// }
