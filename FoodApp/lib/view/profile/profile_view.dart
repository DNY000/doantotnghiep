import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:foodapp/ultils/const/color_extension.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    // Load user data when the view is initialized
    Future.microtask(() => context.read<UserViewModel>().loadCurrentUser());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin tài khoản',
            style: TextStyle(color: Colors.black)),
      ),
      body: Consumer<UserViewModel>(
        builder: (context, userVM, child) {
          if (userVM.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (userVM.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(userVM.error!),
                  ElevatedButton(
                    onPressed: () => userVM.loadCurrentUser(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final user = userVM.currentUser;
          if (user == null) {
            return const Center(
              child: Text('Không tìm thấy thông tin người dùng'),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: TColor.primary,
                        child: Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            fontSize: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(color: TColor.primary),
                          ),
                          child: Icon(
                            Icons.camera_alt,
                            size: 20,
                            color: TColor.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _buildInfoSection(
                  title: 'Thông tin cá nhân',
                  children: [
                    _buildInfoRow(
                      icon: Icons.person,
                      label: 'Họ và tên',
                      value: user.name ?? '',
                    ),
                    _buildInfoRow(
                      icon: Icons.cake,
                      label: 'Ngày sinh',
                      value: user.dateOfBirth?.toString() ?? 'Chưa cập nhật',
                    ),
                    _buildInfoRow(
                      icon: Icons.person_outline,
                      label: 'Giới tính',
                      value: user.gender ?? 'Chưa cập nhật',
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildInfoSection(
                  title: 'Thông tin liên hệ',
                  children: [
                    _buildInfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: user.email ?? 'Chưa cập nhật',
                    ),
                    _buildInfoRow(
                      icon: Icons.phone,
                      label: 'Số điện thoại',
                      value: user.phoneNumber ?? 'Chưa cập nhật',
                    ),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'Địa chỉ',
                      value: user.defaultAddress?.street ?? 'Chưa cập nhật',
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const UpdateProfileView(),
                      //   ),
                      // );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TColor.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: const Text(
                      'Cập nhật thông tin',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
