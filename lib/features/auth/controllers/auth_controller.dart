import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routing/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final RxBool isGoogleLoading = false.obs;
  final RxBool isAppleLoading = false.obs;
  
  Future<void> signInWithGoogle() async {
    isGoogleLoading.value = true;
    
    try {
      final result = await _authService.signInWithGoogle();
      
      if (result['success'] == true) {
        final bool isNew = result['isNewUser'] ?? false;
        
        if (isNew) {
          // New user - navigate to personalization flow
          Get.offAllNamed(AppRoutes.personalize);
        } else {
          // Existing user - navigate to home
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to sign in with Google',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isGoogleLoading.value = false;
    }
  }
  
  Future<void> signInWithApple() async {
    isAppleLoading.value = true;
    
    try {
      final result = await _authService.signInWithApple();
      
      if (result['success'] == true) {
        final bool isNew = result['isNewUser'] ?? false;
        
        if (isNew) {
          // New user - navigate to personalization flow
          Get.offAllNamed(AppRoutes.personalize);
        } else {
          // Existing user - navigate to home
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        Get.snackbar(
          'Error',
          result['error'] ?? 'Failed to sign in with Apple',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAppleLoading.value = false;
    }
  }
}