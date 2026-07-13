import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import '../../../core/services/auth_service.dart';
import '../../home/controllers/home_controller.dart';
import '../../../routing/app_routes.dart';

class AIFoodDetailsPage extends StatefulWidget {
  final Map<String, dynamic> foodData;
  final String imagePath;

  const AIFoodDetailsPage({
    super.key,
    required this.foodData,
    required this.imagePath,
  });

  @override
  State<AIFoodDetailsPage> createState() => _AIFoodDetailsPageState();
}

class _FoodItemState {
  String name;
  double originalGrams;
  double currentGrams;

  // Base values (totals for the original grams)
  double originalCalories;
  double originalProtein;
  double originalCarbs;
  double originalFat;
  double originalFiber;
  double originalSugar;
  double originalSodium;
  double originalSaturatedFat;

  _FoodItemState({
    required this.name,
    required this.originalGrams,
    required this.currentGrams,
    required this.originalCalories,
    required this.originalProtein,
    required this.originalCarbs,
    required this.originalFat,
    required this.originalFiber,
    required this.originalSugar,
    required this.originalSodium,
    required this.originalSaturatedFat,
  });

  double get ratio => originalGrams > 0 ? currentGrams / originalGrams : 1.0;

  double get currentCalories => originalCalories * ratio;
  double get currentProtein => originalProtein * ratio;
  double get currentCarbs => originalCarbs * ratio;
  double get currentFat => originalFat * ratio;
  double get currentFiber => originalFiber * ratio;
  double get currentSugar => originalSugar * ratio;
  double get currentSodium => originalSodium * ratio;
  double get currentSaturatedFat => originalSaturatedFat * ratio;
}

