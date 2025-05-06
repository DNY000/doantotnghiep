// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:foodapp/common/color_extension.dart';
// import 'package:foodapp/view/authentication/screen/otp_verification_view.dart';
// import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
// import 'package:provider/provider.dart';

// class PhoneLoginView extends StatefulWidget {
//   const PhoneLoginView({Key? key}) : super(key: key);

//   @override
//   State<PhoneLoginView> createState() => _PhoneLoginViewState();
// }

// class _PhoneLoginViewState extends State<PhoneLoginView> {
//   final TextEditingController _phoneController = TextEditingController();
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   @override
//   void dispose() {
//     _phoneController.dispose();
//     super.dispose();
//   }

//   // Xử lý khi người dùng nhấn nút tiếp tục
//   void _continueWithPhone() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     // Lấy viewmodel từ Provider
//     final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

//     // Set số điện thoại vào controller của ViewModel
//     loginViewModel.phoneController.text = _phoneController.text.trim();

//     // Gửi OTP
//     await loginViewModel.sendOTP();

//     // Nếu OTP đã được gửi thành công, chuyển sang màn hình xác thực
//     if (loginViewModel.isOtpSent && mounted) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => OtpVerificationView(
//             phoneNumber: _phoneController.text.trim(),
//             onVerificationSuccess: () {
//               // Sau khi xác thực thành công, điều hướng đến màn hình chính
//               Navigator.of(context).pushReplacementNamed('/main_tab');
//             },
//           ),
//         ),
//       );
//     }
//   }

//   // Kiểm tra số điện thoại có hợp lệ không
//   bool _isValidPhoneNumber(String phone) {
//     // Kiểm tra số điện thoại Việt Nam
//     // Bắt đầu bằng 0, tiếp theo là 3-5 số hoặc 7-9 số, tổng cộng 10 số
//     final RegExp phoneRegex = RegExp(r'^0[3-9][0-9]{8}$');
//     return phoneRegex.hasMatch(phone);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Đăng nhập bằng SĐT',
//           style: TextStyle(color: Colors.black87),
//         ),
//         backgroundColor: Colors.white,
//         elevation: 0,
//         iconTheme: const IconThemeData(color: Colors.black87),
//       ),
//       body: Consumer<LoginViewModel>(builder: (context, loginViewModel, child) {
//         return SingleChildScrollView(
//           child: Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 20),
//                   Text(
//                     'Nhập số điện thoại của bạn',
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                       color: TColor.text,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Chúng tôi sẽ gửi mã xác thực đến số điện thoại của bạn',
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: TColor.gray,
//                     ),
//                   ),
//                   const SizedBox(height: 40),

//                   // Phone number input
//                   TextFormField(
//                     controller: _phoneController,
//                     keyboardType: TextInputType.phone,
//                     style: const TextStyle(fontSize: 16),
//                     decoration: InputDecoration(
//                       hintText: '0xxxxxxxxx',
//                       hintStyle: TextStyle(color: TColor.gray.withOpacity(0.5)),
//                       prefixIcon: Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 12.0),
//                         child: Text(
//                           '+84 ',
//                           style: TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                             color: TColor.text,
//                           ),
//                         ),
//                       ),
//                       prefixIconConstraints:
//                           const BoxConstraints(minWidth: 0, minHeight: 0),
//                       contentPadding: const EdgeInsets.symmetric(
//                           horizontal: 12, vertical: 16),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(color: TColor.gray),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(color: TColor.gray),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide(color: TColor.primary),
//                       ),
//                       errorBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: const BorderSide(color: Colors.red),
//                       ),
//                     ),
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(10),
//                     ],
//                     validator: (value) {
//                       if (value == null || value.isEmpty) {
//                         return 'Vui lòng nhập số điện thoại';
//                       }
//                       if (!_isValidPhoneNumber(value)) {
//                         return 'Số điện thoại không hợp lệ';
//                       }
//                       return null;
//                     },
//                   ),

//                   const SizedBox(height: 24),

//                   // Error message
//                   if (loginViewModel.error.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 16.0),
//                       child: Text(
//                         loginViewModel.error,
//                         style: const TextStyle(
//                           color: Colors.red,
//                           fontSize: 14,
//                         ),
//                         textAlign: TextAlign.center,
//                       ),
//                     ),

//                   // Continue Button
//                   SizedBox(
//                     width: double.infinity,
//                     child: ElevatedButton(
//                       onPressed:
//                           loginViewModel.isLoading ? null : _continueWithPhone,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: TColor.primary,
//                         padding: const EdgeInsets.symmetric(vertical: 15),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8),
//                         ),
//                       ),
//                       child: loginViewModel.isLoading
//                           ? const SizedBox(
//                               width: 20,
//                               height: 20,
//                               child: CircularProgressIndicator(
//                                 strokeWidth: 2,
//                                 valueColor:
//                                     AlwaysStoppedAnimation<Color>(Colors.white),
//                               ),
//                             )
//                           : const Text(
//                               'Tiếp tục',
//                               style: TextStyle(
//                                 fontSize: 16,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                     ),
//                   ),

//                   const SizedBox(height: 40),

//                   // Divider with text
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Divider(color: TColor.gray.withOpacity(0.5)),
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.symmetric(horizontal: 16),
//                         child: Text(
//                           'Hoặc',
//                           style: TextStyle(
//                             color: TColor.gray,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ),
//                       Expanded(
//                         child: Divider(color: TColor.gray.withOpacity(0.5)),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 40),

//                   // Other login options (Google và Facebook)
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       // Google button
//                       _socialLoginButton(
//                         icon: 'assets/img/google_icon.png',
//                         onTap: () async {
//                           await loginViewModel.loginWithGoogle();
//                           if (loginViewModel.error.isEmpty && mounted) {
//                             Navigator.of(context)
//                                 .pushReplacementNamed('/main_tab');
//                           }
//                         },
//                       ),

//                       // Facebook button
//                       _socialLoginButton(
//                         icon: 'assets/img/facebook_icon.png',
//                         onTap: () async {
//                           await loginViewModel.loginWithFacebook();
//                           if (loginViewModel.error.isEmpty && mounted) {
//                             Navigator.of(context)
//                                 .pushReplacementNamed('/main_tab');
//                           }
//                         },
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }

//   Widget _socialLoginButton(
//       {required String icon, required VoidCallback onTap}) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(30),
//       child: Container(
//         width: 60,
//         height: 60,
//         decoration: BoxDecoration(
//           shape: BoxShape.circle,
//           border: Border.all(color: TColor.gray.withOpacity(0.3)),
//         ),
//         child: Center(
//           child: Image.asset(
//             icon,
//             width: 30,
//             height: 30,
//           ),
//         ),
//       ),
//     );
//   }
// }
