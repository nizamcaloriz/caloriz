import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';

class MealsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final selectedDay = 3.obs; // Default to today (middle item)
  final RxBool isLoading = true.obs;

  // User data
  final RxString userName = ''.obs;
  final RxDouble weight = 0.0.obs;
  final RxDouble height = 0.0.obs;
  final RxDouble bmi = 0.0.obs;
  final RxString bmiCategory = 'Normal'.obs;

  // Tracking data for selected day
  final RxInt dailySteps = 0.obs;
  final RxInt dailyWater = 0.obs; // glasses
  final RxInt dailyCalories = 0.obs;

  // Meals for selected day
  final RxList<Map<String, dynamic>> breakfastMeals =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> lunchMeals = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> snacksMeals = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> dinnerMeals = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    _loadDataForSelectedDay();
  }

  void selectDay(int index) {
    selectedDay.value = index;
    _loadDataForSelectedDay();
  }

  DateTime getSelectedDate() {
    final now = DateTime.now();
    final dayOffset = selectedDay.value - 3; // 3 is today
    return now.add(Duration(days: dayOffset));
  }

  String getSelectedDateString() {
    final date = getSelectedDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadUserData() async {
    try {
      final userId = _authService.currentUserId.value;

      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;
          userName.value = data['name'] ?? 'User';
          weight.value = (data['weight'] ?? 60).toDouble();
          height.value = (data['height'] ?? 170).toDouble();

          // Calculate BMI
          // Calculate BMI
          final heightInMeters = height.value / 100;
          if (heightInMeters > 0) {
            bmi.value = weight.value / (heightInMeters * heightInMeters);

            // Determine BMI category
            if (bmi.value < 18.5) {
              bmiCategory.value = 'underweight';
            } else if (bmi.value < 25) {
              bmiCategory.value = 'normal';
            } else if (bmi.value < 30) {
              bmiCategory.value = 'overweight';
            } else {
              bmiCategory.value = 'obese';
            }
          } else {
            bmi.value = 0.0;
            bmiCategory.value = 'Unknown';
          }
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadDataForSelectedDay() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUserId.value;

      if (userId != null) {
        final dateStr = getSelectedDateString();

        // Load meals
        final mealsDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('meals')
            .doc(dateStr)
            .get();

        if (mealsDoc.exists) {
          final data = mealsDoc.data()!;
          breakfastMeals.value = List<Map<String, dynamic>>.from(
            data['breakfast'] ?? [],
          );
          lunchMeals.value = List<Map<String, dynamic>>.from(
            data['lunch'] ?? [],
          );
          snacksMeals.value = List<Map<String, dynamic>>.from(
            data['snacks'] ?? [],
          );
          dinnerMeals.value = List<Map<String, dynamic>>.from(
            data['dinner'] ?? [],
          );
        } else {
          breakfastMeals.clear();
          lunchMeals.clear();
          snacksMeals.clear();
          dinnerMeals.clear();
        }

        // Calculate total calories
        int totalCals = 0;
        for (var meal in [
          ...breakfastMeals,
          ...lunchMeals,
          ...snacksMeals,
          ...dinnerMeals,
        ]) {
          totalCals += (meal['calories'] as int? ?? 0);
        }
        dailyCalories.value = totalCals;

        // Load water
        final waterDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('water')
            .doc(dateStr)
            .get();

        dailyWater.value = waterDoc.exists
            ? (waterDoc.data()?['glasses'] as int? ?? 0)
            : 0;

        // Load steps
        final stepsDoc = await _firestore
            .collection('users')
            .doc(userId)
            .collection('steps')
            .doc(dateStr)
            .get();

        dailySteps.value = stepsDoc.exists
            ? (stepsDoc.data()?['steps'] as int? ?? 0)
            : 0;
      }
    } catch (e) {
      print('Error loading day data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addWaterGlass() async {
    try {
      dailyWater.value++;
      final userId = _authService.currentUserId.value;
      final dateStr = getSelectedDateString();

      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('water')
            .doc(dateStr)
            .set({'glasses': dailyWater.value});
      }
    } catch (e) {
      print('Error adding water: $e');
    }
  }

  Future<void> addSteps(int steps) async {
    try {
      dailySteps.value += steps;
      final userId = _authService.currentUserId.value;
      final dateStr = getSelectedDateString();

      if (userId != null) {
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('steps')
            .doc(dateStr)
            .set({'steps': dailySteps.value});
      }
    } catch (e) {
      print('Error adding steps: $e');
    }
  }

  Color getBmiColor() {
    if (bmi.value < 18.5) {
      return Color(0xFF2196F3); // Blue for underweight
    } else if (bmi.value < 25) {
      return Color(0xFF4CAF50); // Green for normal
    } else if (bmi.value < 30) {
      return Color(0xFFFFA726); // Orange for overweight
    } else {
      return Color(0xFFF44336); // Red for obese
    }
  }
}
