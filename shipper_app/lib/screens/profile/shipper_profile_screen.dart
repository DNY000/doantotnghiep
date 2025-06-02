import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../models/shipper_model.dart';

class ShipperProfileScreen extends StatefulWidget {
  const ShipperProfileScreen({super.key});

  @override
  State<ShipperProfileScreen> createState() => _ShipperProfileScreenState();
}

class _ShipperProfileScreenState extends State<ShipperProfileScreen> {
  ShipperModel? _shipper;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShipperData();
  }

  Future<void> _loadShipperData() async {
    try {
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
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading shipper data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông tin cá nhân'),
        actions: [IconButton(icon: const Icon(Icons.edit), onPressed: () {})],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _shipper == null
              ? const Center(child: Text('Không tìm thấy thông tin'))
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar và thông tin cơ bản
                    Center(
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundImage:
                                _shipper!.avatarUrl.isNotEmpty
                                    ? NetworkImage(_shipper!.avatarUrl)
                                    : null,
                            child:
                                _shipper!.avatarUrl.isEmpty
                                    ? const Icon(Icons.person, size: 50)
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _shipper!.name,
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _shipper!.phoneNumber,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Thông tin cá nhân
                    _buildInfoSection('Thông tin cá nhân', [
                      _buildInfoItem('Email', _shipper!.email, Icons.email),
                      _buildInfoItem(
                        'Số điện thoại',
                        _shipper!.phoneNumber,
                        Icons.phone,
                      ),
                      _buildInfoItem(
                        'Địa chỉ',
                        _shipper!.address,
                        Icons.location_on,
                      ),
                      _buildInfoItem(
                        'Ngày tham gia',
                        _formatDate(_shipper!.createdAt),
                        Icons.calendar_today,
                      ),
                    ]),
                    const SizedBox(height: 24),

                    // Thống kê
                    _buildInfoSection('Thống kê', [
                      _buildInfoItem(
                        'Đánh giá',
                        '${_shipper!.rating.toStringAsFixed(1)} ⭐',
                        Icons.star,
                      ),
                      // _buildInfoItem(
                      //   'Tổng đơn hàng',
                      //   '${_shipper!.totalDeliveries} đơn',
                      //   Icons.local_shipping,
                      // ),
                      // _buildInfoItem(
                      //   'Đơn hoàn thành',
                      //   '${_shipper!.completedDeliveries} đơn',
                      //   Icons.check_circle,
                      // ),
                    ]),
                    const SizedBox(height: 24),

                    // Thông tin xe
                    _buildInfoSection('Thông tin xe', [
                      // _buildInfoItem(
                      //   'Loại xe',
                      //   _shipper!.vehicleType.isEmpty
                      //       ? 'Chưa cập nhật'
                      //       : _shipper!.vehicleType,
                      //   Icons.directions_bike,
                      // ),
                      // _buildInfoItem(
                      //   'Biển số xe',
                      //   _shipper!.licensePlate.isEmpty
                      //       ? 'Chưa cập nhật'
                      //       : _shipper!.licensePlate,
                      //   Icons.confirmation_number,
                      // ),
                    ]),
                  ],
                ),
              ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).primaryColor),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
