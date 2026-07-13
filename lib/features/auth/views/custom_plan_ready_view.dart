import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/sign_up_controller.dart';

class CustomPlanReadyView extends GetView<SignUpController> {
  const CustomPlanReadyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF03E0C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 30),
                Builder(
                  builder: (context) => Text(
                    'congratulations'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      height: 1.3,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Builder(
                  builder: (context) => Text(
                    'should_maintain'.tr,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.lato(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Builder(
                  builder: (context) => Obx(() => Text(
                    '${controller.targetWeight.value.toStringAsFixed(1)} ${controller.targetWeightUnit.value}',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  )),
                ),
                const SizedBox(height: 30),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Curved background shape
                    Container(
                      width: double.infinity,
                      height: 480,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFB8EDE6),
                            Color(0xFFD0F4EF),
                          ],
                        ),
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.elliptical(300, 150),
                          bottom: Radius.elliptical(300, 150),
                        ),
                      ),
                    ),
                    // Content
                    Positioned(
                      top: 60,
                      left: 0,
                      right: 0,
                      child: Column(
                        children: [
                          Text(
                            'Daily Recommendation',
                            style: GoogleFonts.lato(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'You can edit this any time',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 35),
                          Obx(() {
                            final macros = _calculateMacros();
                            return Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildNutrientCard('Calories', macros['calories']!, 'assets/icons/calories.png'),
                                    _buildNutrientCard('Carbs', macros['carbs']!, 'assets/icons/carbs.png'),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildNutrientCard('Protein', macros['protein']!, 'assets/icons/protein.png'),
                                    _buildNutrientCard('Fats', macros['fats']!, 'assets/icons/fats.png'),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildInfoItem('assets/icons/track.png', 'Track your food'),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildInfoItem('assets/icons/follow.png', 'Follow your daily calorie\nrecommendation'),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildInfoItem('assets/icons/balance.png', 'Balance your cabs, protein,\nfat'),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Plan based on the following sources, among other peer-reviewed medical studies',
                          style: GoogleFonts.lato(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildBulletPoint('Basal metabolic rate'),
                        _buildBulletPoint('Calorie counting - Harvard'),
                        _buildBulletPoint('International Society of Sports Nutrition'),
                        _buildBulletPoint('National Institutes of Health'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isLoading.value ? null : () => controller.completeSignUp(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03E0C7),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: controller.isLoading.value
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              'Get Started',
                              style: GoogleFonts.lato(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  )),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNutrientCard(String label, String value, String iconPath) {
    IconData iconData;
    switch (label) {
      case 'Calories':
        iconData = Icons.local_fire_department;
        break;
      case 'Carbs':
        iconData = Icons.eco;
        break;
      case 'Protein':
        iconData = Icons.fitness_center;
        break;
      case 'Fats':
        iconData = Icons.water_drop;
        break;
      default:
        iconData = Icons.circle;
    }

    return Container(
      width: 115,
      height: 115,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 8),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  iconData,
                  size: 16,
                  color: Colors.black,
                ),
                const SizedBox(width: 5),
                Text(
                  label,
                  style: GoogleFonts.lato(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF03E0C7),
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    iconPath,
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String iconPath, String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Image.asset(
                iconPath,
                width: 24,
                height: 24,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: GoogleFonts.lato(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.lato(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Map<String, String> _calculateMacros() {
    // Get user data
    final weight = controller.currentWeight.value;
    final height = controller.currentHeight.value;
    final gender = controller.selectedGender.value;
    final goal = controller.selectedGoal.value;
    final activityLevel = controller.selectedActivityLevel.value;
    
    // Calculate age from birth year
    final currentYear = DateTime.now().year;
    final age = currentYear - controller.selectedYear.value;
    
    // Calculate BMR (Basal Metabolic Rate) using Mifflin-St Jeor Equation
    double bmr;
    if (gender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }
    
    // Activity multiplier
    double activityMultiplier;
    switch (activityLevel) {
      case 'sedentary':
        activityMultiplier = 1.2;
        break;
      case 'low_active':
        activityMultiplier = 1.375;
        break;
      case 'active':
        activityMultiplier = 1.55;
        break;
      case 'very_active':
        activityMultiplier = 1.725;
        break;
      default:
        activityMultiplier = 1.2;
    }
    
    // Calculate TDEE (Total Daily Energy Expenditure)
    double tdee = bmr * activityMultiplier;
    
    // Adjust for goal
    double calories;
    switch (goal) {
      case 'lose':
        calories = tdee - 500; // 500 calorie deficit for weight loss
        break;
      case 'gain':
        calories = tdee + 300; // 300 calorie surplus for weight gain
        break;
      case 'keep':
      default:
        calories = tdee; // Maintain current weight
    }
    
    // Ensure minimum calories
    if (calories < 1200) calories = 1200;
    
    // Calculate macros based on goal
    double proteinGrams, carbsGrams, fatsGrams;
    
    if (goal == 'lose') {
      // High protein, moderate carbs, low fat for weight loss
      proteinGrams = weight * 2.2; // 2.2g per kg
      fatsGrams = (calories * 0.25) / 9; // 25% of calories from fat
      carbsGrams = (calories - (proteinGrams * 4) - (fatsGrams * 9)) / 4;
    } else if (goal == 'gain') {
      // Balanced macros for muscle gain
      proteinGrams = weight * 2.0; // 2g per kg
      fatsGrams = (calories * 0.30) / 9; // 30% of calories from fat
      carbsGrams = (calories - (proteinGrams * 4) - (fatsGrams * 9)) / 4;
    } else {
      // Balanced maintenance macros
      proteinGrams = weight * 1.8; // 1.8g per kg
      fatsGrams = (calories * 0.30) / 9; // 30% of calories from fat
      carbsGrams = (calories - (proteinGrams * 4) - (fatsGrams * 9)) / 4;
    }
    
    return {
      'calories': calories.round().toString(),
      'carbs': '${carbsGrams.round()}g',
      'protein': '${proteinGrams.round()}g',
      'fats': '${fatsGrams.round()}g',
    };
  }
}
