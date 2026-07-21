import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/macronutrients_controller.dart';

class AdjustMacronutrientsView extends GetView<MacronutrientsController> {
  const AdjustMacronutrientsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _buildHeader(context),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        _buildDailyCaloriesCard(context),
                        const SizedBox(height: 24),
                        _buildMacroSliders(context),
                        const SizedBox(height: 24),
                        _buildMacroSummary(context),
                        const SizedBox(height: 40),
                        _buildSaveButton(context),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => Get.back(),
          child: Icon(
            Icons.arrow_back,
            size: 24,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        const SizedBox(width: 16),
        Text(
          'adjust_macronutrients_title'.tr,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyCaloriesCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF00E3CC),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'daily_calories'.tr,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 4),
              Obx(
                () => Text(
                  '${controller.dailyCalories} kcal',
                  style: GoogleFonts.lato(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          Icon(
            Icons.local_fire_department,
            size: 48,
            color: Colors.black.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroSliders(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'macro_distribution'.tr,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 20),
        Obx(
          () => _buildSlider(
            context,
            label: 'carbohydrates'.tr,
            value: controller.carbsPercent.value,
            color: const Color(0xFF4CAF50),
            grams: controller.getCarbsGrams(),
            onChanged: (value) => controller.updateCarbs(value),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildSlider(
            context,
            label: 'protein'.tr,
            value: controller.proteinPercent.value,
            color: const Color(0xFF2196F3),
            grams: controller.getProteinGrams(),
            onChanged: (value) => controller.updateProtein(value),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildSlider(
            context,
            label: 'fat'.tr,
            value: controller.fatPercent.value,
            color: const Color(0xFFFF9800),
            grams: controller.getFatGrams(),
            onChanged: (value) => controller.updateFat(value),
          ),
        ),
      ],
    );
  }

  Widget _buildSlider(
    BuildContext context, {
    required String label,
    required double value,
    required Color color,
    required int grams,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            Text(
              '${value.round()}% ($grams g)',
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: color,
            inactiveTrackColor: color.withOpacity(0.2),
            thumbColor: color,
            overlayColor: color.withOpacity(0.1),
            trackHeight: 8,
          ),
          child: Slider(
            value: value.clamp(0.0, 100.0),
            min: 0,
            max: 100,
            divisions: 100,
            label: '${value.round()}%',
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildMacroSummary(BuildContext context) {
    return Obx(
      () => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color ?? Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'daily_intake_summary'.tr,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryRow(
              context,
              'Carbohydrates',
              '${controller.getCarbsGrams()}g',
              const Color(0xFF4CAF50),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              'Protein',
              '${controller.getProteinGrams()}g',
              const Color(0xFF2196F3),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              'Fat',
              '${controller.getFatGrams()}g',
              const Color(0xFFFF9800),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value,
    Color color,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isSaving.value
              ? null
              : () => controller.saveMacroSettings(),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00E3CC),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: controller.isSaving.value
              ? const CircularProgressIndicator(color: Colors.black)
              : Text(
                  'save_changes'.tr,
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
        ),
      ),
    );
  }
}
