import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/sign_up_controller.dart';

class PersonalizeView extends StatefulWidget {
  const PersonalizeView({super.key});

  @override
  State<PersonalizeView> createState() => _PersonalizeViewState();
}

class _PersonalizeViewState extends State<PersonalizeView> {
  final controller = Get.find<SignUpController>();

  @override
  void initState() {
    super.initState();
    // Check if user needs to set up password
    controller.checkPasswordSetupNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Cyan circular decoration bottom left (only for steps 1-3 and light theme)
          Obx(() {
            if (controller.personalizationStep.value <= 3) {
              return Builder(
                builder: (context) {
                  if (Theme.of(context).brightness == Brightness.light) {
                    return Positioned(
                      bottom: -150,
                      left: -180,
                      child: Container(
                        width: 420,
                        height: 420,
                        decoration: const BoxDecoration(
                          color: Color.fromRGBO(207, 249, 244, 1),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              );
            }
            return const SizedBox.shrink();
          }),
          SafeArea(
            child: Obx(() {
              switch (controller.personalizationStep.value) {
                case 0:
                  return _buildPasswordSetupStep();
                case 1:
                  return _buildGoalStep();
                case 2:
                  return _buildGenderStep();
                case 3:
                  return _buildDateOfBirthStep();
                case 4:
                  return _buildHeightWeightStep();
                case 5:
                  return _buildTargetWeightStep();
                default:
                  return _buildGoalStep();
              }
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Builder(
            builder: (context) => Text(
              'whats_your_goal'.tr,
              style: GoogleFonts.lato(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) => Text(
              'we_calculate_daily_calories'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          const Spacer(),
          _buildGoalOption('lose_weight'.tr, 'lose'),
          const SizedBox(height: 16),
          _buildGoalOption('keep_weight'.tr, 'keep'),
          const SizedBox(height: 16),
          Obx(() => _buildGoalOption('gain_weight'.tr, 'gain')),
          const Spacer(),
          Align(
            alignment: Alignment.bottomRight,
            child: GestureDetector(
              onTap: () => controller.nextPersonalizationStep(),
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFF03E0C7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildGoalOption(String title, String value) {
    final isSelected = controller.selectedGoal.value == value;
    return GestureDetector(
      onTap: () => controller.selectedGoal.value = value,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF00E0C6) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Builder(
            builder: (context) => Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Builder(
            builder: (context) => Text(
              'What\'s your gender?',
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Builder(
            builder: (context) => Text(
              'male_bodies_need_calories'.tr,
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
              ),
            ),
          ),
          const Spacer(),
          Obx(() => _buildGenderOption('male'.tr, 'male')),
          const SizedBox(height: 20),
          Obx(() => _buildGenderOption('female'.tr, 'female')),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => controller.previousPersonalizationStep(),
                child: Text(
                  'Back',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.nextPersonalizationStep(),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF03E0C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildGenderOption(String title, String value) {
    final isSelected = controller.selectedGender.value == value;
    return GestureDetector(
      onTap: () => controller.selectedGender.value = value,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? const Color(0xFF00E0C6) : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Builder(
            builder: (context) => Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActivityStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 60),
          Text(
            'How active are you?',
            style: GoogleFonts.lato(
              fontSize: 28,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'A sedentary person burns fewer\ncalories than an active person',
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          _buildActivityOption('Sedentary', 'sedentary'),
          const SizedBox(height: 20),
          _buildActivityOption('Low Active', 'low_active'),
          const SizedBox(height: 20),
          Obx(() => _buildActivityOption('Active', 'active')),
          const SizedBox(height: 20),
          _buildActivityOption('Very Active', 'very_active'),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => controller.previousPersonalizationStep(),
                child: Text(
                  'Back',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => controller.nextPersonalizationStep(),
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: const BoxDecoration(
                    color: Color(0xFF03E0C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildActivityOption(String title, String value) {
    final isSelected = controller.selectedActivityLevel.value == value;
    return GestureDetector(
      onTap: () => controller.selectedActivityLevel.value = value,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(
            color: const Color(0xFF00E0C6),
            width: 2,
          ) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateOfBirthStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => controller.previousPersonalizationStep(),
          ),
          const SizedBox(height: 20),
          Center(
            child: Builder(
              builder: (context) => Text(
                'date_of_birth'.tr,
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Builder(
              builder: (context) => Text(
                'enter_dob'.tr,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            height: 200,
            child: Stack(
              children: [
                // Fixed background containers for all three pickers
                Row(
                  children: [
                    Expanded(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Container(
                          width: double.infinity,
                          height: 50,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8E8E8),
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                // Scrollable pickers
                Row(
                  children: [
                    // Month Picker
                    Expanded(
                      child: ListWheelScrollView(
                        itemExtent: 50,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          final months = ['January', 'February', 'March', 'April', 'May', 'June', 
                                         'July', 'August', 'September', 'October', 'November', 'December'];
                          controller.selectedMonth.value = months[index];
                        },
                        children: ['January', 'February', 'March', 'April', 'May', 'June',
                                  'July', 'August', 'September', 'October', 'November', 'December']
                            .map((month) => Obx(() => Center(
                                    child: Text(
                                      month,
                                      style: GoogleFonts.lato(
                                        fontSize: controller.selectedMonth.value == month ? 18 : 16,
                                        fontWeight: controller.selectedMonth.value == month 
                                            ? FontWeight.w600 
                                            : FontWeight.w400,
                                        color: controller.selectedMonth.value == month 
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  )))
                            .toList(),
                      ),
                    ),
                    // Day Picker
                    Expanded(
                      child: ListWheelScrollView(
                        itemExtent: 50,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        onSelectedItemChanged: (index) {
                          controller.selectedDay.value = index + 1;
                        },
                        children: List.generate(31, (index) => index + 1)
                            .map((day) => Obx(() => Center(
                                    child: Text(
                                      '$day',
                                      style: GoogleFonts.lato(
                                        fontSize: controller.selectedDay.value == day ? 18 : 16,
                                        fontWeight: controller.selectedDay.value == day 
                                            ? FontWeight.w600 
                                            : FontWeight.w400,
                                        color: controller.selectedDay.value == day 
                                            ? Colors.black
                                            : Colors.grey,
                                      ),
                                    ),
                                  )))
                            .toList(),
                      ),
                    ),
                    // Year Picker
                    Expanded(
                      child: ListWheelScrollView.useDelegate(
                        itemExtent: 50,
                        diameterRatio: 1.5,
                        physics: const FixedExtentScrollPhysics(),
                        controller: FixedExtentScrollController(
                          initialItem: 2025 - controller.selectedYear.value,
                        ),
                        onSelectedItemChanged: (index) {
                          controller.selectedYear.value = 2025 - index;
                        },
                        childDelegate: ListWheelChildBuilderDelegate(
                          builder: (context, index) {
                            if (index < 0 || index >= 50) return null;
                            final year = 2025 - index;
                            return Obx(() => Center(
                                  child: Text(
                                    '$year',
                                    style: GoogleFonts.lato(
                                      fontSize: controller.selectedYear.value == year ? 18 : 16,
                                      fontWeight: controller.selectedYear.value == year 
                                          ? FontWeight.w600 
                                          : FontWeight.w400,
                                      color: controller.selectedYear.value == year 
                                          ? Colors.black
                                          : Colors.grey,
                                    ),
                                  ),
                                ));
                          },
                          childCount: 50,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          _buildNextButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildHeightWeightStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => controller.previousPersonalizationStep(),
          ),
          const SizedBox(height: 20),
          Center(
            child: Builder(
              builder: (context) => Text(
                'height_weight'.tr,
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Builder(
              builder: (context) => Text(
                'current_height_weight'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Dynamic Unit Toggle (lb/kg for weight, ft/cm for height)
          Center(
            child: Obx(() {
              final isWeight = controller.heightWeightSelector.value == 'weight';
              final leftUnit = isWeight ? 'kg' : 'cm';
              final rightUnit = isWeight ? 'lb' : 'ft';
              final currentUnit = isWeight ? controller.weightUnit.value : controller.heightUnit.value;
              
              return Builder(
                builder: (context) => Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (isWeight) {
                            final oldUnit = controller.weightUnit.value;
                            controller.weightUnit.value = 'kg';
                            if (oldUnit != 'kg') {
                              controller.currentWeight.value = controller.convertWeight(
                                controller.currentWeight.value, oldUnit, 'kg'
                              );
                            }
                          } else {
                            final oldUnit = controller.heightUnit.value;
                            controller.heightUnit.value = 'cm';
                            if (oldUnit != 'cm') {
                              controller.currentHeight.value = controller.convertHeight(
                                controller.currentHeight.value, oldUnit, 'cm'
                              );
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: currentUnit == leftUnit
                                ? Color(0xFF03E0C7)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: Builder(
                            builder: (context) => Center(
                              child: Text(
                                leftUnit,
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: currentUnit == leftUnit
                                      ? Colors.black
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          if (isWeight) {
                            final oldUnit = controller.weightUnit.value;
                            controller.weightUnit.value = 'lb';
                            if (oldUnit != 'lb') {
                              controller.currentWeight.value = controller.convertWeight(
                                controller.currentWeight.value, oldUnit, 'lb'
                              );
                            }
                          } else {
                            final oldUnit = controller.heightUnit.value;
                            controller.heightUnit.value = 'ft';
                            if (oldUnit != 'ft') {
                              controller.currentHeight.value = controller.convertHeight(
                                controller.currentHeight.value, oldUnit, 'ft'
                              );
                            }
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: currentUnit == rightUnit
                                ? Color(0xFF03E0C7)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(23),
                          ),
                          child: Builder(
                            builder: (context) => Center(
                              child: Text(
                                rightUnit,
                                style: GoogleFonts.lato(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: currentUnit == rightUnit
                                      ? Colors.black
                                      : Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
            }),
          ),
          const SizedBox(height: 20),
          // Weight/Height Toggle
          Center(
            child: Builder(
              builder: (context) => Obx(() => Container(
                width: 300,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.heightWeightSelector.value = 'weight';
                          controller.hasSetWeight.value = true;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: controller.heightWeightSelector.value == 'weight' 
                                ? Color(0xFF03E0C7)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Builder(
                          builder: (context) => Center(
                            child: Text(
                              'Weight',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          controller.heightWeightSelector.value = 'height';
                          controller.hasSetHeight.value = true;
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: controller.heightWeightSelector.value == 'height' 
                                ? Color(0xFF03E0C7)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          child: Builder(
                            builder: (context) => Center(
                              child: Text(
                                'Height',
                                style: GoogleFonts.lato(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Theme.of(context).textTheme.bodyLarge?.color,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
              ),
            )),
            ),
          ),
          const SizedBox(height: 40),
          // Value Display
          Center(
            child: Obx(() {
              final isWeight = controller.heightWeightSelector.value == 'weight';
              final rawValue = isWeight 
                  ? controller.currentWeight.value 
                  : controller.currentHeight.value;
              final unit = isWeight 
                  ? controller.weightUnit.value 
                  : controller.heightUnit.value;
              
              // Format value based on unit
              String displayValue;
              if (isWeight) {
                displayValue = unit == 'kg' 
                    ? rawValue.toInt().toString() 
                    : rawValue.toInt().toString();
              } else {
                displayValue = unit == 'cm' 
                    ? rawValue.toInt().toString() 
                    : rawValue.toStringAsFixed(1);
              }
              
              return Builder(
                builder: (context) => Column(
                  children: [
                    Text(
                      displayValue,
                      style: GoogleFonts.lato(
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      unit,
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          // Scrollable Value Selector with Center Indicator
          Obx(() {
            final isWeight = controller.heightWeightSelector.value == 'weight';
            final unit = isWeight ? controller.weightUnit.value : controller.heightUnit.value;
            
            // Set ranges based on unit
            double minValue, maxValue, step;
            if (isWeight) {
              if (unit == 'kg') {
                minValue = 30;
                maxValue = 150;
                step = 1;
              } else { // lb
                minValue = 66;
                maxValue = 330;
                step = 1;
              }
            } else {
              if (unit == 'cm') {
                minValue = 100;
                maxValue = 220;
                step = 1;
              } else { // ft
                minValue = 3.3;
                maxValue = 7.2;
                step = 0.1;
              }
            }
            
            final currentValue = isWeight 
                ? controller.currentWeight.value 
                : controller.currentHeight.value;
            
            final itemCount = ((maxValue - minValue) / step).round() + 1;
            final scrollController = ScrollController(
              initialScrollOffset: ((currentValue - minValue) / step) * 8.0,
            );
            
            scrollController.addListener(() {
              final offset = scrollController.offset;
              final index = (offset / 8.0).round();
              final newValue = minValue + (index * step);
              if (newValue >= minValue && newValue <= maxValue) {
                if (isWeight) {
                  controller.currentWeight.value = newValue;
                  controller.hasSetWeight.value = true;
                } else {
                  controller.currentHeight.value = newValue;
                  controller.hasSetHeight.value = true;
                }
              }
            });
            
            return SizedBox(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center indicator bar
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF03E0C7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Scrollable scale
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: itemCount,
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      final value = minValue + (index * step);
                      final isCurrent = (value - currentValue).abs() < step / 2;
                      final isMultipleOfFive = (value % 5).abs() < 0.1;
                      
                      return GestureDetector(
                        onTap: () {
                          if (isWeight) {
                            controller.currentWeight.value = value;
                            controller.hasSetWeight.value = true;
                          } else {
                            controller.currentHeight.value = value;
                            controller.hasSetHeight.value = true;
                          }
                          scrollController.animateTo(
                            index * 8.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          width: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          child: Builder(
                            builder: (context) => Container(
                              width: 2,
                              height: isMultipleOfFive ? 40 : 30,
                              color: isCurrent 
                                  ? Color(0xFF03E0C7)
                                  : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
          const Spacer(),
          _buildNextButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTargetWeightStep() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.grey),
            onPressed: () => controller.previousPersonalizationStep(),
          ),
          const SizedBox(height: 20),
          Center(
            child: Builder(
              builder: (context) => Text(
                'target_weight'.tr,
                style: GoogleFonts.lato(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Builder(
              builder: (context) => Text(
                'whats_target_weight'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.lato(
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Unit Toggle
          Center(
            child: Builder(
              builder: (context) => Obx(() => Container(
                width: 300,
                height: 60,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                        final oldUnit = controller.targetWeightUnit.value;
                        controller.targetWeightUnit.value = 'kg';
                        if (oldUnit != 'kg') {
                          controller.targetWeight.value = controller.convertWeight(
                            controller.targetWeight.value, oldUnit, 'kg'
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.targetWeightUnit.value == 'kg' 
                              ? Color(0xFF03E0C7)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Builder(
                          builder: (context) => Center(
                            child: Text(
                              'kg',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        final oldUnit = controller.targetWeightUnit.value;
                        controller.targetWeightUnit.value = 'lb';
                        if (oldUnit != 'lb') {
                          controller.targetWeight.value = controller.convertWeight(
                            controller.targetWeight.value, oldUnit, 'lb'
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: controller.targetWeightUnit.value == 'lb' 
                              ? Color(0xFF03E0C7) 
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Builder(
                          builder: (context) => Center(
                            child: Text(
                              'lb',
                              style: GoogleFonts.lato(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )),
            ),
          ),
          const SizedBox(height: 40),
          // Value Display
          Center(
            child: Obx(() {
              final value = controller.targetWeight.value;
              final unit = controller.targetWeightUnit.value;
              final displayValue = unit == 'kg' 
                  ? value.toInt().toString() 
                  : value.toInt().toString();
              
              return Builder(
                builder: (context) => Column(
                  children: [
                    Text(
                      displayValue,
                      style: GoogleFonts.lato(
                        fontSize: 72,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      unit,
                      style: GoogleFonts.lato(
                        fontSize: 24,
                        fontWeight: FontWeight.w400,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 40),
          // Scrollable Target Weight Selector
          Obx(() {
            final unit = controller.targetWeightUnit.value;
            
            double minValue, maxValue, step;
            if (unit == 'kg') {
              minValue = 30;
              maxValue = 150;
              step = 1;
            } else { // lb
              minValue = 66;
              maxValue = 330;
              step = 1;
            }
            
            final currentValue = controller.targetWeight.value;
            final itemCount = ((maxValue - minValue) / step).round() + 1;
            final scrollController = ScrollController(
              initialScrollOffset: ((currentValue - minValue) / step) * 8.0,
            );
            
            scrollController.addListener(() {
              final offset = scrollController.offset;
              final index = (offset / 8.0).round();
              final newValue = minValue + (index * step);
              if (newValue >= minValue && newValue <= maxValue) {
                controller.targetWeight.value = newValue;
                controller.hasSetTargetWeight.value = true;
              }
            });
            
            return SizedBox(
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Center indicator bar
                  Container(
                    width: 4,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Color(0xFF03E0C7),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Scrollable scale
                  ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: itemCount,
                    controller: scrollController,
                    itemBuilder: (context, index) {
                      final value = minValue + (index * step);
                      final isCurrent = (value - currentValue).abs() < step / 2;
                      final isMultipleOfFive = (value % 5).abs() < 0.1;
                      
                      return GestureDetector(
                        onTap: () {
                          controller.targetWeight.value = value;
                          controller.hasSetTargetWeight.value = true;
                          scrollController.animateTo(
                            index * 8.0,
                            duration: const Duration(milliseconds: 200),
                            curve: Curves.easeOut,
                          );
                        },
                        child: Container(
                          width: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          alignment: Alignment.center,
                          child: Builder(
                            builder: (context) => Container(
                              width: 2,
                              height: isMultipleOfFive ? 40 : 30,
                              color: isCurrent 
                                  ? const Color(0xFF84CC16)
                                  : Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          }),
          const Spacer(),
          _buildNextButton(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildPasswordSetupStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const SizedBox(height: 40),
          
          // Back button
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => controller.previousPersonalizationStep(),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Title
          Builder(
            builder: (context) => Text(
              'Set Up Password',
              style: GoogleFonts.lato(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Subtitle
          Builder(
            builder: (context) => Text(
              'Create a password to sign in with email',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          
          const SizedBox(height: 40),
          
          // Password TextField
          Obx(() => TextField(
            onChanged: (value) => controller.setupPassword.value = value,
            obscureText: controller.obscureSetupPassword.value,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Enter password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureSetupPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: controller.toggleSetupPasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF03E0C7),
                  width: 2,
                ),
              ),
            ),
          )),
          
          const SizedBox(height: 16),
          
          // Confirm Password TextField
          Obx(() => TextField(
            onChanged: (value) => controller.setupConfirmPassword.value = value,
            obscureText: controller.obscureSetupConfirmPassword.value,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              hintText: 'Re-enter password',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  controller.obscureSetupConfirmPassword.value
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed: controller.toggleSetupConfirmPasswordVisibility,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF03E0C7),
                  width: 2,
                ),
              ),
            ),
          )),
          
          const SizedBox(height: 12),
          
          // Password requirements
          Builder(
            builder: (context) => Text(
              '• Minimum 6 characters\n• Use letters, numbers, and symbols',
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodySmall?.color,
              ),
            ),
          ),
          
          const Spacer(),
          
          // Next button
          Obx(() => SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: controller.isLoading.value 
                  ? null 
                  : () => controller.nextPersonalizationStep(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03E0C7),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFF03E0C7).withOpacity(0.5),
              ),
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Continue',
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          )),
          
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: () => controller.nextPersonalizationStep(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF03E0C7),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          'Next',
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

