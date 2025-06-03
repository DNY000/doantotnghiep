import 'package:admin/screens/dashboard/components/topselling_pie_chart.dart';
import 'package:admin/screens/dashboard/components/user_registration_chart.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Row 1: Summary Cards
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _SummaryCard(
                      title: 'Đơn hàng hôm nay',
                      value: '120',
                      icon: Icons.shopping_cart,
                      color: Colors.blue),
                  _SummaryCard(
                      title: 'Doanh thu hôm nay',
                      value: '12.5tr',
                      icon: Icons.attach_money,
                      color: Colors.green),
                  _SummaryCard(
                      title: 'Nhà hàng mới',
                      value: '2',
                      icon: Icons.store,
                      color: Colors.purple),
                  _SummaryCard(
                      title: 'Shipper mới',
                      value: '3',
                      icon: Icons.delivery_dining,
                      color: Colors.teal),
                ],
              ),
              const SizedBox(height: 32),
              // Row 2: Main Charts
              const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Main charts
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        UserRegistrationChart(),
                        SizedBox(height: 24),
                        _FakeChart(title: 'Top món ăn bán chạy'),
                      ],
                    ),
                  ),
                  SizedBox(width: 24),
                  // Right: Pie chart + stats
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        _FakePieChart(title: 'Tỉ lệ trạng thái đơn hàng'),
                        // SizedBox(height: 24),
                        // _MiniStatCard(title: 'Shipper hoạt động', value: '18'),
                        // SizedBox(height: 12),
                        // _MiniStatCard(title: 'Đơn chờ xử lý', value: '7'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              // Row 3: Recent Orders Table
              Text('Đơn hàng gần đây',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              _FakeOrderTable(),
              const SizedBox(
                height: 24,
              ),
              const TopSellingPieChart()
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  const _SummaryCard(
      {required this.title,
      required this.value,
      required this.icon,
      required this.color});
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(value,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class _FakeChart extends StatelessWidget {
  final String title;
  const _FakeChart({required this.title});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        height: 200,
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Center(
            child: Text('Biểu đồ: $title',
                style: const TextStyle(color: Colors.grey))),
      ),
    );
  }
}

class _FakePieChart extends StatelessWidget {
  final String title;
  const _FakePieChart({required this.title});
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: const SizedBox(
          height: 500, width: double.infinity, child: TopSellingPieChart()),
    );
  }
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  const _MiniStatCard({required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _FakeOrderTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Mã đơn')),
          DataColumn(label: Text('Khách hàng')),
          DataColumn(label: Text('Nhà hàng')),
          DataColumn(label: Text('Tổng tiền')),
          DataColumn(label: Text('Trạng thái')),
        ],
        rows: const [
          DataRow(cells: [
            DataCell(Text('DH001')),
            DataCell(Text('Nguyễn Văn A')),
            DataCell(Text('Pizza Hut')),
            DataCell(Text('250.000đ')),
            DataCell(Text('Đã giao')),
          ]),
          DataRow(cells: [
            DataCell(Text('DH002')),
            DataCell(Text('Trần Thị B')),
            DataCell(Text('KFC')),
            DataCell(Text('180.000đ')),
            DataCell(Text('Đang giao')),
          ]),
          DataRow(cells: [
            DataCell(Text('DH003')),
            DataCell(Text('Lê Văn C')),
            DataCell(Text('Lotteria')),
            DataCell(Text('320.000đ')),
            DataCell(Text('Đã hủy')),
          ]),
        ],
      ),
    );
  }
}
