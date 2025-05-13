import 'package:flutter/material.dart';
import 'package:foodapp/data/models/notification_model.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/notification_viewmodel.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    // Load notifications when the view is initialized
    Future.microtask(
        () => context.read<NotificationViewModel>().loadNotifications());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.5,
        backgroundColor: Colors.white,
        title: const Text(
          "Thông báo",
          style: TextStyle(
            color: Colors.black,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Consumer<NotificationViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (viewModel.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(viewModel.error!),
                  ElevatedButton(
                    onPressed: () => viewModel.loadNotifications(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          if (viewModel.notifications.isEmpty) {
            return const Center(
              child: Text('Không có thông báo nào'),
            );
          }

          return ListView.separated(
            itemCount: viewModel.notifications.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final notification = viewModel.notifications[index];
              return NotificationItem(
                notification: notification,
                onMarkAsRead: () => viewModel.markAsRead(notification.id),
                onDelete: () => viewModel.deleteNotification(notification.id),
              );
            },
          );
        },
      ),
    );
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: InkWell(
        onTap: onMarkAsRead,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.notifications,
                  color: Colors.orange,
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: notification.isRead ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.content,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return "${time.hour}:${time.minute} ${time.day}/${time.month}/${time.year}";
  }
}
