import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class FoodDetailsPage extends StatelessWidget {
  final Map<String, dynamic> productData;

  const FoodDetailsPage({super.key, required this.productData});

  @override
  Widget build(BuildContext context) {
    // Extract product details safely
    final product = productData['product'] ?? {};
    final productName = product['product_name'] ?? 'Unknown Product';
    final brand = product['brands'] ?? '';
    final imageUrl = product['image_url'] ?? '';
    final nutriments = product['nutriments'] ?? {};

    // Helper to get nutrient value
    double getNutrient(String key) {
      // OpenFoodFacts usually returns numbers, but sometimes strings
      final val = nutriments[key];
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    final calories = getNutrient('energy-kcal_100g');
    final protein = getNutrient('proteins_100g');
    final carbs = getNutrient('carbohydrates_100g');
    final fat = getNutrient('fat_100g');
    final fiber = getNutrient('fiber_100g');
    final sugar = getNutrient('sugars_100g');
    final sodium = getNutrient('sodium_100g'); // usually in grams in nutriments
    final saturatedFat = getNutrient('saturated-fat_100g');

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Theme.of(context).iconTheme.color,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Product Details',
          style: GoogleFonts.lato(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            if (imageUrl.isNotEmpty)
              Center(
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.contain,
                    ),
                    color: Colors.white,
                  ),
                ),
              )
            else
              Center(
                child: Container(
                  height: 150,
                  width: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // Product Name & Brand
            Text(
              productName,
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            if (brand.isNotEmpty)
              Text(
                brand,
                style: GoogleFonts.lato(fontSize: 16, color: Colors.grey),
              ),

            const SizedBox(height: 30),

            // Nutrition Facts Container
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor.withOpacity(0.5),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nutrition Facts (per 100g)',
                    style: GoogleFonts.lato(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const Divider(height: 20),
                  _buildNutrientRow(
                    context,
                    'Calories',
                    '${calories.toStringAsFixed(0)} kcal',
                    isMain: true,
                  ),
                  _buildNutrientRow(
                    context,
                    'Protein',
                    '${protein.toStringAsFixed(1)}g',
                  ),
                  _buildNutrientRow(
                    context,
                    'Carbs',
                    '${carbs.toStringAsFixed(1)}g',
                  ),
                  _buildNutrientRow(
                    context,
                    'Fat',
                    '${fat.toStringAsFixed(1)}g',
                  ),
                  _buildNutrientRow(
                    context,
                    'Fiber',
                    '${fiber.toStringAsFixed(1)}g',
                  ),
                  _buildNutrientRow(
                    context,
                    'Sugar',
                    '${sugar.toStringAsFixed(1)}g',
                  ),
                  _buildNutrientRow(
                    context,
                    'Sodium',
                    '${sodium.toStringAsFixed(2)}g',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutrientRow(
    BuildContext context,
    String label,
    String value, {
    bool isMain = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: isMain ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: isMain ? FontWeight.bold : FontWeight.w600,
              color: isMain
                  ? const Color(0xFF00E3CC)
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ],
      ),
    );
  }
}
