import 'package:flutter/material.dart';
import 'package:foodapp/core/services/notifications_service.dart';
import 'package:foodapp/data/models/notification_model.dart';
import 'package:foodapp/data/models/order_model.dart';
import 'package:foodapp/data/models/shipper_model.dart';
import 'package:foodapp/data/repositories/order_repository.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/data/repositories/food_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:foodapp/routes/name_router.dart';
import 'package:foodapp/ultils/const/enum.dart';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/data/models/user_model.dart';
import 'package:foodapp/data/repositories/user_repository.dart';
import 'package:foodapp/viewmodels/notification_viewmodel.dart';
import 'dart:async';

import 'package:go_router/go_router.dart';

class OrderViewModel extends ChangeNotifier {
  final OrderRepository _repository;
  List<OrderModel> _orders = [];
  OrderModel? _selectedOrder;
  bool _isLoading = false;
  String? _error;
  final FoodRepository _foodRepository;
  List<Map<String, dynamic>> _topSellingFoods = [];
  List<FoodModel> topSellingFoodsByApp = [];
  List<FoodModel> _recommendedFoods = [];
  Stream<List<OrderModel>>? _ordersStream;
  Stream<OrderModel?>? _orderStatusStream;
  Stream<List<OrderModel>>? _userOrdersStream;
  StreamSubscription<OrderModel?>? _orderStatusSubscription;
  StreamSubscription<List<OrderModel>>? _userOrdersSubscription;

  OrderViewModel(this._repository, {FoodRepository? foodRepository})
      : _foodRepository = foodRepository ?? FoodRepository();

  // Getters
  List<OrderModel> get orders => _orders;
  OrderModel? get selectedOrder => _selectedOrder;
  bool get isLoading => _isLoading;
  String? get error => _error;
  List<Map<String, dynamic>> get topSellingFoods => _topSellingFoods;
  List<FoodModel> get recommendedFoods => _recommendedFoods;
  Stream<List<OrderModel>>? get ordersStream => _ordersStream;

