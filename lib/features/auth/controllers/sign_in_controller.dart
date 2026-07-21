import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routing/app_routes.dart';

class SignInController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();
  
  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }
  
  Future<void> signIn() async {
    if (email.value.isEmpty || password.value.isEmpty) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }
    
    isLoading.value = true;
    
    try {
      final success = await _authService.signIn(email.value, password.value);
      
      if (success) {
        Get.offAllNamed(AppRoutes.home);
      } else {
        Get.snackbar(
          'Error',
          'Invalid email or password',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signInWithGoogle() async {
    isLoading.value = true;
    try {
      final result = await _authService.signInWithGoogle();
      
      if (result['success'] == true) {
        // If new user, go to personalization. Otherwise, go to home
        if (result['isNewUser'] == true) {
          Get.offAllNamed(AppRoutes.personalize);
        } else {
          Get.offAllNamed(AppRoutes.home);
        }
      } else {
        if (result['error'] != null) {
          Get.snackbar(
            'Error',
            'Google Sign In failed: ${result['error']}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        // User cancelled - do nothing
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'An error occurred during Google Sign In',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> signInWithApple() async {
    isLoading.value = true;
    try {
      // TODO: Implement Apple Sign In
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: Check if user profile is complete
      // If new user (no profile data), navigate to personalization
      // If existing user, navigate to home
      bool isNewUser = true; // Replace with actual check
      
      if (isNewUser) {
        Get.offAllNamed(AppRoutes.personalize);
      } else {
        Get.offAllNamed(AppRoutes.home);
      }
    } finally {
      isLoading.value = false;
    }
  }
  
  void navigateToSignUp() {
    Get.toNamed(AppRoutes.signUp);
  }
  
  void navigateToForgotPassword() {
    // TODO: Implement forgot password
    Get.snackbar(
      'Info',
      'Password reset functionality coming soon',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
