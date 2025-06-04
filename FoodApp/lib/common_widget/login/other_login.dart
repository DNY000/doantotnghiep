// ignore_for_file: public_member_api_docs, sort_constructors_first

// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
import 'package:foodapp/view/main_tab/main_tab_view.dart';
import 'package:provider/provider.dart';

class OtherLogin extends StatefulWidget {
  final Color color1;

  const OtherLogin({
    Key? key,
    required this.color1,
  }) : super(key: key);

  @override
  State<OtherLogin> createState() => _OtherLoginState();
}

class _OtherLoginState extends State<OtherLogin> {
  bool _isLoadingGoogle = false;
  bool _isLoadingFacebook = false;

  @override
  Widget build(BuildContext context) {
    final loginViewModel = Provider.of<LoginViewModel>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 15),
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: Divider(
                  thickness: 1,
                  color: widget.color1,
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Đăng nhập bằng',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: widget.color1),
                ),
              ),
              Expanded(
                flex: 1,
                child: Divider(
                  thickness: 1,
                  color: widget.color1,
                ),
              ),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Facebook Login Button
            CircleAvatar(
              backgroundColor: Colors.white,
              child: SizedBox(
                width: 40,
                height: 40,
                child: _isLoadingFacebook
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                      )
                    : IconButton(
                        onPressed: (_isLoadingFacebook || _isLoadingGoogle)
                            ? null
                            : () async {
                                try {
                                  setState(() {
                                    _isLoadingFacebook = true;
                                  });

                                  await loginViewModel.loginWithFacebook();

                                  // loginWithFacebook đã được cập nhật để xử lý chuyển màn hình bên trong ViewModel
                                  // và trả về void thay vì bool, nên không cần kiểm tra giá trị trả về nữa
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(loginViewModel
                                                .error.isNotEmpty
                                            ? loginViewModel.error
                                            : 'Đã có lỗi xảy ra vui lòng thử lại'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 2),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  }
                                } finally {
                                  setState(() {
                                    _isLoadingFacebook = false;
                                  });
                                }
                              },
                        icon: const Icon(FontAwesomeIcons.facebook),
                      ),
              ),
            ),

            // Google Login Button
            CircleAvatar(
              backgroundColor: Colors.white,
              child: SizedBox(
                height: 40,
                width: 40,
                child: _isLoadingGoogle
                    ? const CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                      )
                    : IconButton(
                        onPressed: (_isLoadingGoogle || _isLoadingFacebook)
                            ? null
                            : () async {
                                try {
                                  setState(() {
                                    _isLoadingGoogle = true;
                                  });

                                  final success =
                                      await loginViewModel.loginWithGoogle();

                                  setState(() {
                                    _isLoadingGoogle = false;
                                  });

                                  if (success && context.mounted) {
                                    Navigator.pushAndRemoveUntil(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const MainTabView(),
                                      ),
                                      (route) => false,
                                    );
                                  } else if (!success && context.mounted) {
                                    if (loginViewModel.error.isNotEmpty) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(loginViewModel.error),
                                          backgroundColor: Colors.red,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  setState(() {
                                    _isLoadingGoogle = false;
                                  });

                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(loginViewModel
                                                .error.isNotEmpty
                                            ? loginViewModel.error
                                            : 'Đã có lỗi xảy ra vui lòng thử lại'),
                                        backgroundColor: Colors.red,
                                        duration: const Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                        icon: const Icon(
                          FontAwesomeIcons.google,
                          color: Colors.redAccent,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
