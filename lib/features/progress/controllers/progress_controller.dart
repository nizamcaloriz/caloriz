import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';

class ProgressController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;

  // User data
  final RxString userName = ''.obs;
  final RxDouble currentWeight = 0.0.obs;
  final RxDouble startingWeight = 0.0.obs;
  final RxDouble targetWeight = 0.0.obs;
  final RxString weightUnit = 'kg'.obs;
  final RxString userGoal = ''.obs;

  // Progress data
  final RxDouble weightProgress = 0.0.obs; // 0.0 to 1.0
  final RxDouble weightLost = 0.0.obs;
  final RxDouble remainingWeight = 0.0.obs;

  // Weekly data for charts
  final RxList<Map<String, dynamic>> weeklyCalories =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> weeklyWater = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> weeklySteps = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> weeklyWeight =
      <Map<String, dynamic>>[].obs;

  // Averages
  final RxInt avgDailyCalories = 0.obs;
  final RxInt avgDailyWater = 0.obs;
  final RxInt avgDailySteps = 0.obs;

  // Calculated nutrition
  final RxInt dailyCalorieGoal = 0.obs;
  final RxInt dailyWaterGoal = 8.obs; // Default 8 glasses

  // Weekly macro totals
  final RxInt weeklyProtein = 0.obs;
  final RxInt weeklyCarbs = 0.obs;
  final RxInt weeklyFat = 0.obs;
  final RxInt weeklySugar = 0.obs;
  final RxInt weeklySodium = 0.obs;
  final RxInt weeklyFiber = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUserId.value;

      if (userId != null) {
        // Load user profile
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;

          userName.value = data['name'] ?? 'default_user_name'.tr;
          currentWeight.value = (data['weight'] ?? 0).toDouble();
          targetWeight.value = (data['targetWeight'] ?? 0).toDouble();
          weightUnit.value = data['weightUnit'] ?? 'kg';
          userGoal.value = data['goal'] ?? 'lose';

          // Calculate starting weight (for demo, using current + 10)
          // In production, this should be saved separately
          startingWeight.value = currentWeight.value + 10;

          // Calculate progress
          _calculateProgress();

          // Calculate daily calorie goal (same as home)
          _calculateCalorieGoal(data);

          // Load weekly data
          await _loadWeeklyData(userId);
        }
      }
    } catch (e) {
      print('Error loading progress data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateProgress() {
    if (userGoal.value == 'lose') {
      weightLost.value = startingWeight.value - currentWeight.value;
      remainingWeight.value = currentWeight.value - targetWeight.value;
      final totalToLose = startingWeight.value - targetWeight.value;
      weightProgress.value = totalToLose > 0
          ? (weightLost.value / totalToLose).clamp(0.0, 1.0)
          : 0.0;
    } else if (userGoal.value == 'gain') {
      weightLost.value = currentWeight.value - startingWeight.value;
      remainingWeight.value = targetWeight.value - currentWeight.value;
      final totalToGain = targetWeight.value - startingWeight.value;
      weightProgress.value = totalToGain > 0
          ? (weightLost.value / totalToGain).clamp(0.0, 1.0)
          : 0.0;
    } else {
      weightProgress.value = 1.0;
    }
  }

  void _calculateCalorieGoal(Map<String, dynamic> data) {
    final weight = (data['weight'] ?? 60).toDouble();
    final height = (data['height'] ?? 170).toDouble();
    final gender = data['gender'] ?? 'male';
    final goal = data['goal'] ?? 'lose';
    final activityLevel = data['activityLevel'] ?? 'sedentary';
    final birthYear =
        data['dateOfBirth']?.toString().split(', ').last ?? '2000';

    final currentYear = DateTime.now().year;
    final age = currentYear - int.parse(birthYear);

    double bmr;
    if (gender == 'male') {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) + 5;
    } else {
      bmr = (10 * weight) + (6.25 * height) - (5 * age) - 161;
    }

    double activityMultiplier = 1.2;
    switch (activityLevel) {
      case 'low_active':
        activityMultiplier = 1.375;
        break;
      case 'active':
        activityMultiplier = 1.55;
        break;
      case 'very_active':
        activityMultiplier = 1.725;
        break;
    }

    double tdee = bmr * activityMultiplier;
    double calories = tdee;

    switch (goal) {
      case 'lose':
        calories = tdee - 500;
        break;
      case 'gain':
        calories = tdee + 300;
        break;
    }

    if (calories < 1200) calories = 1200;

    dailyCalorieGoal.value = calories.round();

    // Calculate water goal: weight (kg) × 35ml ÷ 250ml per glass
    // Formula: approximately 30-35ml per kg of body weight
    final weightInKg = weightUnit.value == 'lbs'
        ? currentWeight.value * 0.453592
        : currentWeight.value;
    final waterGoalGlasses = (weightInKg * 35 / 250).round();
    dailyWaterGoal.value = waterGoalGlasses < 8
        ? 8
        : waterGoalGlasses; // Minimum 8 glasses
  }

  Future<void> _loadWeeklyData(String userId) async {
    try {
      final now = DateTime.now();
      weeklyCalories.clear();
      weeklyWater.clear();
      weeklySteps.clear();

      int totalCalories = 0;
      int totalWater = 0;
      int totalSteps = 0;
      int totalProtein = 0;
      int totalCarbs = 0;
      int totalFat = 0;
      int totalSugar = 0;
      int totalSodium = 0;
      int totalFiber = 0;
      int daysWithData = 0;

      // Load last 7 days
      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final dateStr =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
        final dayName = [
          'mon'.tr,
          'tue'.tr,
          'wed'.tr,
          'thu'.tr,
          'fri'.tr,
          'sat'.tr,
          'sun'.tr,
        ][date.weekday - 1];

        // Load meals for calories
        final mealsDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('meals')
            .doc(dateStr)
            .get();

        int dayCalories = 0;
        int dayProtein = 0;
        int dayCarbs = 0;
        int dayFat = 0;
        int daySugar = 0;
        int daySodium = 0;
        int dayFiber = 0;

        if (mealsDoc.exists) {
          final data = mealsDoc.data()!;
          for (var mealType in ['breakfast', 'lunch', 'snacks', 'dinner']) {
            final meals = List<Map<String, dynamic>>.from(data[mealType] ?? []);
            for (var meal in meals) {
              dayCalories += (meal['calories'] as int? ?? 0);
              dayProtein += (meal['protein'] as int? ?? 0);
              dayCarbs += (meal['carbs'] as int? ?? 0);
              dayFat += (meal['fat'] as int? ?? 0);
              daySugar += (meal['sugar'] as int? ?? 0);
              daySodium += (meal['sodium'] as int? ?? 0);
              dayFiber += (meal['fiber'] as int? ?? 0);
            }
          }
        }

        // Load water
        final waterDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('water')
            .doc(dateStr)
            .get();

        final dayWater = waterDoc.exists
            ? (waterDoc.data()?['glasses'] as int? ?? 0)
            : 0;

        // Load steps
        final stepsDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('steps')
            .doc(dateStr)
            .get();

        final daySteps = stepsDoc.exists
            ? (stepsDoc.data()?['steps'] as int? ?? 0)
            : 0;

        weeklyCalories.add({'day': dayName, 'value': dayCalories});
        weeklyWater.add({'day': dayName, 'value': dayWater});
        weeklySteps.add({'day': dayName, 'value': daySteps});

        if (dayCalories > 0 || dayWater > 0 || daySteps > 0) {
          totalCalories += dayCalories;
          totalWater += dayWater;
          totalSteps += daySteps;
          totalProtein += dayProtein;
          totalCarbs += dayCarbs;
          totalFat += dayFat;
          totalSugar += daySugar;
          totalSodium += daySodium;
          totalFiber += dayFiber;
          daysWithData++;
        }
      }

      // Calculate averages
      if (daysWithData > 0) {
        avgDailyCalories.value = (totalCalories / daysWithData).round();
        avgDailyWater.value = (totalWater / daysWithData).round();
        avgDailySteps.value = (totalSteps / daysWithData).round();
      }

      // Store weekly macro totals
      weeklyProtein.value = totalProtein;
      weeklyCarbs.value = totalCarbs;
      weeklyFat.value = totalFat;
      weeklySugar.value = totalSugar;
      weeklySodium.value = totalSodium;
      weeklyFiber.value = totalFiber;

      print('Loaded weekly data: ${weeklyCalories.length} days');
    } catch (e) {
      print('Error loading weekly data: $e');
    }
  }

  String get progressPercentage =>
      '${(weightProgress.value * 100).toStringAsFixed(0)}%';

  String get goalText {
    if (userGoal.value == 'lose') {
      return 'weight_loss_progress'.tr;
    } else if (userGoal.value == 'gain') {
      return 'weight_gain_progress'.tr;
    } else {
      return 'weight_maintenance'.tr;
    }
  }
}
