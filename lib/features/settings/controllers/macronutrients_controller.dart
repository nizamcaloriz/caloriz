import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../home/controllers/home_controller.dart';

class MacronutrientsController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxDouble carbsPercent = 50.0.obs;
  final RxDouble proteinPercent = 25.0.obs;
  final RxDouble fatPercent = 25.0.obs;
  final RxInt dailyCalories = 2000.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUserId.value;

      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          final data = userDoc.data()!;

          // Load custom macros if exist, otherwise use defaults
          carbsPercent.value = (data['carbsPercent'] ?? 50).toDouble();
          proteinPercent.value = (data['proteinPercent'] ?? 25).toDouble();
          fatPercent.value = (data['fatPercent'] ?? 25).toDouble();

          // Calculate daily calories from user data
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

          dailyCalories.value = calories.round();
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      Get.snackbar('Error', 'Failed to load data');
    } finally {
      isLoading.value = false;
    }
  }

  void updateCarbs(double value) {
    carbsPercent.value = value;
    _autoAdjustMacros('carbs');
  }

  void updateProtein(double value) {
    proteinPercent.value = value;
    _autoAdjustMacros('protein');
  }

  void updateFat(double value) {
    fatPercent.value = value;
    _autoAdjustMacros('fat');
  }

  void _autoAdjustMacros(String changed) {
    double total = carbsPercent.value + proteinPercent.value + fatPercent.value;

    // Allow small floating point error
    if ((total - 100).abs() < 0.1) return;

    if (changed == 'carbs') {
      double remaining = 100 - carbsPercent.value;
      if (remaining < 0) {
        carbsPercent.value = 100;
        proteinPercent.value = 0;
        fatPercent.value = 0;
      } else {
        // Distribute remaining proportionally
        double currentRest = proteinPercent.value + fatPercent.value;
        if (currentRest <= 0) {
          proteinPercent.value = remaining / 2;
          fatPercent.value = remaining / 2;
        } else {
          proteinPercent.value =
              (proteinPercent.value / currentRest) * remaining;
          fatPercent.value = (fatPercent.value / currentRest) * remaining;
        }
      }
    } else if (changed == 'protein') {
      double remaining = 100 - proteinPercent.value;
      if (remaining < 0) {
        proteinPercent.value = 100;
        carbsPercent.value = 0;
        fatPercent.value = 0;
      } else {
        double currentRest = carbsPercent.value + fatPercent.value;
        if (currentRest <= 0) {
          carbsPercent.value = remaining / 2;
          fatPercent.value = remaining / 2;
        } else {
          carbsPercent.value = (carbsPercent.value / currentRest) * remaining;
          fatPercent.value = (fatPercent.value / currentRest) * remaining;
        }
      }
    } else {
      // fat
      double remaining = 100 - fatPercent.value;
      if (remaining < 0) {
        fatPercent.value = 100;
        carbsPercent.value = 0;
        proteinPercent.value = 0;
      } else {
        double currentRest = carbsPercent.value + proteinPercent.value;
        if (currentRest <= 0) {
          carbsPercent.value = remaining / 2;
          proteinPercent.value = remaining / 2;
        } else {
          carbsPercent.value = (carbsPercent.value / currentRest) * remaining;
          proteinPercent.value =
              (proteinPercent.value / currentRest) * remaining;
        }
      }
    }
  }

  int getCarbsGrams() {
    return ((dailyCalories.value * (carbsPercent.value / 100)) / 4).round();
  }

  int getProteinGrams() {
    return ((dailyCalories.value * (proteinPercent.value / 100)) / 4).round();
  }

  int getFatGrams() {
    return ((dailyCalories.value * (fatPercent.value / 100)) / 9).round();
  }

  Future<void> saveMacroSettings() async {
    try {
      isSaving.value = true;
      final userId = _authService.currentUserId.value;

      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'carbsPercent': carbsPercent.value,
          'proteinPercent': proteinPercent.value,
          'fatPercent': fatPercent.value,
        });

        // Refresh Home Controller user data to reflect new macro settings
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadUserData();
        }

        Get.back();

        Get.snackbar(
          'Success',
          'Macronutrient settings saved successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error saving macro settings: $e');
      Get.snackbar('Error', 'Failed to save settings');
    } finally {
      isSaving.value = false;
    }
  }
}
