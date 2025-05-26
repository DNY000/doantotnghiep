import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shipper_app/screens/wallet/naptien.dart';

class WalletScreens extends StatefulWidget {
  const WalletScreens({super.key});

  @override
  State<WalletScreens> createState() => _WalletScreensState();
}

class _WalletScreensState extends State<WalletScreens> {
  final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
  double _walletBalance = 0; // Số dư ví demo

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví của tôi'),
        centerTitle: true,
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Số dư ví
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Tài khoản chính',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(_walletBalance),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Nút nạp tiền và rút tiền
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.add,
                      label: 'Nạp tiền',
                      onTap: () async {
                        // Mở màn hình nạp tiền và chờ kết quả
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DepositScreen(
                                  shipperId:
                                      '123456', // Thay bằng ID shipper thực tế
                                ),
                          ),
                        );

                        // Nếu nạp tiền thành công, cập nhật lại giao diện
                        if (result == true) {
                          setState(() {
                            // Demo: Tăng số dư 100,000 đ
                            _walletBalance += 100000;
                          });
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildActionButton(
                      icon: Icons.account_balance_wallet,
                      label: 'Rút tiền',
                      onTap: () {},
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            const Divider(height: 1),

            // Danh sách các tính năng
            _buildMenuItem(
              icon: Icons.account_balance,
              title: 'Tài khoản kỳ quỹ',
              trailing: '0đ',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.receipt_long,
              title: 'Giao dịch',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.bar_chart,
              title: 'Báo cáo thu nhập',
              onTap: () {},
            ),
            _buildMenuItem(
              icon: Icons.history,
              title: 'Lịch sử nạp & rút tiền',
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Theme.of(context).primaryColor),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing:
          trailing != null
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(trailing, style: const TextStyle(color: Colors.grey)),
                  const Icon(Icons.chevron_right),
                ],
              )
              : const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
