import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00E0C6),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }
        return SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(top: 20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildNotificationHeader(),
                      Expanded(
                        child: controller.notifications.isEmpty
                            ? Center(
                                child: Text(
                                  'No notifications yet',
                                  style: GoogleFonts.lato(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.all(20),
                                itemCount: controller.notifications.length,
                                itemBuilder: (context, index) {
                                  return _buildNotificationItem(
                                    controller.notifications[index],
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back, size: 24, color: Colors.black),
          ),
          Expanded(
            child: Center(
              child: Text(
                'notifications'.tr,
                style: GoogleFonts.lato(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
          ),
          const SizedBox(width: 24),
        ],
      ),
    );
  }

  Widget _buildNotificationHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Latest notification',
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          GestureDetector(
            onTap: () => controller.changeSortBy(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Obx(() => Text(
                    'Sort By ${controller.sortBy.value}',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  )),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.grey[700]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) => controller.deleteNotification(notification.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () => controller.markAsRead(notification.id),
        child: Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getIconData(notification.type),
                      size: 28,
                      color: Colors.black87,
                    ),
                  ),
                  if (!notification.isRead)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.description,
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.grey[600],
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      notification.getTimeAgo(),
                      style: GoogleFonts.lato(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[500],
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

  IconData _getIconData(String type) {
    switch (type) {
      case 'meal':
        return Icons.restaurant;
      case 'goal':
        return Icons.flag;
      case 'weight':
        return Icons.monitor_weight;
      case 'reminder':
        return Icons.notifications_active;
      case 'budget':
        return Icons.attach_money;
      default:
        return Icons.notifications_outlined;
    }
  }
}
