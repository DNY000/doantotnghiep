import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ChatScreen extends StatefulWidget {
  final String orderId;
  final String recipientId;

  ChatScreen({required this.orderId, required this.recipientId});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMessages() async {
    // TODO: Implement actual message loading from API or database
    // Simulating network delay
    await Future.delayed(Duration(seconds: 1));

    setState(() {
      _messages.addAll([
        ChatMessage(
          text:
              'Xin chào, bạn có thể cho tôi biết khi nào đơn hàng sẽ được giao không?',
          isMe: false,
          time: DateTime.now().subtract(Duration(minutes: 30)),
        ),
        ChatMessage(
          text:
              'Chào bạn, tôi đang trên đường giao hàng và sẽ đến trong khoảng 15 phút nữa',
          isMe: true,
          time: DateTime.now().subtract(Duration(minutes: 25)),
        ),
      ]);
      _isLoading = false;
    });
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = ChatMessage(
      text: _messageController.text,
      isMe: true,
      time: DateTime.now(),
    );

    setState(() {
      _messages.add(message);
      _messageController.clear();
    });

    // Scroll to the bottom after sending a message
    Future.delayed(Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });

    // TODO: Send message to API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Chat'), elevation: 1),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Expanded(
                    child:
                        _messages.isEmpty
                            ? Center(
                              child: Text(
                                'Chưa có tin nhắn nào',
                                style: TextStyle(color: Colors.grey),
                              ),
                            )
                            : ListView.builder(
                              controller: _scrollController,
                              padding: EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final message = _messages[index];
                                return MessageBubble(message: message);
                              },
                            ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _messageController,
                            decoration: InputDecoration(
                              hintText: 'Nhập tin nhắn...',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(24),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Colors.grey[100],
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                            ),
                            textCapitalization: TextCapitalization.sentences,
                            minLines: 1,
                            maxLines: 5,
                          ),
                        ),
                        SizedBox(width: 8),
                        FloatingActionButton(
                          onPressed: _sendMessage,
                          child: Icon(Icons.send),
                          mini: true,
                          backgroundColor: Theme.of(context).primaryColor,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isMe; // true if this message was sent by me (shipper)
  final DateTime time;

  ChatMessage({required this.text, required this.isMe, required this.time});
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final timeString = DateFormat('HH:mm').format(message.time);

    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment:
            message.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isMe) ...[
            CircleAvatar(radius: 16, child: Icon(Icons.person, size: 16)),
            SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment:
                message.isMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      message.isMe
                          ? Theme.of(context).primaryColor
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isMe ? Colors.white : Colors.black,
                  ),
                ),
              ),
              SizedBox(height: 4),
              Text(
                timeString,
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ),
          if (message.isMe) ...[
            SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).primaryColor,
              child: Icon(Icons.directions_bike, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }
}
