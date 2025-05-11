import 'package:foodapp/data/models/cart_item_model.dart';

class DraftOrderModel {
  final String id;
  final String restaurantId;
  final List<CartItemModel> items;
  final double totalAmount;
  final DateTime createdAt;

  DraftOrderModel({
    required this.id,
    required this.restaurantId,
    required this.items,
    required this.totalAmount,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'restaurantId': restaurantId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DraftOrderModel.fromJson(Map<String, dynamic> json) {
    return DraftOrderModel(
      id: json['id'],
      restaurantId: json['restaurantId'],
      items: (json['items'] as List)
          .map((item) => CartItemModel.fromMap(item))
          .toList(),
      totalAmount: json['totalAmount'],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }
}
