import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/nutrition_service.dart';
import '../../../core/services/auth_service.dart';
import '../../../routing/app_routes.dart';

class HomeController extends GetxController {
  final NutritionService _nutritionService = Get.find<NutritionService>();
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final selectedDateIndex =
      3.obs; // Today selected by default (middle position)
  final RxBool isLoading = true.obs;

  // Date-wise meal storage: Map<dateString, Map<mealType, List<meals>>>
  final RxMap<String, Map<String, List<Map<String, dynamic>>>> mealsByDate =
      <String, Map<String, List<Map<String, dynamic>>>>{}.obs;

  // User profile data
  final RxString userName = ''.obs;
  final RxString userGoal = ''.obs;
  final RxString profileImageUrl = ''.obs;
  final RxDouble currentWeight = 0.0.obs;
  final RxDouble targetWeight = 0.0.obs;
  final RxString weightUnit = 'kg'.obs;

  // Calculated nutrition data
  final RxInt dailyCalories = 0.obs;
  final RxInt carbsGrams = 0.obs;
  final RxInt proteinGrams = 0.obs;
  final RxInt fatsGrams = 0.obs;

  // Today's consumed data (can be enhanced with real meal tracking later)
  final RxInt consumedCalories = 0.obs;
  final RxInt consumedCarbs = 0.obs;
  final RxInt consumedProtein = 0.obs;
  final RxInt consumedFats = 0.obs;

  // Water tracking by date
  final RxMap<String, int> waterByDate = <String, int>{}.obs;
  final RxInt currentWaterGlasses = 0.obs;
  final waterGoalGlasses = 8; // 8 glasses = 2 liters

  // Steps tracking by date
  final RxMap<String, int> stepsByDate = <String, int>{}.obs;
  final RxInt currentSteps = 0.obs;
  final stepsGoal = 10000; // 10,000 steps per day

