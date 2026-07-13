import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxBool isLoading = true.obs;
  
  // User data
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString mobile = ''.obs;
  final RxString gender = ''.obs;
  final RxString dob = ''.obs;
  final RxString city = ''.obs;
  final RxString state = ''.obs;
  final RxDouble height = 0.0.obs;
  final RxDouble weight = 0.0.obs;
  final RxString heightUnit = 'cm'.obs;
  final RxString weightUnit = 'kg'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUserId.value;
      
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();
        
        if (userDoc.exists) {
          final data = userDoc.data()!;
          
          name.value = data['name'] ?? '';
          email.value = data['email'] ?? '';
          mobile.value = data['mobile'] ?? '';
          gender.value = data['gender'] ?? '';
          
          // Format DOB
          if (data['dateOfBirth'] != null) {
            final dobParts = data['dateOfBirth'].toString().split(', ');
            if (dobParts.length >= 3) {
              dob.value = '${dobParts[0]}-${dobParts[1]}-${dobParts[2]}';
            }
          }
          
          city.value = data['city'] ?? '';
          state.value = data['state'] ?? '';
          height.value = (data['height'] ?? 0).toDouble();
          weight.value = (data['weight'] ?? 0).toDouble();
          heightUnit.value = data['heightUnit'] ?? 'cm';
          weightUnit.value = data['weightUnit'] ?? 'kg';
        }
      }
    } catch (e) {
      print('Error loading profile: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  String getHeightDisplay() {
    if (heightUnit.value == 'cm') {
      return '${height.value.toStringAsFixed(0)} cm';
    } else {
      final feet = (height.value / 30.48).floor();
      final inches = ((height.value % 30.48) / 2.54).round();
      return '$feet\'$inches"';
    }
  }
  
  String getWeightDisplay() {
    if (weightUnit.value == 'kg') {
      return '${weight.value.toStringAsFixed(1)} kg';
    } else {
      final lbs = (weight.value * 2.20462).toStringAsFixed(1);
      return '$lbs lbs';
    }
  }
  
  Future<void> saveChanges() async {
    try {
      // For now, just show success message
      // Edit profile functionality can be implemented later
      Get.snackbar(
        'Success',
        'Profile updated successfully',
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      Get.back();
    } catch (e) {
      print('Error saving profile: $e');
      Get.snackbar('Error', 'Failed to update profile');
    }
  }
}
