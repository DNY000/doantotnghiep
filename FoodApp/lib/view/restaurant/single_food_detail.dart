import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/food_order_controller.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:foodapp/view/restaurant/review_user.dart';
import 'package:foodapp/view/order/order_screen.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/favorite_viewmodel.dart';
import 'package:foodapp/viewmodels/cart_viewmodel.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';

class SingleFoodDetail extends StatefulWidget {
  final FoodModel? foodItem;
  final String? restaurantId;
  final String? restaurantUserId;

  const SingleFoodDetail({
    Key? key,
    this.foodItem,
    this.restaurantId,
    this.restaurantUserId,
  }) : super(key: key);

  @override
  State<SingleFoodDetail> createState() => _SingleFoodDetailState();
}

class _SingleFoodDetailState extends State<SingleFoodDetail> {
  bool isAddedToCart = false;
  double totalAmount = 0;

  @override
  void initState() {
    super.initState();
    _checkExistingCartItem();
    totalAmount = widget.foodItem?.price ?? 0;
  }

  void _checkExistingCartItem() {
    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    final existingItem = cartVM.getCartItemByFoodId(widget.foodItem!.id);
    if (existingItem != null) {
      setState(() {
        isAddedToCart = true;
        totalAmount = widget.foodItem!.price * existingItem.quantity;
      });
    }
  }

  void _onOrderComplete() {
    setState(() {
      isAddedToCart = true;
    });
  }

  void _onQuantityChanged(int qty, double totalPrice) {
    setState(() {
      totalAmount = totalPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.width * 0.6,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    widget.foodItem!.images[0],
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => context
                            .read<FavoriteViewModel>()
                            .toggleFavorite(widget.foodItem!.id),
                        child: Container(
                          height: 30,
                          width: 30,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Icon(
                            context
                                    .watch<FavoriteViewModel>()
                                    .isFavorite(widget.foodItem!.id)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: context
                                    .watch<FavoriteViewModel>()
                                    .isFavorite(widget.foodItem!.id)
                                ? Colors.red
                                : Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    widget.foodItem!.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: Text(
                    widget.foodItem!.ingredients.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      const Text(
                        'Đã bán: 100',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 15,
                        width: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Lượt xem: 100',
                        style: TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        height: 15,
                        width: 1,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Số lượng còn',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${widget.foodItem!.price}đ',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                      FoodOrderController(
                        food: widget.foodItem!,
                        showQuantitySelector: true,
                        onOrderComplete: _onOrderComplete,
                        showTotalPrice: false,
                        onQuantityChanged: _onQuantityChanged,
                        restaurantId: widget.restaurantId!,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Expanded(
              child: ReviewUser(
                foodId: widget.foodItem!.id,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: isAddedToCart
          ? Container(
              width: double.infinity,
              height: 56,
              margin: const EdgeInsets.only(left: 28, right: 28, bottom: 16),
              child: FloatingActionButton.extended(
                backgroundColor: const Color.fromARGB(255, 223, 151, 57),
                onPressed: () {
                  if (widget.restaurantId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Không tìm thấy thông tin nhà hàng')),
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => MultiProvider(
                        providers: [
                          ChangeNotifierProvider.value(
                            value: Provider.of<OrderViewModel>(context,
                                listen: false),
                          ),
                          ChangeNotifierProvider.value(
                            value: Provider.of<CartViewModel>(context,
                                listen: false),
                          ),
                        ],
                        child: OrderScreen(
                          cartItems: [
                            CartItemModel(
                              id: DateTime.now().toString(),
                              foodId: widget.foodItem!.id,
                              foodName: widget.foodItem!.name,
                              quantity: 1,
                              restaurantId: widget.restaurantId!,
                              price: widget.foodItem!.price,
                              image: widget.foodItem!.images[0],
                              note: '',
                              options: {},
                            )
                          ],
                          restaurantId: widget.restaurantId!,
                          totalAmount: widget.foodItem!.price,
                        ),
                      ),
                    ),
                  );
                },
                label: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text(
                      "${totalAmount.toStringAsFixed(0)}đ",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 64),
                    const Text(
                      "Giao hàng",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
