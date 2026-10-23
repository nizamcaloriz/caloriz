import 'package:get/get.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../controllers/language_controller.dart';

class AIService extends GetxService {
  static const String _cachePrefix = 'food_scan_cache_';
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  Future<AIService> init() async {
    try {
      // Still loaded for other keys used elsewhere in the app (e.g. AdMob).
      // GEMINI_API_KEY is no longer read here — Gemini calls now go
      // through the analyzeFood Firebase Cloud Function instead.
      await dotenv.load(fileName: ".env");
      print('✅ AI Service initialized (Gemini calls via Cloud Function)');
    } catch (e) {
      print('❌ Error initializing AI Service: $e');
    }
    return this;
  }

  // Generate image hash for caching
  String _generateImageHash(List<int> imageBytes) {
    return md5.convert(imageBytes).toString();
  }

  // Get current app language name for AI prompts
  String _getCurrentLanguageName() {
    try {
      final langController = Get.find<LanguageController>();
      return langController.currentLanguageName;
    } catch (_) {
      return 'English';
    }
  }

  // STRICT PROMPT FOR DETAILED FOOD ANALYSIS
  String _getCaloriePrompt() {
    final language = _getCurrentLanguageName();
    return '''Analyze the food in the image and return ONLY a JSON response (no markdown, no code blocks, just pure JSON).

IMPORTANT: Detect ALL distinct food items visible in the image. If there are multiple items (e.g., Rice, Dal, Salad), list them separately with their estimated quantities.
Estimate the ACTUAL QUANTITY of each item visible in the image.

IMPORTANT: The "foodName" value for each item MUST be written in $language language. Do NOT use English for food names unless the app language is English.

Return ONLY valid JSON in this exact format:
{
  "items": [
    {
      "foodName": "specific food name in $language",
      "servingSize": "estimated weight in grams (e.g., 180g)",
      "calories": number,
      "protein": grams,
      "carbs": grams,
      "fats": grams,
      "fiber": grams,
      "sugar": grams,
      "sodium": milligrams,
      "saturatedFat": grams
    }
  ],
  "confidence": decimal between 0.5 and 1.0
}

IMPORTANT: servingSize MUST be in grams format like "180g". Calculate all nutrition values for this estimated weight, NOT per 100g.
Return ONLY the JSON object, nothing else.''';
  }

