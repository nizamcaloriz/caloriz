import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routing/app_routes.dart';

class ActivityQuestionsController extends GetxController {
  final PageController pageController = PageController();
  final RxInt currentPage = 0.obs;
  
  final RxString workoutFrequency = ''.obs;
  final RxString referralSource = ''.obs;
  final RxString triedOtherApps = ''.obs;

  void goNext() {
    if (currentPage.value < 3) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to home after completing all questions
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void goBack() {
    if (currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Get.back();
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
