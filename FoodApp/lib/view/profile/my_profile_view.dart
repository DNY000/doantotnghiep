import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:foodapp/view/authentication/viewmodel/login_viewmodel.dart';
import 'package:foodapp/view/profile/widget/information_user_view.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/data/models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/cupertino.dart';
import '../../ultils/const/color_extension.dart';

class MyProfileView extends StatefulWidget {
  const MyProfileView({super.key});

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;

    try {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);

      if (userViewModel.currentUser != null) {
        return;
      }

      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await Future.microtask(() async {
          await userViewModel.fetchUser(userId);
        });
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();

    return SafeArea(
      child: Scaffold(
        backgroundColor: TColor.bg,
        body: userViewModel.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Column(
                  children: [
                    // Header with user info
                    Container(
                      padding: const EdgeInsets.all(20),
                      color: TColor.orange4,
                      child: SafeArea(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.white,
                                  child: (userViewModel
                                                  .currentUser?.avatarUrl !=
                                              null &&
                                          userViewModel.currentUser!.avatarUrl
                                              .isNotEmpty)
                                      ? ClipOval(
                                          child: Image.network(
                                            userViewModel
                                                .currentUser!.avatarUrl,
                                            width:
                                                60, // Twice the radius for fill
                                            height:
                                                60, // Twice the radius for fill
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              // Fallback to initial if network image fails
                                              return const Icon(Icons.person);
                                            },
                                          ),
                                        )
                                      : Text(
                                          (userViewModel.currentUser?.name
                                                      .isNotEmpty ==
                                                  true)
                                              ? userViewModel.currentUser!.name
                                                  .substring(0, 1)
                                                  .toUpperCase()
                                              : 'U',
                                          style: const TextStyle(
                                            fontSize: 24,
                                            fontWeight: FontWeight.bold,
                                            color: Colors
                                                .green, // Or a suitable default color
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        userViewModel.currentUser?.name ??
                                            'User',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        userViewModel.currentUser?.email ?? '',
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Menu sections
                    const SizedBox(height: 20),
                    _buildSection(
                      'Tài khoản',
                      [
                        _buildMenuItem(
                          icon: Icons.person_outline,
                          title: 'Thông tin cá nhân',
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const InformationUserView(),
                              ),
                            );
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.payment,
                          title: 'Quản lý phương thức thanh toán',
                          onTap: () {
                            // TODO: Navigate to payment methods
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    _buildSection(
                      'Cài đặt',
                      [
                        _buildMenuItem(
                          icon: Icons.settings_outlined,
                          title: 'Cài đặt chung',
                          onTap: () {
                            // TODO: Navigate to general settings
                          },
                        ),
                        _buildMenuItem(
                          icon: Icons.lock_outline,
                          title: 'Quyền riêng tư',
                          onTap: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () => _showLogoutConfirmation(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.logout, color: Colors.white),
                              SizedBox(width: 8),
                              Text(
                                'Đăng xuất',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: items),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.black12, width: 0.5),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.black54, size: 24),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black54),
          ],
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(CupertinoIcons.exclamationmark_triangle,
                  color: TColor.color1),
              const SizedBox(width: 8),
              const Text("Đăng xuất"),
            ],
          ),
          content:
              const Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
              },
              child: Text("Hủy", style: TextStyle(color: TColor.gray)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: TColor.color1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text("Đăng xuất",
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _performLogout(BuildContext context) async {
    final loginViewModel = context.read<LoginViewModel>();

    try {
      loginViewModel.navigationCallback = (String route) {
        if (route == '/login') {
          Future.microtask(() {
            if (context.mounted) {
              context.go('/login');
            }
          });
        }
      };

      await loginViewModel.logOut();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi đăng xuất: $e'),
          backgroundColor: TColor.color1,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
