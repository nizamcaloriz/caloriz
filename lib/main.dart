import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';
import 'core/controllers/language_controller.dart';
import 'core/controllers/theme_controller.dart';
import 'core/localization/app_translations.dart';
import 'core/services/ai_service.dart';
import 'core/services/ad_service.dart';
import 'core/services/auth_service.dart';
import 'core/services/iap_service.dart';
import 'core/services/nutrition_service.dart';
import 'core/themes/app_theme.dart';
import 'routing/app_pages.dart';
import 'routing/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize controllers
  Get.put(ThemeController());
  Get.put(LanguageController());

  // Initialize services
  await initServices();

  runApp(const MyApp());
}

Future<void> initServices() async {
  // Initialize core services
  await Get.putAsync(() => AuthService().init());
  await Get.putAsync(() => NutritionService().init());
  await Get.putAsync(() => AIService().init());
  Get.put(AdService()); // Initialize Ad Service
  await Get.putAsync(() => IAPService().onInit()); // Initialize IAP Service
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Caloriz - AI Calorie Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: themeController.isDarkMode
            ? ThemeMode.dark
            : ThemeMode.light,
        translations: AppTranslations(),
        locale: Get.find<LanguageController>().currentLocale.value,
        fallbackLocale: const Locale('en', 'US'),
        initialRoute: AppRoutes.splash,
        getPages: AppPages.routes,
      ),
    );
  }
}
