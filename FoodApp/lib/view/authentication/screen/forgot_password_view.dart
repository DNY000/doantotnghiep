import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/common_widget/line_textfield.dart';
import 'package:foodapp/common_widget/round_button.dart';
import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
import 'package:provider/provider.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppBar(
                    backgroundColor: Colors.transparent,
                    elevation: 0,
                    centerTitle: true,
                    leading: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: Icon(
                        Icons.arrow_back_ios,
                        color: TColor.color3,
                      ),
                    ),
                  ),

                  // Icon
                  Icon(
                    Icons.lock_reset_outlined,
                    size: 80,
                    color: TColor.color3,
                  ),
                  SizedBox(height: media.width * 0.05),

                  Text(
                    "Quên mật khẩu",
                    style: TextStyle(
                      color: TColor.text,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: media.width * 0.02),
                  Text(
                    "Vui lòng nhập email của bạn để đặt lại mật khẩu",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: TColor.gray,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: media.width * 0.1),

                  // Email Field
                  LineTextField(
                    controller: _emailController,
                    hitText: "Email",
                    keyboardType: TextInputType.emailAddress,
                    validator: viewModel.validateEmail,
                  ),

                  // Error message
                  // if (viewModel.error.isNotEmpty)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 16.0),
                  //     child: Container(
                  //       padding: const EdgeInsets.all(12),
                  //       decoration: BoxDecoration(
                  //         color: Colors.red.withOpacity(0.1),
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: Row(
                  //         children: [
                  //           const Icon(
                  //             Icons.error_outline,
                  //             color: Colors.red,
                  //             size: 20,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           Expanded(
                  //             child: Text(
                  //               viewModel.error,
                  //               style: const TextStyle(
                  //                 color: Colors.red,
                  //                 fontSize: 14,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),

                  // // Success message
                  // if (viewModel.isSuccess)
                  //   Padding(
                  //     padding: const EdgeInsets.only(top: 16.0),
                  //     child: Container(
                  //       padding: const EdgeInsets.all(12),
                  //       decoration: BoxDecoration(
                  //         color: Colors.green.withOpacity(0.1),
                  //         borderRadius: BorderRadius.circular(8),
                  //       ),
                  //       child: Row(
                  //         children: [
                  //           const Icon(
                  //             Icons.check_circle_outline,
                  //             color: Colors.green,
                  //             size: 20,
                  //           ),
                  //           const SizedBox(width: 8),
                  //           const Expanded(
                  //             child: Text(
                  //               "Email khôi phục mật khẩu đã được gửi. Vui lòng kiểm tra hòm thư của bạn.",
                  //               style: TextStyle(
                  //                 color: Colors.green,
                  //                 fontSize: 14,
                  //               ),
                  //             ),
                  //           ),
                  //         ],
                  //       ),
                  //     ),
                  //   ),

                  SizedBox(height: media.width * 0.1),

                  // Reset Password Button
                  RoundButton(
                    title: viewModel.isLoading ? "Đang xử lý..." : "Xác nhận ",
                    onPressed: () async {
                      if (viewModel.isLoading) return;

                      if (_formKey.currentState!.validate()) {
                        viewModel.txtEmail.text = _emailController.text;
                        await viewModel.resetPassword();

                        if (viewModel.isSuccess && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content:
                                  Text('Email khôi phục mật khẩu đã được gửi!'),
                              backgroundColor: Colors.green,
                              duration: Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        } else if (viewModel.error.isNotEmpty &&
                            context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(viewModel.error),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 3),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                    isLoading: viewModel.isLoading,
                  ),

                  SizedBox(height: media.width * 0.1),

                  // Back to Login
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Quay lại ",
                        style: TextStyle(
                          fontSize: 14,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Đăng nhập",
                          style: TextStyle(
                            color: TColor.color3,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
