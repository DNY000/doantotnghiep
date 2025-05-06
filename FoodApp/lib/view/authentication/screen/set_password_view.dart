// import 'package:flutter/material.dart';
// import 'package:foodapp/ultils/const/color_extension.dart';
// import 'package:foodapp/ultils/validators.dart';
// import 'package:foodapp/view/main_tab/main_tab_view.dart';
// import 'package:provider/provider.dart';

// import '../../../common_widget/line_textfield.dart';
// import '../../../common_widget/round_button.dart';
// import '../viewmodel/login_viewmodel.dart';

// class SetPasswordView extends StatelessWidget {
//   const SetPasswordView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     var media = MediaQuery.of(context).size;
//     final viewModel = Provider.of<LoginViewModel>(context);

//     return SafeArea(
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: SingleChildScrollView(
//           child: SizedBox(
//             width: media.width,
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 AppBar(
//                   backgroundColor: Colors.transparent,
//                   elevation: 0,
//                   leading: IconButton(
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                     icon: Icon(
//                       Icons.arrow_back_ios,
//                       color: TColor.color3,
//                     ),
//                   ),
//                 ),
//                 Text(
//                   "Đặt mật khẩu",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: TColor.text,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(
//                   height: media.width * 0.02,
//                 ),
//                 Text(
//                   "Tạo mật khẩu cho tài khoản của bạn",
//                   textAlign: TextAlign.center,
//                   style: TextStyle(
//                     color: TColor.gray,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 SizedBox(
//                   height: media.width * 0.07,
//                 ),
//                 // Password TextField
//                 LineTextField(
//                   controller: viewModel.txtPassword,
//                   obscureText: true,
//                   hitText: "Mật khẩu",
//                   validator: viewModel.validatePassword,
//                 ),
//                 SizedBox(
//                   height: media.width * 0.07,
//                 ),
//                 // Confirm Password TextField
//                 LineTextField(
//                   controller: viewModel.txtConfirmPassword,
//                   obscureText: true,
//                   hitText: "Xác nhận mật khẩu",
//                   validator: (value) => Validators.validateConfirmPassword(
//                     value,
//                     viewModel.txtPassword.text,
//                   ),
//                 ),
//                 SizedBox(
//                   height: media.width * 0.07,
//                 ),
//                 // Error Message
//                 if (viewModel.error.isNotEmpty)
//                   Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Text(
//                       viewModel.error,
//                       style: const TextStyle(
//                         color: Colors.red,
//                         fontSize: 14,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 SizedBox(
//                   height: media.width * 0.05,
//                 ),
//                 RoundButton(
//                   title: viewModel.isLoading ? "Đang xử lý..." : "Xác nhận",
//                   onPressed: () async {
//                     if (!viewModel.isLoading) {
//                       if (viewModel.txtPassword.text.isEmpty) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Vui lòng nhập mật khẩu"),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }
                
//                       if (viewModel.txtPassword.text !=
//                           viewModel.txtConfirmPassword.text) {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text("Mật khẩu không khớp"),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                         return;
//                       }
                
//                       // Implement set password function here
//                       final success = await viewModel.setPassword();
                
//                       if (success) {
//                         // Clear data sau khi đặt mật khẩu thành công
//                         viewModel.clearControllers();
                
//                         // Navigate to main screen
//                         Navigator.pushAndRemoveUntil(
//                           context,
//                           MaterialPageRoute<void>(
//                             builder: (BuildContext context) =>
//                                 const MainTabView(),
//                           ),
//                           (route) => false,
//                         );
//                       } else {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           SnackBar(
//                             content: Text(viewModel.error),
//                             backgroundColor: Colors.red,
//                           ),
//                         );
//                       }
//                     }
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
