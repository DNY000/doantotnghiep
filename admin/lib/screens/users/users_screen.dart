import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/user_viewmodel.dart';
import 'package:admin/models/user_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';
import 'package:admin/ultils/const/enum.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Add AppBar for mobile view
      appBar: Responsive.isMobile(context)
          ? AppBar(
              leading: Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              ),
              title: Text('Quản lý Người dùng',
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(color: Colors.white)),
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
            )
          : null,
      // Use SideMenu as drawer on mobile
      drawer: Responsive.isMobile(context) ? const SideMenu() : null,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (Responsive.isDesktop(context))
            const Expanded(flex: 1, child: SideMenu()),
          const Expanded(
            flex: 5,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: UsersContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UsersContent extends StatefulWidget {
  const UsersContent({super.key});

  @override
  State<UsersContent> createState() => _UsersContentState();
}

class _UsersContentState extends State<UsersContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedRole = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<UserViewModel>().getAllUsers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Hide title on mobile as it's in AppBar
            if (!Responsive.isMobile(context))
              Text(
                'Quản lý Người dùng',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Thêm Người dùng'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Search and filter section
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Tìm kiếm người dùng...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                onChanged: (value) => setState(() {}),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRole,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                      DropdownMenuItem(
                        value: 'user',
                        child: Text('Người dùng'),
                      ),
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedRole = value!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Users list
        Expanded(
          child: Consumer<UserViewModel>(
            builder: (context, viewModel, child) {
              if (viewModel.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (viewModel.error != null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(viewModel.error!),
                      ElevatedButton(
                        onPressed: () => viewModel.getAllUsers(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              var filteredUsers = viewModel.users;

              // Apply search filter
              if (_searchController.text.isNotEmpty) {
                filteredUsers = filteredUsers.where((user) {
                  final searchLower = _searchController.text.toLowerCase();
                  return user.name.toLowerCase().contains(searchLower) ||
                      user.email?.toLowerCase().contains(searchLower) == true ||
                      user.phoneNumber.toLowerCase().contains(searchLower);
                }).toList();
              }

              // Apply role filter
              if (_selectedRole != 'all') {
                filteredUsers = filteredUsers
                    .where((user) => user.role.name == _selectedRole)
                    .toList();
              }

              if (filteredUsers.isEmpty) {
                return const Center(
                  child: Text('Không tìm thấy người dùng nào'),
                );
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredUsers, viewModel)
                  : _buildMobileView(filteredUsers, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(List<UserModel> users, UserViewModel viewModel) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Avatar')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Số điện thoại')),
          DataColumn(label: Text('Vai trò')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: users.map((user) {
          return DataRow(
            cells: [
              DataCell(
                CircleAvatar(
                  backgroundImage: user.avatarUrl.isNotEmpty
                      ? NetworkImage(user.avatarUrl)
                      : null,
                  child: user.avatarUrl.isEmpty
                      ? Text(
                          user.name.isNotEmpty
                              ? user.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
              ),
              DataCell(Text(user.name)),
              DataCell(Text(user.email ?? '')),
              DataCell(Text(user.phoneNumber)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: user.role == Role.admin ? Colors.blue : Colors.green,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    user.role == Role.admin ? 'Admin' : 'Người dùng',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              DataCell(
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Xác nhận xóa'),
                            content: Text(
                              'Bạn có chắc muốn xóa người dùng ${user.name}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Hủy'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Xóa'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await viewModel.deleteUser(user.id);
                          await viewModel.getAllUsers();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMobileView(List<UserModel> users, UserViewModel viewModel) {
    return ListView.builder(
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: user.avatarUrl.isNotEmpty
                          ? NetworkImage(user.avatarUrl)
                          : null,
                      child: user.avatarUrl.isEmpty
                          ? Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(fontSize: 24),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('Email: ${user.email ?? "N/A"}'),
                          Text('SĐT: ${user.phoneNumber}'),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: user.role == Role.admin
                            ? Colors.blue
                            : Colors.green,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        user.role == Role.admin ? 'Admin' : 'Người dùng',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            final confirmed = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Xác nhận xóa'),
                                content: Text(
                                  'Bạn có chắc muốn xóa người dùng ${user.name}?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Hủy'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Xóa'),
                                  ),
                                ],
                              ),
                            );

                            if (confirmed == true) {
                              await viewModel.deleteUser(user.id);
                              await viewModel.getAllUsers();
                            }
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
