import 'package:get/get.dart';

class NutritionService extends GetxService {
  final RxInt dailyCalorieGoal = 2000.obs;
  final RxInt consumedCalories = 0.obs;
  final RxDouble consumedProtein = 0.0.obs;
  final RxDouble consumedCarbs = 0.0.obs;
  final RxDouble consumedFats = 0.0.obs;
  
  // Water intake
  final RxInt waterGlasses = 0.obs;
  final RxInt waterGoal = 8.obs;
  
  // User profile
  final RxDouble weight = 70.0.obs;
  final RxDouble height = 170.0.obs;
  final RxInt age = 25.obs;
  final RxString gender = 'Male'.obs;
  final RxString activityLevel = 'Moderate'.obs;
  final RxString goal = 'Maintain Weight'.obs;
  
  Future<NutritionService> init() async {
    // Load saved data
    calculateDailyGoal();
    return this;
  }
  
  int get remainingCalories => (dailyCalorieGoal.value - consumedCalories.value).clamp(0, dailyCalorieGoal.value);
  
  double get calorieProgress => consumedCalories.value / dailyCalorieGoal.value;
  
  double get waterProgress => waterGlasses.value / waterGoal.value;
  
  double get bmi => weight.value / ((height.value / 100) * (height.value / 100));
  
  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
  
  void calculateDailyGoal() {
    // BMR calculation using Mifflin-St Jeor Equation
    double bmr;
    if (gender.value == 'Male') {
      bmr = 10 * weight.value + 6.25 * height.value - 5 * age.value + 5;
    } else {
      bmr = 10 * weight.value + 6.25 * height.value - 5 * age.value - 161;
    }
    
    // Apply activity multiplier
    double multiplier = _getActivityMultiplier(activityLevel.value);
    double tdee = bmr * multiplier;
    
    // Adjust based on goal
    switch (goal.value) {
      case 'Weight Loss':
        dailyCalorieGoal.value = (tdee - 500).round();
        break;
      case 'Weight Gain':
        dailyCalorieGoal.value = (tdee + 500).round();
        break;
      default:
        dailyCalorieGoal.value = tdee.round();
    }
  }
  
  double _getActivityMultiplier(String level) {
    switch (level) {
      case 'Sedentary':
        return 1.2;
      case 'Light':
        return 1.375;
      case 'Moderate':
        return 1.55;
      case 'Active':
        return 1.725;
      case 'Very Active':
        return 1.9;
      default:
        return 1.55;
    }
  }
  
  void addMeal(Map<String, dynamic> meal) {
    consumedCalories.value += (meal['calories'] as num).toInt();
    consumedProtein.value += (meal['protein'] as num).toDouble();
    consumedCarbs.value += (meal['carbs'] as num).toDouble();
    consumedFats.value += (meal['fats'] as num).toDouble();
  }
  
  void addWaterGlass() {
    if (waterGlasses.value < waterGoal.value) {
      waterGlasses.value++;
    }
  }
  
  void resetDaily() {
    consumedCalories.value = 0;
    consumedProtein.value = 0;
    consumedCarbs.value = 0;
    consumedFats.value = 0;
    waterGlasses.value = 0;
  }
  
  void updateProfile({
    double? newWeight,
    double? newHeight,
    int? newAge,
    String? newGender,
    String? newActivityLevel,
    String? newGoal,
  }) {
    if (newWeight != null) weight.value = newWeight;
    if (newHeight != null) height.value = newHeight;
    if (newAge != null) age.value = newAge;
    if (newGender != null) gender.value = newGender;
    if (newActivityLevel != null) activityLevel.value = newActivityLevel;
    if (newGoal != null) goal.value = newGoal;
    
    calculateDailyGoal();
  }
}
