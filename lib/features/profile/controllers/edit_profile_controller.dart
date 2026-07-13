import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../core/services/auth_service.dart';

class EditProfileController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final Rx<File?> profileImage = Rx<File?>(null);
  final RxString profileImageUrl = ''.obs;

  // Text Controllers
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  // Observable values
  final RxString gender = ''.obs;
  final RxString dob = ''.obs;
  final RxDouble height = 0.0.obs;
  final RxDouble weight = 0.0.obs;
  final RxString heightUnit = 'cm'.obs;
  final RxString weightUnit = 'kg'.obs;

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

          nameController.text = data['name'] ?? '';
          emailController.text = data['email'] ?? '';
          profileImageUrl.value = data['profileImage'] ?? '';

          gender.value = data['gender'] ?? 'male';

          // Format DOB
          if (data['dateOfBirth'] != null) {
            final dobParts = data['dateOfBirth'].toString().split(', ');
            if (dobParts.length >= 3) {
              dob.value = '${dobParts[0]}-${dobParts[1]}-${dobParts[2]}';
            }
          }

          height.value = (data['height'] ?? 170).toDouble();
          weight.value = (data['weight'] ?? 60).toDouble();
          heightUnit.value = data['heightUnit'] ?? 'cm';
          weightUnit.value = data['weightUnit'] ?? 'kg';
        }
      }
    } catch (e) {
      print('Error loading user data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        profileImage.value = File(image.path);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to pick image');
    }
  }

  void updateGender(String value) {
    gender.value = value;
  }

  void updateHeight(double value) {
    height.value = value;
  }

  void updateWeight(double value) {
    weight.value = value;
  }

  void toggleHeightUnit() {
    if (heightUnit.value == 'cm') {
      heightUnit.value = 'ft';
      // Convert cm to feet
      height.value = height.value / 30.48;
    } else {
      heightUnit.value = 'cm';
      // Convert feet to cm
      height.value = height.value * 30.48;
    }
  }

  void toggleWeightUnit() {
    if (weightUnit.value == 'kg') {
      weightUnit.value = 'lbs';
      // Convert kg to lbs
      weight.value = weight.value * 2.20462;
    } else {
      weightUnit.value = 'kg';
      // Convert lbs to kg
      weight.value = weight.value / 2.20462;
    }
  }

  String getHeightDisplay() {
    if (heightUnit.value == 'cm') {
      return '${height.value.toStringAsFixed(0)} cm';
    } else {
      final feet = height.value.floor();
      final inches = ((height.value - feet) * 12).round();
      return '$feet\'$inches"';
    }
  }

  Future<void> saveProfile() async {
    try {
      if (nameController.text.trim().isEmpty) {
        Get.snackbar('Error', 'Name cannot be empty');
        return;
      }

      isSaving.value = true;
      final userId = _authService.currentUserId.value;

      if (userId != null) {
        String imageUrl = profileImageUrl.value;

        // Upload profile image if selected
        if (profileImage.value != null) {
          try {
            print('Uploading image for user: $userId');
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('profile_images')
                .child('$userId.jpg');

            print('Starting upload...');
            final uploadTask = storageRef.putFile(profileImage.value!);

            // Wait for upload with timeout
            final snapshot = await uploadTask.timeout(
              const Duration(seconds: 30),
              onTimeout: () {
                throw Exception('Upload timeout');
              },
            );

            print('Upload complete, getting download URL...');
            imageUrl = await snapshot.ref.getDownloadURL();
            print('Download URL: $imageUrl');
          } catch (uploadError) {
            print('Image upload error: $uploadError');
            print('Error type: ${uploadError.runtimeType}');
            // Continue without updating image if upload fails
            Get.snackbar(
              'Warning',
              'Image upload failed: ${uploadError.toString()}',
              backgroundColor: Colors.orange,
              colorText: Colors.white,
              duration: const Duration(seconds: 3),
            );
          }
        }

        print('Updating Firestore...');
        await _firestore.collection('users').doc(userId).update({
          'name': nameController.text.trim(),
          'email': emailController.text.trim(),
          'gender': gender.value,
          'height': height.value,
          'weight': weight.value,
          'heightUnit': heightUnit.value,
          'weightUnit': weightUnit.value,
          if (imageUrl.isNotEmpty) 'profileImage': imageUrl,
        });

        print('Profile updated successfully');

        Get.snackbar(
          'Success',
          'Profile updated successfully',
          backgroundColor: const Color(0xFF00E3CC),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        );

        // Wait a bit for snackbar to show, then navigate
        await Future.delayed(const Duration(milliseconds: 500));
        Get.offAllNamed('/home');
      }
    } catch (e) {
      print('Error saving profile: $e');
      Get.snackbar(
        'Error',
        'Failed to update profile: ${e.toString()}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    } finally {
      isSaving.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
