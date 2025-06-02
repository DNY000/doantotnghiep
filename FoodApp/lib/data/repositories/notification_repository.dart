import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:foodapp/data/models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  Future<List<NotificationModel>> getNotifications(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('userId', isEqualTo: userId)
          // .orderBy('createdAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NotificationModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      throw Exception('Error getting notifications: $e');
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      throw Exception('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).delete();
    } catch (e) {
      throw Exception('Error deleting notification: $e');
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(notification.toMap());
      await docRef.update({'id': docRef.id});
    } catch (e) {
      throw Exception('Error creating notification: $e');
    }
  }

  Future<int> getUnreadNotificationsCount(String userId) async {
    try {
      final AggregateQuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('isRead', isEqualTo: false)
          .where('userId', isEqualTo: userId) // Lọc theo userId

          .count()
          .get();

      // Access the count value and ensure it's non-nullable
      final count = snapshot.count ??
          0; // Use null-aware operator to handle potential null
      return count;
    } catch (e) {
      return 0; // Return 0 in case of error
    }
  }
}
