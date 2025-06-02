import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:foodapp/data/models/review_model.dart';
import 'package:foodapp/ultils/const/color_extension.dart';
import 'package:readmore/readmore.dart';

class UserReviewRow extends StatelessWidget {
  final bool isBottomActionBar;
  final VoidCallback? onCommentPress;
  final VoidCallback? onLikePress;
  final VoidCallback? onSharePress;
  final ReviewModel reviews;
  const UserReviewRow({
    super.key,
    this.isBottomActionBar = false,
    this.onSharePress,
    this.onLikePress,
    this.onCommentPress,
    required this.reviews,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row chứa avatar, tên, rating và ngày
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: Colors.white,
                foregroundColor: Colors.white,
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: TColor.color3,
                ),
              ),
              // Avatar

              const SizedBox(width: 12),
              // Thông tin người dùng và đánh giá
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên người dùng
                    Text(
                      reviews.name,
                      style: TextStyle(
                        color: TColor.text,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Rating và ngày
                    Row(
                      children: [
                        IgnorePointer(
                          ignoring: true,
                          child: RatingBar.builder(
                            initialRating: reviews.rating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: true,
                            unratedColor: Colors.grey[300],
                            itemCount: 5,
                            itemSize: 16,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 1.0),
                            itemBuilder: (context, _) => Icon(
                              Icons.star,
                              color: TColor.color3,
                            ),
                            onRatingUpdate: (rating) {},
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          reviews.rating.toString(),
                          style: TextStyle(
                            color: TColor.color3,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(reviews.createdAt),
                          style: TextStyle(
                            color: TColor.gray,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Nội dung bình luận
          ReadMoreText(
            reviews.comment,
            trimLines: 3,
            colorClickableText: TColor.color3,
            trimMode: TrimMode.Line,
            style: TextStyle(
              fontSize: 14,
              color: TColor.text,
            ),
            trimCollapsedText: 'Xem thêm',
            trimExpandedText: 'Thu gọn',
            moreStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: TColor.color3,
            ),
          ),
          const SizedBox(height: 12),
          // Actions (like, comment, share)
          if (isBottomActionBar)
            Row(
              children: [
                IconButton(
                  onPressed: onLikePress,
                  icon: Icon(
                    Icons.thumb_up_outlined,
                    size: 20,
                    color: TColor.gray,
                  ),
                ),
                Text(
                  "${reviews.likeCount}",
                  style: TextStyle(
                    color: TColor.gray,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 16),
                IconButton(
                  onPressed: onCommentPress,
                  icon: Icon(
                    Icons.comment_outlined,
                    size: 20,
                    color: TColor.gray,
                  ),
                ),
                IconButton(
                  onPressed: onSharePress,
                  icon: Icon(
                    Icons.share_outlined,
                    size: 20,
                    color: TColor.gray,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return '${difference.inMinutes} phút trước';
      }
      return '${difference.inHours} giờ trước';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
