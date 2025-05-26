import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/data/models/order_model.dart';
import 'package:foodapp/data/models/shipper_model.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:intl/intl.dart';
import 'package:foodapp/data/repositories/food_repository.dart';

class OrderRepository {
  final FirebaseFirestore _firestore;
  final String _collection = 'orders';

  OrderRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // Tạo đơn hàng mới
  Future<String> createOrder(OrderModel order) async {
    try {
      final docRef = _firestore.collection(_collection).doc();
      final orderWithId = order.copyWith(id: docRef.id);
      await docRef.set(orderWithId.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Không thể tạo đơn hàng: $e');
    }
  }

  // Lấy danh sách đơn hàng của người dùng
  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Lấy chi tiết một đơn hàng
  Future<OrderModel?> getOrderById(String orderId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(orderId).get();
      if (!doc.exists) return null;
      return OrderModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw Exception('Không thể lấy thông tin đơn hàng: $e');
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, OrderState newStatus) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': newStatus.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái đơn hàng: $e');
    }
  }

  // Hủy đơn hàng
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': OrderState.cancelled.toString().split('.').last,
        'cancelReason': reason,
      });
    } catch (e) {
      throw Exception('Không thể hủy đơn hàng: $e');
    }
  }

  // Lấy đơn hàng của nhà hàng
  Stream<List<OrderModel>> getRestaurantOrders(String restaurantId) {
    return _firestore
        .collection(_collection)
        .where('restaurantId', isEqualTo: restaurantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Lấy số lượng đơn hàng theo trạng thái
  Future<int> getOrderCountByStatus(String userId, OrderState status) async {
    try {
      final snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: status.toString().split('.').last)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      throw Exception('Không thể lấy số lượng đơn hàng: $e');
    }
  }

  // Cập nhật thông tin giao hàng
  Future<void> updateDeliveryInfo(
      String orderId, Map<String, dynamic> deliveryInfo) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'delivery': deliveryInfo,
        'metadata.lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật thông tin giao hàng: $e');
    }
  }

  // Lấy đơn hàng theo ngày
  Future<List<OrderModel>> getOrders({
    DateTime? fromDate,
    DateTime? toDate,
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore.collection(_collection);

      if (fromDate != null) {
        query = query.where('metadata.orderTime',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }

      if (toDate != null) {
        query = query.where('metadata.orderTime',
            isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }

      if (status != null) {
        query = query.where('metadata.status', isEqualTo: status.name);
      }

      query =
          query.orderBy('metadata.orderTime', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách đơn hàng: $e');
    }
  }

  // Lấy đơn hàng theo khách hàng
  Future<List<OrderModel>> getOrdersByCustomer(
    String customerId, {
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('participants.customerId', isEqualTo: customerId);

      if (status != null) {
        query = query.where('metadata.status', isEqualTo: status.name);
      }

      query =
          query.orderBy('metadata.orderTime', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy đơn hàng của khách hàng: $e');
    }
  }

  // Lấy đơn hàng theo nhà hàng
  Future<List<OrderModel>> getOrdersByRestaurant(
    String restaurantId, {
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('participants.restaurantId', isEqualTo: restaurantId);

      if (status != null) {
        query = query.where('metadata.status', isEqualTo: status.name);
      }

      query =
          query.orderBy('metadata.orderTime', descending: true).limit(limit);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) =>
              OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy đơn hàng của nhà hàng: $e');
    }
  }

  //  món ăn phổ biến của nhà hàng
  Future<List<FoodModel>> getTopSellingFoods({
    required String restaurantId,
    int limit = 10,
  }) async {
    try {
      // Lấy tất cả order của nhà hàng có trạng thái delivered
      Query query = _firestore
          .collection(_collection)
          .where('status', isEqualTo: OrderState.delivered.name)
          .where('restaurantId', isEqualTo: restaurantId);

      final snapshot = await query.get();
      Map<String, int> foodCount = {};

      for (var doc in snapshot.docs) {
        final order =
            OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        for (var item in order.items) {
          final foodKey = item.foodId;
          if (foodKey.isEmpty) continue;
          foodCount[foodKey] = (foodCount[foodKey] ?? 0) + 1;
        }
      }

      // Sắp xếp theo số lần xuất hiện giảm dần
      var sortedFoodIds = foodCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topFoodIds = sortedFoodIds.take(limit).map((e) => e.key).toList();

      // Lấy chi tiết từng món ăn
      List<FoodModel> foods = [];
      for (final id in topFoodIds) {
        try {
          final food = await FoodRepository().getFoodById(id);
          foods.add(food);
        } catch (e) {
          // Nếu không tìm thấy món ăn, bỏ qua
          continue;
        }
      }
      return foods;
    } catch (e) {
      throw Exception('Không thể lấy thống kê món ăn bán chạy: $e');
    }
  }

  // Thống kê doanh thu
  Future<Map<String, dynamic>> getRevenueStats({
    String? restaurantId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('metadata.status', isEqualTo: OrderState.delivered.name);

      if (restaurantId != null) {
        query = query.where('restaurantId', isEqualTo: restaurantId);
      }

      if (fromDate != null) {
        query = query.where('createdAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(fromDate));
      }

      if (toDate != null) {
        query = query.where('createdAt',
            isLessThanOrEqualTo: Timestamp.fromDate(toDate));
      }

      final snapshot = await query.get();
      double totalRevenue = 0;
      int totalOrders = 0;
      Map<String, double> dailyRevenue = {};

      for (var doc in snapshot.docs) {
        final order =
            OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
        totalRevenue += order.totalPrice;
        totalOrders++;

        // Thống kê theo ngày
        final dateKey = DateFormat('yyyy-MM-dd').format(order.orderTime);
        dailyRevenue[dateKey] = (dailyRevenue[dateKey] ?? 0) + order.totalPrice;
      }

      return {
        'totalRevenue': totalRevenue,
        'totalOrders': totalOrders,
        'averageOrderValue': totalOrders > 0 ? totalRevenue / totalOrders : 0,
        'dailyRevenue': dailyRevenue,
      };
    } catch (e) {
      throw Exception('Không thể lấy thống kê doanh thu: $e');
    }
  }

  // Lấy danh sách đơn hàng đang chờ shipper
  Stream<List<OrderModel>> getOrdersWaitingForShipper() {
    return _firestore
        .collection(_collection)
        .where('status',
            isEqualTo: OrderState.waitingForShipper.toString().split('.').last)
        .where('idShipper', isEqualTo: '')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Cập nhật shipper cho đơn hàng
  Future<void> assignShipperToOrder(String orderId, String shipperId) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'idShipper': shipperId,
        'status': OrderState.shipperAssigned.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật shipper cho đơn hàng: $e');
    }
  }

  // Lấy danh sách đơn hàng của shipper
  Stream<List<OrderModel>> getShipperOrders(String shipperId) {
    return _firestore
        .collection(_collection)
        .where('idShipper', isEqualTo: shipperId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // Cập nhật trạng thái giao hàng
  Future<void> updateDeliveryStatus(String orderId, OrderState status) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'status': status.toString().split('.').last,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái giao hàng: $e');
    }
  }

  // Cập nhật vị trí shipper
  Future<void> updateShipperLocation(String orderId, GeoPoint location) async {
    try {
      await _firestore.collection(_collection).doc(orderId).update({
        'delivery.location': location,
        'delivery.lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật vị trí shipper: $e');
    }
  }

  // Lấy thông tin shipper
  Future<ShipperModel> getShipperInfo(String shipperId) async {
    try {
      final doc = await _firestore.collection('shippers').doc(shipperId).get();
      if (!doc.exists) throw Exception('Không tìm thấy shipper');
      return ShipperModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
    } catch (e) {
      throw Exception('Không thể lấy thông tin shipper: $e');
    }
  }

  // Lắng nghe thay đổi trạng thái đơn hàng của người dùng
  Stream<OrderModel?> listenToOrderStatus(String orderId) {
    return _firestore.collection(_collection).doc(orderId).snapshots().map(
        (doc) => doc.exists ? OrderModel.fromMap(doc.data()!, doc.id) : null);
  }

  // Lắng nghe tất cả đơn hàng của người dùng
  Stream<List<OrderModel>> listenToUserOrders(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  Future<List<FoodModel>> getTopSellingFoodsByApp({
    int limit = 10,
  }) async {
    try {
      // Lấy tất cả order của nhà hàng có trạng thái delivered
      Query query = _firestore
          .collection(_collection)
          .where('status', isEqualTo: OrderState.delivered.name);

      final snapshot = await query.get();
      Map<String, int> foodCount = {};

      for (var doc in snapshot.docs) {
        try {
          final order =
              OrderModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
          for (var item in order.items) {
            final foodKey = item.foodId;
            if (foodKey.isEmpty) continue;
            foodCount[foodKey] = (foodCount[foodKey] ?? 0) + item.quantity;
          }
        } catch (e) {
          continue;
        }
      }

      // Sắp xếp theo số lần xuất hiện giảm dần
      var sortedFoodIds = foodCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      final topFoodIds = sortedFoodIds.take(limit).map((e) => e.key).toList();

      // Lấy chi tiết từng món ăn
      List<FoodModel> foods = [];
      for (final id in topFoodIds) {
        try {
          final food = await FoodRepository().getFoodById(id);
          foods.add(food);
        } catch (e) {
          continue;
        }
      }

      return foods;
    } catch (e) {
      throw Exception('Không thể lấy thống kê món ăn bán chạy: $e');
    }
  }
}
