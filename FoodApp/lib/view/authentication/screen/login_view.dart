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
    // Gọi autoLogin sau khi frame được build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final viewModel = Provider.of<LoginViewModel>(context, listen: false);

        // Đặt callback điều hướng cho ViewModel
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

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        body: viewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Form(
                  key: viewModel.formKey,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: SizedBox(
                      width: media.width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 32),
                          // Logo or App Name with Icon
                          Container(
                            width: 120,
                            height: 140,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/logo/foodapp.jpg',
                                filterQuality: FilterQuality.high,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),

                          SizedBox(height: media.width * 0.06),
                          // Text(
                          //   "Food APP",
                          //   style: TextStyle(
                          //     color: TColor.text,
                          //     fontSize: 28,
                          //     fontWeight: FontWeight.w700,
                          //   ),
                          // ),
                          // SizedBox(height: media.width * 0.02),
                          Text(
                            "Đăng nhập để tiếp tục",
                            style: TextStyle(
                              color: TColor.gray,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: media.width * 0.12),

                          // Email Field
                          Container(
                            height: 50,
                            child: TextFormField(
                              controller: viewModel.txtEmail,
                              keyboardType: TextInputType.emailAddress,
                              validator: viewModel.validateEmail,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: TColor.gray, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: TColor.color3, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                suffixIcon: Icon(
                                  Icons.email_outlined,
                                  color: TColor.gray,
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Password Field
                          Container(
                            height: 50,
                            child: TextFormField(
                              controller: viewModel.txtPassword,
                              obscureText: isShowPassword,
                              validator: viewModel.validatePassword,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              decoration: InputDecoration(
                                hintText: "Mật khẩu",
                                hintStyle: TextStyle(
                                  color: TColor.gray,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: TColor.gray, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: TColor.color3, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.red, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  color: TColor.gray,
                                  size: 18,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isShowPassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    color: TColor.gray,
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
                          ),
                          SizedBox(height: media.width * 0.02),

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
                                "Quên mật khẩu?",
                                style: TextStyle(
                                  color: TColor.color3,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: media.width * 0.04),

                          // Login Button
                          RoundButton(
                            title: viewModel.isLoading
                                ? "Đang đăng nhập..."
                                : "Đăng nhập",
                            onPressed: () async {
                              if (viewModel.isLoading) return;

                              // Luôn đặt callback điều hướng trước khi đăng nhập
                              viewModel.navigationCallback = (String route) {
                                if (mounted) {
                                  context.go(route);
                                }
                              };

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
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
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
      ),
    );
  }
}
