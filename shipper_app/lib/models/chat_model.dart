import 'package:cloud_firestore/cloud_firestore.dart';

// 1. Thông tin tin nhắn
class MessageModel {
  final String id;
  final String senderId;
  final String content;
  final String? imageUrl;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type; // Loại tin nhắn: text, image, location...
  final Map<String, dynamic>? metadata; // Dữ liệu bổ sung (vị trí, emoji, ...)

  MessageModel({
    required this.id,
    required this.senderId,
    required this.content,
    this.imageUrl,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.metadata,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
    id: json['id'],
    senderId: json['senderId'],
    content: json['content'],
    imageUrl: json['imageUrl'],
    timestamp:
        json['timestamp'] is DateTime
            ? json['timestamp']
            : (json['timestamp'] is Timestamp
                ? (json['timestamp'] as Timestamp).toDate()
                : DateTime.parse(json['timestamp'])),
    isRead: json['isRead'] ?? false,
    type: MessageType.values.firstWhere(
      (e) => e.toString() == 'MessageType.${json['type'] ?? 'text'}',
      orElse: () => MessageType.text,
    ),
    metadata: json['metadata'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'content': content,
    'imageUrl': imageUrl,
    'timestamp': timestamp.toIso8601String(),
    'isRead': isRead,
    'type': type.toString().split('.').last,
    'metadata': metadata,
  };
}

// 2. Thông tin về phòng chat
class Chat {
  final String id;
  final String userId;
  final String shipperId;
  final List<String> participantIds;
  final DateTime lastMessageTime;
  final String lastMessage;
  final String orderId;
  final Map<String, int> unreadCounts;
  final ChatStatus status; // Trạng thái: active, archived, blocked
  final bool isPinned; // Ghim hội thoại
  final Map<String, dynamic>? chatMetadata; // Thông tin thêm về chat

  Chat({
    required this.id,
    required this.userId,
    required this.shipperId,
    required this.participantIds,
    required this.lastMessageTime,
    required this.lastMessage,
    required this.orderId,
    required this.unreadCounts,
    this.status = ChatStatus.active,
    this.isPinned = false,
    this.chatMetadata,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    final Map<String, int> unreadCounts = {};
    json.forEach((key, value) {
      if (key.startsWith('unreadCount_')) {
        final userId = key.substring('unreadCount_'.length);
        unreadCounts[userId] = value as int;
      }
    });

    return Chat(
      id: json['id'],
      userId: json['userId'],
      shipperId: json['shipperId'],
      participantIds: List<String>.from(json['participantIds']),
      lastMessageTime:
          json['lastMessageTime'] is DateTime
              ? json['lastMessageTime']
              : (json['lastMessageTime'] is Timestamp
                  ? (json['lastMessageTime'] as Timestamp).toDate()
                  : DateTime.parse(json['lastMessageTime'])),
      lastMessage: json['lastMessage'],
      orderId: json['orderId'] ?? '',
      unreadCounts: unreadCounts,
      status: ChatStatus.values.firstWhere(
        (e) => e.toString() == 'ChatStatus.${json['status'] ?? 'active'}',
        orElse: () => ChatStatus.active,
      ),
      isPinned: json['isPinned'] ?? false,
      chatMetadata: json['chatMetadata'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'id': id,
      'userId': userId,
      'shipperId': shipperId,
      'participantIds': participantIds,
      'lastMessageTime': lastMessageTime.toIso8601String(),
      'lastMessage': lastMessage,
      'orderId': orderId,
      'status': status.toString().split('.').last,
      'isPinned': isPinned,
      'chatMetadata': chatMetadata,
    };

    unreadCounts.forEach((userId, count) {
      data['unreadCount_$userId'] = count;
    });

    return data;
  }
}

// Enums cho các trạng thái
enum MessageType {
  text,
  image,
  location,
  file,
  audio,
  video,
  system, // Tin nhắn hệ thống
}

enum ChatStatus { active, archived, blocked }

enum ReceiptStatus {
  sent, // Đã gửi
  delivered, // Đã chuyển tới server
  read, // Đã đọc
}
