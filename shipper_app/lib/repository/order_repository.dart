import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shipper_app/models/order_model.dart';
import 'package:shipper_app/ultils/const/enum.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<OrderModel> orders = [];

  // lấy danh sách đơn hàng trạng thái pedding
  Future<List<OrderModel>> getOrders() async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where('status', isEqualTo: 'pending')
              // .where('idShipper', isEqualTo: "")
              .get();
      orders =
          snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
      return orders;
    } catch (e) {
      throw Exception(e);
    }
  }

  // Cập nhật shipper cho đơn hàng
  Future<void> assignShipperToOrder(String orderId, String shipperId) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'idShipper': shipperId,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật shipper cho đơn hàng: $e');
    }
  }

  // Lấy danh sách đơn hàng của shipper
  Future<List<OrderModel>> getShipperOrders(
    String shipperId, [
    String status = "delivered",
  ]) async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where('idShipper', isEqualTo: shipperId)
              .get();

      return snapshot.docs
          .where((doc) => doc['status'] != status)
          .map((doc) => OrderModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Không thể lấy danh sách đơn hàng của shipper: $e');
    }
  }

  // Cập nhật trạng thái giao hàng
  Future<void> updateDeliveryStatus(
    String orderId,
    OrderState status,
    String shipperId,
  ) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status.toString().split('.').last,
        'idShipper': shipperId,
      });
    } catch (e) {
      throw Exception('Không thể cập nhật trạng thái giao hàng: $e');
    }
  }

  // Cập nhật vị trí shipper
  Future<void> updateShipperLocation(String orderId, GeoPoint location) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'delivery.location': location,
        'delivery.lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Không thể cập nhật vị trí shipper: $e');
    }
  }

  Future<bool> isOrders(String idShipper) async {
    try {
      final snapshot =
          await _firestore
              .collection('orders')
              .where('idShipper', isEqualTo: idShipper)
              .where('status', isEqualTo: "shipperAssigned")
              .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      throw Exception('Không thể kiểm tra đơn hàng: $e');
    }
  }
}
