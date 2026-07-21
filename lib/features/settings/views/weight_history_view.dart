import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/weight_history_controller.dart';

class WeightHistoryView extends GetView<WeightHistoryController> {
  const WeightHistoryView({super.key});

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
              _buildHeader(context),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCards(context),
                      const SizedBox(height: 24),
                      _buildWeightChart(context),
                      const SizedBox(height: 24),
                      _buildHistoryList(context),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddWeightDialog(context),
        backgroundColor: const Color(0xFF00E3CC),
        child: const Icon(Icons.add, color: Colors.black),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
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
            'weight_history_title'.tr,
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

  Widget _buildSummaryCards(BuildContext context) {
    return Obx(
      () => Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              context,
              'starting'.tr,
              '${controller.startingWeight.value.toStringAsFixed(1)} ${controller.weightUnit}',
              Icons.flag_outlined,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              'current'.tr,
              '${controller.currentWeight.value.toStringAsFixed(1)} ${controller.weightUnit}',
              Icons.monitor_weight_outlined,
              const Color(0xFF00E3CC),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              context,
              controller.getChangeText(),
              '${controller.weightChange.value.abs().toStringAsFixed(1)} ${controller.weightUnit}',
              controller.weightChange.value < 0
                  ? Icons.trending_up
                  : Icons.trending_down,
              controller.getChangeColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 8),
          Text(
            label,
            style: GoogleFonts.lato(
              fontSize: 11,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChart(BuildContext context) {
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
          Text(
            'progress_chart'.tr,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 180,
            child: CustomPaint(
              size: const Size(double.infinity, 180),
              painter: WeightChartPainter(),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Nov 1',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                'Nov 7',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                'Nov 14',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                'Nov 21',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                'Nov 28',
                style: GoogleFonts.lato(
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context) {
    return Obx(() {
      if (controller.weightHistory.isEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(40),
            child: Text(
              '${'no_weight_history'.tr}.\n${'start_tracking'.tr}!',
              textAlign: TextAlign.center,
              style: GoogleFonts.lato(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'history_list_title'.tr,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 16),
          ...controller.weightHistory.map((item) {
            final date = item['date'] as DateTime;
            final weight = item['weight'] as double;
            final formattedDate =
                '${_getMonthName(date.month)} ${date.day}, ${date.year}';

            return _buildHistoryItem(context, {
              'date': formattedDate,
              'weight': weight.toStringAsFixed(1),
              'unit': controller.weightUnit.value,
              'note': item['note'] ?? '',
            });
          }),
        ],
      );
    });
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month];
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, String> item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['date']!,
                  style: GoogleFonts.lato(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item['weight']} ${item['unit']}',
                  style: GoogleFonts.lato(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF00E3CC),
                  ),
                ),
                if (item['note']!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item['note']!,
                    style: GoogleFonts.lato(
                      fontSize: 11,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context) {
    double weight = controller.currentWeight.value;
    final noteController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'add_weight'.tr,
            style: GoogleFonts.lato(fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${weight.toStringAsFixed(1)} ${controller.weightUnit}',
                style: GoogleFonts.lato(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00E3CC),
                ),
              ),
              const SizedBox(height: 16),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: const Color(0xFF00E3CC),
                  inactiveTrackColor: const Color(0xFF00E3CC).withOpacity(0.2),
                  thumbColor: const Color(0xFF00E3CC),
                  trackHeight: 8,
                ),
                child: Slider(
                  value: weight,
                  min: 40,
                  max: 150,
                  onChanged: (value) => setState(() => weight = value),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: noteController,
                decoration: InputDecoration(
                  labelText: '${'note'.tr} (optional)',
                  hintText: '${'add'.tr} ${'note'.tr}...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'cancel'.tr,
                style: GoogleFonts.lato(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                controller.addWeightEntry(weight, noteController.text);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00E3CC),
              ),
              child: Text(
                'save'.tr,
                style: GoogleFonts.lato(color: Colors.black),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WeightChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF00E3CC)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF00E3CC).withOpacity(0.3),
          const Color(0xFF00E3CC).withOpacity(0.0),
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Sample data points
    final points = [
      Offset(0, size.height * 0.1),
      Offset(size.width * 0.2, size.height * 0.25),
      Offset(size.width * 0.4, size.height * 0.35),
      Offset(size.width * 0.6, size.height * 0.5),
      Offset(size.width * 0.8, size.height * 0.65),
      Offset(size.width, size.height * 0.8),
    ];

    // Draw filled area
    final fillPath = Path()..moveTo(0, size.height);
    for (final point in points) {
      fillPath.lineTo(point.dx, point.dy);
    }
    fillPath.lineTo(size.width, size.height);
    fillPath.close();
    canvas.drawPath(fillPath, fillPaint);

    // Draw line
    final linePath = Path()..moveTo(points.first.dx, points.first.dy);
    for (int i = 1; i < points.length; i++) {
      linePath.lineTo(points[i].dx, points[i].dy);
    }
    canvas.drawPath(linePath, paint);

    // Draw points
    final dotPaint = Paint()
      ..color = const Color(0xFF00E3CC)
      ..style = PaintingStyle.fill;
    for (final point in points) {
      canvas.drawCircle(point, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