  // AI Food Scanner - Analyze food from image (Gemini 2.0 Flash - Latest Model)
  Future<Map<String, dynamic>> scanFood(String imagePath) async {
    try {
      print('═══════════════════════════════════════════════════');
      print('🔍 [SCAN START] Time: ${DateTime.now()}');
      print('📸 Image path: $imagePath');

      // Read image file
      final imageFile = File(imagePath);
      if (!await imageFile.exists()) {
        print('❌ [ERROR] Image file not found at: $imagePath');
        throw Exception('Image file not found');
      }

      final imageBytes = await imageFile.readAsBytes();
      print('✅ Image loaded: ${imageBytes.length} bytes');

      // Generate image hash for caching (include language so different languages cache separately)
      final imageHash = _generateImageHash(imageBytes);
      final currentLang = _getCurrentLanguageName();
      print('🔍 Image hash: $imageHash');
      print('🌐 Current language: $currentLang');

      // Check cache first
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = '${_cachePrefix}${currentLang}_$imageHash';
      final cachedResult = prefs.getString(cacheKey);

      if (cachedResult != null) {
        print('⚡ [CACHE HIT] Using cached result for this image');
        final cached = json.decode(cachedResult);
        cached['fromCache'] = true;
        print('✅ Cached calories: ${cached['calories']}');
        print('═══════════════════════════════════════════════════\n');
        return cached;
      }

      print('📡 [API CALL] No cache found, calling Cloud Function...');

      final base64Image = base64Encode(imageBytes);

      String responseText = '{}';

      try {
        print('🚀 Calling analyzeFood Cloud Function...');
        final HttpsCallable callable = _functions.httpsCallable(
          'analyzeFood',
          options: HttpsCallableOptions(
            timeout: const Duration(seconds: 60),
          ),
        );

        final result = await callable.call<Map<String, dynamic>>({
          'imageBase64': base64Image,
          'mimeType': 'image/jpeg',
          'language': currentLang,
        });

        responseText = (result.data['text'] as String?)?.trim() ?? '{}';
        final modelUsed = result.data['modelUsed'] as String? ?? 'unknown';
        print('✅ Response received from model: $modelUsed');
        print('📥 [RESPONSE] Raw: "$responseText"');
      } on FirebaseFunctionsException catch (e) {
        print('❌ [ERROR] Cloud Function error: ${e.code} - ${e.message}');
        rethrow;
      }
      // Token usage is now logged server-side (Firebase Functions logs)
      // since Gemini is called from the Cloud Function, not the client.

      // Parse JSON response
      Map<String, dynamic> foodData = {
        'calories': 0.0,
        'foodName': 'Mixed Food',
        'servingSize': 'Total',
        'confidence': 0.6,
        'protein': 0.0,
        'carbs': 0.0,
        'fats': 0.0,
        'fiber': 0.0,
        'sugar': 0.0,
        'sodium': 0.0,
        'saturatedFat': 0.0,
        'ingredients': <String>[],
        'items': [],
        'isEstimated': true,
        'fromCache': false,
      };

      try {
        // Clean response - remove markdown code blocks if present
        String cleanResponse = responseText
            .replaceAll('```json', '')
            .replaceAll('```', '')
            .trim();

        final parsed = json.decode(cleanResponse);
        print('✅ Successfully parsed JSON response');

        if (parsed is Map) {
          foodData['confidence'] = (parsed['confidence'] ?? 0.6).toDouble();

          if (parsed['items'] is List) {
            final items = List<Map<String, dynamic>>.from(parsed['items']);
            foodData['items'] = items;

            // Calculate totals
            double totalCalories = 0;
            double totalProtein = 0;
            double totalCarbs = 0;
            double totalFat = 0;
            double totalFiber = 0;
            double totalSugar = 0;
            double totalSodium = 0;
            double totalSatFat = 0;
            List<String> allIngredients = [];
            List<String> foodNames = [];

            for (var item in items) {
              totalCalories += (item['calories'] ?? 0).toDouble();
              totalProtein += (item['protein'] ?? 0).toDouble();
              totalCarbs += (item['carbs'] ?? 0).toDouble();
              totalFat += (item['fats'] ?? 0).toDouble();
              totalFiber += (item['fiber'] ?? 0).toDouble();
              totalSugar += (item['sugar'] ?? 0).toDouble();
              totalSodium += (item['sodium'] ?? 0).toDouble();
              totalSatFat += (item['saturatedFat'] ?? 0).toDouble();

              if (item['foodName'] != null) {
                foodNames.add(item['foodName']);
                allIngredients.add(item['foodName']);
              }
            }

            foodData['calories'] = totalCalories;
            foodData['protein'] = totalProtein;
            foodData['carbs'] = totalCarbs;
            foodData['fats'] = totalFat;
            foodData['fiber'] = totalFiber;
            foodData['sugar'] = totalSugar;
            foodData['sodium'] = totalSodium;
            foodData['saturatedFat'] = totalSatFat;
            foodData['ingredients'] = allIngredients;

            if (foodNames.isNotEmpty) {
              foodData['foodName'] = foodNames.join(' + ');
            }
          } else {
            // Fallback for single item response format compatibility
            foodData['foodName'] = parsed['foodName'] ?? 'Unknown Food';
            foodData['servingSize'] = parsed['servingSize'] ?? '100g';
            foodData['calories'] = (parsed['calories'] ?? 0).toDouble();
            foodData['protein'] = (parsed['protein'] ?? 0).toDouble();
            foodData['carbs'] = (parsed['carbs'] ?? 0).toDouble();
            foodData['fats'] = (parsed['fats'] ?? 0).toDouble();
            foodData['fiber'] = (parsed['fiber'] ?? 0).toDouble();
            foodData['sugar'] = (parsed['sugar'] ?? 0).toDouble();
            foodData['sodium'] = (parsed['sodium'] ?? 0).toDouble();
            foodData['saturatedFat'] = (parsed['saturatedFat'] ?? 0).toDouble();

            // Create a single item in items list for compatibility
            foodData['items'] = [
              {
                'foodName': foodData['foodName'],
                'servingSize': foodData['servingSize'],
                'calories': foodData['calories'],
                'protein': foodData['protein'],
                'carbs': foodData['carbs'],
                'fats': foodData['fats'],
                'fiber': foodData['fiber'],
                'sugar': foodData['sugar'],
                'sodium': foodData['sodium'],
                'saturatedFat': foodData['saturatedFat'],
              },
            ];
          }

          print('📊 Parsed values:');
          print('  🍽️ Food: ${foodData['foodName']}');
          print('  🔥 Calories: ${foodData['calories']}');
          print('  🎯 Confidence: ${foodData['confidence']}');
        }
      } catch (e) {
        print('❌ [ERROR] Could not parse JSON: $e');
        print('⚠️ Using fallback values');
        foodData['error'] = true;
        foodData['errorMessage'] = 'Failed to parse AI response';
      }

      foodData['isEstimated'] = true;
      foodData['fromCache'] = false;
      print('📊 Final food data prepared');

      // Cache the result
      try {
        await prefs.setString(cacheKey, json.encode(foodData));
        print('💾 Result cached with key: $cacheKey');
      } catch (e) {
        print('⚠️ Could not cache result: $e');
      }

      print('✅ [SCAN SUCCESS]');
      print('═══════════════════════════════════════════════════\n');
      return foodData;
    } catch (e) {
      print('❌ [SCAN FAILED] Error: $e');
      print('═══════════════════════════════════════════════════\n');
      return {'calories': 0.0, 'error': true, 'errorMessage': e.toString()};
    }
  }

