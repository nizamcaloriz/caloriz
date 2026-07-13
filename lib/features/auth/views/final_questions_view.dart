import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/sign_up_controller.dart';

class FinalQuestionsView extends GetView<SignUpController> {
  const FinalQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        // Show loading screen without decorations
        if (controller.finalStep.value == 5) {
          return _buildLoadingStep();
        }

        // Regular screens with bottom decoration
        return Stack(
          children: [
            // Cyan circular decoration bottom left (only in light theme)
            Builder(
              builder: (context) {
                if (Theme.of(context).brightness == Brightness.light) {
                  return Positioned(
                    bottom: -150,
                    left: -180,
                    child: Container(
                      width: 420,
                      height: 420,
                      decoration: const BoxDecoration(
                        color: Color.fromRGBO(207, 249, 244, 1),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            SafeArea(
              child: Obx(() {
                switch (controller.finalStep.value) {
                  case 1:
                    return _buildDietTypeStep();
                  case 2:
                    return _buildAccomplishStep();
                  case 3:
                    return _buildThankYouStep();
                  case 4:
                    return _buildReferralCodeStep();
                  case 6:
                    return _buildProgressStep();
                  default:
                    return _buildDietTypeStep();
                }
              }),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDietTypeStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Builder(
            builder: (context) => Text(
              'follow_specific_diet'.tr,
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Obx(
            () => _buildOptionCard(
              'classic'.tr,
              controller.dietType.value == 'Classic',
              () => controller.dietType.value = 'Classic',
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _buildOptionCard(
              'pescatarian'.tr,
              controller.dietType.value == 'Pescatarian',
              () => controller.dietType.value = 'Pescatarian',
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _buildOptionCard(
              'vegan'.tr,
              controller.dietType.value == 'Vegan',
              () => controller.dietType.value = 'Vegan',
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _buildOptionCard(
              'vegetarian'.tr,
              controller.dietType.value == 'Vegetarian',
              () => controller.dietType.value = 'Vegetarian',
            ),
          ),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => controller.nextFinalStep(),
              child: Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFF03E0C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildAccomplishStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Builder(
            builder: (context) => Text(
              'what_accomplish'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Obx(
            () => _buildOptionCard(
              'eat_live_healthier'.tr,
              controller.accomplishGoal.value == 'Eat and live healthier',
              () => controller.accomplishGoal.value = 'Eat and live healthier',
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _buildOptionCard(
              'boost_energy_mood'.tr,
              controller.accomplishGoal.value == 'Boost my energy and mood',
              () =>
                  controller.accomplishGoal.value = 'Boost my energy and mood',
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _buildOptionCard(
              'feel_better_body'.tr,
              controller.accomplishGoal.value == 'Feel better about my body',
              () =>
                  controller.accomplishGoal.value = 'Feel better about my body',
            ),
          ),
          const SizedBox(height: 20),
          Obx(
            () => _buildOptionCard(
              'stay_motivated'.tr,
              controller.accomplishGoal.value == 'Stay motivated about my body',
              () => controller.accomplishGoal.value =
                  'Stay motivated about my body',
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => controller.previousFinalStep(),
                child: Text(
                  'Back',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.nextFinalStep(),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF03E0C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildThankYouStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF03E0C7), width: 30),
            ),
            child: Center(
              child: ClipOval(
                child: Image.asset(
                  'assets/images/clap.gif',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          Builder(
            builder: (context) => Text(
              'thank_you'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (context) => Text(
              'personalize_caloriz'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => controller.previousFinalStep(),
                child: Text(
                  'Back',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.nextFinalStep(),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF03E0C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildReferralCodeStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Builder(
            builder: (context) => Text(
              'referral_code'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Builder(
            builder: (context) => Obx(
              () => TextField(
                onChanged: (value) {
                  controller.referralCode.value = value;
                  if (controller.referralCodeError.value.isNotEmpty) {
                    controller.referralCodeError.value = '';
                  }
                },
                decoration: InputDecoration(
                  helperText: 'Optional - Enter code (e.g., JO1234)',
                  helperStyle: GoogleFonts.lato(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade600
                        : Colors.grey.shade500,
                  ),
                  errorText: controller.referralCodeError.value.isEmpty
                      ? null
                      : controller.referralCodeError.value,
                  hintText: 'referral_code'.tr,
                  hintStyle: GoogleFonts.lato(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey.shade500
                        : Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade800
                      : Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 1),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.red, width: 2),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                style: GoogleFonts.lato(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => controller.previousFinalStep(),
                child: Text(
                  'Back',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Row(
                children: [
                  TextButton(
                    onPressed: () {
                      // Clear referral code and proceed
                      controller.referralCode.value = '';
                      controller.nextFinalStep();
                    },
                    child: Text(
                      'Skip',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(
                    () => GestureDetector(
                      onTap: controller.referralCode.value.isEmpty
                          ? null
                          : () => controller.nextFinalStep(),
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: controller.referralCode.value.isEmpty
                              ? Colors.grey.withOpacity(0.3)
                              : const Color(0xFF03E0C7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildLoadingStep() {
    return Builder(
      builder: (context) => Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Animated Progress Circle
                Obx(
                  () => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: CircularProgressIndicator(
                          value: controller.loadingProgress.value,
                          strokeWidth: 10,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF03E0C7),
                          ),
                        ),
                      ),
                      Text(
                        '${(controller.loadingProgress.value * 100).toInt()}%',
                        style: GoogleFonts.lato(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 50),
                // Dynamic Loading Text
                Obx(
                  () => Text(
                    _getLoadingText(controller.loadingProgress.value),
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Sub-text with animation
                Obx(
                  () => AnimatedOpacity(
                    opacity: controller.loadingProgress.value > 0.1 ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 500),
                    child: Text(
                      _getLoadingSubtext(controller.loadingProgress.value),
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 40),
            Obx(
              () => Text(
                '${(controller.loadingProgress.value * 100).toInt()}%',
                style: GoogleFonts.lato(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF03E0C7),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Builder(
              builder: (context) => Text(
                'setting_everything'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Builder(
              builder: (context) => Container(
                width: double.infinity,
                height: 8,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade700
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Obx(
                  () => FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: controller.loadingProgress.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF03E0C7),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Builder(
              builder: (context) => Obx(
                () => Text(
                  _getLoadingText(controller.loadingProgress.value),
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 60),
            Builder(
              builder: (context) => Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey.shade900
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.3)
                          : Colors.grey.shade200,
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Builder(
                      builder: (context) => Text(
                        'daily_recommendation'.tr,
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildCheckItem('calories'.tr),
                    _buildCheckItem('carbs'.tr),
                    _buildCheckItem('protein'.tr),
                    _buildCheckItem('fats'.tr),
                    _buildCheckItem('health_score'.tr),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            Align(
              alignment: Alignment.bottomRight,
              child: GestureDetector(
                onTap: () => controller.nextFinalStep(),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF03E0C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard(String text, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF00E0C6) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Builder(
          builder: (context) => Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCheckItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Builder(
            builder: (context) => Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color:
                    Theme.of(context).textTheme.bodyLarge?.color ??
                    Colors.black,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Builder(
            builder: (context) => Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getLoadingText(double progress) {
    if (progress < 0.2) {
      return 'Analyzing your profile...';
    } else if (progress < 0.4) {
      return 'Calculating your BMR...';
    } else if (progress < 0.6) {
      return 'Customizing meal plan...';
    } else if (progress < 0.8) {
      return 'Setting up your goals...';
    } else if (progress < 0.95) {
      return 'Finalizing your plan...';
    } else {
      return 'Almost ready!';
    }
  }

  String _getLoadingSubtext(double progress) {
    if (progress < 0.2) {
      return 'We\'re reviewing your age, height, and weight';
    } else if (progress < 0.4) {
      return 'Calculating your daily calorie needs';
    } else if (progress < 0.6) {
      return 'Creating personalized macros for your ${controller.selectedGoal.value} goal';
    } else if (progress < 0.8) {
      return 'Adjusting for your ${controller.selectedActivityLevel.value} activity level';
    } else if (progress < 0.95) {
      return 'Preparing your ${controller.dietType.value} diet recommendations';
    } else {
      return 'Your custom plan is ready! 🎉';
    }
  }
}

class ArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF03E0C7).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, size.height / 2),
        radius: size.width / 2,
      ),
      -1.5,
      3.0,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class SlowCircularLoader extends StatefulWidget {
  const SlowCircularLoader({super.key});

  @override
  State<SlowCircularLoader> createState() => _SlowCircularLoaderState();
}

class _SlowCircularLoaderState extends State<SlowCircularLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CircularProgressIndicator(
          strokeWidth: 8,
          value: _controller.value,
          valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF03E0C7)),
        );
      },
    );
  }
}
