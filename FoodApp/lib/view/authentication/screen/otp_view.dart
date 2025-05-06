// import 'package:flutter/material.dart';
// import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
// import 'package:foodapp/common/color_extension.dart';
// import 'package:foodapp/view/authentication/screen/set_password_view.dart';
// import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
// import 'package:foodapp/view/main_tab/main_tab_view.dart';
// import 'package:provider/provider.dart';
// import '../../../common_widget/round_button.dart';

// class OtpView extends StatelessWidget {
//   const OtpView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var media = MediaQuery.of(context).size;
//     final viewModel = Provider.of<LoginViewModel>(context);

//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: SingleChildScrollView(
//         child: SafeArea(
//             child: SizedBox(
//           width: media.width,
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               AppBar(
//                 backgroundColor: Colors.transparent,
//                 elevation: 0,
//                 leading: IconButton(
//                   onPressed: () {
//                     Navigator.pop(context);
//                   },
//                   icon: const Icon(
//                     Icons.arrow_back_ios,
//                     color: Colors.orange,
//                   ),
//                 ),
//               ),
//               Text(
//                 "Xác thực số điện thoại",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: TColor.text,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700),
//               ),
//               SizedBox(
//                 height: media.width * 0.02,
//               ),
//               Text(
//                 "Nhập mã OTP đã gửi đến số điện thoại của bạn",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                     color: TColor.gray,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700),
//               ),
//               SizedBox(
//                 height: media.width * 0.05,
//               ),
//               OtpTextField(
//                 numberOfFields: 6,
//                 borderColor: TColor.gray,
//                 focusedBorderColor: TColor.primary,
//                 textStyle:
//                     const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
//                 showFieldAsBox: false,
//                 borderWidth: 4.0,
//                 //runs when a code is typed in
//                 onCodeChanged: (String code) {
//                   viewModel.otpController.text = code;
//                 },
//                 //runs when every textfield is filled
//                 onSubmit: (String verificationCode) {
//                   viewModel.otpController.text = verificationCode;
//                 },
//               ),
//               SizedBox(
//                 height: media.width * 0.25,
//               ),
//               // Error Message
//               if (viewModel.error.isNotEmpty)
//                 Padding(
//                   padding: const EdgeInsets.all(8.0),
//                   child: Text(
//                     viewModel.error,
//                     style: const TextStyle(
//                       color: Colors.red,
//                       fontSize: 14,
//                     ),
//                     textAlign: TextAlign.center,
//                   ),
//                 ),
//               RoundButton(
//                 title: viewModel.isLoading ? "Đang xử lý..." : "Xác thực",
//                 type: RoundButtonType.primary,
//                 onPressed: () async {
//                   if (!viewModel.isLoading) {
//                     final success = await viewModel.verifyOTPAndSignIn();

//                     if (success) {
//                       if (viewModel.isNewAccount) {
//                         // Nếu là tài khoản mới, chuyển đến màn hình đặt mật khẩu
//                         Navigator.pushReplacement(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => ChangeNotifierProvider.value(
//                               value: viewModel,
//                               child: const SetPasswordView(),
//                             ),
//                           ),
//                         );
//                       } else {
//                         // Nếu là tài khoản cũ, chuyển đến màn hình chính
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => const MainTabView(),
//                           ),
//                           (route) => false,
//                         );
//                       }
//                     } else {
//                       // Hiển thị thông báo lỗi
//                       ScaffoldMessenger.of(context).showSnackBar(
//                         SnackBar(
//                           content: Text(viewModel.error),
//                           backgroundColor: Colors.red,
//                         ),
//                       );
//                     }
//                   }
//                 },
//               ),
//             ],
//           ),
//         )),
//       ),
//     );
//   }
// }
