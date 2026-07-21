import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';

class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String description;
  final DateTime timestamp;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.timestamp,
    this.isRead = false,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      type: data['type'] ?? 'general',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  String getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class NotificationController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxBool isLoading = true.obs;
  final sortBy = 'Latest'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUserId.value;
      
      if (userId != null) {
        final snapshot = await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('timestamp', descending: true)
            .get();
        
        notifications.value = snapshot.docs
            .map((doc) => NotificationModel.fromFirestore(doc))
            .toList();
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final userId = _authService.currentUserId.value;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notificationId)
            .update({'isRead': true});
        
        // Update local list
        final index = notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          notifications[index] = NotificationModel(
            id: notifications[index].id,
            type: notifications[index].type,
            title: notifications[index].title,
            description: notifications[index].description,
            timestamp: notifications[index].timestamp,
            isRead: true,
          );
          notifications.refresh();
        }
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final userId = _authService.currentUserId.value;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .doc(notificationId)
            .delete();
        
        notifications.removeWhere((n) => n.id == notificationId);
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  void changeSortBy() {
    Get.bottomSheet(
      Container(
        color: Colors.white,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('latest'.tr),
              onTap: () {
                sortBy.value = 'latest'.tr;
                notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
                Get.back();
              },
            ),
            ListTile(
              title: Text('oldest'.tr),
              onTap: () {
                sortBy.value = 'oldest'.tr;
                notifications.sort((a, b) => a.timestamp.compareTo(b.timestamp));
                Get.back();
              },
            ),
          ],
        ),
      ),
    );
  }
}
