import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/sign_up_controller.dart';

class ActivityQuestionsView extends GetView<SignUpController> {
  const ActivityQuestionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
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
            child: Column(
              children: [
                Expanded(
                  child: Obx(() {
                    switch (controller.activityStep.value) {
                      case 1:
                        return _buildActivityLevelStep();
                      case 2:
                        return _buildWorkoutFrequencyPage();
                      case 3:
                        return _buildReferralSourcePage();
                      case 4:
                        return _buildTriedOtherAppsPage();
                      case 5:
                        return _buildResultsPage();
                      default:
                        return _buildActivityLevelStep();
                    }
                  }),
                ),
                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => controller.previousActivityStep(),
                        child: Text(
                          'back'.tr,
                          style: GoogleFonts.lato(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => controller.nextActivityStep(),
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
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Builder(
            builder: (context) => Text(
              'how_active'.tr,
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) => Text(
              'sedentary_burns_fewer'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          const Spacer(),
          Obx(() => _buildOptionCard(
                title: 'sedentary'.tr,
                isSelected: controller.selectedActivityLevel.value == 'sedentary',
                onTap: () => controller.selectedActivityLevel.value = 'sedentary',
              )),
          const SizedBox(height: 20),
          Obx(() => _buildOptionCard(
                title: 'low_active'.tr,
                isSelected: controller.selectedActivityLevel.value == 'low_active',
                onTap: () => controller.selectedActivityLevel.value = 'low_active',
              )),
          const SizedBox(height: 20),
          Obx(() => _buildOptionCard(
                title: 'active'.tr,
                isSelected: controller.selectedActivityLevel.value == 'active',
                onTap: () => controller.selectedActivityLevel.value = 'active',
              )),
          const SizedBox(height: 20),
          Obx(() => _buildOptionCard(
                title: 'very_active'.tr,
                isSelected: controller.selectedActivityLevel.value == 'very_active',
                onTap: () => controller.selectedActivityLevel.value = 'very_active',
              )),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildWorkoutFrequencyPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Builder(
            builder: (context) => Text(
              'workouts_per_week'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) => Text(
              'calibrate_custom_plan'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Obx(() => _buildOptionCard(
                title: '0-2',
                subtitle: 'workouts_now_then'.tr,
                isSelected: controller.workoutFrequency.value == '0-2',
                onTap: () => controller.workoutFrequency.value = '0-2',
              )),
          const SizedBox(height: 16),
          Obx(() => _buildOptionCard(
                title: '3-5',
                subtitle: 'few_workouts_week'.tr,
                isSelected: controller.workoutFrequency.value == '3-5',
                onTap: () => controller.workoutFrequency.value = '3-5',
              )),
          const SizedBox(height: 16),
          Obx(() => _buildOptionCard(
                title: '6+',
                subtitle: 'dedicated_athlete'.tr,
                isSelected: controller.workoutFrequency.value == '6+',
                onTap: () => controller.workoutFrequency.value = '6+',
              )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildReferralSourcePage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Builder(
            builder: (context) => Text(
              'where_hear_about_us'.tr,
              style: GoogleFonts.lato(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Obx(() => _buildOptionCard(
                title: 'TikTok',
                isSelected: controller.referralSource.value == 'TikTok',
                onTap: () => controller.referralSource.value = 'TikTok',
              )),
          const SizedBox(height: 16),
          Obx(() => _buildOptionCard(
                title: 'Youtube',
                isSelected: controller.referralSource.value == 'Youtube',
                onTap: () => controller.referralSource.value = 'Youtube',
              )),
          const SizedBox(height: 16),
          Obx(() => _buildOptionCard(
                title: 'Google',
                isSelected: controller.referralSource.value == 'Google',
                onTap: () => controller.referralSource.value = 'Google',
              )),
          const SizedBox(height: 16),
          Obx(() => _buildOptionCard(
                title: 'Playstore',
                isSelected: controller.referralSource.value == 'Playstore',
                onTap: () => controller.referralSource.value = 'Playstore',
              )),
          const SizedBox(height: 16),
          Obx(() => _buildOptionCard(
                title: 'Facebook',
                isSelected: controller.referralSource.value == 'Facebook',
                onTap: () => controller.referralSource.value = 'Facebook',
              )),
          const SizedBox(height: 16),
          Obx(() => _buildOptionCard(
                title: 'Family/Friends',
                isSelected: controller.referralSource.value == 'Family/Friends',
                onTap: () => controller.referralSource.value = 'Family/Friends',
              )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildTriedOtherAppsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Builder(
            builder: (context) => Text(
              'tried_other_apps'.tr,
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 120),
          Obx(() => _buildOptionCard(
                title: 'yes'.tr,
                isSelected: controller.triedOtherApps.value == 'Yes',
                onTap: () => controller.triedOtherApps.value = 'Yes',
              )),
          const SizedBox(height: 16),
          Obx(() => _buildOptionCard(
                title: 'no'.tr,
                isSelected: controller.triedOtherApps.value == 'No',
                onTap: () => controller.triedOtherApps.value = 'No',
              )),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildResultsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40),
          Builder(
            builder: (context) => Text(
              'long_term_results'.tr,
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                height: 1.2,
              ),
            ),
          ),
          const SizedBox(height: 60),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF9DE5DB),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'your_weight'.tr,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: CustomPaint(
                    painter: WeightChartPainter(),
                    child: Container(),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text('Mon', style: GoogleFonts.lato(fontSize: 12, color: Colors.black87)),
                    Text('Tue', style: GoogleFonts.lato(fontSize: 12, color: Colors.black87)),
                    Text('Wed', style: GoogleFonts.lato(fontSize: 12, color: Colors.black87)),
                    Text('Thu', style: GoogleFonts.lato(fontSize: 12, color: Colors.black87)),
                    Text('Fri', style: GoogleFonts.lato(fontSize: 12, color: Colors.black87)),
                    Text('Sat', style: GoogleFonts.lato(fontSize: 12, color: Colors.black87)),
                    Text('Sun', style: GoogleFonts.lato(fontSize: 12, color: Colors.black87)),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'MONTH 1',
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildOptionCard({
    required String title,
    String? subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Builder(
              builder: (context) => Text(
                title,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Builder(
                builder: (context) => Text(
                  subtitle,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class WeightChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Draw grid lines
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * i / 3;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Draw black line (current weight)
    paint.color = Colors.black;
    final blackPath = Path();
    blackPath.moveTo(0, size.height * 0.3);
    blackPath.lineTo(size.width * 0.15, size.height * 0.35);
    blackPath.cubicTo(
      size.width * 0.25, size.height * 0.2,
      size.width * 0.35, size.height * 0.45,
      size.width * 0.5, size.height * 0.5,
    );
    blackPath.cubicTo(
      size.width * 0.65, size.height * 0.55,
      size.width * 0.75, size.height * 0.4,
      size.width * 0.85, size.height * 0.35,
    );
    blackPath.lineTo(size.width, size.height * 0.3);
    canvas.drawPath(blackPath, paint);

    // Draw orange line (target weight)
    paint.color = Colors.orange;
    final orangePath = Path();
    orangePath.moveTo(0, size.height * 0.75);
    orangePath.cubicTo(
      size.width * 0.15, size.height * 0.6,
      size.width * 0.25, size.height * 0.35,
      size.width * 0.4, size.height * 0.15,
    );
    orangePath.cubicTo(
      size.width * 0.5, size.height * 0.25,
      size.width * 0.65, size.height * 0.5,
      size.width * 0.75, size.height * 0.6,
    );
    orangePath.cubicTo(
      size.width * 0.85, size.height * 0.65,
      size.width * 0.9, size.height * 0.55,
      size.width, size.height * 0.5,
    );
    canvas.drawPath(orangePath, paint);

    // Draw y-axis labels
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final labels = ['400', '300', '200', '100'];
    for (int i = 0; i < labels.length; i++) {
      textPainter.text = TextSpan(
        text: labels[i],
        style: GoogleFonts.lato(
          fontSize: 12,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(-5, size.height * i / 3 - 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