  // Tạo đơn hàng mới
  Future<void> createOrder({
    required BuildContext context, // 👈 thêm dòng này

    required String userId,
    required String restaurantId,
    required List<CartItemModel> items,
    required String address,
    required PaymentMethod paymentMethod,
    String? note,
    UserModel? currentUser,
  }) async {
    try {
      final _notificationViewModel = NotificationViewModel();
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Tính tổng tiền
      final totalAmount = items.fold<double>(
        0,
        (sum, item) => sum + item.totalAmount,
      );

      // Lấy thông tin người dùng hiện tại nếu chưa được cung cấp
      UserModel? user = currentUser;
      if (user == null) {
        final userRepository = UserRepository();
        user = await userRepository.getUserById(userId);
      }

      // Lấy vị trí nhà hàng cố định từ Firestore
      String restaurantName = '';
      GeoPoint? restaurantLocation;
      final doc = await FirebaseFirestore.instance
          .collection('restaurants')
          .doc(restaurantId)
          .get();
      if (doc.exists) {
        final data = doc.data();
        if (data != null && data['location'] is GeoPoint) {
          restaurantLocation = data['location'] as GeoPoint;
          restaurantName = data['name'] ?? '';
        }
      }

      // Tạo metadata với thông tin người dùng
      final Map<String, dynamic> orderMetadata = {
        'fullName': user?.name ?? '',
        'phoneNumber': user?.phoneNumber ?? '',
        'address': user?.defaultAddress?.street ?? '',
        'createdAt': Timestamp.now(),
      };

      // Tạo đơn hàng mới
      final order = OrderModel(
        id: '',
        userId: userId,
        restaurantId: restaurantId,
        restaurantName: restaurantName,
        items: items,
        totalAmount: totalAmount,
        address: address,
        paymentMethod: paymentMethod,
        status: OrderState.pending,
        createdAt: DateTime.now(),
        note: note,
        idShipper: "",
        metadata: orderMetadata,
        restaurantLocation: restaurantLocation,
      );

      // Tạo đơn hàng và lấy ID
      final orderId = await _repository.createOrder(order);

      // Tạo thông báo với order ID
      final notification = NotificationModel(
        id: '',
        userId: userId,
        title: 'Đặt đơn thành công',
        content:
            'Đơn hàng của bạn đã được đặt thành công! Cảm ơn bạn đã sử dụng dịch vụ.',
        type: NotificationType.order,
        createdAt: DateTime.now(),
        isRead: false,
        data: {
          'orderId': orderId, // Use the returned order ID
        },
      );

      await _notificationViewModel.createNotification(notification);
      await NotificationsService.showLocalNotification(
        title: 'Đặt đơn thành công',
        body:
            'Đơn hàng của bạn đã được đặt thành công! Cảm ơn bạn đã sử dụng dịch vụ.',
        payload: orderId,
      );
      context.go("/home");
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Lấy danh sách đơn hàng của user
  Future<bool> loadUserOrders(String userId) async {
    _isLoading = true;
    _error = null;
    _orders = []; // Xoá dữ liệu cũ để tránh hiển thị nhầm
    notifyListeners();

    try {
      final orders = await _repository.getUserOrders(userId);
      _orders = orders ?? [];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e, stack) {
      _orders = [];
      _error = e.toString();
      _isLoading = false;
      debugPrint('Lỗi loadUserOrders: $e\n$stack');
      notifyListeners();
      return false;
    }
  }

  // Lắng nghe thay đổi trạng thái của một đơn hàng cụ thể
  void listenToOrderStatus(String orderId) {
    _orderStatusStream = _repository.listenToOrderStatus(orderId);
    _orderStatusSubscription?.cancel();
    _orderStatusSubscription = _orderStatusStream?.listen((order) {
      if (order != null) {
        // Kiểm tra nếu đơn hàng vừa được giao thành công
        if (order.status == OrderState.delivered) {
          _sendDeliverySuccessNotification(order);
        }
      }
    });
  }

  // Lắng nghe tất cả đơn hàng của người dùng
  void listenToUserOrders(String userId) {
    _userOrdersStream = _repository.listenToUserOrders(userId);
    _userOrdersSubscription?.cancel();
    _userOrdersSubscription = _userOrdersStream?.listen((orders) {
      _orders = orders;
      notifyListeners();
    });
  }

  // Gửi thông báo khi đơn hàng được giao thành công
  Future<void> _sendDeliverySuccessNotification(OrderModel order) async {
    try {
      final _notificationViewModel = NotificationViewModel();

      // Tạo thông báo trong ứng dụng
      final notification = NotificationModel(
        id: '',
        userId: order.userId,
        title: 'Đơn hàng đã được giao thành công',
        content:
            'Đơn hàng #${order.id.substring(0, 8)} của bạn đã được giao thành công. Cảm ơn bạn đã sử dụng dịch vụ!',
        type: NotificationType.order,
        createdAt: DateTime.now(),
        isRead: false,
        data: {
          'orderId': order.id,
        },
      );
      await _notificationViewModel.createNotification(notification);

      // Hiển thị thông báo hệ thống
      await NotificationsService.showLocalNotification(
        title: 'Đơn hàng đã được giao thành công',
        body:
            'Đơn hàng #${order.id.substring(0, 8)} của bạn đã được giao thành công. Cảm ơn bạn đã sử dụng dịch vụ!',
        payload: order.id,
      );
    } catch (e) {
      debugPrint('Lỗi khi gửi thông báo: $e');
    }
  }

  // Hủy đơn hàng
  Future<void> cancelOrder(String orderId, String reason) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.cancelOrder(orderId, reason);

      // Cập nhật lại trạng thái đơn hàng trong danh sách
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = _orders[index].copyWith(
          status: OrderState.cancelled,
          cancelReason: reason,
        );
        _orders[index] = updatedOrder;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, OrderState status) async {
    try {
      _setLoading(true);
      await _repository.updateOrderStatus(orderId, status);
      _error = null;
    } catch (e) {
      _error = 'Không thể cập nhật trạng thái đơn hàng: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy đơn hàng theo ngày
  Future<void> loadOrders({
    DateTime? fromDate,
    DateTime? toDate,
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      _orders = await _repository.getOrders(
        fromDate: fromDate,
        toDate: toDate,
        status: status,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải danh sách đơn hàng: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy đơn hàng theo khách hàng
  Future<void> loadOrdersByCustomer(
    String customerId, {
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      _orders = await _repository.getOrdersByCustomer(
        customerId,
        status: status,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải đơn hàng của khách hàng: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy đơn hàng theo nhà hàng
  Future<void> loadOrdersByRestaurant(
    String restaurantId, {
    OrderState? status,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      _orders = await _repository.getOrdersByRestaurant(
        restaurantId,
        status: status,
        limit: limit,
      );
      _error = null;
    } catch (e) {
      _error = 'Không thể tải đơn hàng của nhà hàng: $e';
      if (kDebugMode) {
        print(_error);
      }
    } finally {
      _setLoading(false);
    }
  }

  // Lấy thống kê món ăn bán chạy
  Future<List<FoodModel>> getTopSellingFoods({
    String? restaurantId,
    int limit = 10,
  }) async {
    try {
      _setLoading(true);
      final result = await _repository.getTopSellingFoods(
        restaurantId: restaurantId ?? '',
        limit: limit,
      );
      _error = null;
      return result;
    } catch (e) {
      _error = 'Không thể lấy thống kê món ăn bán chạy: $e';
      if (kDebugMode) {
        print(_error);
      }
      return [];
    } finally {
      _setLoading(false);
    }
  }

  // Lấy thống kê doanh thu
  Future<Map<String, dynamic>> getRevenueStats({
    String? restaurantId,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    try {
      _setLoading(true);
      final result = await _repository.getRevenueStats(
        restaurantId: restaurantId,
        fromDate: fromDate,
        toDate: toDate,
      );
      _error = null;
      return result;
    } catch (e) {
      _error = 'Không thể lấy thống kê doanh thu: $e';
      if (kDebugMode) {
        print(_error);
      }
      return {};
    } finally {
      _setLoading(false);
    }
  }

  // Helper methods
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setSelectedOrder(OrderModel order) {
    _selectedOrder = order;
    notifyListeners();
  }

  void clearSelectedOrder() {
    _selectedOrder = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Lọc đơn hàng theo trạng thái
  List<OrderModel> filterByStatus(OrderState status) {
    return _orders.where((order) => order.status == status).toList();
  }

  // Lọc đơn hàng theo khoảng thời gian
  List<OrderModel> filterByDateRange(DateTime fromDate, DateTime toDate) {
    return _orders
        .where((order) =>
            order.orderTime.isAfter(fromDate) &&
            order.orderTime.isBefore(toDate))
        .toList();
  }

  // Sắp xếp theo thời gian
  void sortByOrderTime({bool ascending = false}) {
    _orders.sort((a, b) => ascending
        ? a.orderTime.compareTo(b.orderTime)
        : b.orderTime.compareTo(a.orderTime));
    notifyListeners();
  }

  // Sắp xếp theo tổng tiền
  void sortByTotalAmount({bool ascending = false}) {
    _orders.sort((a, b) => ascending
        ? a.totalPrice.compareTo(b.totalPrice)
        : b.totalPrice.compareTo(a.totalPrice));
    notifyListeners();
  }

  // Thêm phương thức để lọc món ăn bán chạy theo danh mục
  List<Map<String, dynamic>> getTopSellingFoodsByCategory(String category) {
    return _topSellingFoods
        .where((food) => food['category'] == category)
        .toList();
  }

  // Thêm phương thức để lấy tổng doanh thu của các món ăn bán chạy
  double getTotalRevenue() {
    return _topSellingFoods.fold(
        0, (sum, food) => sum + (food['totalRevenue'] as double));
  }

  // Thêm phương thức để lấy tổng số lượng món đã bán
  int getTotalQuantitySold() {
    return _topSellingFoods.fold(
        0, (sum, food) => sum + (food['quantity'] as int));
  }

  Future<void> loadRecommendedFoods() async {
    _isLoading = true;
    notifyListeners();

    try {
      _recommendedFoods = await _foodRepository.getRecommendedFoods();
    } catch (e) {
      debugPrint('Error loading recommended foods: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // Lấy danh sách đơn hàng đang chờ shipper
  void listenToOrdersWaitingForShipper() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _ordersStream = _repository.getOrdersWaitingForShipper();
    _ordersStream?.listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  // Shipper nhận đơn hàng
  Future<void> acceptOrder(String orderId, String shipperId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.assignShipperToOrder(orderId, shipperId);

      // Cập nhật lại trạng thái đơn hàng trong danh sách
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = _orders[index].copyWith(
          idShipper: shipperId,
          status: OrderState.shipperAssigned,
        );
        _orders[index] = updatedOrder;
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  // Lấy danh sách đơn hàng của shipper
  void listenToShipperOrders(String shipperId) {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _ordersStream = _repository.getShipperOrders(shipperId);
    _ordersStream?.listen(
      (orders) {
        _orders = orders;
        _isLoading = false;
        notifyListeners();
      },
      onError: (e) {
        _error = e.toString();
        _isLoading = false;
        notifyListeners();
      },
    );
  }

  Future<void> updateDeliveryStatus(String orderId, OrderState status) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      // Cập nhật trạng thái đơn hàng
      await _repository.updateDeliveryStatus(orderId, status);

      // Cập nhật lại trạng thái đơn hàng trong danh sách
      final index = _orders.indexWhere((order) => order.id == orderId);
      if (index != -1) {
        final updatedOrder = _orders[index].copyWith(
          status: status,
        );
        _orders[index] = updatedOrder;

        // Nếu đơn hàng đã được giao thành công, gửi thông báo cho người dùng
        if (status == OrderState.delivered) {
          final order = updatedOrder;
          final _notificationViewModel = NotificationViewModel();

          // Tạo thông báo trong ứng dụng
          final notification = NotificationModel(
            id: '',
            userId: order.userId,
            title: 'Đơn hàng đã được giao thành công',
            content:
                'Đơn hàng #${order.id.substring(0, 8)} của bạn đã được giao thành công. Cảm ơn bạn đã sử dụng dịch vụ!',
            type: NotificationType.order,
            createdAt: DateTime.now(),
            isRead: false,
            data: {
              'orderId': order.id,
            },
          );
          await _notificationViewModel.createNotification(notification);

          // Hiển thị thông báo hệ thống
          await NotificationsService.showLocalNotification(
            title: 'Đơn hàng đã được giao thành công',
            body:
                'Đơn hàng #${order.id.substring(0, 8)} của bạn đã được giao thành công. Cảm ơn bạn đã sử dụng dịch vụ!',
            payload: order.id,
          );
        }
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateShipperLocation(String orderId, GeoPoint location) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await _repository.updateShipperLocation(orderId, location);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<ShipperModel> getShipperInfo(String shipperId) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final info = await _repository.getShipperInfo(shipperId);

      _isLoading = false;
      notifyListeners();
      return info;
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  @override
  void dispose() {
    _orderStatusSubscription?.cancel();
    _userOrdersSubscription?.cancel();
    super.dispose();
  }

  Future<void> getTopSellingFoodsByApp() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      topSellingFoodsByApp = await _repository.getTopSellingFoodsByApp();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> getOrderById(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      _selectedOrder = await _repository.getOrderById(id);
      print('có data ${_selectedOrder?.id}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}
