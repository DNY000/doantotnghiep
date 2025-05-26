import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:foodapp/common_widget/user_review_row.dart';
import 'package:foodapp/viewmodels/review_viewmodel.dart';

class ReviewUser extends StatefulWidget {
  final String foodId;
  final String restaurantId;
  const ReviewUser(
      {super.key, required this.foodId, required this.restaurantId});

  @override
  State<ReviewUser> createState() => _ReviewUserState();
}

class _ReviewUserState extends State<ReviewUser> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context
          .read<ReviewViewModel>()
          .loadReviews(widget.foodId, widget.restaurantId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewViewModel>(
      builder: (context, reviewVM, child) {
        if (reviewVM.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }
        if (reviewVM.error != null) {
          return Center(child: Text(reviewVM.error!));
        }
        if (reviewVM.reviews.isEmpty) {
          return const Center(child: Text('Chưa có đánh giá nào'));
        }
        return ListView.builder(
          shrinkWrap: true,
          itemCount: reviewVM.reviews.length,
          itemBuilder: (context, index) {
            final review = reviewVM.reviews[index];
            return UserReviewRow(reviews: review);
          },
        );
      },
    );
  }
}
