import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/nutrition_service.dart';
import '../../home/controllers/home_controller.dart';

class GoalWeightController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final RxDouble currentWeight = 0.0.obs;
  final RxDouble goalWeight = 0.0.obs;
  final RxDouble targetWeight = 0.0.obs;
  final RxString selectedGoal = 'lose'.obs;
  final RxString weightUnit = 'kg'.obs;
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
          currentWeight.value = (data['weight'] ?? 60).toDouble();
          targetWeight.value = (data['targetWeight'] ?? 60).toDouble();
          goalWeight.value = targetWeight.value;
          selectedGoal.value = data['goal'] ?? 'lose';
          weightUnit.value = data['weightUnit'] ?? 'kg';
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
      Get.snackbar('Error', 'Failed to load data');
    } finally {
      isLoading.value = false;
    }
  }

  void updateGoal(String goal) {
    selectedGoal.value = goal;
  }

  void updateCurrentWeight(double weight) {
    currentWeight.value = weight;
  }

  void updateGoalWeight(double weight) {
    goalWeight.value = weight;
    targetWeight.value = weight;
  }

  double get weightDifference {
    return (goalWeight.value - currentWeight.value).abs();
  }

  String get progressMessage {
    if (selectedGoal.value == 'lose') {
      return 'You need to lose ${weightDifference.toStringAsFixed(1)} $weightUnit';
    } else if (selectedGoal.value == 'gain') {
      return 'You need to gain ${weightDifference.toStringAsFixed(1)} $weightUnit';
    } else {
      return 'Maintain your current weight';
    }
  }

  Future<void> saveGoalWeight() async {
    try {
      isSaving.value = true;
      final userId = _authService.currentUserId.value;

      if (userId != null) {
        await _firestore.collection('users').doc(userId).update({
          'weight': currentWeight.value,
          'targetWeight': targetWeight.value,
          'goal': selectedGoal.value,
        });

        // Update local services/controllers to reflect changes immediately
        if (Get.isRegistered<HomeController>()) {
          Get.find<HomeController>().loadUserData();
        }

        if (Get.isRegistered<NutritionService>()) {
          Get.find<NutritionService>().updateProfile(
            newWeight: currentWeight.value,
            newGoal: selectedGoal.value,
          );
        }

        Get.back();

        Get.snackbar(
          'Success',
          'Goal weight updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print('Error saving goal weight: $e');
      Get.snackbar('Error', 'Failed to save goal weight');
    } finally {
      isSaving.value = false;
    }
  }
}
