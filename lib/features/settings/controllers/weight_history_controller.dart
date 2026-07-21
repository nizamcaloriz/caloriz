import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/services/auth_service.dart';

class WeightHistoryController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  final RxBool isLoading = true.obs;
  final RxList<Map<String, dynamic>> weightHistory = <Map<String, dynamic>>[].obs;
  
  final RxDouble startingWeight = 0.0.obs;
  final RxDouble currentWeight = 0.0.obs;
  final RxDouble weightChange = 0.0.obs;
  final RxString weightUnit = 'kg'.obs;
  final RxString userGoal = 'lose'.obs;
  
  @override
  void onInit() {
    super.onInit();
    _loadWeightHistory();
  }
  
  Future<void> _loadWeightHistory() async {
    try {
      isLoading.value = true;
      final userId = _authService.currentUserId.value;
      
      if (userId != null) {
        // Load user profile
        final userDoc = await _firestore.collection('users').doc(userId).get();
        
        if (userDoc.exists) {
          final data = userDoc.data()!;
          currentWeight.value = (data['weight'] ?? 60).toDouble();
          weightUnit.value = data['weightUnit'] ?? 'kg';
          userGoal.value = data['goal'] ?? 'lose';
          
          // Load weight history from subcollection
          final historySnapshot = await _firestore
              .collection('users')
              .doc(userId)
              .collection('weightHistory')
              .orderBy('date', descending: true)
              .get();
          
          weightHistory.value = historySnapshot.docs.map((doc) {
            final data = doc.data();
            return {
              'id': doc.id,
              'weight': (data['weight'] ?? 0).toDouble(),
              'date': (data['date'] as Timestamp).toDate(),
              'note': data['note'] ?? '',
            };
          }).toList();
          
          // Set starting weight (oldest entry or current if no history)
          if (weightHistory.isNotEmpty) {
            startingWeight.value = weightHistory.last['weight'];
          } else {
            startingWeight.value = currentWeight.value;
          }
          
          // Calculate change
          weightChange.value = startingWeight.value - currentWeight.value;
        }
      }
    } catch (e) {
      print('Error loading weight history: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> addWeightEntry(double weight, String note) async {
    try {
      final userId = _authService.currentUserId.value;
      
      if (userId != null) {
        // Add to weight history
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('weightHistory')
            .add({
          'weight': weight,
          'date': Timestamp.now(),
          'note': note,
        });
        
        // Update current weight in profile
        await _firestore.collection('users').doc(userId).update({
          'weight': weight,
        });
        
        Get.snackbar(
          'Success',
          'Weight entry added successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        
        // Reload data
        await _loadWeightHistory();
      }
    } catch (e) {
      print('Error adding weight entry: $e');
      Get.snackbar('Error', 'Failed to add weight entry');
    }
  }
  
  String getChangeText() {
    if (userGoal.value == 'lose') {
      return weightChange.value >= 0 ? 'Lost' : 'Gained';
    } else if (userGoal.value == 'gain') {
      return weightChange.value <= 0 ? 'Gained' : 'Lost';
    } else {
      return 'Changed';
    }
  }
  
  Color getChangeColor() {
    if (userGoal.value == 'lose' && weightChange.value > 0) {
      return Colors.green;
    } else if (userGoal.value == 'gain' && weightChange.value < 0) {
      return Colors.green;
    } else if (weightChange.value == 0) {
      return Colors.blue;
    } else {
      return Colors.orange;
    }
  }
}
