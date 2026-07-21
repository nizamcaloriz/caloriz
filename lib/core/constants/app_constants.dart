class AppConstants {
  // App Info
  static const String appName = 'Caloriz';
  static const String appVersion = '1.0.0';
  
  // API Keys (Add your actual API keys here)
  static const String openAIApiKey = 'YOUR_OPENAI_API_KEY';
  static const String nutritionAPIKey = 'YOUR_NUTRITION_API_KEY';
  
  // Nutrition Goals
  static const int defaultCalorieGoal = 2000;
  static const int defaultWaterGoal = 8; // glasses
  
  // Meal Types
  static const String breakfast = 'Breakfast';
  static const String lunch = 'Lunch';
  static const String dinner = 'Dinner';
  static const String snacks = 'Snacks';
  
  // Premium Features
  // ⚠️  DO NOT add hardcoded prices here.
  // All subscription pricing must come exclusively from the store
  // via SubscriptionPricingHelper (IAPService.productMap).
  // The store handles regional/localized pricing automatically.

  // Activity Levels
  static const Map<String, double> activityMultipliers = {
    'Sedentary': 1.2,
    'Light': 1.375,
    'Moderate': 1.55,
    'Active': 1.725,
    'Very Active': 1.9,
  };
  
  // Goals
  static const List<String> dietGoals = [
    'Weight Loss',
    'Weight Gain',
    'Maintain Weight',
    'Build Muscle',
    'Improve Health'
  ];
  
  // Onboarding
  static const List<Map<String, String>> onboardingData = [
    {
      'title': 'AI Diet Plan Generator',
      'description': 'Get meal plans tailored to your goals.',
      'image': 'assets/images/diet_plan.png'
    },
    {
      'title': 'Food Scanner',
      'description': 'Snap a meal and get instant calories & nutrition.',
      'image': 'assets/images/food_scanner.png'
    },
    {
      'title': 'Progress Tracker',
      'description': 'Visualize your journey to a healthier you',
      'image': 'assets/images/progress.png'
    },
  ];
}