class _AIFoodDetailsPageState extends State<AIFoodDetailsPage> {
  late Map<String, dynamic> _currentFoodData;
  List<_FoodItemState> _foodItems = [];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _currentFoodData = Map<String, dynamic>.from(widget.foodData);
    _parseFoodItems();
  }

  void _parseFoodItems() {
    _foodItems.clear();

    if (_currentFoodData.containsKey('items') &&
        _currentFoodData['items'] is List) {
      final itemsList = List<Map<String, dynamic>>.from(
        _currentFoodData['items'],
      );

      if (itemsList.isEmpty) {
        // Fallback if list is empty but we have data (should not happen with new API)
        _addSingleFallbackItem();
      } else {
        for (var item in itemsList) {
          final servingSizeStr = item['servingSize']?.toString() ?? '100g';
          final match = RegExp(r'(\d+)').firstMatch(servingSizeStr);
          final grams = match != null ? double.parse(match.group(1)!) : 100.0;

          _foodItems.add(
            _FoodItemState(
              name: item['foodName'] ?? 'Food Item',
              originalGrams: grams,
              currentGrams: grams,
              originalCalories: (item['calories'] ?? 0).toDouble(),
              originalProtein: (item['protein'] ?? 0).toDouble(),
              originalCarbs: (item['carbs'] ?? 0).toDouble(),
              originalFat: (item['fats'] ?? 0).toDouble(),
              originalFiber: (item['fiber'] ?? 0).toDouble(),
              originalSugar: (item['sugar'] ?? 0).toDouble(),
              originalSodium: (item['sodium'] ?? 0).toDouble(),
              originalSaturatedFat: (item['saturatedFat'] ?? 0).toDouble(),
            ),
          );
        }
      }
    } else {
      _addSingleFallbackItem();
    }
  }

  void _addSingleFallbackItem() {
    final servingSizeStr =
        _currentFoodData['servingSize']?.toString() ?? '100g';
    final match = RegExp(r'(\d+)').firstMatch(servingSizeStr);
    final grams = match != null ? double.parse(match.group(1)!) : 100.0;

    _foodItems.add(
      _FoodItemState(
        name: _currentFoodData['foodName'] ?? 'Unknown',
        originalGrams: grams,
        currentGrams: grams,
        originalCalories: (_currentFoodData['calories'] ?? 0).toDouble(),
        originalProtein: (_currentFoodData['protein'] ?? 0).toDouble(),
        originalCarbs: (_currentFoodData['carbs'] ?? 0).toDouble(),
        originalFat: (_currentFoodData['fats'] ?? 0).toDouble(),
        originalFiber: (_currentFoodData['fiber'] ?? 0).toDouble(),
        originalSugar: (_currentFoodData['sugar'] ?? 0).toDouble(),
        originalSodium: (_currentFoodData['sodium'] ?? 0).toDouble(),
        originalSaturatedFat: (_currentFoodData['saturatedFat'] ?? 0)
            .toDouble(),
      ),
    );
  }

  void _recalculateTotals() {
    double totalCalories = 0;
    double totalProtein = 0;
    double totalCarbs = 0;
    double totalFat = 0;
    double totalFiber = 0;
    double totalSugar = 0;
    double totalSodium = 0;
    double totalSatFat = 0;

    // Track total grams for display
    double totalGrams = 0;

    for (var item in _foodItems) {
      totalCalories += item.currentCalories;
      totalProtein += item.currentProtein;
      totalCarbs += item.currentCarbs;
      totalFat += item.currentFat;
      totalFiber += item.currentFiber;
      totalSugar += item.currentSugar;
      totalSodium += item.currentSodium;
      totalSatFat += item.currentSaturatedFat;
      totalGrams += item.currentGrams;
    }

    setState(() {
      _currentFoodData['calories'] = totalCalories;
      _currentFoodData['protein'] = totalProtein;
      _currentFoodData['carbs'] = totalCarbs;
      _currentFoodData['fats'] = totalFat;
      _currentFoodData['fiber'] = totalFiber;
      _currentFoodData['sugar'] = totalSugar;
      _currentFoodData['sodium'] = totalSodium;
      _currentFoodData['saturatedFat'] = totalSatFat;
      _currentFoodData['servingSize'] = '${totalGrams.round()}g (Total)';
    });
  }

  void _showFixResultsBottomSheet() {
    Get.bottomSheet(
      StatefulBuilder(
        builder: (context, setStateBottomSheet) {
          return SafeArea(
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.75,
              ),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Text(
                    'Adjust Items',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: _foodItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 24),
                      itemBuilder: (context, index) {
                        final item = _foodItems[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.name,
                                    style: GoogleFonts.lato(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF00E3CC,
                                    ).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${item.currentGrams.round()}g',
                                    style: GoogleFonts.lato(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: const Color(0xFF00E3CC),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: const Color(0xFF00E3CC),
                                inactiveTrackColor: const Color(
                                  0xFF00E3CC,
                                ).withOpacity(0.2),
                                thumbColor: const Color(0xFF00E3CC),
                                overlayColor: const Color(
                                  0xFF00E3CC,
                                ).withOpacity(0.1),
                                trackHeight: 4,
                              ),
                              child: Slider(
                                value: item.currentGrams,
                                min: 0,
                                max: 1000,
                                onChanged: (val) {
                                  setStateBottomSheet(() {
                                    item.currentGrams = val;
                                  });
                                  _recalculateTotals();
                                },
                              ),
                            ),
                            Text(
                              '${item.currentCalories.round()} kcal',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Get.back(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E3CC),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Done',
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Current Food Data is updated by _recalculateTotals
    final foodName = _currentFoodData['foodName'] ?? 'Unknown Food';
    final servingSize = _currentFoodData['servingSize'] ?? '100g';
    final calories = (_currentFoodData['calories'] ?? 0).toDouble();
    final protein = (_currentFoodData['protein'] ?? 0).toDouble();
    final carbs = (_currentFoodData['carbs'] ?? 0).toDouble();
    final fat = (_currentFoodData['fats'] ?? 0).toDouble();
    final fiber = (_currentFoodData['fiber'] ?? 0).toDouble();
    final sugar = (_currentFoodData['sugar'] ?? 0).toDouble();
    final sodium = (_currentFoodData['sodium'] ?? 0).toDouble();
    final saturatedFat = (_currentFoodData['saturatedFat'] ?? 0).toDouble();
    final confidence = (_currentFoodData['confidence'] ?? 0.0).toDouble();
    final ingredients = List<String>.from(
      _currentFoodData['ingredients'] ?? [],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.offAllNamed(AppRoutes.home),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'AI Food Analysis',
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Food Image
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.file(
                          File(widget.imagePath),
                          height: 200,
                          width: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Food Name
                    Center(
                      child: Text(
                        foodName,
                        style: GoogleFonts.lato(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Fix Results Button
                    Center(
                      child: TextButton.icon(
                        onPressed: _showFixResultsBottomSheet,
                        icon: const Icon(
                          Icons.edit,
                          size: 16,
                          color: Color(0xFF00E3CC),
                        ),
                        label: Text(
                          'Adjust Items & Quantity',
                          style: GoogleFonts.lato(
                            fontSize: 14,
                            color: const Color(0xFF00E3CC),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          backgroundColor: const Color(
                            0xFF00E3CC,
                          ).withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Serving Size & Confidence
                    Center(
                      child: Column(
                        children: [
                          Text(
                            'Serving Size: $servingSize',
                            style: GoogleFonts.lato(
                              fontSize: 16,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Display breakdown of items briefly
                          if (_foodItems.length > 1)
                            Padding(
                              padding: const EdgeInsets.only(top: 4, bottom: 4),
                              child: Text(
                                '(${_foodItems.map((e) => "${e.currentGrams.round()}g ${e.name}").join(", ")})',
                                textAlign: TextAlign.center,
                                style: GoogleFonts.lato(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.bodySmall?.color,
                                ),
                              ),
                            ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                confidence > 0.7
                                    ? Icons.check_circle
                                    : Icons.info_outline,
                                size: 16,
                                color: confidence > 0.7
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  color: confidence > 0.7
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Nutrition Facts Label
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Theme.of(context).dividerColor,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Nutrition Facts',
                            style: GoogleFonts.lato(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Per $servingSize',
                            style: GoogleFonts.lato(
                              fontSize: 14,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                            ),
                          ),
                          const Divider(height: 24, thickness: 2),

                          // Calories - Large Display
                          _buildMainNutrient(
                            context,
                            'Calories',
                            '${calories.toStringAsFixed(0)} kcal',
                          ),

                          // Disclaimer
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00E3CC).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF00E3CC).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              'ℹ️ Calories are AI-estimated and may vary slightly. Use as a reference guide.',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodySmall?.color,
                                height: 1.4,
                              ),
                            ),
                          ),

                          const Divider(height: 24),

                          // Macronutrients
                          _buildNutrientRow(
                            context,
                            'Total Fat',
                            '${fat.toStringAsFixed(1)}g',
                            isMain: true,
                          ),
                          _buildNutrientRow(
                            context,
                            '  Saturated Fat',
                            '${saturatedFat.toStringAsFixed(1)}g',
                            indent: true,
                          ),
                          const SizedBox(height: 12),
                          _buildNutrientRow(
                            context,
                            'Total Carbohydrates',
                            '${carbs.toStringAsFixed(1)}g',
                            isMain: true,
                          ),
                          _buildNutrientRow(
                            context,
                            '  Dietary Fiber',
                            '${fiber.toStringAsFixed(1)}g',
                            indent: true,
                          ),
                          _buildNutrientRow(
                            context,
                            '  Sugars',
                            '${sugar.toStringAsFixed(1)}g',
                            indent: true,
                          ),
                          const SizedBox(height: 12),
                          _buildNutrientRow(
                            context,
                            'Protein',
                            '${protein.toStringAsFixed(1)}g',
                            isMain: true,
                          ),
                          const SizedBox(height: 12),
                          _buildNutrientRow(
                            context,
                            'Sodium',
                            '${(sodium * 1000).toStringAsFixed(0)}mg',
                            isMain: true,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Macros Chart
                    Text(
                      'Macronutrient Distribution',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildMacroBar(context, protein, carbs, fat),
                    const SizedBox(height: 20),

                    // Ingredients
                    if (ingredients.isNotEmpty) ...[
                      Text(
                        'Possible Ingredients',
                        style: GoogleFonts.lato(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: ingredients
                            .map(
                              (ingredient) => Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF00E3CC,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: const Color(0xFF00E3CC),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  ingredient,
                                  style: GoogleFonts.lato(
                                    fontSize: 14,
                                    color: const Color(0xFF00E3CC),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                      const SizedBox(height: 30),
                    ],

                    // AI Disclaimer
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.orange.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'AI-estimated values. For packaged foods, use barcode scanner for accurate data.',
                              style: GoogleFonts.lato(
                                fontSize: 12,
                                color: Colors.orange.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: _buildMealButton(
                            context,
                            'Breakfast',
                            Icons.wb_sunny_outlined,
                            () => _saveMealToFirestore('breakfast'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMealButton(
                            context,
                            'Lunch',
                            Icons.lunch_dining_outlined,
                            () => _saveMealToFirestore('lunch'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildMealButton(
                            context,
                            'Snack',
                            Icons.cookie_outlined,
                            () => _saveMealToFirestore('snacks'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildMealButton(
                            context,
                            'Dinner',
                            Icons.dinner_dining_outlined,
                            () => _saveMealToFirestore('dinner'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMealButton(
    BuildContext context,
    String label,
    IconData icon,
    VoidCallback onPressed,
  ) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.black),
      label: Text(
        label,
        style: GoogleFonts.lato(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF00E3CC),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _saveMealToFirestore(String mealType) async {
    try {
      print('💾 Attempting to save meal to $mealType');
      final authService = Get.find<AuthService>();
      final userId = authService.currentUserId.value;
      print('👤 User ID: $userId');

      if (userId == null) {
        print('❌ User not logged in');
        Get.snackbar(
          'Error',
          'Please login to save meals',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final foodName = _currentFoodData['foodName'] ?? 'Unknown Food';
      final calories = (_currentFoodData['calories'] ?? 0).toDouble();
      final protein = (_currentFoodData['protein'] ?? 0).toDouble();
      final carbs = (_currentFoodData['carbs'] ?? 0).toDouble();
      final fat = (_currentFoodData['fats'] ?? 0).toDouble();
      final sugar = (_currentFoodData['sugar'] ?? 0).toDouble();
      final sodium = (_currentFoodData['sodium'] ?? 0).toDouble();
      final fiber = (_currentFoodData['fiber'] ?? 0).toDouble();

      final now = DateTime.now();
      final dateStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      final mealData = {
        'name': foodName,
        'calories': calories.round(),
        'protein': protein.round(),
        'carbs': carbs.round(),
        'fat': fat.round(),
        'sugar': sugar.round(),
        'sodium': sodium.round(),
        'fiber': fiber.round(),
        'timestamp': now.toIso8601String(),
        'source': 'ai_scan',
      };

      print('📋 Meal data: $mealData');

      final docRef = FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('meals')
          .doc(dateStr);

      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          mealType: FieldValue.arrayUnion([mealData]),
        });
      } else {
        await docRef.set({
          mealType: [mealData],
          'date': dateStr,
        });
      }

      print('✅ Meal saved successfully to Firestore');

      // Refresh home controller to show updated data
      try {
        final homeController = Get.find<HomeController>();
        homeController.onInit(); // Reload all data
        print('🔄 Home screen data refreshed');
      } catch (e) {
        print('⚠️ Could not refresh home controller: $e');
      }

      Get.offAllNamed(AppRoutes.home);
      Get.snackbar(
        'Success',
        '$foodName added to $mealType',
        backgroundColor: const Color(0xFF00E3CC),
        colorText: Colors.black,
      );
    } catch (e, stackTrace) {
      print('❌ Failed to save meal: $e');
      print('Stack trace: $stackTrace');
      Get.snackbar(
        'Error',
        'Failed to save meal: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildMainNutrient(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00E3CC),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientRow(
    BuildContext context,
    String label,
    String value, {
    bool isMain = false,
    bool indent = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: indent ? 6 : 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: isMain ? 16 : 14,
              fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: isMain ? 16 : 14,
              fontWeight: isMain ? FontWeight.w600 : FontWeight.w500,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroBar(
    BuildContext context,
    double protein,
    double carbs,
    double fat,
  ) {
    final total = protein + carbs + fat;
    if (total == 0) return const SizedBox();

    final proteinPercent = protein / total;
    final carbsPercent = carbs / total;
    final fatPercent = fat / total;

    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Row(
            children: [
              if (protein > 0)
                Expanded(
                  flex: (proteinPercent * 100).round(),
                  child: Container(height: 30, color: const Color(0xFF00E3CC)),
                ),
              if (carbs > 0)
                Expanded(
                  flex: (carbsPercent * 100).round(),
                  child: Container(height: 30, color: Colors.orange),
                ),
              if (fat > 0)
                Expanded(
                  flex: (fatPercent * 100).round(),
                  child: Container(height: 30, color: Colors.purple),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMacroLegend(
              'Protein',
              '${(proteinPercent * 100).toStringAsFixed(0)}%',
              const Color(0xFF00E3CC),
            ),
            _buildMacroLegend(
              'Carbs',
              '${(carbsPercent * 100).toStringAsFixed(0)}%',
              Colors.orange,
            ),
            _buildMacroLegend(
              'Fat',
              '${(fatPercent * 100).toStringAsFixed(0)}%',
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMacroLegend(String label, String value, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          '$label $value',
          style: GoogleFonts.lato(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
