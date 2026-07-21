import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../controllers/progress_controller.dart';

class ProgressView extends StatefulWidget {
  const ProgressView({super.key});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  int selectedPeriod = 0; // 0 = Week, 1 = Month, 2 = Year
  final controller = Get.find<ProgressController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildGoalProgressAnalytics(context),
                    const SizedBox(height: 30),
                    _buildBarChartSection(context),
                    const SizedBox(height: 100),
                    _buildHealthScore(context),
                    const SizedBox(height: 30),
                    _buildWaterIntakeTracker(context),
                    const SizedBox(height: 30),
                    _buildAdditionalMacros(context),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 3),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // GestureDetector(
          //   onTap: () => Get.back(),
          //   child: Icon(
          //     Icons.arrow_back,
          //     size: 22,
          //     color: Theme.of(context).iconTheme.color,
          //   ),
          // ),
          // const SizedBox(width: 12),
          Text(
            'progress'.tr,
            style: GoogleFonts.lato(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalProgressAnalytics(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'goal_progress_analytics'.tr,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        // Period Selector Tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.grey[800]
                : Colors.grey[200],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              _buildPeriodTab('week'.tr, 0),
              _buildPeriodTab('month'.tr, 1),
              _buildPeriodTab('year'.tr, 2),
            ],
          ),
        ),
        const SizedBox(height: 20),
        // Analytics Content based on selected period
        _buildAnalyticsContent(context),
      ],
    );
  }

  Widget _buildPeriodTab(String label, int index) {
    final isSelected = selectedPeriod == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedPeriod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF00E3CC) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? Colors.black
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        children: [
          // Summary Stats Row
          Obx(
            () => Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    context,
                    'calories',
                    '${controller.avgDailyCalories}',
                    'kcal_unit',
                    Colors.orange,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'weight_label',
                    controller.weightLost.value.toStringAsFixed(1),
                    controller.weightUnit.value,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    context,
                    'water_label',
                    (controller.avgDailyWater.value * 0.25).toStringAsFixed(1),
                    'liters_unit',
                    const Color(0xFF00E3CC),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Progress Chart
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: 500,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      getTitlesWidget: (value, meta) => Text(
                        value.toInt().toString(),
                        style: GoogleFonts.lato(
                          fontSize: 10,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) => Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          _getBottomLabel(value.toInt()),
                          style: GoogleFonts.lato(
                            fontSize: 10,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        ),
                      ),
                    ),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: _getChartSpots(),
                    isCurved: true,
                    color: const Color(0xFF00E3CC),
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: const Color(0xFF00E3CC),
                            strokeWidth: 2,
                            strokeColor: Colors.white,
                          ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: const Color(0xFF00E3CC).withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Goal Progress Bar
          _buildGoalProgressBar(context),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context,
    String label,
    String value,
    String unit,
    Color color,
  ) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Icon(
              label == 'calories'
                  ? Icons.local_fire_department
                  : label == 'weight_label'
                  ? Icons.monitor_weight_outlined
                  : Icons.water_drop,
              color: color,
              size: 24,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.lato(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        Text(
          '${label.tr} (${unit.tr})',
          style: GoogleFonts.lato(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
      ],
    );
  }

  String _getBottomLabel(int index) {
    switch (selectedPeriod) {
      case 0: // Week
        final days = [
          'mon'.tr,
          'tue'.tr,
          'wed'.tr,
          'thu'.tr,
          'fri'.tr,
          'sat'.tr,
          'sun'.tr,
        ];
        return index < days.length ? days[index] : '';
      case 1: // Month
        final weeks = ['w1'.tr, 'w2'.tr, 'w3'.tr, 'w4'.tr];
        return index < weeks.length ? weeks[index] : '';
      case 2: // Year
        final months = [
          'jan'.tr,
          'mar'.tr,
          'may'.tr,
          'jul'.tr,
          'sep'.tr,
          'nov'.tr,
        ];
        return index < months.length ? months[index] : '';
      default:
        return '';
    }
  }

  List<FlSpot> _getChartSpots() {
    if (selectedPeriod == 0) {
      // Week - use real data
      return controller.weeklyCalories.asMap().entries.map((entry) {
        return FlSpot(entry.key.toDouble(), entry.value['value'].toDouble());
      }).toList();
    } else if (selectedPeriod == 1) {
      // Month - placeholder
      return [
        const FlSpot(0, 14000),
        const FlSpot(1, 13500),
        const FlSpot(2, 14200),
        const FlSpot(3, 13800),
      ];
    } else {
      // Year - placeholder
      return [
        const FlSpot(0, 58000),
        const FlSpot(1, 55000),
        const FlSpot(2, 52000),
        const FlSpot(3, 54000),
        const FlSpot(4, 51000),
        const FlSpot(5, 49000),
      ];
    }
  }

  Widget _buildGoalProgressBar(BuildContext context) {
    return Obx(() {
      double progress = controller.weightProgress.value;
      String goalText = controller.progressPercentage;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                controller.goalText,
                style: GoogleFonts.lato(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Text(
                '$goalText ${'achieved'.tr}',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: const Color(0xFF00A89E),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Stack(
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[700]
                      : Colors.grey[200],
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  height: 10,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00E3CC), Color(0xFF00A89E)],
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${controller.userGoal.value == "lose"
                    ? "lost".tr
                    : controller.userGoal.value == "gain"
                    ? "gained".tr
                    : "changed".tr}: ${controller.weightLost.value.toStringAsFixed(1)} ${controller.weightUnit}',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                '${'remaining'.tr}: ${controller.remainingWeight.value.toStringAsFixed(1)} ${controller.weightUnit}',
                style: GoogleFonts.lato(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildCaloriesConsumedChart(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'calories_vs_goal_title'.tr,
          style: GoogleFonts.lato(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF00E3CC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            children: [
              SizedBox(
                height: 200,
                child: LineChart(
                  LineChartData(
                    gridData: FlGridData(
                      show: true,
                      drawVerticalLine: false,
                      drawHorizontalLine: true,
                      horizontalInterval: 100,
                      getDrawingHorizontalLine: (value) => FlLine(
                        color: Colors.black.withOpacity(0.1),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      ),
                    ),
                    titlesData: FlTitlesData(
                      show: true,
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          interval: 100,
                          reservedSize: 40,
                          getTitlesWidget: (value, meta) => Text(
                            value.toInt().toString(),
                            style: GoogleFonts.lato(
                              fontSize: 11,
                              color: Colors.black,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 30,
                          getTitlesWidget: (value, meta) {
                            final days = [
                              'mon'.tr,
                              'tue'.tr,
                              'wed'.tr,
                              'thu'.tr,
                              'fri'.tr,
                              'sat'.tr,
                              'sun'.tr,
                            ];
                            if (value.toInt() >= 0 &&
                                value.toInt() < days.length) {
                              return Text(
                                days[value.toInt()],
                                style: GoogleFonts.lato(
                                  fontSize: 11,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    minX: 0,
                    maxX: 6,
                    minY: 0,
                    maxY: 450,
                    lineBarsData: [
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 150),
                          FlSpot(1, 200),
                          FlSpot(2, 320),
                          FlSpot(3, 180),
                          FlSpot(4, 280),
                          FlSpot(5, 320),
                          FlSpot(6, 280),
                        ],
                        isCurved: true,
                        color: Colors.black,
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                      LineChartBarData(
                        spots: const [
                          FlSpot(0, 120),
                          FlSpot(1, 180),
                          FlSpot(2, 220),
                          FlSpot(3, 400),
                          FlSpot(4, 350),
                          FlSpot(5, 330),
                          FlSpot(6, 200),
                        ],
                        isCurved: true,
                        color: const Color(0xFFFF6B6B),
                        barWidth: 3,
                        dotData: const FlDotData(show: false),
                        belowBarData: BarAreaData(show: false),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildLegendItem('goal'.tr, Colors.black),
                  const SizedBox(width: 24),
                  _buildLegendItem('consumed'.tr, const Color(0xFFFF6B6B)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.lato(
            fontSize: 12,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChartSection(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF00E3CC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'macro_distribution'.tr,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'macro_low_protein'.tr,
                style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
        Positioned(
          bottom: -60,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildMacroCard(
                      'fats'.tr,
                      '${controller.weeklyFat.value}${'grams_unit'.tr}',
                      'assets/icons/fats.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMacroCard(
                      'carbs'.tr,
                      '${controller.weeklyCarbs.value}${'grams_unit'.tr}',
                      'assets/icons/carbs.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildMacroCard(
                      'protein'.tr,
                      '${controller.weeklyProtein.value}${'grams_unit'.tr}',
                      'assets/icons/protein.png',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMacroCard(String title, String value, String iconPath) {
    return Builder(
      builder: (context) => Container(
        height: 150,
        padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2C2C2C)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).dividerColor, width: 2),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: GoogleFonts.lato(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 5,
                ),
              ),
              child: Center(
                child: Image.asset(iconPath, width: 24, height: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdditionalMacros(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF00E3CC),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'additional_nutrients'.tr,
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'track_nutrients_text'.tr,
                style: GoogleFonts.lato(fontSize: 14, color: Colors.black87),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
        Positioned(
          bottom: -60,
          left: 0,
          right: 0,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildNutrientCard(
                      context,
                      'sugar'.tr,
                      '${controller.weeklySugar.value}${'grams_unit'.tr}',
                      'assets/icons/sugar.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNutrientCard(
                      context,
                      'sodium'.tr,
                      '${controller.weeklySodium.value}${'mg_unit'.tr}',
                      'assets/icons/salt.png',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildNutrientCard(
                      context,
                      'fiber'.tr,
                      '${controller.weeklyFiber.value}${'grams_unit'.tr}',
                      'assets/icons/fiber.png',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNutrientCard(
    BuildContext context,
    String title,
    String value,
    String iconPath,
  ) {
    return Container(
      height: 150,
      padding: const EdgeInsets.fromLTRB(10, 16, 10, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? const Color(0xFF2C2C2C)
            : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor, width: 2),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 5,
              ),
            ),
            child: Center(child: Image.asset(iconPath, width: 24, height: 24)),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScore(BuildContext context) {
    return Obx(() {
      final calorieProgress = controller.dailyCalorieGoal.value > 0
          ? (controller.avgDailyCalories.value.toDouble() /
                    controller.dailyCalorieGoal.value.toDouble())
                .clamp(0.0, 1.0)
          : 0.6;

      String healthMessage;
      if (calorieProgress >= 0.9 && calorieProgress <= 1.1) {
        healthMessage = 'health_msg_great'.tr;
      } else if (calorieProgress < 0.9) {
        healthMessage = 'health_msg_low'.tr;
      } else {
        healthMessage = 'health_msg_high'.tr;
      }

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF2C2C2C)
              : Colors.grey[200],
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'health_score'.tr,
              style: GoogleFonts.lato(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 16),
            Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[600]
                        : Colors.grey[400],
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: calorieProgress,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: const Color(0xFF00E3CC),
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              healthMessage,
              style: GoogleFonts.lato(
                fontSize: 13,
                color: Theme.of(context).textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildWaterIntakeTracker(BuildContext context) {
    return Obx(() {
      final waterGoal = controller.dailyWaterGoal.value > 0
          ? controller.dailyWaterGoal.value
          : 8;
      final waterProgress =
          (controller.avgDailyWater.value.toDouble() / waterGoal.toDouble())
              .clamp(0.0, 1.0);
      final waterPercent = (waterProgress * 100).toStringAsFixed(0);

      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'water_intake_tracker'.tr,
              style: GoogleFonts.lato(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[700]
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/glass.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'daily_average'.tr,
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${controller.avgDailyWater.value} / $waterGoal ${'glasses'.tr}',
                        style: GoogleFonts.lato(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$waterPercent% ${'complete'.tr}',
                        style: GoogleFonts.lato(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          Container(
                            height: 8,
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[600]
                                  : Colors.grey[300],
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: waterProgress,
                            child: Container(
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E3CC),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
