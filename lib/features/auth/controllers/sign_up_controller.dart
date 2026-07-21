import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../routing/app_routes.dart';

class SignUpController extends GetxController {
  final AuthService _authService = Get.find<AuthService>();

  final RxBool isLoading = false.obs;
  final RxBool obscurePassword = true.obs;
  final RxBool obscureConfirmPassword = true.obs;
  final RxString name = ''.obs;
  final RxString email = ''.obs;
  final RxString password = ''.obs;
  final RxString confirmPassword = ''.obs;
  final RxInt currentStep = 1.obs;

  // Password setup for Google Sign-In users
  final RxString setupPassword = ''.obs;
  final RxString setupConfirmPassword = ''.obs;
  final RxBool obscureSetupPassword = true.obs;
  final RxBool obscureSetupConfirmPassword = true.obs;
  final RxBool skipPasswordSetup = false.obs;
  final RxBool needsPasswordSetup = false.obs;

  // Personalization fields
  final RxInt personalizationStep = 0.obs; // Start at 0 for password setup
  final RxString selectedGoal = ''.obs; // lose, keep, gain
  final RxString selectedGender = ''.obs; // male, female
  final RxString selectedActivityLevel =
      ''.obs; // sedentary, low_active, active, very_active
  final RxString dateOfBirth = ''.obs;
  final RxString selectedMonth = 'January'.obs;
  final RxInt selectedDay = 1.obs;
  final RxInt selectedYear = 2020.obs;
  final RxString heightWeightSelector = 'weight'.obs; // weight or height
  final RxString weightUnit = 'kg'.obs; // lb or kg
  final RxString heightUnit = 'cm'.obs; // ft or cm
  final RxDouble currentWeight = 60.0.obs;
  final RxDouble currentHeight = 170.0.obs;
  final RxBool hasSetWeight = false.obs; // Track if user has set weight
  final RxBool hasSetHeight = false.obs; // Track if user has set height
  final RxString targetWeightUnit = 'kg'.obs;
  final RxDouble targetWeight = 55.0.obs;
  final RxBool hasSetTargetWeight =
      false.obs; // Track if user has set target weight

  // Activity questions fields
  final RxInt activityStep = 1.obs;
  final RxString workoutFrequency = ''.obs;
  final RxString referralSource = ''.obs;
  final RxString triedOtherApps = ''.obs;

  // Final questions fields
  final RxInt finalStep = 1.obs;
  final RxString dietType = ''.obs; // classic, pescatarian, vegan, vegetarian
  final RxString accomplishGoal = ''.obs;
  final RxString referralCode = ''.obs;
  final RxString referralCodeError = ''.obs;
  final RxDouble loadingProgress = 0.0.obs;

  // Helper methods for unit conversion
  double convertWeight(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;
    if (fromUnit == 'kg' && toUnit == 'lb') return value * 2.20462;
    if (fromUnit == 'lb' && toUnit == 'kg') return value / 2.20462;
    return value;
  }