  // Generate AI Diet Plan
  Future<Map<String, dynamic>> generateDietPlan({
    required String goal,
    required int targetCalories,
    required String activityLevel,
    List<String>? dietaryRestrictions,
  }) async {
    try {
      // TODO: Implement actual AI diet plan generation
      await Future.delayed(const Duration(seconds: 3));

      return {
        'planName': '$goal Meal Plan',
        'duration': '7 days',
        'dailyCalories': targetCalories,
        'meals': _generateSampleMeals(targetCalories),
      };
    } catch (e) {
      throw Exception('Failed to generate diet plan: $e');
    }
  }

  // Food Substitution AI
  Future<List<Map<String, dynamic>>> suggestSubstitutions(
    String foodName,
  ) async {
    try {
      // TODO: Implement actual AI substitution suggestions
      await Future.delayed(const Duration(seconds: 1));

      return [
        {
          'name': 'Brown Rice',
          'reason': 'Lower GI, more fiber',
          'caloriesDiff': -20,
        },
        {
          'name': 'Quinoa',
          'reason': 'Higher protein, gluten-free',
          'caloriesDiff': 15,
        },
        {
          'name': 'Cauliflower Rice',
          'reason': 'Much lower calories and carbs',
          'caloriesDiff': -150,
        },
      ];
    } catch (e) {
      throw Exception('Failed to suggest substitutions: $e');
    }
  }

  // Barcode Scanner - Get nutrition data
  Future<Map<String, dynamic>> scanBarcode(String barcode) async {
    try {
      // TODO: Implement actual barcode scanning using nutrition API
      await Future.delayed(const Duration(seconds: 1));

      return {
        'productName': 'Protein Bar - Chocolate',
        'brand': 'FitFood',
        'calories': 200,
        'protein': 20,
        'carbs': 25,
        'fats': 6,
        'fiber': 4,
        'servingSize': '60g',
      };
    } catch (e) {
      throw Exception('Failed to scan barcode: $e');
    }
  }

  List<Map<String, dynamic>> _generateSampleMeals(int targetCalories) {
    // Sample meal structure
    return [
      {
        'day': 'Monday',
        'breakfast': {
          'name': 'Oatmeal with Berries',
          'calories': (targetCalories * 0.25).round(),
        },
        'lunch': {
          'name': 'Grilled Chicken Salad',
          'calories': (targetCalories * 0.35).round(),
        },
        'dinner': {
          'name': 'Salmon with Vegetables',
          'calories': (targetCalories * 0.30).round(),
        },
        'snacks': {
          'name': 'Mixed Nuts',
          'calories': (targetCalories * 0.10).round(),
        },
      },
      // Add more days...
    ];
  }
}
