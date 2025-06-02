import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/shipper_viewmodel.dart';
import 'package:admin/models/shipper_model.dart';
import 'package:admin/reponsive.dart';
import 'package:admin/screens/main/components/side_menu.dart';

class ShipperScreen extends StatelessWidget {
  const ShipperScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                child: ShipperContent(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShipperContent extends StatefulWidget {
  const ShipperContent({super.key});

  @override
  State<ShipperContent> createState() => _ShipperContentState();
}

class _ShipperContentState extends State<ShipperContent> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    Future.microtask(() => context.read<ShipperViewModel>().loadShippers());
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
            Text(
              'Quản lý Shipper',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Thêm Shipper'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
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
                  hintText: 'Tìm kiếm shipper...',
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
                    value: _selectedStatus,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'all', child: Text('Tất cả')),
                      DropdownMenuItem(
                        value: 'active',
                        child: Text('Đang hoạt động'),
                      ),
                      DropdownMenuItem(
                        value: 'inactive',
                        child: Text('Không hoạt động'),
                      ),
                    ],
                    onChanged: (value) =>
                        setState(() => _selectedStatus = value!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Shipper list
        Expanded(
          child: Consumer<ShipperViewModel>(
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
                        onPressed: () => viewModel.loadShippers(),
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                );
              }

              var filteredShippers = viewModel.shippers;

              // Apply search filter
              if (_searchController.text.isNotEmpty) {
                filteredShippers = viewModel.searchShippers(
                  _searchController.text,
                );
              }

              // Apply status filter
              if (_selectedStatus != 'all') {
                filteredShippers = filteredShippers
                    .where((shipper) => shipper.status == _selectedStatus)
                    .toList();
              }

              if (filteredShippers.isEmpty) {
                return const Center(child: Text('Không tìm thấy shipper nào'));
              }

              return Responsive.isDesktop(context)
                  ? _buildDesktopView(filteredShippers, viewModel)
                  : _buildMobileView(filteredShippers, viewModel);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopView(
    List<ShipperModel> shippers,
    ShipperViewModel viewModel,
  ) {
    return SingleChildScrollView(
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Avatar')),
          DataColumn(label: Text('Tên')),
          DataColumn(label: Text('Số điện thoại')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Trạng thái')),
          DataColumn(label: Text('Thao tác')),
        ],
        rows: shippers.map((shipper) {
          return DataRow(
            cells: [
              DataCell(
                CircleAvatar(
                  backgroundImage: shipper.avatarUrl.isNotEmpty
                      ? NetworkImage(shipper.avatarUrl)
                      : null,
                  child: shipper.avatarUrl.isEmpty
                      ? Text(
                          shipper.name.isNotEmpty
                              ? shipper.name[0].toUpperCase()
                              : '?',
                          style: const TextStyle(fontSize: 24),
                        )
                      : null,
                ),
              ),
              DataCell(Text(shipper.name)),
              DataCell(Text(shipper.phoneNumber)),
              DataCell(Text(shipper.email)),
              DataCell(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        shipper.status == 'active' ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    shipper.status == 'active'
                        ? 'Đang hoạt động'
                        : 'Không hoạt động',
                    style: TextStyle(
                      color: shipper.status == 'active'
                          ? Colors.green
                          : Colors.red,
                    ),
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
                              'Bạn có chắc muốn xóa shipper ${shipper.name}?',
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
                          await viewModel.deleteShipper(shipper.id);
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

  Widget _buildMobileView(
    List<ShipperModel> shippers,
    ShipperViewModel viewModel,
  ) {
    return ListView.builder(
      itemCount: shippers.length,
      itemBuilder: (context, index) {
        final shipper = shippers[index];
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
                      backgroundImage: shipper.avatarUrl.isNotEmpty
                          ? NetworkImage(shipper.avatarUrl)
                          : null,
                      child: shipper.avatarUrl.isEmpty
                          ? Text(
                              shipper.name.isNotEmpty
                                  ? shipper.name[0].toUpperCase()
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
                            shipper.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text('SĐT: ${shipper.phoneNumber}'),
                          Text('Email: ${shipper.email}'),
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
                        color: shipper.status == 'active'
                            ? Colors.green
                            : Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        shipper.status == 'active'
                            ? 'Đang hoạt động'
                            : 'Không hoạt động',
                        style: TextStyle(
                          color: shipper.status == 'active'
                              ? Colors.green
                              : Colors.red,
                        ),
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
                                  'Bạn có chắc muốn xóa shipper ${shipper.name}?',
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
                              await viewModel.deleteShipper(shipper.id);
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
