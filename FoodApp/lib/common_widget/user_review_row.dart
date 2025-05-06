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
  const UserReviewRow(
      {super.key,
      this.isBottomActionBar = false,
      this.onSharePress,
      this.onLikePress,
      this.onCommentPress,
      required this.reviews});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: Icon(
                Icons.person,
                size: 50,
                color: TColor.color3,
              ),
            ),
            const SizedBox(
              width: 15,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reviews.userId,
                    style: TextStyle(
                        color: TColor.text,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 8,
        ),
        Row(children: [
          Text(
            "Rated",
            style: TextStyle(
                color: TColor.gray, fontSize: 12, fontWeight: FontWeight.w700),
          ),
          IgnorePointer(
            ignoring: true,
            child: RatingBar.builder(
              initialRating: 1,
              minRating: 1,
              direction: Axis.horizontal,
              allowHalfRating: true,
              unratedColor: Colors.transparent,
              itemCount: 5,
              itemSize: 20,
              itemPadding: const EdgeInsets.symmetric(horizontal: 2.0),
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: TColor.color3,
              ),
              onRatingUpdate: (rating) {
                // print(rating);
              },
            ),
          ),
          Text(
            reviews.rating.toString(),
            style: TextStyle(
                color: TColor.color3,
                fontSize: 14,
                fontWeight: FontWeight.w700),
          ),
          const Spacer(),
          Text(
            reviews.createdAt.toString(),
            style: TextStyle(
                color: TColor.gray, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ]),
        const SizedBox(
          height: 8,
        ),
        ReadMoreText(
          reviews.comment,
          trimLines: 4,
          colorClickableText: TColor.text,
          trimMode: TrimMode.Line,
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: TColor.text),
          trimCollapsedText: 'Read more',
          trimExpandedText: 'Read less',
          moreStyle: TextStyle(
              fontSize: 14, fontWeight: FontWeight.bold, color: TColor.color3),
        ),
        const SizedBox(
          height: 8,
        ),
        SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        if (onLikePress != null) {
                          onLikePress!();
                        }
                      },
                      icon: Image.asset(
                        "assets/img/like.png",
                        width: 22,
                        height: 22,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (onCommentPress != null) {
                          onCommentPress!();
                        }
                      },
                      icon: Image.asset(
                        "assets/img/comments.png",
                        width: 22,
                        height: 22,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        if (onSharePress != null) {
                          onSharePress!();
                        }
                      },
                      icon: Image.asset(
                        "assets/img/share.png",
                        width: 22,
                        height: 22,
                        fit: BoxFit.fitWidth,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Text(
                      "4 Likes",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Text(
                      "3 Comments",
                      style: TextStyle(
                          color: TColor.gray,
                          fontSize: 16,
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                )
              ],
            ))
      ]),
    );
  }
}
