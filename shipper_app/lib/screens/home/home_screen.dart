import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shipper_app/models/order_model.dart';
import 'package:shipper_app/repository/location_provider.dart';
import 'package:shipper_app/screens/history/history_screens.dart';
import 'package:shipper_app/screens/notifications/notification_screens.dart';
import 'package:shipper_app/screens/order/order_screens.dart';
import 'package:shipper_app/screens/wallet/wallet_screens.dart';
import 'package:shipper_app/viewmodels/order_viewmodel.dart';
import '../../models/shipper_model.dart';
import 'package:provider/provider.dart';
import '../profile/shipper_profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isAvailable = false;
  ShipperModel? _shipper;

  @override
  void initState() {
    super.initState();
    _loadShipperData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().initLocation(context);
    });
  }

  Future<void> _loadShipperData() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('shippers')
              .doc(userId)
              .get();
      if (doc.exists) {
        setState(() {
          _shipper = ShipperModel.fromMap(doc.data()!, doc.id);
          _isAvailable = _shipper!.isActive;
        });
      }
    }
  }

  Future<void> _toggleAvailability() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      setState(() {
        _isAvailable = !_isAvailable;
      });

      await FirebaseFirestore.instance
          .collection('shippers')
          .doc(userId)
          .update({
            'stats.isAvailable': _isAvailable,
            'metadata.lastUpdated': FieldValue.serverTimestamp(),
          });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<LocationProvider>(
        builder: (context, locationProvider, child) {
          if (locationProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final currentLocation = locationProvider.currentLocation;
          if (currentLocation == null) {
            return const Center(
              child: Text(
                'Không thể lấy vị trí. Vui lòng kiểm tra quyền truy cập.',
              ),
            );
          }

          return SafeArea(
            child: Column(
              children: [
                // Header với avatar và thông tin người dùng
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (_shipper != null)
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 20,
                                  backgroundImage:
                                      _shipper!.avatarUrl.isNotEmpty
                                          ? NetworkImage(_shipper!.avatarUrl)
                                          : null,
                                  child:
                                      _shipper!.avatarUrl.isEmpty
                                          ? const Icon(Icons.person, size: 20)
                                          : null,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _shipper!.name,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _isAvailable ? Colors.green : Colors.grey,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _isAvailable
                                      ? Icons.check_circle
                                      : Icons.pause_circle,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _isAvailable ? 'Đang hoạt động' : 'Tạm dừng',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Switch(
                                  value: _isAvailable,
                                  onChanged: (value) => _toggleAvailability(),
                                  activeColor: Colors.white,
                                  activeTrackColor: Colors.green,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Grid các chức năng
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: GridView.count(
                          padding: const EdgeInsets.all(16),
                          crossAxisCount: 2,
                          mainAxisSpacing: 16,
                          crossAxisSpacing: 16,
                          children: [
                            _buildFunctionCard(
                              context,
                              'Thông tin cá nhân',
                              'Xem & chỉnh sửa',
                              Icons.person,
                              Colors.blue,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            const ShipperProfileScreen(),
                                  ),
                                );
                              },
                            ),
                            Selector<OrderViewModel, List<OrderModel>>(
                              selector:
                                  (context, viewModel) =>
                                      viewModel.shipperOrders,
                              builder: (context, orders, child) {
                                return _buildFunctionCard(
                                  context,
                                  'Đơn Giao Hàng',
                                  '${orders.length} đơn mới',
                                  Icons.shopping_bag,
                                  Colors.orange,
                                  onTap:
                                      () => Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) => const OrderScreen(),
                                        ),
                                      ),
                                );
                              },
                            ),
                            _buildFunctionCard(
                              context,
                              'Thông báo',
                              '0 thông báo mới',
                              Icons.notifications,
                              Colors.purple,
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const NotificationScreens(),
                                    ),
                                  ),
                            ),
                            _buildFunctionCard(
                              context,
                              'Ví',
                              '0đ',
                              Icons.account_balance_wallet,
                              Colors.green,
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const WalletScreens(),
                                    ),
                                  ),
                            ),
                            _buildFunctionCard(
                              context,
                              'Thu nhập',
                              '0đ hôm nay',
                              Icons.attach_money,
                              Colors.red,
                              onTap: () {},
                              // () => Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //     builder:
                              //         (context) => const IncomeScreens(),
                              //   ),
                              // ),
                            ),
                            _buildFunctionCard(
                              context,
                              'Lịch sử',
                              'Xem lịch sử giao hàng',
                              Icons.history,
                              Colors.blueGrey,
                              onTap:
                                  () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => const HistoryScreens(),
                                    ),
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Nút đăng xuất ở dưới cùng
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _signOut,
                            icon: const Icon(Icons.logout),
                            label: const Text('Đăng xuất'),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFunctionCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: color),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
