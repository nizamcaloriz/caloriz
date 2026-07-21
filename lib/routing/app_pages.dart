import 'package:get/get.dart';
import '../features/auth/bindings/auth_binding.dart';
import '../features/auth/bindings/sign_in_binding.dart';
import '../features/auth/bindings/sign_up_binding.dart';
import '../features/auth/views/auth_view.dart';
import '../features/auth/views/sign_in_view.dart';
import '../features/auth/views/sign_up_view.dart';
import '../features/auth/views/personalize_view.dart';
import '../features/auth/views/activity_questions_view.dart';
import '../features/auth/views/final_questions_view.dart';
import '../features/auth/views/custom_plan_ready_view.dart';
import '../features/onboarding/bindings/splash_binding.dart';
import '../features/onboarding/bindings/onboarding_binding.dart';
import '../features/onboarding/views/splash_view.dart';
import '../features/onboarding/views/onboarding_view.dart';
import '../features/home/bindings/home_binding.dart';
import '../features/home/views/home_view.dart';
import '../features/meals/bindings/meals_binding.dart';
import '../features/meals/views/meals_view.dart';
import '../features/progress/bindings/progress_binding.dart';
import '../features/progress/views/progress_view.dart';
import '../features/premium/bindings/premium_binding.dart';
import '../features/premium/views/premium_view.dart';
import '../features/settings/bindings/settings_binding.dart';
import '../features/settings/views/settings_view.dart';
import '../features/settings/views/adjust_macronutrients_view.dart';
import '../features/settings/views/goal_weight_view.dart';
import '../features/settings/views/weight_history_view.dart';
import '../features/settings/views/terms_conditions_view.dart';
import '../features/settings/views/privacy_policy_view.dart';
import '../features/settings/views/support_view.dart';
import '../features/settings/views/partner_program_view.dart';
import '../features/profile/bindings/profile_binding.dart';
import '../features/profile/views/profile_view.dart';
import '../features/profile/views/edit_profile_view.dart';
import '../features/notification/bindings/notification_binding.dart';
import '../features/notification/views/notification_view.dart';
import '../features/scanner/bindings/scanner_binding.dart';
import '../features/scanner/views/scanner_view.dart';
import 'app_routes.dart';

class AppPages {
  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.signIn,
      page: () => const SignInView(),
      binding: SignInBinding(),
    ),
    GetPage(
      name: AppRoutes.signUp,
      page: () => const SignUpView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.personalize,
      page: () => const PersonalizeView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.activityQuestions,
      page: () => const ActivityQuestionsView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.finalQuestions,
      page: () => const FinalQuestionsView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.customPlanReady,
      page: () => const CustomPlanReadyView(),
      binding: SignUpBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.meals,
      page: () => const MealsView(),
      binding: MealsBinding(),
    ),
    GetPage(
      name: AppRoutes.progress,
      page: () => const ProgressView(),
      binding: ProgressBinding(),
    ),
    GetPage(
      name: AppRoutes.premium,
      page: () => const PremiumView(),
      binding: PremiumBinding(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.editProfile,
      page: () => const EditProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.scanner,
      page: () => const ScannerView(),
      binding: ScannerBinding(),
    ),
    GetPage(
      name: AppRoutes.adjustMacros,
      page: () => const AdjustMacronutrientsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.goalWeight,
      page: () => const GoalWeightView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.weightHistory,
      page: () => const WeightHistoryView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.termsConditions,
      page: () => const TermsConditionsView(),
    ),
    GetPage(
      name: AppRoutes.privacyPolicy,
      page: () => const PrivacyPolicyView(),
    ),
    GetPage(
      name: AppRoutes.support,
      page: () => const SupportView(),
    ),
    GetPage(
      name: AppRoutes.partnerProgram,
      page: () => const PartnerProgramView(),
      binding: SettingsBinding(),
    ),
  ];
}
