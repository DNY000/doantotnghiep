import 'package:admin/models/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:admin/ultils/const/enum.dart';

class OrderModel {
  final String id;
  final String userId;
  final String restaurantId;
  final List<CartItemModel> items;
  final double totalAmount;
  final String address;
  final PaymentMethod paymentMethod;
  final OrderState status;
  final DateTime createdAt;
  final String? note;
  final String? cancelReason;
  final Map<String, dynamic>? delivery;
  final Map<String, dynamic>? metadata;
  final String idShipper;
  final GeoPoint? restaurantLocation;

  const OrderModel({
    required this.id,
    required this.userId,
    required this.restaurantId,
    required this.items,
    required this.totalAmount,
    required this.address,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    this.note,
    this.cancelReason,
    this.delivery,
    this.metadata,
    this.idShipper = "",
    this.restaurantLocation,
  });

  // Tính tổng giá trị đơn hàng
  double get totalPrice {
    return items.fold(0.0, (sum, item) {
      final price = item.price.toDouble();
      final quantity = item.quantity;
      return sum + (price * quantity);
    });
  }

  // Alias cho createdAt để tương thích với code cũ
  DateTime get orderTime => createdAt;

  factory OrderModel.fromMap(Map<String, dynamic> map, [String? docId]) {
    return OrderModel(
      id: docId ?? map['id'] as String,
      userId: map['userId'] as String,
      restaurantId: map['restaurantId'] as String,
      items:
          (map['items'] as List<dynamic>).map((item) {
            final itemMap = item as Map<String, dynamic>;
            itemMap['id'] = itemMap['id'] ?? DateTime.now().toString();
            return CartItemModel.fromMap(itemMap);
          }).toList(),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      address: map['address'] as String,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.toString() == 'PaymentMethod.${map['paymentMethod']}',
      ),
      status: OrderState.values.firstWhere(
        (e) => e.toString() == 'OrderState.${map['status']}',
      ),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      note: map['note'] as String?,
      cancelReason: map['cancelReason'] as String?,
      delivery: map['delivery'] as Map<String, dynamic>?,
      metadata: map['metadata'] as Map<String, dynamic>?,
      idShipper: map['idShipper'] as String? ?? "",
      restaurantLocation: map['restaurantLocation'] as GeoPoint?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'address': address,
      'paymentMethod': paymentMethod.toString().split('.').last,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'note': note,
      'cancelReason': cancelReason,
      'delivery': delivery,
      'metadata': metadata,
      'idShipper': idShipper,
      'restaurantLocation': restaurantLocation,
    };
  }

  // Helper method để hiển thị thông tin đơn hàng ngắn gọn
  Map<String, dynamic> toListView() {
    final firstItem = items.isNotEmpty ? items.first : null;
    final itemsDescription =
        firstItem != null
            ? "${firstItem.foodName} ${items.length > 1 ? 'và ${items.length - 1} món khác' : ''}"
            : "Không có món";

    return {
      'id': id,
      'createdAt': createdAt,
      'status': status.name,
      'totalAmount': totalAmount,
      'itemsDescription': itemsDescription,
      'itemCount': items.length,
    };
  }

  // Copy with method để tạo bản sao với một số thuộc tính được thay đổi
  OrderModel copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    List<CartItemModel>? items,
    double? totalAmount,
    String? address,
    PaymentMethod? paymentMethod,
    OrderState? status,
    DateTime? createdAt,
    String? note,
    String? cancelReason,
    Map<String, dynamic>? delivery,
    Map<String, dynamic>? metadata,
    String? idShipper,
    GeoPoint? restaurantLocation,
  }) {
    return OrderModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      address: address ?? this.address,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      note: note ?? this.note,
      cancelReason: cancelReason ?? this.cancelReason,
      delivery: delivery ?? this.delivery,
      metadata: metadata ?? this.metadata,
      idShipper: idShipper ?? this.idShipper,
      restaurantLocation: restaurantLocation ?? this.restaurantLocation,
    );
  }
}
