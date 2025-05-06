import 'package:cloud_firestore/cloud_firestore.dart';

class IncomeModel {
  final String? id;
  final String shipperId;
  final DateTime startDate;
  final DateTime endDate;
  final double totalAmount;
  final double deliveryFees;
  final double bonusAmount;
  final double taxAmount;
  final double serviceCharge;
  final double netAmount;
  final String status; // pending, paid, processing
  final int totalOrders;
  final int completedOrders;
  final DateTime? paidDate;
  final String? transactionId;
  final List<OrderIncome> orderIncomes;
  final Map<String, dynamic>? statistics;

  IncomeModel({
    this.id,
    required this.shipperId,
    required this.startDate,
    required this.endDate,
    this.totalAmount = 0.0,
    this.deliveryFees = 0.0,
    this.bonusAmount = 0.0,
    this.taxAmount = 0.0,
    this.serviceCharge = 0.0,
    this.netAmount = 0.0,
    this.status = 'pending',
    this.totalOrders = 0,
    this.completedOrders = 0,
    this.paidDate,
    this.transactionId,
    this.orderIncomes = const [],
    this.statistics,
  });

  Map<String, dynamic> toMap() {
    return {
      'shipperId': shipperId,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'totalAmount': totalAmount,
      'deliveryFees': deliveryFees,
      'bonusAmount': bonusAmount,
      'taxAmount': taxAmount,
      'serviceCharge': serviceCharge,
      'netAmount': netAmount,
      'status': status,
      'totalOrders': totalOrders,
      'completedOrders': completedOrders,
      'paidDate': paidDate != null ? Timestamp.fromDate(paidDate!) : null,
      'transactionId': transactionId,
      'orderIncomes': orderIncomes.map((order) => order.toMap()).toList(),
      'statistics': statistics,
    };
  }

  factory IncomeModel.fromMap(Map<String, dynamic> map, String id) {
    return IncomeModel(
      id: id,
      shipperId: map['shipperId'],
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      totalAmount: map['totalAmount'] ?? 0.0,
      deliveryFees: map['deliveryFees'] ?? 0.0,
      bonusAmount: map['bonusAmount'] ?? 0.0,
      taxAmount: map['taxAmount'] ?? 0.0,
      serviceCharge: map['serviceCharge'] ?? 0.0,
      netAmount: map['netAmount'] ?? 0.0,
      status: map['status'] ?? 'pending',
      totalOrders: map['totalOrders'] ?? 0,
      completedOrders: map['completedOrders'] ?? 0,
      paidDate:
          map['paidDate'] != null
              ? (map['paidDate'] as Timestamp).toDate()
              : null,
      transactionId: map['transactionId'],
      orderIncomes:
          map['orderIncomes'] != null
              ? List<OrderIncome>.from(
                map['orderIncomes'].map((order) => OrderIncome.fromMap(order)),
              )
              : [],
      statistics: map['statistics'],
    );
  }

  IncomeModel copyWith({
    String? id,
    String? shipperId,
    DateTime? startDate,
    DateTime? endDate,
    double? totalAmount,
    double? deliveryFees,
    double? bonusAmount,
    double? taxAmount,
    double? serviceCharge,
    double? netAmount,
    String? status,
    int? totalOrders,
    int? completedOrders,
    DateTime? paidDate,
    String? transactionId,
    List<OrderIncome>? orderIncomes,
    Map<String, dynamic>? statistics,
  }) {
    return IncomeModel(
      id: id ?? this.id,
      shipperId: shipperId ?? this.shipperId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFees: deliveryFees ?? this.deliveryFees,
      bonusAmount: bonusAmount ?? this.bonusAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceCharge: serviceCharge ?? this.serviceCharge,
      netAmount: netAmount ?? this.netAmount,
      status: status ?? this.status,
      totalOrders: totalOrders ?? this.totalOrders,
      completedOrders: completedOrders ?? this.completedOrders,
      paidDate: paidDate ?? this.paidDate,
      transactionId: transactionId ?? this.transactionId,
      orderIncomes: orderIncomes ?? this.orderIncomes,
      statistics: statistics ?? this.statistics,
    );
  }
}

class OrderIncome {
  final String orderId;
  final double amount;
  final double deliveryFee;
  final double? tipAmount;
  final DateTime completedDate;
  final String orderStatus;
  final double distance;
  final String? customerName;
  final String? storeName;
  final bool isPeak;
  final double? bonusAmount;

  OrderIncome({
    required this.orderId,
    required this.amount,
    required this.deliveryFee,
    this.tipAmount,
    required this.completedDate,
    required this.orderStatus,
    required this.distance,
    this.customerName,
    this.storeName,
    this.isPeak = false,
    this.bonusAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'orderId': orderId,
      'amount': amount,
      'deliveryFee': deliveryFee,
      'tipAmount': tipAmount,
      'completedDate': Timestamp.fromDate(completedDate),
      'orderStatus': orderStatus,
      'distance': distance,
      'customerName': customerName,
      'storeName': storeName,
      'isPeak': isPeak,
      'bonusAmount': bonusAmount,
    };
  }

  factory OrderIncome.fromMap(Map<String, dynamic> map) {
    return OrderIncome(
      orderId: map['orderId'],
      amount: map['amount'],
      deliveryFee: map['deliveryFee'],
      tipAmount: map['tipAmount'],
      completedDate: (map['completedDate'] as Timestamp).toDate(),
      orderStatus: map['orderStatus'],
      distance: map['distance'],
      customerName: map['customerName'],
      storeName: map['storeName'],
      isPeak: map['isPeak'] ?? false,
      bonusAmount: map['bonusAmount'],
    );
  }
}

class WeeklyIncomeData {
  final DateTime startDate;
  final DateTime endDate;
  final double amount;
  final int totalOrders;
  final double averagePerDay;
  final String? topDay;
  final double topDayAmount;

  WeeklyIncomeData({
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.totalOrders,
    required this.averagePerDay,
    this.topDay,
    required this.topDayAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'amount': amount,
      'totalOrders': totalOrders,
      'averagePerDay': averagePerDay,
      'topDay': topDay,
      'topDayAmount': topDayAmount,
    };
  }

  factory WeeklyIncomeData.fromMap(Map<String, dynamic> map) {
    return WeeklyIncomeData(
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      amount: map['amount'],
      totalOrders: map['totalOrders'],
      averagePerDay: map['averagePerDay'],
      topDay: map['topDay'],
      topDayAmount: map['topDayAmount'],
    );
  }
}
