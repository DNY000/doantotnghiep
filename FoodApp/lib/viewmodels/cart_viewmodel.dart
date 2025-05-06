import 'package:flutter/foundation.dart';
import 'package:foodapp/data/models/cart_item_model.dart';

class CartViewModel extends ChangeNotifier {
  List<CartItemModel> _items = [];
  String? _error;

  List<CartItemModel> get items => _items;
  String? get error => _error;
  bool get isEmpty => _items.isEmpty;

  double get totalAmount {
    return _items.fold(0, (sum, item) => sum + item.totalAmount);
  }

  void addToCart(CartItemModel item) {
    try {
      // Kiểm tra xem món ăn đã có trong giỏ hàng chưa
      final existingIndex = _items.indexWhere((i) => i.foodId == item.foodId);

      if (existingIndex >= 0) {
        // Nếu có rồi thì cập nhật số lượng
        final existingItem = _items[existingIndex];
        _items[existingIndex] = existingItem.copyWith(
          quantity: existingItem.quantity + item.quantity,
        );
      } else {
        // Nếu chưa có thì thêm mới
        _items.add(item);
      }

      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void removeFromCart(String foodId) {
    try {
      _items.removeWhere((item) => item.foodId == foodId);
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void updateQuantity(String foodId, int quantity) {
    try {
      final index = _items.indexWhere((item) => item.foodId == foodId);
      if (index >= 0) {
        if (quantity > 0) {
          _items[index] = _items[index].copyWith(quantity: quantity);
        } else {
          _items.removeAt(index);
        }
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearCart() {
    _items = [];
    _error = null;
    notifyListeners();
  }

  // Get cart item by food ID
  CartItemModel? getCartItemByFoodId(String foodId) {
    try {
      final index = _items.indexWhere((item) => item.foodId == foodId);
      if (index >= 0) {
        return _items[index];
      }
      return null;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  // Update cart item
  void updateCartItem(CartItemModel item) {
    try {
      final index = _items.indexWhere((i) => i.foodId == item.foodId);
      if (index >= 0) {
        _items[index] = item;
        _error = null;
        notifyListeners();
      } else {
        // If item doesn't exist, add it
        addToCart(item);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}
