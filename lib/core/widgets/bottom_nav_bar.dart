import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../routing/app_routes.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;

  const BottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                'assets/icons/home.png',
                'nav_home',
                0,
                isDark,
              ),
              _buildNavItem(
                context,
                'assets/icons/meals.png',
                'nav_bmi',
                1,
                isDark,
              ),
              _buildNavItem(
                context,
                'assets/icons/scan.png',
                'nav_scan',
                2,
                isDark,
              ),
              _buildNavItem(
                context,
                'assets/icons/chart.png',
                'nav_progress',
                3,
                isDark,
              ),
              _buildNavItem(
                context,
                'assets/icons/premium.png',
                'nav_premium',
                4,
                isDark,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context,
    String iconPath,
    String label,
    int index,
    bool isDark,
  ) {
    final isSelected = currentIndex == index;
    final activeColor = isDark ? Colors.white : Colors.black;
    final inactiveColor = isDark
        ? Colors.white.withOpacity(0.5)
        : Colors.black.withOpacity(0.5);

    // Special color handling for scan icon
    final iconColor = index == 2
        ? (isSelected ? Colors.white : Colors.grey)
        : (isSelected ? activeColor : inactiveColor);

    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ColorFiltered(
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
            child: Image.asset(
              iconPath,
              width: index == 2 ? 30 : 26,
              height: index == 2 ? 30 : 26,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label.tr,
            style: GoogleFonts.lato(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected ? activeColor : inactiveColor,
            ),
          ),
        ],
      ),
    );
  }

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Get.offAllNamed(AppRoutes.home);
        break;
      case 1:
        Get.offAllNamed(AppRoutes.meals);
        break;
      case 2:
        Get.toNamed(AppRoutes.scanner);
        break;
      case 3:
        Get.offAllNamed(AppRoutes.progress);
        break;
      case 4:
        Get.offAllNamed(AppRoutes.premium);
        break;
    }
  }
}
