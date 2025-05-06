import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:shipper_app/models/order_model.dart';
import 'package:shipper_app/repository/order_repository.dart';
import 'package:shipper_app/ultils/const/enum.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _orderRepository = OrderRepository();

  bool isOrder = false;
  List<OrderModel> orders = [];
  bool isLoading = false;
  String? error;
  List<OrderModel> shipperOrders = [];
  OrderViewModel() {
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    isLoading = true;
    notifyListeners();
    try {
      orders = await _orderRepository.getOrders();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, OrderState newStatus) async {
    try {
      final idShipper = FirebaseAuth.instance.currentUser?.uid;

      await _orderRepository.updateDeliveryStatus(
        orderId,
        newStatus,
        idShipper ?? '',
      );
      _loadOrders();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // cập nhật vị trí shipper
  Future<void> updateShipperLocation(String orderId, GeoPoint location) async {
    try {
      await _orderRepository.updateShipperLocation(orderId, location);
      _loadOrders();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  // lấy danh sách đơn hàng của shipper
  Future<void> getShipperOrders(String shipperId) async {
    try {
      shipperOrders = await _orderRepository.getShipperOrders(
        shipperId,
        "delivered",
      );
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    } finally {
      print("số lượng đơn hàng của shipper ${shipperOrders.length}");
    }
  }

  Future<void> checkOrder() async {
    final String? idShipper = FirebaseAuth.instance.currentUser?.uid;
    if (idShipper == null) {
      error = 'Không tìm thấy người dùng đăng nhập';
      notifyListeners();
      return;
    }

    isOrder = await _orderRepository.isOrders(idShipper);
    notifyListeners();
  }
}
