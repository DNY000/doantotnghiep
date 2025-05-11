import 'package:flutter/material.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:foodapp/data/models/draft_order_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/cart_viewmodel.dart';
import 'package:foodapp/ultils/local_storage/storage_utilly.dart';
import 'dart:convert';

class FoodOrderController extends StatefulWidget {
  final FoodModel food;
  final String restaurantId;
  final VoidCallback? onOrderComplete;
  final bool showQuantitySelector;
  final bool isDialog;
  final bool showTotalPrice;
  final Function(int, double)? onQuantityChanged;

  const FoodOrderController({
    Key? key,
    required this.food,
    required this.restaurantId,
    this.onOrderComplete,
    this.showQuantitySelector = false,
    this.isDialog = false,
    this.showTotalPrice = false,
    this.onQuantityChanged,
  }) : super(key: key);

  @override
  State<FoodOrderController> createState() => _FoodOrderControllerState();
}

class _FoodOrderControllerState extends State<FoodOrderController> {
  int qty = 0;
  bool isAddedToCart = false;
  bool _isOrderConfirmed = false;
  final _storage = TLocalStorage.instance();

  double get totalPrice => widget.food.price * qty;

  @override
  void initState() {
    super.initState();
    qty = 0;
    isAddedToCart = false;
  }

  void _notifyQuantityChanged() {
    if (widget.onQuantityChanged != null) {
      widget.onQuantityChanged!(qty, totalPrice);
    }
  }

  void _addToCart() {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final cartItem = CartItemModel(
      id: DateTime.now().toString(),
      foodId: widget.food.id,
      foodName: widget.food.name,
      quantity: qty,
      restaurantId: widget.restaurantId,
      price: widget.food.price,
      image: widget.food.images.isNotEmpty
          ? widget.food.images[0]
          : 'assets/img/placeholder_food.png',
      note: '',
      options: {},
    );

    cartViewModel.addToCart(cartItem);
    setState(() {
      isAddedToCart = true;
    });

    if (widget.onOrderComplete != null) {
      _isOrderConfirmed = true;
      widget.onOrderComplete!();
    }

    _notifyQuantityChanged();
  }

  void _increaseQuantity() {
    setState(() {
      qty++;
    });
    if (isAddedToCart) {
      _updateCartItem();
    } else {
      _addToCart();
    }
    _notifyQuantityChanged();
  }

  void _decreaseQuantity() {
    if (qty > 1) {
      setState(() {
        qty--;
      });
      _updateCartItem();
    } else {
      _removeFromCart();
    }
    _notifyQuantityChanged();
  }

  void _updateCartItem() {
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    final cartItem = CartItemModel(
      id: DateTime.now().toString(),
      foodId: widget.food.id,
      foodName: widget.food.name,
      quantity: qty,
      restaurantId: widget.restaurantId,
      price: widget.food.price,
      image: widget.food.images.isNotEmpty
          ? widget.food.images[0]
          : 'assets/img/placeholder_food.png',
      note: '',
      options: {},
    );
    cartViewModel.updateCartItem(cartItem);
  }

  void _removeFromCart() {
    setState(() {
      isAddedToCart = false;
      qty = 0;
    });
    final cartViewModel = Provider.of<CartViewModel>(context, listen: false);
    cartViewModel.removeFromCart(widget.food.id);
    _notifyQuantityChanged();
  }

  void _saveDraftOrder() {
    if (qty > 0) {
      final draftOrder = DraftOrderModel(
        id: DateTime.now().toString(),
        restaurantId: widget.restaurantId,
        items: [
          CartItemModel(
            id: DateTime.now().toString(),
            foodId: widget.food.id,
            foodName: widget.food.name,
            quantity: qty,
            restaurantId: widget.restaurantId,
            price: widget.food.price,
            image: widget.food.images.isNotEmpty
                ? widget.food.images[0]
                : 'assets/img/placeholder_food.png',
            note: '',
            options: {},
          )
        ],
        totalAmount: totalPrice,
        createdAt: DateTime.now(),
      );

      // Get existing draft orders
      final draftOrdersJson = _storage.readData<String>('draft_orders') ?? '[]';
      final List<dynamic> draftOrdersList = json.decode(draftOrdersJson);
      final draftOrders = draftOrdersList
          .map((json) => DraftOrderModel.fromJson(json))
          .toList();

      // Add new draft order
      draftOrders.add(draftOrder);

      // Save back to storage
      _storage.saveData(
        'draft_orders',
        json.encode(draftOrders.map((order) => order.toJson()).toList()),
      );
    }
  }

  @override
  void dispose() {
    if (!_isOrderConfirmed) {
      _saveDraftOrder();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showQuantitySelector && isAddedToCart) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildQuantitySelector(),
          if (widget.showTotalPrice && qty > 0)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                children: [
                  Text(
                    '${totalPrice.toStringAsFixed(0)}đ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: TColor.color3,
                    ),
                  ),
                  if (qty > 1)
                    Text(
                      '${widget.food.price.toStringAsFixed(0)}đ x $qty',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: _increaseQuantity,
          icon: Icon(
            isAddedToCart ? Icons.shopping_cart : Icons.add_shopping_cart,
            color: TColor.color3,
          ),
        ),
        if (widget.showTotalPrice && qty > 0)
          Column(
            children: [
              Text(
                '${totalPrice.toStringAsFixed(0)}đ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: TColor.color3,
                ),
              ),
              if (qty > 1)
                Text(
                  '${widget.food.price.toStringAsFixed(0)}đ x $qty',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
      ],
    );
  }

  Widget _buildQuantitySelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _decreaseQuantity,
            icon: Icon(Icons.remove, color: TColor.color3),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          Text(
            '$qty',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            onPressed: _increaseQuantity,
            icon: Icon(Icons.add, color: TColor.color3),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}
