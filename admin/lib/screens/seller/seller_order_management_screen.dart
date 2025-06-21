import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../routes/seller_router.dart';
import 'package:admin/screens/seller/components/seller_side_menu.dart';
import 'package:admin/responsive.dart';

class SellerOrderManagementScreen extends StatefulWidget {
  final bool showDetailDialog;
  final String? orderId;

  const SellerOrderManagementScreen({
    Key? key,
    this.showDetailDialog = false,
    this.orderId,
  }) : super(key: key);

  @override
  State<SellerOrderManagementScreen> createState() => _SellerOrderScreenState();
}

class _SellerOrderScreenState extends State<SellerOrderManagementScreen> {
  String _selectedStatus = 'Tất cả';

  @override
  void initState() {
    super.initState();
    if (widget.showDetailDialog && widget.orderId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showOrderDetailDialog(widget.orderId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: Responsive.isMobile(context) ? null : GlobalKey<ScaffoldState>(),
      drawer: Responsive.isMobile(context) ? const SellerSideMenu() : null,
      appBar: AppBar(
        title: const Text('Quản lý đơn hàng'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                flex: 1,
                child: SellerSideMenu(),
              ),
            Expanded(
              flex: 5,
              child: Column(
                children: [
                  // Status Filter
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildStatusChip('Tất cả'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Chờ xác nhận'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Đang chuẩn bị'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Đang giao'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Hoàn thành'),
                          const SizedBox(width: 8),
                          _buildStatusChip('Đã hủy'),
                        ],
                      ),
                    ),
                  ),
                  // Order List
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 0, // TODO: Add orders
                      itemBuilder: (context, index) {
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(
                              child: Icon(Icons.shopping_cart),
                            ),
                            title: const Text('No orders yet'),
                            subtitle: const Text('Orders will appear here'),
                            trailing: PopupMenuButton(
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'view',
                                  child: Text('Xem chi tiết'),
                                ),
                                const PopupMenuItem(
                                  value: 'confirm',
                                  child: Text('Xác nhận'),
                                ),
                                const PopupMenuItem(
                                  value: 'cancel',
                                  child: Text('Hủy đơn'),
                                ),
                              ],
                              onSelected: (value) {
                                // TODO: Implement order actions
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isSelected = _selectedStatus == status;
    return FilterChip(
      label: Text(status),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedStatus = status;
        });
      },
    );
  }

  void _showOrderDetailDialog(String orderId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chi tiết đơn hàng'),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Mã đơn hàng: #12345'),
              SizedBox(height: 8),
              Text('Trạng thái: Chờ xác nhận'),
              SizedBox(height: 8),
              Text('Thời gian đặt: 12:00 01/01/2024'),
              SizedBox(height: 16),
              Text('Danh sách món:'),
              SizedBox(height: 8),
              Text('• Món 1 - 50.000đ'),
              Text('• Món 2 - 75.000đ'),
              SizedBox(height: 16),
              Text('Tổng tiền: 125.000đ'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đóng'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement order confirmation
              Navigator.pop(context);
            },
            child: const Text('Xác nhận đơn'),
          ),
        ],
      ),
    );
  }
}
