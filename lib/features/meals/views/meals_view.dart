import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../controllers/meals_controller.dart';

class MealsView extends GetView<MealsController> {
  const MealsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    _buildPersonalizedPlanText(),
                    const SizedBox(height: 24),
                    _buildDayTabs(),
                    const SizedBox(height: 32),
                    _buildLogTodaysMeal(),
                    const SizedBox(height: 32),
                    _buildCalculatedBMI(),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 1),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Text(
              'ai_meal_plan'.tr,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalizedPlanText() {
    return Text(
      'personalized_7day_plan'.tr,
      style: GoogleFonts.lato(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Theme.of(Get.context!).textTheme.bodyLarge?.color,
      ),
    );
  }

  Widget _buildDayTabs() {
    final now = DateTime.now();
    final today = now.day;
    final currentMonth = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ][now.month - 1];

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SizedBox(
          height: 60,
          child: Row(
            children: List.generate(7, (index) {
              // Calculate date (middle item is today)
              final dayOffset = index - 3;
              final date = now.add(Duration(days: dayOffset));
              final dayNumber = date.day;
              final monthName = [
                'Jan',
                'Feb',
                'Mar',
                'Apr',
                'May',
                'Jun',
                'Jul',
                'Aug',
                'Sep',
                'Oct',
                'Nov',
                'Dec',
              ][date.month - 1];

              return Obx(() {
                final isSelected = controller.selectedDay.value == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectDay(index),
                    child: Container(
                      margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00E3CC)
                            : (isDark
                                  ? const Color(0xFF2C2C2C)
                                  : const Color(0xFFCBF2F2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: isSelected
                                  ? Colors.black
                                  : (isDark
                                        ? Colors.white70
                                        : const Color(0xFF007E7C)),
                            ),
                          ),
                          Text(
                            monthName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: isSelected
                                  ? Colors.black
                                  : (isDark
                                        ? Colors.white70
                                        : const Color(0xFF007E7C)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            }),
          ),
        );
      },
    );
  }

  Widget _buildLogTodaysMeal() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'log_todays_meal'.tr,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Obx(
                () => _buildTrackingCard(
                  context,
                  icon: Icons.directions_walk,
                  label: 'steps'.tr,
                  value: '${controller.dailySteps.value}',
                  color: const Color(0xFF00E3CC),
                  onTap: () => _showAddStepsDialog(context),
                ),
              ),
              Obx(
                () => _buildTrackingCard(
                  context,
                  icon: Icons.water_drop,
                  label: 'water'.tr,
                  value:
                      '${(controller.dailyWater.value * 0.25).toStringAsFixed(1)}L',
                  color: const Color(0xFF00E3CC),
                  onTap: () => controller.addWaterGlass(),
                ),
              ),
              Obx(
                () => _buildTrackingCard(
                  context,
                  icon: Icons.local_fire_department,
                  label: 'calories'.tr,
                  value: '${controller.dailyCalories.value}',
                  color: const Color(0xFF00E3CC),
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrackingCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        height: 110,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Icon(icon, size: 32, color: Colors.black),
            const SizedBox(height: 8),
            Text(
              value,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculatedBMI() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'calculated_bmi'.tr,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF2C2C2C)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Column(
              children: [
                // BMI Value
                Obx(
                  () => Text(
                    controller.bmi.value.toStringAsFixed(1),
                    style: GoogleFonts.lato(
                      fontSize: 72,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF00E3CC),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Status Badge with pointer
                Obx(
                  () => Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: controller.getBmiColor(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          controller.bmiCategory.value.tr,
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      // Triangle pointer
                      CustomPaint(
                        size: const Size(12, 8),
                        painter: TrianglePainter(
                          color: controller.getBmiColor(),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // BMI Scale
                _buildBMIScale(),
                const SizedBox(height: 20),
                Divider(color: Theme.of(context).dividerColor),
                const SizedBox(height: 16),
                // Stats Row
                Obx(
                  () => Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '${controller.weight.value.toStringAsFixed(1)} kg',
                        'weight_stat'.tr,
                      ),
                      _buildStatItem(
                        '${controller.height.value.toStringAsFixed(0)} cm',
                        'height_stat'.tr,
                      ),
                      _buildStatItem('--', 'age_stat'.tr),
                      _buildStatItem('--', 'gender_stat'.tr),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // Healthy weight info
                Text(
                  'healthy_weight_for_height'.tr,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Obx(() {
                  final heightInMeters = controller.height.value / 100;
                  final minWeight = (18.5 * heightInMeters * heightInMeters)
                      .toStringAsFixed(1);
                  final maxWeight = (24.9 * heightInMeters * heightInMeters)
                      .toStringAsFixed(1);
                  return Text(
                    '$minWeight kg - $maxWeight kg',
                    style: GoogleFonts.lato(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00E3CC),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIScale() {
    return SizedBox(
      height: 24,
      child: Row(
        children: List.generate(40, (index) {
          Color color;
          if (index < 10) {
            color = const Color(0xFF00E3CC); // Underweight - cyan
          } else if (index < 20) {
            color = const Color(0xFF4CAF50); // Normal - green
          } else if (index < 28) {
            color = const Color(0xFFFFEB3B); // Overweight - yellow
          } else if (index < 34) {
            color = const Color(0xFFFF9800); // Obese - orange
          } else {
            color = const Color(0xFFF44336); // Severely obese - red
          }
          return Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 0.5),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Builder(
      builder: (context) => Column(
        children: [
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF00E3CC),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 12,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'meal_section'.tr,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          _buildMealCard(
            'assets/images/breakfast.jpg',
            'breakfast'.tr,
            'Oat Meal - 300 cal',
          ),
          const SizedBox(height: 16),
          _buildMealCard(
            'assets/images/lunch.jpg',
            'lunch'.tr,
            'Chicken Salad- 400 cal',
          ),
          const SizedBox(height: 16),
          _buildMealCard(
            'assets/images/snacks.jpg',
            'snacks'.tr,
            'Grilled Chicken- 350 cal',
          ),
          const SizedBox(height: 16),
          _buildMealCard(
            'assets/images/dinner.jpg',
            'dinner'.tr,
            'Oat Meal - 300 cal',
          ),
        ],
      ),
    );
  }

  void _showAddStepsDialog(BuildContext context) {
    final TextEditingController stepsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add Steps'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Steps',
                hintText: 'e.g., 1000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(stepsController.text);
              if (steps != null && steps > 0) {
                controller.addSteps(steps);
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E3CC),
            ),
            child: Text('Add', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(String imagePath, String title, String subtitle) {
    // Determine placeholder color based on meal type
    Color placeholderColor;
    IconData placeholderIcon;

    // Normalize title for comparison (check for translated values)
    final normalizedTitle = title.toLowerCase();

    if (normalizedTitle.contains('breakfast') ||
        normalizedTitle.contains('desayuno') ||
        normalizedTitle.contains('नाश्ता') ||
        normalizedTitle.contains('petit-déjeuner') ||
        normalizedTitle.contains('早餐')) {
      placeholderColor = Colors.blue.shade100;
      placeholderIcon = Icons.breakfast_dining;
    } else if (normalizedTitle.contains('lunch') ||
        normalizedTitle.contains('almuerzo') ||
        normalizedTitle.contains('दोपहर') ||
        normalizedTitle.contains('déjeuner') ||
        normalizedTitle.contains('午餐')) {
      placeholderColor = Colors.orange.shade100;
      placeholderIcon = Icons.lunch_dining;
    } else if (normalizedTitle.contains('snack') ||
        normalizedTitle.contains('bocadillo') ||
        normalizedTitle.contains('collation') ||
        normalizedTitle.contains('小吃')) {
      placeholderColor = Colors.brown.shade100;
      placeholderIcon = Icons.local_cafe;
    } else if (normalizedTitle.contains('dinner') ||
        normalizedTitle.contains('cena') ||
        normalizedTitle.contains('रात') ||
        normalizedTitle.contains('dîner') ||
        normalizedTitle.contains('晚餐')) {
      placeholderColor = Colors.blue.shade100;
      placeholderIcon = Icons.dinner_dining;
    } else {
      placeholderColor = Colors.grey.shade400;
      placeholderIcon = Icons.restaurant;
    }

    return Builder(
      builder: (context) => Container(
        height: 100,
        decoration: BoxDecoration(
          color:
              Theme.of(context).cardTheme.color ??
              Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        ),
        child: Row(
          children: [
            // Image with rounded corners
            Container(
              width: 80,
              height: 80,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: placeholderColor,
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {},
                ),
              ),
              child: imagePath.isEmpty
                  ? Icon(placeholderIcon, size: 48, color: Colors.white70)
                  : null,
            ),
            // Text content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00E3CC),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF00E3CC),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Arrow
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(
                Icons.arrow_forward_ios,
                color: Theme.of(context).iconTheme.color,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Triangle painter for badge pointer
class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
