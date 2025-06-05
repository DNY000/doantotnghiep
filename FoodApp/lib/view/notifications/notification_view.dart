import 'package:flutter/material.dart';
import 'package:foodapp/data/models/notification_model.dart';
import 'package:foodapp/view/order/order_detail_screen.dart';
import 'package:foodapp/viewmodels/user_viewmodel.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/notification_viewmodel.dart';
import '../../viewmodels/order_viewmodel.dart';
import 'package:foodapp/ultils/const/enum.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) {
        context
            .read<NotificationViewModel>()
            .loadNotifications(context.read<UserViewModel>().currentUser!.id);
      },
    );
    // Load notifications when the view is initialized
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
        centerTitle: true,
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
                    onPressed: () => viewModel.loadNotifications(
                        context.read<UserViewModel>().currentUser!.id),
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
                onTap: () => _handleNotificationTap(context, notification),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleNotificationTap(
      BuildContext context, NotificationModel notification) async {
    // Mark notification as read
    await context.read<NotificationViewModel>().markAsRead(notification.id);

    // If notification is about an order, navigate to order detail
    if (notification.type == NotificationType.order &&
        notification.data.containsKey('orderId')) {
      final orderId = notification.data['orderId'] as String;

      // Get order details and wait for it to complete
      final orderViewModel = context.read<OrderViewModel>();
      await orderViewModel.getOrderById(orderId);

      final order = orderViewModel.selectedOrder;

      // Check if order is not null before navigating
      if (context.mounted && order != null) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailScreen(order: order),
          ),
        );
      } else if (context.mounted) {
        // Show an error message if order details could not be loaded
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể tải chi tiết đơn hàng.')),
        );
      }
    }
  }
}

class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const NotificationItem({
    Key? key,
    required this.notification,
    required this.onMarkAsRead,
    required this.onDelete,
    required this.onTap,
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getNotificationIcon(notification.type),
                  color: _getNotificationColor(notification.type),
                  size: 30,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title ?? "",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: notification.isRead ? Colors.grey : Colors.black,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.content ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatTime(notification.createdAt) ?? "",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getNotificationColor(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Colors.orange;
      case NotificationType.promotion:
        return Colors.green;
      case NotificationType.system:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getNotificationIcon(NotificationType type) {
    switch (type) {
      case NotificationType.order:
        return Icons.shopping_bag;
      case NotificationType.promotion:
        return Icons.local_offer;
      case NotificationType.system:
        return Icons.notifications;
      default:
        return Icons.notifications;
    }
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inDays > 0) {
      return "${time.day}/${time.month}/${time.year}";
    } else if (difference.inHours > 0) {
      return "${difference.inHours} giờ trước";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes} phút trước";
    } else {
      return "Vừa xong";
    }
  }
}
