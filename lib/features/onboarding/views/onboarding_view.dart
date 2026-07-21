import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        top: false,
        left: false,
        right: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: controller.pageController,
                itemCount: controller.items.length,
                onPageChanged: controller.onPageChanged,
                itemBuilder: (context, index) {
                  final item = controller.items[index];
                  return _buildPage(item);
                },
              ),
            ),
            
            // Page Indicator
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Obx(() => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.items.length,
                  (index) => _buildIndicator(
                    isActive: index == controller.currentPage.value,
                  ),
                ),
              )),
            ),
            
            // Next/Get Started Button
            Padding(
              padding: const EdgeInsets.all(24),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: Obx(() => ElevatedButton(
                  onPressed: controller.nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00E0C6),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    controller.currentPage.value == controller.items.length - 1
                        ? 'get_started'.tr
                        : 'next'.tr,
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPage(OnboardingItem item) {
    return Column(
      children: [
        // Image placeholder - full width, no padding
        Expanded(
          child: _getImageForItem(item),
        ),
        const SizedBox(height: 40),
        
        // Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            item.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Description
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            item.description,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ),
        const SizedBox(height: 40),
      ],
    );
  }
  
  Widget _getImageForItem(OnboardingItem item) {
    // Use placeholder images based on the provided screenshots
    IconData icon;
    if (item.title.contains('Diet Plan')) {
      icon = Icons.restaurant_menu;
    } else if (item.title.contains('Scanner')) {
      icon = Icons.camera_alt;
    } else {
      icon = Icons.show_chart;
    }
    
    return Image.asset(
      item.imagePath,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Center(
          child: Icon(
            icon,
            size: 150,
            color: Colors.white54,
          ),
        );
      },
    );
  }
  
  Widget _buildIndicator({required bool isActive}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 32 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white38,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
