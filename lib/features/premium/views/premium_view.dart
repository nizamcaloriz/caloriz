import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/services/auth_service.dart';
import '../controllers/premium_controller.dart';

class PremiumView extends GetView<PremiumController> {
  const PremiumView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authService = Get.find<AuthService>();

    return Obx(() {
      final isPremium = authService.isPremium.value;

      return Scaffold(
        backgroundColor: isDark ? Colors.black : Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Premium badge for existing premium users
                  if (isPremium)
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFF00E3CC).withOpacity(0.2),
                            const Color(0xFFFF69B4).withOpacity(0.2),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF00E3CC),
                          width: 1.5,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.verified,
                                color: Color(0xFF00E3CC),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '✨ You\'re Premium',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF00E3CC),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Thank you for supporting Caloriz!\nEnjoy unlimited access to all features.',
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: isDark ? Colors.white70 : Colors.black87,
                              height: 1.4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                  Text(
                    isPremium ? 'Your Premium Benefits' : 'pricing'.tr,
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isPremium
                        ? 'Enjoy unlimited access to all features'
                        : 'get_unlimited_access'.tr,
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: isDark ? Colors.white70 : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // Pricing card — shows loading/error/content states
                  _buildPricingSection(context, isDark),

                  const SizedBox(height: 24),
                  _buildWhatsIncluded(context),
                  const SizedBox(height: 32),

                  if (isPremium)
                    _buildPremiumUserButton(context)
                  else
                    _buildGetAccessButton(context),

                  const SizedBox(height: 32),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavBar(currentIndex: 4),
      );
    });
  }

  // ─── Pricing section: handles loading / error / loaded states ─────────────

  Widget _buildPricingSection(BuildContext context, bool isDark) {
    return Obx(() {
      // Loading state
      if (controller.isLoading.value && !controller.productsLoaded.value) {
        return _buildLoadingCard(context, isDark);
      }

      // Load failed state
      if (controller.loadFailed.value && !controller.productsLoaded.value) {
        return _buildErrorCard(context, isDark);
      }

      // Products loaded — show actual prices from store
      return _buildPricingCard(context, isDark);
    });
  }

  Widget _buildLoadingCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00E3CC)),
            strokeWidth: 2,
          ),
          const SizedBox(height: 16),
          Text(
            'Loading prices from store...',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        children: [
          Icon(Icons.wifi_off_rounded,
              size: 40,
              color: isDark ? Colors.white38 : Colors.black38),
          const SizedBox(height: 12),
          Text(
            'Could not load pricing',
            style: GoogleFonts.lato(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Check your internet connection and try again.',
            style: GoogleFonts.lato(
              fontSize: 13,
              color: isDark ? Colors.white54 : Colors.black54,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          OutlinedButton.icon(
            onPressed: () => controller.retryLoadProducts(),
            icon: const Icon(Icons.refresh, size: 16),
            label: Text(
              'Retry',
              style: GoogleFonts.lato(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF00E3CC),
              side: const BorderSide(color: Color(0xFF00E3CC)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPricingCard(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Obx(
        () => Column(
          children: [
            _buildPricingOption(
              context,
              isDark,
              title: 'monthly'.tr,
              // Price comes ONLY from the store product — never hardcoded
              priceText: controller.monthlyPriceText,
              period: 'month'.tr,
              isBestValue: false,
              index: 0,
            ),
            const SizedBox(height: 16),
            _buildPricingOption(
              context,
              isDark,
              title: 'yearly'.tr,
              // Price comes ONLY from the store product — never hardcoded
              priceText: controller.yearlyPriceText,
              period: 'year'.tr,
              isBestValue: true,
              index: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingOption(
    BuildContext context,
    bool isDark, {
    required String title,
    required String priceText,
    required String period,
    required bool isBestValue,
    required int index,
  }) {
    return Obx(() {
      final isSelected = controller.selectedPlan.value == index;
      return GestureDetector(
        onTap: () => controller.selectPlan(index),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00E3CC)
                      : (isDark ? Colors.grey.shade600 : Colors.grey.shade300),
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF00E3CC)
                            : (isDark
                                  ? Colors.grey.shade500
                                  : Colors.grey.shade400),
                        width: 2,
                      ),
                      color: isSelected
                          ? const Color(0xFF00E3CC)
                          : Colors.transparent,
                    ),
                    child: isSelected
                        ? const Icon(Icons.check, color: Colors.black, size: 16)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: GoogleFonts.lato(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // priceText is always from the store — localized automatically
                        priceText.isNotEmpty
                            ? Text(
                                '$priceText / $period',
                                style: GoogleFonts.lato(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.black87,
                                ),
                              )
                            : _buildPriceShimmer(isDark),
                        if (isBestValue) ...[
                          const SizedBox(height: 4),
                          Text(
                            'two_months_free'.tr,
                            style: GoogleFonts.lato(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0xFF00E3CC),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (isBestValue)
              Positioned(
                right: 12,
                top: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF69B4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'best_value'.tr,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    });
  }

  /// Small shimmer placeholder shown while price is still loading.
  Widget _buildPriceShimmer(bool isDark) {
    return Container(
      height: 14,
      width: 70,
      decoration: BoxDecoration(
        color: isDark ? Colors.white12 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ─── What's Included ─────────────────────────────────────────────────────

  Widget _buildWhatsIncluded(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'whats_included'.tr,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          const SizedBox(height: 20),
          _buildFeatureItem(context, 'ai_meal_suggestions'.tr),
          const SizedBox(height: 16),
          _buildFeatureItem(context, 'full_nutrient_analysis'.tr),
          const SizedBox(height: 16),
          _buildFeatureItem(context, 'exclusive_diet_programs'.tr),
          const SizedBox(height: 16),
          _buildFeatureItem(context, 'unlimited_saved_meals'.tr),
          const SizedBox(height: 16),
          _buildFeatureItem(context, 'ai_progress_reports'.tr),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: Color(0xFF00E3CC),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.black, size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  // ─── CTA Buttons ─────────────────────────────────────────────────────────

  Widget _buildGetAccessButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.upgradeToPremium(),
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isLoading.value
                ? Colors.grey
                : const Color(0xFF00E3CC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 2,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : Text(
                  'get_full_access'.tr,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildPremiumUserButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          onPressed: controller.isLoading.value
              ? null
              : () => controller.upgradeToPremium(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: controller.isLoading.value
                ? Colors.grey
                : const Color(0xFF00E3CC),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            elevation: 2,
          ),
          child: controller.isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                  ),
                )
              : Text(
                  'Change Plan',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}
