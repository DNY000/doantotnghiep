// ignore_for_file: public_member_api_docs, sort_constructors_first

// ignore: must_be_immutable
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Google Login Button with ElevatedButton
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isLoadingGoogle
                    ? null
                    : () async {
                        try {
                          setState(() {
                            _isLoadingGoogle = true;
                          });

                          final success =
                              await loginViewModel.loginWithGoogle();

                          if (mounted) {
                            setState(() {
                              _isLoadingGoogle = false;
                            });
                          }

                          if (success && context.mounted) {
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const MainTabView(),
                              ),
                              (route) => false,
                            );
                          } else if (!success && context.mounted) {
                            if (loginViewModel.error.isNotEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(loginViewModel.error),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            }
                          }
                        } catch (e) {
                          if (mounted) {
                            setState(() {
                              _isLoadingGoogle = false;
                            });
                          }

                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(loginViewModel.error.isNotEmpty
                                    ? loginViewModel.error
                                    : 'Đã có lỗi xảy ra vui lòng thử lại'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                icon: _isLoadingGoogle
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(FontAwesomeIcons.google, color: Colors.red),
                label: const Text(
                  'Đăng nhập với Google',
                  style: TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF8C00),
                  foregroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 2,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
