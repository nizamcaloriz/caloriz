import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/goal_weight_controller.dart';

class GoalWeightView extends GetView<GoalWeightController> {
  const GoalWeightView({super.key});

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
                        _buildGoalSelector(context),
                        const SizedBox(height: 24),
                        _buildCurrentWeightCard(context),
                        const SizedBox(height: 16),
                        _buildGoalWeightCard(context),
                        const SizedBox(height: 24),
                        _buildProgressIndicator(context),
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
          'goal_and_current_weight'.tr,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'whats_your_goal_question'.tr,
          style: GoogleFonts.lato(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => Row(
            children: [
              _buildGoalOption(
                context,
                'lose',
                'lose_weight_option'.tr,
                Icons.trending_down,
              ),
              const SizedBox(width: 12),
              _buildGoalOption(
                context,
                'maintain',
                'maintain_option'.tr,
                Icons.balance,
              ),
              const SizedBox(width: 12),
              _buildGoalOption(
                context,
                'gain',
                'gain_weight_option'.tr,
                Icons.trending_up,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalOption(
    BuildContext context,
    String value,
    String label,
    IconData icon,
  ) {
    final isSelected = controller.selectedGoal.value == value;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.updateGoal(value),

        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E3CC) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF00E3CC)
                  : Theme.of(context).dividerColor,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected
                    ? Colors.black
                    : Theme.of(context).iconTheme.color,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: GoogleFonts.lato(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? Colors.black
                      : Theme.of(context).textTheme.bodyMedium?.color,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentWeightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'current_weight_label'.tr,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF00E3CC).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(
                  () => Text(
                    '${controller.currentWeight.value.toStringAsFixed(1)} ${controller.weightUnit}',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF00A89E),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final isLbs =
                controller.weightUnit.value == 'lb' ||
                controller.weightUnit.value == 'lbs';
            final min = isLbs ? 80.0 : 30.0;
            final max = isLbs ? 400.0 : 200.0;

            return SliderTheme(
              data: SliderThemeData(
                activeTrackColor: const Color(0xFF00E3CC),
                inactiveTrackColor: const Color(0xFF00E3CC).withOpacity(0.2),
                thumbColor: const Color(0xFF00E3CC),
                overlayColor: const Color(0xFF00E3CC).withOpacity(0.1),
                trackHeight: 8,
              ),
              child: Slider(
                value: controller.currentWeight.value.clamp(min, max),
                min: min,
                max: max,
                onChanged: (value) => controller.updateCurrentWeight(value),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildGoalWeightCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'goal_weight_label'.tr,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Obx(
                  () => Text(
                    '${controller.goalWeight.value.toStringAsFixed(1)} ${controller.weightUnit}',
                    style: GoogleFonts.lato(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Obx(() {
            final isLbs =
                controller.weightUnit.value == 'lb' ||
                controller.weightUnit.value == 'lbs';
            final min = isLbs ? 80.0 : 30.0;
            final max = isLbs ? 400.0 : 200.0;

            return SliderTheme(
              data: SliderThemeData(
                activeTrackColor: Colors.orange,
                inactiveTrackColor: Colors.orange.withOpacity(0.2),
                thumbColor: Colors.orange,
                overlayColor: Colors.orange.withOpacity(0.1),
                trackHeight: 8,
              ),
              child: Slider(
                value: controller.goalWeight.value.clamp(min, max),
                min: min,
                max: max,
                onChanged: (value) => controller.updateGoalWeight(value),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(BuildContext context) {
    return Obx(() {
      final isLosing = controller.selectedGoal.value == 'lose';
      final isGaining = controller.selectedGoal.value == 'gain';

      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF00E3CC).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              isLosing
                  ? Icons.trending_down
                  : isGaining
                  ? Icons.trending_up
                  : Icons.balance,
              size: 40,
              color: const Color(0xFF00A89E),
            ),
            const SizedBox(height: 12),
            Text(
              controller.progressMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            if (controller.selectedGoal.value != 'maintain') ...[
              const SizedBox(height: 4),
              Text(
                '${controller.weightDifference.toStringAsFixed(1)} ${controller.weightUnit}',
                style: GoogleFonts.lato(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00A89E),
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildSaveButton(BuildContext context) {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isSaving.value
              ? null
              : () => controller.saveGoalWeight(),
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