  double convertHeight(double value, String fromUnit, String toUnit) {
    if (fromUnit == toUnit) return value;
    if (fromUnit == 'cm' && toUnit == 'ft') return value / 30.48;
    if (fromUnit == 'ft' && toUnit == 'cm') return value * 30.48;
    return value;
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  void nextStep() {
    if (currentStep.value == 1) {
      if (name.value.isEmpty || email.value.isEmpty) {
        Get.snackbar(
          'Error',
          'Please fill all fields',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
      currentStep.value = 2;
    }
  }

  Future<void> signUp() async {
    if (password.value.isEmpty || confirmPassword.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'please_fill_all_fields'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.value != confirmPassword.value) {
      Get.snackbar(
        'error'.tr,
        'passwords_do_not_match'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (password.value.length < 6) {
      Get.snackbar(
        'error'.tr,
        'password_min_length'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Check if password contains letters, numbers, and symbols
    final hasLetter = password.value.contains(RegExp(r'[a-zA-Z]'));
    final hasNumber = password.value.contains(RegExp(r'[0-9]'));
    final hasSymbol = password.value.contains(
      RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
    );

    if (!hasLetter || !hasNumber || !hasSymbol) {
      Get.snackbar(
        'error'.tr,
        'Password must contain letters, numbers, and symbols',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    isLoading.value = true;

    try {
      // Create Firebase account
      final success = await _authService.signUp(
        name.value,
        email.value,
        password.value,
      );

      if (success) {
        // Navigate to personalization flow after successful signup
        Get.toNamed(AppRoutes.personalize);
      } else {
        Get.snackbar(
          'error'.tr,
          'signup_failed'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'An error occurred during signup',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void nextPersonalizationStep() async {
    // Step 0: Password Setup (for Google Sign-In users)
    if (personalizationStep.value == 0) {
      if (!skipPasswordSetup.value) {
        // Validate password fields
        if (setupPassword.value.isEmpty || setupConfirmPassword.value.isEmpty) {
          Get.snackbar(
            'error'.tr,
            'Please enter password',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        if (setupPassword.value != setupConfirmPassword.value) {
          Get.snackbar(
            'error'.tr,
            'passwords_do_not_match'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        if (setupPassword.value.length < 6) {
          Get.snackbar(
            'error'.tr,
            'password_min_length'.tr,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Check if password contains letters, numbers, and symbols
        final hasLetter = setupPassword.value.contains(RegExp(r'[a-zA-Z]'));
        final hasNumber = setupPassword.value.contains(RegExp(r'[0-9]'));
        final hasSymbol = setupPassword.value.contains(
          RegExp(r'[!@#$%^&*(),.?":{}|<>]'),
        );

        if (!hasLetter || !hasNumber || !hasSymbol) {
          Get.snackbar(
            'error'.tr,
            'Password must contain letters, numbers, and symbols',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }

        // Link email/password to account
        isLoading.value = true;
        final email = _authService.currentUserEmail.value ?? '';
        final success = await _authService.linkEmailPassword(
          email,
          setupPassword.value,
        );
        isLoading.value = false;

        if (!success) {
          Get.snackbar(
            'error'.tr,
            'Failed to set password. Please try again.',
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }

      personalizationStep.value++;
      return;
    }

    // Validate current step before proceeding
    if (personalizationStep.value == 1 && selectedGoal.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select your goal',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (personalizationStep.value == 2 && selectedGender.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select your gender',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (personalizationStep.value == 3) {
      // Date of birth validation is implicit as it has default values
    }

    if (personalizationStep.value == 4) {
      // Check if both height and weight have been set
      if (!hasSetWeight.value || !hasSetHeight.value) {
        final missing = !hasSetWeight.value && !hasSetHeight.value
            ? 'Please set both your weight and height'
            : !hasSetWeight.value
            ? 'Please set your weight'
            : 'Please set your height';
        Get.snackbar('error'.tr, missing, snackPosition: SnackPosition.BOTTOM);
        return;
      }
    }

    if (personalizationStep.value == 5) {
      // Check if target weight has been set
      if (!hasSetTargetWeight.value) {
        Get.snackbar(
          'error'.tr,
          'Please set your target weight',
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }
    }

    if (personalizationStep.value < 5) {
      personalizationStep.value++;
    } else {
      // Navigate to activity questions page instead of completing signup
      Get.toNamed(AppRoutes.activityQuestions);
    }
  }

  void previousPersonalizationStep() {
    if (personalizationStep.value > 0) {
      personalizationStep.value--;
    } else {
      Get.back();
    }
  }

  void toggleSetupPasswordVisibility() {
    obscureSetupPassword.value = !obscureSetupPassword.value;
  }

  void toggleSetupConfirmPasswordVisibility() {
    obscureSetupConfirmPassword.value = !obscureSetupConfirmPassword.value;
  }

  Future<void> checkPasswordSetupNeeded() async {
    // Check if user has email/password provider
    final hasPassword = await _authService.hasEmailPasswordProvider();
    needsPasswordSetup.value = !hasPassword;

    // If already has password, start from step 1 (goal selection)
    if (hasPassword) {
      personalizationStep.value = 1;
    } else {
      // Start from step 0 (password setup)
      personalizationStep.value = 0;
    }
  }

  void nextActivityStep() {
    // Validate current step before proceeding
    if (activityStep.value == 1 && selectedActivityLevel.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select your activity level',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (activityStep.value == 2 && workoutFrequency.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select workout frequency',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (activityStep.value == 3 && referralSource.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please tell us where you heard about us',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (activityStep.value == 4 && triedOtherApps.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select an option',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Step 5 (results page) doesn't require selection

    if (activityStep.value < 5) {
      activityStep.value++;
    } else {
      // Navigate to final questions page after step 5
      Get.toNamed(AppRoutes.finalQuestions);
    }
  }

  void previousActivityStep() {
    if (activityStep.value > 1) {
      activityStep.value--;
    } else {
      Get.back();
    }
  }

  Future<void> nextFinalStep() async {
    // Validate current step before proceeding
    if (finalStep.value == 1 && dietType.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select a diet type',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    if (finalStep.value == 2 && accomplishGoal.value.isEmpty) {
      Get.snackbar(
        'error'.tr,
        'Please select what you want to accomplish',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Step 3 (thank you) is just info
    // Step 4 (referral code) validation - optional but must be valid if provided
    if (finalStep.value == 4 && referralCode.value.isNotEmpty) {
      if (!await _validateReferralCode(referralCode.value)) {
        return;
      }
    }

    if (finalStep.value < 6) {
      finalStep.value++;

      // Start loading animation on step 5
      if (finalStep.value == 5) {
        _simulateLoading();
      }
    } else if (finalStep.value == 6) {
      // Navigate to custom plan ready page after progress step
      Get.toNamed(AppRoutes.customPlanReady);
    } else {
      completeSignUp();
    }
  }

  void previousFinalStep() {
    if (finalStep.value > 1) {
      finalStep.value--;
    } else {
      Get.back();
    }
  }

  void _simulateLoading() async {
    loadingProgress.value = 0.0;
    for (int i = 0; i <= 100; i++) {
      await Future.delayed(const Duration(milliseconds: 30));
      loadingProgress.value = i / 100;
    }
    // Auto-advance to next step when loading completes
    await Future.delayed(const Duration(milliseconds: 500));
    finalStep.value++;
  }

  Future<void> completeSignUp() async {
    isLoading.value = true;

    try {
      // Save personalization data to Firestore
      // Combine date fields into a single dateOfBirth string
      final birthDate =
          '${selectedMonth.value} ${selectedDay.value}, ${selectedYear.value}';

      // Update the dateOfBirth field
      dateOfBirth.value = birthDate;

      await _authService.completeProfile({
        // Personalization data
        'goal': selectedGoal.value,
        'gender': selectedGender.value,
        'dateOfBirth': birthDate,
        'birthMonth': selectedMonth.value,
        'birthDay': selectedDay.value.toString(),
        'birthYear': selectedYear.value.toString(),

        // Height & Weight (matching Firestore field names)
        'height': currentHeight.value,
        'heightUnit': heightUnit.value,
        'weight': currentWeight.value,
        'weightUnit': weightUnit.value,
        'targetWeight': targetWeight.value,
        'targetWeightUnit': targetWeightUnit.value,

        // Activity data
        'activityLevel': selectedActivityLevel.value,
        'workoutFrequency': workoutFrequency.value,
        'referralSource': referralSource.value,
        'triedOtherApps': triedOtherApps.value,

        // Final questions
        'dietType': dietType.value,
        'accomplishGoal': accomplishGoal.value,
        // Store the referral code they entered (who referred them)
        if (referralCode.value.isNotEmpty) 'referredBy': referralCode.value,
        // Note: user's own referralCode is already set during signup, don't overwrite it
      });

      Get.offAllNamed(AppRoutes.home);
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save profile data',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithGoogle() async {
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
            'error'.tr,
            'Google Sign In failed: ${result['error']}',
            snackPosition: SnackPosition.BOTTOM,
          );
        }
        // User cancelled - do nothing
      }
    } catch (e) {
      Get.snackbar(
        'error'.tr,
        'An error occurred during Google Sign In',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signUpWithApple() async {
    isLoading.value = true;
    try {
      // TODO: Implement Apple Sign In
      await Future.delayed(const Duration(seconds: 1));

      // Navigate to personalization flow after successful social signup
      Get.offAllNamed(AppRoutes.personalize);
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToSignIn() {
    Get.toNamed(AppRoutes.signIn);
  }

  Future<bool> _validateReferralCode(String code) async {
    // Clear previous error
    referralCodeError.value = '';

    // Format validation: 2 letters + 4 digits
    final regex = RegExp(r'^[A-Z]{2}[0-9]{4}$');
    if (!regex.hasMatch(code)) {
      referralCodeError.value =
          'Invalid code format. 2 letters + 4 digits (e.g., JO1234)';
      Get.snackbar(
        'error'.tr,
        referralCodeError.value,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    // Check if code exists in Firebase
    try {
      final result = await _authService.validateReferralCode(code);
      if (!result) {
        referralCodeError.value = 'Referral code not found';
        Get.snackbar(
          'error'.tr,
          'This referral code does not exist',
          snackPosition: SnackPosition.BOTTOM,
        );
        return false;
      }
    } catch (e) {
      referralCodeError.value = 'Failed to validate code';
      Get.snackbar(
        'error'.tr,
        'Unable to verify referral code. Please try again',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    }

    return true;
  }
}
