import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/auth_service.dart';
import '../../../routing/app_routes.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  @override
  void onInit() {
    super.onInit();
    print('🚀 SplashController initialized');
    _navigateToNext();
  }

  Future<void> _navigateToNext() async {
    print('⏱️ Starting 3 second delay...');
    await Future.delayed(const Duration(seconds: 3));

    print('✅ Delay complete, checking login status...');

    // Get shared preferences
    final prefs = await SharedPreferences.getInstance();
    final hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

    // Check if user is logged in via Firebase Auth
    final isLoggedIn = _authService.isLoggedIn;

    print('👀 Has seen onboarding: $hasSeenOnboarding');
    print('🔐 Is logged in: $isLoggedIn');

    if (hasSeenOnboarding) {
      if (isLoggedIn) {
        // Double check ban status just in case (AuthService should catch it, but splash is safer)
        final isBanned = await _authService.checkBanStatus(
          _authService.currentUserId.value!,
        );
        if (isBanned) {
          await _authService.signOut();
          Get.offAllNamed(AppRoutes.auth);
          return;
        }

        print('🏠 User is logged in, navigating to home');
        Get.offAllNamed(AppRoutes.home);
      } else {
        print('🔑 User not logged in, navigating to auth');
        Get.offAllNamed(AppRoutes.auth);
      }
    } else {
      print('🎯 First time user, navigating to onboarding');
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
