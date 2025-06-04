import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/common_widget/login/other_login.dart';
import 'package:foodapp/common_widget/round_button.dart';
import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
import 'package:go_router/go_router.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  bool isShowPassword = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = Provider.of<LoginViewModel>(context, listen: false);
        viewModel.navigationCallback = (String route) {
          if (mounted) {
            context.go(route);
          }
        };

        viewModel.autoLoginUser();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context).size;
    final viewModel = Provider.of<LoginViewModel>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: viewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Form(
                key: viewModel.formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0), // Increased horizontal padding
                  child: SizedBox(
                    width: media.width,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Align children to start
                      children: [
                        // Space below back button
                        const SizedBox(
                          height: 40,
                        ),
                        // Logo and Text
                        Center(
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/images/logo/logoappfood.png', // Replace with actual logo path
                                height: 200, // Adjust size
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: media.width * 0.1),

                        const Text(
                          "Email",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Email Field
                        TextFormField(
                          controller: viewModel.txtEmail,
                          keyboardType: TextInputType.emailAddress,
                          validator: viewModel.validateEmail,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            filled: true, // Add fill
                            fillColor:
                                Colors.grey.shade200, // Light grey background
                            hintText: "duy000.vn@gmail.com", // Example hint
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600, // Darker grey hint
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  8), // Slightly rounded corners
                              borderSide: BorderSide.none, // No visible border
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.transparent,
                                  width: 1), // Orange border when focused
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14), // Adjusted padding
                            // suffixIcon: Icon(
                            //   Icons.email_outlined,
                            //   color: TColor.gray,
                            //   size: 18,
                            // ), // Removed email icon
                          ),
                        ),
                        const SizedBox(height: 20), // Reduced space

                        const Text(
                          "Mật khẩu",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Password Field
                        TextFormField(
                          controller: viewModel.txtPassword,
                          obscureText: isShowPassword,
                          validator: viewModel.validatePassword,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            hintText: "********", // Example hint
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: const BorderSide(
                                  color: Colors.transparent, width: 1),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide:
                                  const BorderSide(color: Colors.red, width: 1),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),

                            suffixIcon: IconButton(
                              icon: Icon(
                                isShowPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color:
                                    Colors.grey.shade600, // Changed icon color
                                size: 18,
                              ),
                              onPressed: () {
                                setState(() {
                                  isShowPassword = !isShowPassword;
                                });
                              },
                            ),
                          ),
                        ),

                        // SizedBox(height: media.width * 0.04),

                        // Forgot Password
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              context.push('/forgot_password');
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: const Size(50, 30),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              "Quên mật khẩu?", // Updated text
                              style: TextStyle(
                                color: Colors
                                    .orange.shade600, // Darker orange color
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: media.width * 0.06),

                        // Login Button
                        RoundButton(
                          title: viewModel.isLoading
                              ? "Loading..."
                              : "Đăng nhập", // Updated text
                          backgroundColor:
                              const Color(0xFFFF8C00), // Orange color
                          onPressed: () async {
                            if (viewModel.isLoading) return;

                            viewModel.navigationCallback = (String route) {
                              if (mounted) {
                                context.go(route);
                              }
                            };

                            if (viewModel.error.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(viewModel.error),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }

                            final success =
                                await viewModel.loginWithEmailAndPassword();

                            if (success && context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Đăng nhập thành công!'),
                                  backgroundColor: Colors.green,
                                  // duration: Duration(seconds: 3),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'Đã có lỗi xảy ra vui lòng thử lại '),
                                  backgroundColor: Colors.red,
                                  duration: Duration(seconds: 2),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          isLoading: viewModel.isLoading,
                        ),

                        SizedBox(height: media.width * 0.04),
                        const OtherLogin(color1: Colors.grey),
                        SizedBox(height: media.width * 0.04),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Bạn chưa có tài khoản? ",
                              style: TextStyle(
                                color: TColor.gray,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                if (context.mounted) {
                                  context.push('/register');
                                }
                              },
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(50, 30),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                "Đăng ký",
                                style: TextStyle(
                                  color: TColor.color3,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Sign Up Link
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
