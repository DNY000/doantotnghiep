import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shipper_app/models/chat_model.dart';

class ChatRealtimeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Cache của các chat streams để tránh tạo nhiều streams
  final Map<String, StreamController<List<MessageModel>>>
  _chatStreamControllers = {};

  // Cache của online presence streams
  final StreamController<Map<String, bool>> _onlineStatusController =
      StreamController<Map<String, bool>>.broadcast();

  // Lấy ID của người dùng hiện tại (shipper)
  String? get currentUserId => _auth.currentUser?.uid;

  // Tạo ID phòng chat duy nhất từ shipperId và userId
  String getChatRoomId(String shipperId, String userId) {
    List<String> ids = [shipperId, userId];
    ids.sort(); // Sắp xếp theo thứ tự từ điển
    return ids.join('_');
  }

  // =========== MESSAGING FUNCTIONS ===========

  // Gửi tin nhắn văn bản
  Future<void> sendTextMessage({
    required String orderId,
    required String recipientId,
    required String content,
  }) async {
    return _sendMessage(
      orderId: orderId,
      recipientId: recipientId,
      content: content,
      type: MessageType.text,
    );
  }

  // Gửi hình ảnh
  Future<void> sendImageMessage({
    required String orderId,
    required String recipientId,
    required String imageUrl,
    String content = 'Đã gửi hình ảnh',
  }) async {
    return _sendMessage(
      orderId: orderId,
      recipientId: recipientId,
      content: content,
      imageUrl: imageUrl,
      type: MessageType.image,
    );
  }

  // Gửi vị trí
  Future<void> sendLocationMessage({
    required String orderId,
    required String recipientId,
    required double latitude,
    required double longitude,
    String content = 'Đã chia sẻ vị trí',
  }) async {
    return _sendMessage(
      orderId: orderId,
      recipientId: recipientId,
      content: content,
      type: MessageType.location,
      metadata: {'latitude': latitude, 'longitude': longitude},
    );
  }

  // Hàm gửi tin nhắn chung
  Future<void> _sendMessage({
    required String orderId,
    required String recipientId,
    required String content,
    String? imageUrl,
    MessageType type = MessageType.text,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (currentUserId == null) {
        throw Exception('Không có người dùng đăng nhập');
      }

      final String chatRoomId = getChatRoomId(currentUserId!, recipientId);
      final String messageId =
          _firestore
              .collection('chats')
              .doc(chatRoomId)
              .collection('messages')
              .doc()
              .id;

      final MessageModel message = MessageModel(
        id: messageId,
        senderId: currentUserId!,
        content: content,
        imageUrl: imageUrl,
        timestamp: DateTime.now(),
        isRead: false,
        type: type,
        metadata: metadata,
      );

      // Lưu tin nhắn
      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .doc(messageId)
          .set(message.toJson());

      // Cập nhật thông tin chat
      final chatData = {
        'userId': recipientId, // Người nhận
        'shipperId': currentUserId, // Người gửi (shipper)
        'participantIds': [currentUserId, recipientId],
        'lastMessage': content,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'orderId': orderId,
        'status': ChatStatus.active.toString().split('.').last,
        'unreadCount_$recipientId': FieldValue.increment(1),
      };

      await _firestore
          .collection('chats')
          .doc(chatRoomId)
          .set(chatData, SetOptions(merge: true));

      // Cập nhật trạng thái tin nhắn
      _updateMessageStatus(messageId, ReceiptStatus.sent);
    } catch (e) {
      rethrow;
    }
  }

  // Cập nhật trạng thái tin nhắn (đã gửi, đã nhận, đã đọc)
  Future<void> _updateMessageStatus(
    String messageId,
    ReceiptStatus status,
  ) async {
    // Implementation for tracking message status
  }

  // =========== READING MESSAGES ===========

  // Lấy stream tin nhắn cho một cuộc trò chuyện
  Stream<List<MessageModel>> getChatMessages(String recipientId) {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    final String chatRoomId = getChatRoomId(currentUserId!, recipientId);

    // Kiểm tra xem đã có stream controller chưa
    if (!_chatStreamControllers.containsKey(chatRoomId)) {
      _chatStreamControllers[chatRoomId] =
          StreamController<List<MessageModel>>.broadcast();

      // Đăng ký lắng nghe từ Firestore
      _firestore
          .collection('chats')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen((snapshot) {
            final messages =
                snapshot.docs
                    .map(
                      (doc) =>
                          MessageModel.fromJson({...doc.data(), 'id': doc.id}),
                    )
                    .toList();
            _chatStreamControllers[chatRoomId]!.add(messages);
          });
    }

    return _chatStreamControllers[chatRoomId]!.stream;
  }

  // Đánh dấu tin nhắn là đã đọc
  Future<void> markMessagesAsRead(String senderId) async {
    if (currentUserId == null) return;

    final String chatRoomId = getChatRoomId(currentUserId!, senderId);

    // Cập nhật trạng thái đã đọc cho tất cả tin của người gửi
    final messagesSnapshot =
        await _firestore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .where('senderId', isEqualTo: senderId)
            .where('isRead', isEqualTo: false)
            .get();

    // Batch update để hiệu quả hơn
    final batch = _firestore.batch();
    for (var doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Đặt lại bộ đếm tin nhắn chưa đọc
    batch.update(_firestore.collection('chats').doc(chatRoomId), {
      'unreadCount_$currentUserId': 0,
    });

    await batch.commit();
  }

  // =========== CHAT LIST & UNREAD MANAGEMENT ===========

  // Lấy số tin nhắn chưa đọc tổng cộng
  Stream<int> getUnreadMessageCount() {
    if (currentUserId == null) {
      return Stream.value(0);
    }

    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: currentUserId)
        .snapshots()
        .map((snapshot) {
          int count = 0;
          for (var doc in snapshot.docs) {
            count += (doc.data()['unreadCount_$currentUserId'] ?? 0) as int;
          }
          return count;
        });
  }

  // Lấy danh sách cuộc trò chuyện
  Stream<List<Chat>> getChatRooms() {
    if (currentUserId == null) {
      return Stream.value([]);
    }

    return _firestore
        .collection('chats')
        .where('participantIds', arrayContains: currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => Chat.fromJson({...doc.data(), 'id': doc.id}))
              .toList();
        });
  }

  // =========== ONLINE PRESENCE MANAGEMENT ===========

  // Cập nhật trạng thái online
  Future<void> updateOnlineStatus(bool isOnline) async {
    if (currentUserId == null) return;

    await _firestore.collection('presence').doc(currentUserId).set({
      'isOnline': isOnline,
      'lastActive': FieldValue.serverTimestamp(),
      'isTyping': false,
    }, SetOptions(merge: true));
  }

  // Cập nhật trạng thái đang gõ
  Future<void> updateTypingStatus(String chatId, bool isTyping) async {
    if (currentUserId == null) return;

    await _firestore.collection('presence').doc(currentUserId).set({
      'isTyping': isTyping,
      'currentChatId': chatId,
      'lastActive': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // Lắng nghe trạng thái online của người dùng
  Stream<bool> getUserOnlineStatus(String userId) {
    return _firestore
        .collection('presence')
        .doc(userId)
        .snapshots()
        .map((doc) => doc.exists ? (doc.data()?['isOnline'] ?? false) : false);
  }

  // Lắng nghe trạng thái đang gõ
  Stream<bool> getUserTypingStatus(String userId, String chatId) {
    return _firestore.collection('presence').doc(userId).snapshots().map((doc) {
      if (!doc.exists) return false;
      final data = doc.data();
      return (data?['isTyping'] ?? false) && (data?['currentChatId'] == chatId);
    });
  }

  // =========== UTILS & CLEANUP ===========

  // Đóng tất cả streams khi không cần thiết
  void dispose() {
    for (var controller in _chatStreamControllers.values) {
      controller.close();
    }
    _chatStreamControllers.clear();
    _onlineStatusController.close();

    // Cập nhật trạng thái offline
    if (currentUserId != null) {
      updateOnlineStatus(false);
    }
  }

  // Xóa lịch sử chat
  Future<void> clearChatHistory(String recipientId) async {
    if (currentUserId == null) return;

    final String chatRoomId = getChatRoomId(currentUserId!, recipientId);

    final messagesSnapshot =
        await _firestore
            .collection('chats')
            .doc(chatRoomId)
            .collection('messages')
            .get();

    final batch = _firestore.batch();
    for (var doc in messagesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

  // Ghim/bỏ ghim cuộc trò chuyện
  Future<void> pinChat(String recipientId, bool isPinned) async {
    if (currentUserId == null) return;

    final String chatRoomId = getChatRoomId(currentUserId!, recipientId);

    await _firestore.collection('chats').doc(chatRoomId).update({
      'isPinned': isPinned,
    });
  }

  // Ẩn/archive chat
  Future<void> archiveChat(String recipientId) async {
    if (currentUserId == null) return;

    final String chatRoomId = getChatRoomId(currentUserId!, recipientId);

    await _firestore.collection('chats').doc(chatRoomId).update({
      'status': ChatStatus.archived.toString().split('.').last,
    });
  }
}
