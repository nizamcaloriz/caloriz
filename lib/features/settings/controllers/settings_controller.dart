import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';

class SettingsController extends GetxController {
  final notificationEnabled = true.obs;
  final isDeleting = false.obs;

  final AuthService _authService = Get.find<AuthService>();

  void toggleNotification(bool value) {
    notificationEnabled.value = value;
  }

  void changeFitnessGoal() {
    // Navigate to fitness goal selection
    Get.snackbar('info'.tr, 'change_fitness_goal'.tr);
  }

  void changeMotivationTone() {
    // Navigate to motivation tone selection
    Get.snackbar('info'.tr, 'change_motivation_tone'.tr);
  }

  void changeActivityLevel() {
    // Navigate to activity level selection
    Get.snackbar('info'.tr, 'change_activity_level'.tr);
  }

  void manualGoalAdjustment() {
    // Navigate to manual goal adjustment
    Get.snackbar('info'.tr, 'manual_goal_adjustment'.tr);
  }

  void resetGoals() {
    Get.dialog(
      AlertDialog(
        title: Text('reset_goals'.tr),
        content: Text('reset_goals_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              Get.snackbar('success'.tr, 'goals_reset_success'.tr);
            },
            child: Text('reset'.tr),
          ),
        ],
      ),
    );
  }

  void logout() {
    Get.dialog(
      AlertDialog(
        title: Text('logout'.tr),
        content: Text('logout_message'.tr),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await _authService.signOut();
              Get.offAllNamed('/sign-in');
            },
            child: Text('logout'.tr),
          ),
        ],
      ),
    );
  }

  void deleteAccount() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            Expanded(child: Text('delete_account'.tr)),
          ],
        ),
        content: Text(
          'delete_account_message'.tr,
          style: const TextStyle(fontSize: 15, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('cancel'.tr),
          ),
          Obx(() => TextButton(
                onPressed: isDeleting.value ? null : () => _performDeleteAccount(),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: isDeleting.value ? Colors.grey : Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                child: isDeleting.value
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text('delete'.tr),
              )),
        ],
      ),
      barrierDismissible: false,
    );
  }

  Future<void> _performDeleteAccount() async {
    isDeleting.value = true;

    final result = await _authService.deleteAccount();

    isDeleting.value = false;

    if (result['success'] == true) {
      Get.back(); // Close dialog
      Get.offAllNamed('/sign-in');
      Get.snackbar(
        'success'.tr,
        'account_deletion_initiated'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } else {
      Get.back(); // Close dialog
      Get.snackbar(
        'error'.tr,
        result['error']?.toString() ?? 'Failed to delete account',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }
}
