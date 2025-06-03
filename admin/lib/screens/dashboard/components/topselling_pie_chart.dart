import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:provider/provider.dart';
import 'package:admin/viewmodels/order_viewmodel.dart';
import 'package:admin/models/food_model.dart'; // Import FoodModel

class TopSellingPieChart extends StatefulWidget {
  const TopSellingPieChart({super.key});

  @override
  State<TopSellingPieChart> createState() => _TopSellingPieChartState();
}

class _TopSellingPieChartState extends State<TopSellingPieChart> {
  List<FoodModel> _topFoods = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    // Gọi hàm lấy dữ liệu khi widget được tạo
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchTopSellingFoods();
    });
  }

  Future<void> _fetchTopSellingFoods() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // Gọi hàm từ ViewModel để lấy dữ liệu từ Repository
      final orderViewModel = context.read<OrderViewModel>();
      // getTopSellingFoods trong OrderViewModel trả về List<FoodModel>
      final result = await orderViewModel.getTopSellingFoods(limit: 6);

      // Log dữ liệu nhận được để kiểm tra cấu trúc (sẽ là List<FoodModel>)
      debugPrint('Fetched top selling foods: $result');

      setState(() {
        _topFoods = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
      debugPrint('Error fetching top selling foods: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
          child:
              Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)));
    }

    if (_topFoods.isEmpty) {
      return const Center(child: Text('Không có dữ liệu món ăn bán chạy.'));
    }

    // Chuyển đổi List<FoodModel> sang List<_PieChartData> cho biểu đồ
    final List<_PieChartData> chartData = _topFoods.map((foodModel) {
      // Sử dụng thuộc tính name và soldCount từ FoodModel
      // **Bạn cần đảm bảo FoodModel có thuộc tính soldCount và là kiểu num/int**
      // Nếu tên thuộc tính khác, hãy chỉnh sửa ở đây
      final name = foodModel.name; // Giả định FoodModel có thuộc tính name
      final soldCount = foodModel
          .soldCount; // Giả định FoodModel có thuộc tính soldCount (num)

      // Chỉ thêm vào nếu số lượng bán > 0
      if (soldCount > 0) {
        return _PieChartData(name, soldCount);
      } else {
        return _PieChartData(name, 0); // Hoặc loại bỏ nếu soldCount <= 0
      }
    }).toList();

    // Lọc bỏ các mục có value <= 0 nếu cần thiết
    final filteredChartData =
        chartData.where((data) => data.value > 0).toList();

    if (filteredChartData.isEmpty) {
      return const Center(child: Text('Không có dữ liệu bán hàng dương.'));
    }

    return Padding(
      padding: const EdgeInsets.all(4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top 6 món ăn bán chạy',
              style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          SfCircularChart(
            title: const ChartTitle(text: 'Số lượng bán'),
            legend: const Legend(isVisible: true),
            series: <CircularSeries>[
              PieSeries<_PieChartData, String>(
                dataSource: filteredChartData,
                xValueMapper: (_PieChartData data, _) => data.category,
                yValueMapper: (_PieChartData data, _) => data.value,
                dataLabelSettings: DataLabelSettings(
                    isVisible: true,
                    labelPosition: ChartDataLabelPosition.inside,
                    builder: (dynamic data, dynamic point, dynamic series,
                        int pointIndex, int seriesIndex) {
                      final total = filteredChartData.fold<num>(
                          0, (sum, item) => sum + item.value);
                      final percentage = (data.value / total) * 100;
                      return Text('${percentage.toStringAsFixed(1)}%');
                    }),
                // pointColorMapper: (_PieChartData data, _) => data.color,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Data model cho biểu đồ tròn
class _PieChartData {
  _PieChartData(this.category, this.value);
  final String category;
  final num value; // Sử dụng num cho số lượng bán
  // final Color? color;
}
