import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routing/app_routes.dart';

class OnboardingController extends GetxController {
  final RxInt currentPage = 0.obs;
  final PageController pageController = PageController();
  
  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
  
  final List<OnboardingItem> items = [
    OnboardingItem(
      title: 'AI Diet Plan Generator',
      description: 'Get meal plans tailored to your goals.',
      imagePath: 'assets/images/diet_plan.png',
    ),
    OnboardingItem(
      title: 'Food Scanner',
      description: 'Snap a meal and get instant calories & nutrition.',
      imagePath: 'assets/images/food_scanner.png',
    ),
    OnboardingItem(
      title: 'Progress Tracker',
      description: 'Visualize your journey to a healthier you',
      imagePath: 'assets/images/progress.png',
    ),
  ];
  
  void onPageChanged(int index) {
    currentPage.value = index;
  }
  
  void nextPage() {
    if (currentPage.value < items.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      getStarted();
    }
  }
  
  Future<void> getStarted() async {
    // Mark onboarding as seen
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Get.offAllNamed(AppRoutes.auth);
  }
  
  void skip() {
    getStarted();
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final String imagePath;
  
  OnboardingItem({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}
