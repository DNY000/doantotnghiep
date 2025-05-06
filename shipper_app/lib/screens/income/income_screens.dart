// import 'package:flutter/material.dart';
// import 'package:syncfusion_flutter_charts/charts.dart';
// import 'package:intl/intl.dart';

// class IncomeScreens extends StatefulWidget {
//   const IncomeScreens({super.key});

//   @override
//   State<IncomeScreens> createState() => _IncomeScreensState();
// }

// class _IncomeScreensState extends State<IncomeScreens> {
//   final currencyFormat = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');
//   final List<WeeklyIncome> weeklyIncomes = [
//     WeeklyIncome(
//       startDate: DateTime(2024, 6, 6),
//       endDate: DateTime(2024, 6, 12),
//     ),
//     WeeklyIncome(
//       startDate: DateTime(2024, 6, 13),
//       endDate: DateTime(2024, 6, 19),
//     ),
//     WeeklyIncome(
//       startDate: DateTime(2024, 6, 20),
//       endDate: DateTime(2024, 6, 26),
//     ),
//     WeeklyIncome(
//       startDate: DateTime(2024, 6, 27),
//       endDate: DateTime(2024, 7, 3),
//     ),
//     WeeklyIncome(
//       startDate: DateTime(2024, 7, 4),
//       endDate: DateTime(2024, 7, 10),
//     ),
//   ];

//   // Sample income data for chart
//   List<IncomeData> chartData = [
//     IncomeData(1, 500000),
//     IncomeData(2, 600000),
//     IncomeData(3, 550000),
//     IncomeData(4, 700000),
//     IncomeData(5, 629500),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Thu nhập'), centerTitle: true),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Thông tin thu nhập hiện tại
//             Container(
//               padding: const EdgeInsets.all(16),
//               color: Theme.of(context).primaryColor,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         'Bạn có thể nhận được:',
//                         style: Theme.of(
//                           context,
//                         ).textTheme.titleMedium?.copyWith(color: Colors.white),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           // TODO: Implement rút tiền
//                         },
//                         style: TextButton.styleFrom(
//                           backgroundColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 16,
//                             vertical: 8,
//                           ),
//                         ),
//                         child: const Text('Rút tiền'),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     currencyFormat.format(629500),
//                     style: Theme.of(context).textTheme.headlineMedium?.copyWith(
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 16),
//                   Text(
//                     'Dữ liệu đã được cập nhật lúc ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
//                     style: Theme.of(
//                       context,
//                     ).textTheme.bodySmall?.copyWith(color: Colors.white70),
//                   ),
//                 ],
//               ),
//             ),

//             // Biểu đồ thu nhập theo tuần với Syncfusion
//             Container(
//               padding: const EdgeInsets.all(16),
//               height: 300,
//               child: SfCartesianChart(
//                 primaryXAxis: CategoryAxis(
//                   title: AxisTitle(text: 'Tuần'),
//                   labelStyle: const TextStyle(fontSize: 12),
//                 ),
//                 primaryYAxis: NumericAxis(
//                   numberFormat: NumberFormat.compact(locale: 'vi_VN'),
//                   labelStyle: const TextStyle(fontSize: 12),
//                   axisLine: const AxisLine(width: 0),
//                   majorTickLines: const MajorTickLines(size: 0),
//                 ),
//                 series: <ChartSeries>[
//                   SplineAreaSeries<IncomeData, int>(
//                     dataSource: chartData,
//                     xValueMapper: (IncomeData data, _) => data.week,
//                     yValueMapper: (IncomeData data, _) => data.amount,
//                     color: Theme.of(context).primaryColor.withOpacity(0.2),
//                     borderColor: Theme.of(context).primaryColor,
//                     borderWidth: 3,
//                     markerSettings: MarkerSettings(
//                       isVisible: true,
//                       color: Theme.of(context).primaryColor,
//                       borderColor: Colors.white,
//                       borderWidth: 2,
//                     ),
//                   ),
//                 ],
//                 tooltipBehavior: TooltipBehavior(
//                   enable: true,
//                   format: 'Tuần \${point.x}: ${currencyFormat.format(0)}',
//                   header: '',
//                 ),
//               ),
//             ),

//             // Danh sách thu nhập theo tuần
//             ListView.builder(
//               shrinkWrap: true,
//               physics: const NeverScrollableScrollPhysics(),
//               itemCount: weeklyIncomes.length,
//               itemBuilder: (context, index) {
//                 final week = weeklyIncomes[index];
//                 return ListTile(
//                   title: Text(
//                     'Tuần ${DateFormat('dd/MM').format(week.startDate)}-${DateFormat('dd/MM').format(week.endDate)}',
//                   ),
//                   trailing: const Icon(Icons.chevron_right),
//                   onTap: () {
//                     // TODO: Navigate to weekly detail
//                   },
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// // Lớp dữ liệu cho biểu đồ
// class IncomeData {
//   final int week;
//   final double amount;

//   IncomeData(this.week, this.amount);
// }

// class WeeklyIncome {
//   final DateTime startDate;
//   final DateTime endDate;
//   final double amount;
//   final double serviceRate;
//   final double tax;

//   WeeklyIncome({
//     required this.startDate,
//     required this.endDate,
//     this.amount = 0,
//     this.serviceRate = 0,
//     this.tax = 0,
//   });
// }