  // Meal tracking
  final RxList<Map<String, dynamic>> breakfastMeals =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> lunchMeals = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> snackMeals = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> dinnerMeals = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    _loadMealsFromFirestore(); // Load all meals from Firestore
  }

  Future<void> loadUserData() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUserId.value;

      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;

          // Set user info
          userName.value = data['name'] ?? 'User';
          userGoal.value = data['goal'] ?? 'lose';
          profileImageUrl.value = data['profileImage'] ?? '';
          currentWeight.value = (data['weight'] ?? 0).toDouble();
          targetWeight.value = (data['targetWeight'] ?? 0).toDouble();
          weightUnit.value = data['weightUnit'] ?? 'kg';

          // Calculate nutrition values
          _calculateNutrition(data);
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadMealsFromFirestore() async {
    try {
      final userId = _authService.currentUserId.value;
      if (userId == null) return;

      print('Loading meals from Firestore for user: $userId');

      // Load meals collection
      final mealsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('meals')
          .get();

      print('Found ${mealsSnapshot.docs.length} meal dates in Firestore');

      // Clear existing data
      mealsByDate.clear();

      // Load each date's meals
      for (var doc in mealsSnapshot.docs) {
        final dateStr = doc.id;
        final data = doc.data();

        mealsByDate[dateStr] = {
          'breakfast': List<Map<String, dynamic>>.from(data['breakfast'] ?? []),
          'lunch': List<Map<String, dynamic>>.from(data['lunch'] ?? []),
          'snacks': List<Map<String, dynamic>>.from(data['snacks'] ?? []),
          'dinner': List<Map<String, dynamic>>.from(data['dinner'] ?? []),
        };

        print('Loaded meals for $dateStr');
      }

      // Load today's meals into observable lists
      _loadMealsForSelectedDate();

      // Load water data
      await _loadWaterData();
    } catch (e) {
      print('Error loading meals from Firestore: $e');
    }
  }

  Future<void> _loadWaterData() async {
    try {
      final userId = _authService.currentUserId.value;
      if (userId == null) return;

      print('Loading water data from Firestore');

      final waterSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('water')
          .get();

      waterByDate.clear();

      for (var doc in waterSnapshot.docs) {
        final dateStr = doc.id;
        final glasses = doc.data()['glasses'] as int? ?? 0;
        waterByDate[dateStr] = glasses;
      }

      // Load today's water intake
      currentWaterGlasses.value = waterByDate[selectedDateString] ?? 0;
      print(
        'Loaded water data: ${currentWaterGlasses.value} glasses for today',
      );

      // Load steps data
      await _loadStepsData();
    } catch (e) {
      print('Error loading water data: $e');
    }
  }

  Future<void> _loadStepsData() async {
    try {
      final userId = _authService.currentUserId.value;
      if (userId == null) return;

      print('Loading steps data from Firestore');

      final stepsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('steps')
          .get();

      stepsByDate.clear();

      for (var doc in stepsSnapshot.docs) {
        final dateStr = doc.id;
        final steps = doc.data()['steps'] as int? ?? 0;
        stepsByDate[dateStr] = steps;
      }

      // Load today's steps
      currentSteps.value = stepsByDate[selectedDateString] ?? 0;
      print('Loaded steps data: ${currentSteps.value} steps for today');
    } catch (e) {
      print('Error loading steps data: $e');
    }
  }

  void _calculateNutrition(Map<String, dynamic> data) {
    final weight = (data['weight'] ?? 60).toDouble();
    final height = (data['height'] ?? 170).toDouble();
    final gender = data['gender'] ?? 'male';
    final goal = data['goal'] ?? 'lose';
    final activityLevel = data['activityLevel'] ?? 'sedentary';
    final birthYear =
        data['dateOfBirth']?.toString().split(', ').last ?? '2000';

    // Calculate age
    final currentYear = DateTime.now().year;
    final age = currentYear - int.parse(birthYear);

    // Calculate BMR (Mifflin-St Jeor Equation)
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

    // Calculate TDEE
    double tdee = bmr * activityMultiplier;

    // Adjust for goal
    double calories;
    switch (goal) {
      case 'lose':
        calories = tdee - 500;
        break;
      case 'gain':
        calories = tdee + 300;
        break;
      case 'keep':
      default:
        calories = tdee;
    }

    // Ensure minimum calories
    if (calories < 1200) calories = 1200;

    // Calculate macros
    double proteinG, carbsG, fatsG;

    // Check if custom macros are set
    if (data['carbsPercent'] != null &&
        data['proteinPercent'] != null &&
        data['fatPercent'] != null) {
      double cP = (data['carbsPercent'] as num).toDouble();
      double pP = (data['proteinPercent'] as num).toDouble();
      double fP = (data['fatPercent'] as num).toDouble();

      carbsG = (calories * (cP / 100)) / 4;
      proteinG = (calories * (pP / 100)) / 4;
      fatsG = (calories * (fP / 100)) / 9;
    } else {
      // Default logic if no custom macros
      if (goal == 'lose') {
        proteinG = weight * 2.2;
        fatsG = (calories * 0.25) / 9;
        carbsG = (calories - (proteinG * 4) - (fatsG * 9)) / 4;
      } else if (goal == 'gain') {
        proteinG = weight * 2.0;
        fatsG = (calories * 0.30) / 9;
        carbsG = (calories - (proteinG * 4) - (fatsG * 9)) / 4;
      } else {
        proteinG = weight * 1.8;
        fatsG = (calories * 0.30) / 9;
        carbsG = (calories - (proteinG * 4) - (fatsG * 9)) / 4;
      }
    }

    // Set calculated values
    dailyCalories.value = calories.round();
    carbsGrams.value = carbsG.round();
    proteinGrams.value = proteinG.round();
    fatsGrams.value = fatsG.round();
  }

  void selectDate(int index) {
    selectedDateIndex.value = index;
    _loadMealsForSelectedDate();
    // Load water for selected date
    currentWaterGlasses.value = waterByDate[selectedDateString] ?? 0;
    // Load steps for selected date
    currentSteps.value = stepsByDate[selectedDateString] ?? 0;
  }

  String get selectedDateString {
    final now = DateTime.now();
    final dayOffset = selectedDateIndex.value - 3;
    final selectedDate = now.add(Duration(days: dayOffset));
    return '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}';
  }

  void _loadMealsForSelectedDate() {
    final dateStr = selectedDateString;
    final dateMeals = mealsByDate[dateStr];

    if (dateMeals != null) {
      breakfastMeals.value = List<Map<String, dynamic>>.from(
        dateMeals['breakfast'] ?? [],
      );
      lunchMeals.value = List<Map<String, dynamic>>.from(
        dateMeals['lunch'] ?? [],
      );
      snackMeals.value = List<Map<String, dynamic>>.from(
        dateMeals['snacks'] ?? [],
      );
      dinnerMeals.value = List<Map<String, dynamic>>.from(
        dateMeals['dinner'] ?? [],
      );
    } else {
      // Clear meals if no data for this date
      breakfastMeals.clear();
      lunchMeals.clear();
      snackMeals.clear();
      dinnerMeals.clear();
    }

    _updateConsumedCalories();
  }

  int get dailyGoal => _nutritionService.dailyCalorieGoal.value;
  int get consumed => _nutritionService.consumedCalories.value;
  int get remaining => _nutritionService.remainingCalories;
  double get progress => _nutritionService.calorieProgress;

  int get waterGlasses => _nutritionService.waterGlasses.value;
  int get waterGoal => _nutritionService.waterGoal.value;

  void navigateToScanner() {
    Get.toNamed(AppRoutes.scanner);
  }

  void navigateToDietPlan() {
    Get.toNamed(AppRoutes.dietPlan);
  }

  void navigateToMealLog() {
    Get.toNamed(AppRoutes.mealLog);
  }

  void navigateToProgress() {
    Get.toNamed(AppRoutes.progress);
  }

  void navigateToWaterTracker() {
    Get.toNamed(AppRoutes.waterTracker);
  }

  Future<void> logout() async {
    try {
      await _authService.signOut();
      Get.offAllNamed(AppRoutes.auth);
    } catch (e) {
      print('Error during logout: $e');
      Get.snackbar(
        'Error',
        'Failed to logout',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> addWaterGlass() async {
    currentWaterGlasses.value++;
    final dateStr = selectedDateString;
    waterByDate[dateStr] = currentWaterGlasses.value;

    // Save to Firestore
    try {
      final userId = _authService.currentUserId.value;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('water')
            .doc(dateStr)
            .set({'glasses': currentWaterGlasses.value});

        print(
          'Saved water intake: ${currentWaterGlasses.value} glasses for $dateStr',
        );
      }
    } catch (e) {
      print('Error saving water intake: $e');
    }
  }

  String get waterProgress {
    return '${(currentWaterGlasses.value * 0.25).toStringAsFixed(1)}L / ${(waterGoalGlasses * 0.25).toStringAsFixed(1)}L';
  }

  Future<void> addSteps(int steps) async {
    currentSteps.value += steps;
    final dateStr = selectedDateString;
    stepsByDate[dateStr] = currentSteps.value;

    // Save to Firestore
    try {
      final userId = _authService.currentUserId.value;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('steps')
            .doc(dateStr)
            .set({'steps': currentSteps.value});

        print('Saved steps: ${currentSteps.value} for $dateStr');
      }
    } catch (e) {
      print('Error saving steps: $e');
    }
  }

  String get stepsDisplay {
    return currentSteps.value.toString();
  }

  void addMeal(String mealType, String name, int calories) {
    final meal = {
      'name': name,
      'calories': calories,
      'timestamp': DateTime.now(),
    };

    print('Adding meal: $mealType - $name - $calories cal');
    print('Selected date: $selectedDateString');

    // Add to current date's meals
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        breakfastMeals.add(meal);
        print('Breakfast meals count: ${breakfastMeals.length}');
        break;
      case 'lunch':
        lunchMeals.add(meal);
        print('Lunch meals count: ${lunchMeals.length}');
        break;
      case 'snacks':
        snackMeals.add(meal);
        print('Snacks meals count: ${snackMeals.length}');
        break;
      case 'dinner':
        dinnerMeals.add(meal);
        print('Dinner meals count: ${dinnerMeals.length}');
        break;
    }

    // Save to date-wise storage and Firestore
    _saveMealsForSelectedDate();
    _updateConsumedCalories();

    // Force UI refresh
    breakfastMeals.refresh();
    lunchMeals.refresh();
    snackMeals.refresh();
    dinnerMeals.refresh();
  }

  Future<void> _saveMealsForSelectedDate() async {
    final dateStr = selectedDateString;
    final mealsData = {
      'breakfast': List<Map<String, dynamic>>.from(breakfastMeals),
      'lunch': List<Map<String, dynamic>>.from(lunchMeals),
      'snacks': List<Map<String, dynamic>>.from(snackMeals),
      'dinner': List<Map<String, dynamic>>.from(dinnerMeals),
    };

    // Save to local storage
    mealsByDate[dateStr] = mealsData;

    // Save to Firestore
    try {
      final userId = _authService.currentUserId.value;
      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('meals')
            .doc(dateStr)
            .set(mealsData);

        print('Saved meals to Firestore for $dateStr');
      }
    } catch (e) {
      print('Error saving meals to Firestore: $e');
    }
  }

  void _updateConsumedCalories() {
    int total = 0;

    for (var meal in breakfastMeals) {
      total += (meal['calories'] as int);
    }
    for (var meal in lunchMeals) {
      total += (meal['calories'] as int);
    }
    for (var meal in snackMeals) {
      total += (meal['calories'] as int);
    }
    for (var meal in dinnerMeals) {
      total += (meal['calories'] as int);
    }

    consumedCalories.value = total;
  }

  int getMealCalories(String mealType) {
    List<Map<String, dynamic>> meals;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        meals = breakfastMeals;
        break;
      case 'lunch':
        meals = lunchMeals;
        break;
      case 'snacks':
        meals = snackMeals;
        break;
      case 'dinner':
        meals = dinnerMeals;
        break;
      default:
        return 0;
    }

    return meals.fold(0, (sum, meal) => sum + (meal['calories'] as int));
  }

  String getMealSummary(String mealType) {
    List<Map<String, dynamic>> meals;

    switch (mealType.toLowerCase()) {
      case 'breakfast':
        meals = breakfastMeals;
        break;
      case 'lunch':
        meals = lunchMeals;
        break;
      case 'snacks':
        meals = snackMeals;
        break;
      case 'dinner':
        meals = dinnerMeals;
        break;
      default:
        return 'Tap to add';
    }

    print('getMealSummary for $mealType: ${meals.length} meals');

    if (meals.isEmpty) {
      return 'Tap to add';
    }

    final totalCals = getMealCalories(mealType);
    final itemCount = meals.length;

    if (itemCount == 1) {
      return '${meals[0]['name']} - $totalCals cal';
    } else {
      return '$itemCount items - $totalCals cal';
    }
  }

  void editMeal(String mealType, int index, String newName, int newCalories) {
    List<Map<String, dynamic>> meals = _getMealListByType(mealType);

    if (index >= 0 && index < meals.length) {
      meals[index] = {
        'name': newName,
        'calories': newCalories,
        'timestamp': meals[index]['timestamp'] ?? DateTime.now(),
      };

      print('Updated meal: $mealType - index $index - $newName - $newCalories cal');

      _refreshMealList(mealType);
      _saveMealsForSelectedDate();
      _updateConsumedCalories();
    }
  }

  void deleteMeal(String mealType, int index) {
    List<Map<String, dynamic>> meals = _getMealListByType(mealType);

    if (index >= 0 && index < meals.length) {
      meals.removeAt(index);

      print('Deleted meal: $mealType - index $index');

      _refreshMealList(mealType);
      _saveMealsForSelectedDate();
      _updateConsumedCalories();
    }
  }

  List<Map<String, dynamic>> _getMealListByType(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return breakfastMeals;
      case 'lunch':
        return lunchMeals;
      case 'snacks':
        return snackMeals;
      case 'dinner':
        return dinnerMeals;
      default:
        return <Map<String, dynamic>>[];
    }
  }

  void _refreshMealList(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        breakfastMeals.refresh();
        break;
      case 'lunch':
        lunchMeals.refresh();
        break;
      case 'snacks':
        snackMeals.refresh();
        break;
      case 'dinner':
        dinnerMeals.refresh();
        break;
    }
  }
}
