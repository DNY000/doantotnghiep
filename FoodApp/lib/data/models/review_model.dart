import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  String id;
  String userId;
  String foodId;
  String name;
  String restaurantId;
  double rating;
  String comment;
  List<String> images;
  DateTime createdAt;
  int likeCount;

  ReviewModel({
    required this.id,
    required this.userId,
    required this.foodId,
    required this.name,
    required this.restaurantId,
    required this.rating,
    required this.comment,
    required this.images,
    required this.createdAt,
    required this.likeCount,
  });

  factory ReviewModel.fromMap(Map<String, dynamic> map, String id) {
    DateTime parseCreatedAt(dynamic createdAt) {
      if (createdAt is Timestamp) {
        return createdAt.toDate();
      } else if (createdAt is String) {
        return DateTime.parse(createdAt);
      }
      return DateTime.now();
    }

    return ReviewModel(
      id: id,
      name: map['name'] ?? "duy",
      userId: map['userId'] ?? '',
      foodId: map['foodId'] ?? '',
      restaurantId: map['restaurantId'] ?? '',
      rating: (map['rating'] is double)
          ? map['rating']
          : (map['rating'] is int)
              ? (map['rating'] as int).toDouble()
              : 0.0,
      comment: map['comment'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      createdAt: parseCreatedAt(map['createdAt']),
      likeCount: map['likeCount'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'foodId': foodId,
      'restaurantId': restaurantId,
      'rating': rating,
      'comment': comment,
      'images': images,
      'createdAt': Timestamp.fromDate(createdAt),
      'likeCount': likeCount,
    };
  }

  ReviewModel.empty()
      : this(
            id: '',
            userId: '',
            foodId: '',
            restaurantId: '',
            rating: 0.0,
            comment: '',
            images: [],
            createdAt: DateTime.now(),
            likeCount: 0,
            name: 'duy');
}
