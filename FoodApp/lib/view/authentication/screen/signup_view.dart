import 'package:flutter/material.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:provider/provider.dart';
import '../viewmodel/signup_viewmodel.dart';
import '../../../common_widget/line_textfield.dart';
import '../../../common_widget/round_button.dart';

class SignUpView extends StatelessWidget {
  const SignUpView({super.key});

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final viewModel = Provider.of<SignUpViewModel>(context);

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          child: Form(
            key: viewModel.formKey,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: SizedBox(
                width: media.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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

                    // Logo Container
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.restaurant,
                        size: 50,
                        color: TColor.color3,
                      ),
                    ),
                    SizedBox(height: media.width * 0.05),

                    Text(
                      "Tạo tài khoản mới",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TColor.text,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: media.width * 0.02),
                    Text(
                      "Đăng ký để tiếp tục",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: TColor.gray,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: media.width * 0.08),

                    // Email TextField with icon
                    LineTextField(
                      controller: viewModel.txtUserName,
                      hitText: "Tên người dùng",
                      keyboardType: TextInputType.emailAddress,
                      validator: viewModel.validateUserName,
                    ),
                    SizedBox(height: media.width * 0.05),
                    LineTextField(
                      controller: viewModel.txtEmail,
                      hitText: "Email",
                      keyboardType: TextInputType.emailAddress,
                      validator: viewModel.validateEmail,
                    ),
                    SizedBox(height: media.width * 0.05),

                    // Password TextField with icon
                    LineTextField(
                      controller: viewModel.txtPassword,
                      obscureText: true,
                      hitText: "Mật khẩu",
                      validator: viewModel.validatePassword,
                    ),
                    SizedBox(height: media.width * 0.05),

                    // Confirm Password TextField with icon
                    LineTextField(
                      controller: viewModel.txtConfirmPassword,
                      obscureText: true,
                      hitText: "Xác nhận mật khẩu",
                      validator: viewModel.validateConfirmPassword,
                    ),
                    SizedBox(height: media.width * 0.05),

                    // Error Message
                    if (viewModel.error.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: Colors.red,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                viewModel.error,
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    SizedBox(height: media.width * 0.06),

                    // Terms and Conditions
                    // Container(
                    //   padding: const EdgeInsets.symmetric(horizontal: 4),
                    //   child: Row(
                    //     children: [
                    //       Icon(
                    //         Icons.check_circle,
                    //         color: TColor.primary,
                    //         size: 16,
                    //       ),
                    //       const SizedBox(width: 8),
                    //       Expanded(
                    //         child: Text(
                    //           "Bằng cách đăng ký, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của chúng tôi",
                    //           style: TextStyle(
                    //             color: TColor.gray,
                    //             fontSize: 12,
                    //           ),
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),

                    SizedBox(height: media.width * 0.06),

                    // Signup Button
                    RoundButton(
                      title: viewModel.isLoading ? "Đang xử lý..." : "Đăng ký",
                      onPressed: () async {
                        if (!viewModel.isLoading) {
                          // Kiểm tra loading state
                          if (viewModel.formKey.currentState!.validate()) {
                            await viewModel.signUpWithEmailAndPassword();
                            if (viewModel.error.isEmpty && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đăng ký thành công!'),
                                  backgroundColor: Colors.green,
                                  duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              Navigator.pop(context);
                            }
                          }
                        }
                      },
                      isLoading: viewModel.isLoading,
                    ),

                    SizedBox(height: media.width * 0.08),

                    // Login Link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Đã có tài khoản? ",
                          style: TextStyle(
                            color: TColor.gray,
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
                    SizedBox(height: media.width * 0.05),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
