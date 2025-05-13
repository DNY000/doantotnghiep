import 'package:admin/models/notification_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection(_collection)
              .orderBy('createdAt', descending: true)
              .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return NotificationModel.fromMap(data, doc.id);
      }).toList();
    } catch (e) {
      print('Error getting notifications: $e');
      return [];
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  Future<void> createNotification(NotificationModel notification) async {
    try {
      print('Tạo notification với dữ liệu: ' + notification.toMap().toString());
      final docRef = await _firestore
          .collection(_collection)
          .add(notification.toMap());
      print('Đã tạo notification với docID: ' + docRef.id);
      await docRef.update({'id': docRef.id});
      print('Đã cập nhật trường id cho notification');
    } catch (e) {
      print('Error creating notification: $e');
    }
  }
}
