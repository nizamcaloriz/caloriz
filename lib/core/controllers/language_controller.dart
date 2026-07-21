import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageController extends GetxController {
  static const String _languageKey = 'selected_language';
  
  final Rx<Locale> currentLocale = const Locale('en', 'US').obs;
  
  final Map<String, Locale> locales = {
    'English': const Locale('en', 'US'),
    'Spanish': const Locale('es', 'ES'),
    'German': const Locale('de', 'DE'),
    'French': const Locale('fr', 'FR'),
    'Portuguese': const Locale('pt', 'PT'),
    'Japanese': const Locale('ja', 'JP'),
    'Italian': const Locale('it', 'IT'),
  };
  
  @override
  void onInit() {
    super.onInit();
    _loadLanguage();
  }
  
  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    final languageCode = prefs.getString(_languageKey);
    
    if (languageCode != null) {
      final locale = locales.values.firstWhere(
        (l) => '${l.languageCode}_${l.countryCode}' == languageCode,
        orElse: () => const Locale('en', 'US'),
      );
      currentLocale.value = locale;
      Get.updateLocale(locale);
    }
  }
  
  Future<void> changeLanguage(String languageName) async {
    final locale = locales[languageName];
    if (locale != null) {
      currentLocale.value = locale;
      Get.updateLocale(locale);
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, '${locale.languageCode}_${locale.countryCode}');
    }
  }
  
  String get currentLanguageName {
    return locales.entries
        .firstWhere((entry) => entry.value == currentLocale.value)
        .key;
  }
}
