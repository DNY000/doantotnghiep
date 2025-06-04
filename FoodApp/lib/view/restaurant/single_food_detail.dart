import 'package:flutter/material.dart';
import 'package:foodapp/common_widget/food_order_controller.dart';
import 'package:foodapp/data/models/food_model.dart';
import 'package:foodapp/data/models/cart_item_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:foodapp/view/restaurant/review_user.dart';
import 'package:foodapp/view/order/order_screen.dart';
import 'package:foodapp/viewmodels/review_viewmodel.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/viewmodels/favorite_viewmodel.dart';
import 'package:foodapp/viewmodels/cart_viewmodel.dart';
import 'package:foodapp/viewmodels/order_viewmodel.dart';
import 'package:foodapp/data/models/review_model.dart';

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
  bool canReview = false;

  @override
  void initState() {
    super.initState();
    totalAmount = widget.foodItem?.price ?? 0;
    _checkCanReview();
  }

  Future<void> _checkCanReview() async {
    if (widget.foodItem != null && widget.restaurantId != null) {
      final userId = context.read<UserViewModel>().currentUser?.id;
      if (userId != null) {
        final result = await context.read<ReviewViewModel>().canUserReview(
              widget.foodItem!.id,
              userId,
            );
        if (mounted) {
          setState(() {
            canReview = result;
          });
        }
      }
    }
  }

  void _onOrderComplete() {
    setState(() {
      isAddedToCart = true;
    });
  }

  void _onQuantityChanged(int qty, double totalPrice) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          totalAmount = totalPrice;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartVM = Provider.of<CartViewModel>(context, listen: false);
    final existingItem = cartVM.getCartItemByFoodId(widget.foodItem!.id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Phần ảnh và nút back/favorite
            _buildImageSection(),

            // Phần thông tin món ăn
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildFoodInfo(),
                    _buildReviewSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildOrderButton(existingItem),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildImageSection() {
    return SizedBox(
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
          _buildBackButton(),
          _buildFavoriteButton(),
        ],
      ),
    );
  }

  Widget _buildBackButton() {
    return Positioned(
      top: 16,
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          child: const Icon(
            Icons.arrow_back,
            color: Color.fromRGBO(0, 0, 0, 1),
            size: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildFavoriteButton() {
    return Positioned(
      top: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context
              .read<FavoriteViewModel>()
              .toggleFavorite(widget.foodItem!.id),
          child: Container(
            height: 32,
            width: 32,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Icon(
              context.watch<FavoriteViewModel>().isFavorite(widget.foodItem!.id)
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
    );
  }

  Widget _buildFoodInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            widget.foodItem!.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            widget.foodItem!.ingredients.toString(),
            style: const TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
    );
  }

  Widget _buildReviewSection() {
    return Column(
      children: [
        if (canReview) ...[
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
            child: ElevatedButton.icon(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => ReviewInputDialog(
                    foodId: widget.foodItem!.id,
                    restaurantId: widget.restaurantId!,
                    userId: context.read<UserViewModel>().currentUser!.id,
                    name: context.read<UserViewModel>().currentUser!.name,
                  ),
                );
              },
              icon: const Icon(Icons.rate_review),
              label: const Text('Viết đánh giá'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 45),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const Divider(height: 1),
        ],
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.4,
          child: ReviewUser(
            foodId: widget.foodItem!.id,
            restaurantId: widget.restaurantId!,
          ),
        ),
      ],
    );
  }

  Widget? _buildOrderButton(CartItemModel? existingItem) {
    if (!isAddedToCart || existingItem == null || existingItem.quantity <= 0) {
      return null;
    }

    return Container(
      width: double.infinity,
      height: 56,
      margin: const EdgeInsets.only(left: 28, right: 28, bottom: 16),
      child: FloatingActionButton.extended(
        backgroundColor: const Color.fromARGB(255, 223, 151, 57),
        onPressed: () => _navigateToOrderScreen(),
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
    );
  }

  void _navigateToOrderScreen() {
    if (widget.restaurantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không tìm thấy thông tin nhà hàng')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiProvider(
          providers: [
            ChangeNotifierProvider.value(
              value: Provider.of<OrderViewModel>(context, listen: false),
            ),
            ChangeNotifierProvider.value(
              value: Provider.of<CartViewModel>(context, listen: false),
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
  }
}

class ReviewInputDialog extends StatefulWidget {
  final String foodId;
  final String restaurantId;
  final String userId;
  final String name;
  const ReviewInputDialog(
      {Key? key,
      required this.foodId,
      required this.restaurantId,
      required this.userId,
      required this.name})
      : super(key: key);

  @override
  State<ReviewInputDialog> createState() => _ReviewInputDialogState();
}

class _ReviewInputDialogState extends State<ReviewInputDialog> {
  final TextEditingController _commentController = TextEditingController();
  double _rating = 0;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submitReview() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số sao đánh giá')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final review = ReviewModel(
          id: '', // ID sẽ được tạo bởi Firestore
          foodId: widget.foodId,
          restaurantId: widget.restaurantId,
          userId: widget.userId,
          rating: _rating,
          comment: _commentController.text.trim(),
          images: [], // Chưa hỗ trợ upload ảnh
          createdAt: DateTime.now(),
          likeCount: 0,
          name: widget.name);

      await context.read<ReviewViewModel>().addReview(review);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đánh giá đã được gửi thành công')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi gửi đánh giá: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.white,
      title: const Text('Đánh giá món ăn'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    color: Colors.orange,
                    size: 32,
                  ),
                  onPressed: () {
                    setState(() {
                      _rating = index + 1;
                    });
                  },
                );
              }),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                  hintText: 'Viết đánh giá của bạn...',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey)),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 0.5),
                      borderRadius: BorderRadius.all(Radius.circular(8)))),
              maxLines: 3,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          style: TextButton.styleFrom(backgroundColor: TColor.orange4),
          onPressed: _isSubmitting ? null : () => Navigator.pop(context),
          child: const Text(
            'Hủy',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: TColor.orange4),
          onPressed: _isSubmitting ? null : _submitReview,
          child: _isSubmitting
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text(
                  'Gửi',
                  style: TextStyle(color: Colors.black),
                ),
        ),
      ],
    );
  }
}
