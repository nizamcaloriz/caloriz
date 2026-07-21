import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../core/widgets/bottom_nav_bar.dart';
import '../../../core/widgets/language_selector_dialog.dart';
import '../controllers/home_controller.dart';
import 'meal_items_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey =
      const GlobalObjectKey<ScaffoldState>('homeScaffold');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      drawer: _buildDrawer(context),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                _buildDateSelector(),
                const SizedBox(height: 24),
                _buildCaloriesOverview(),
                const SizedBox(height: 24),
                _buildMealSection(),
                const SizedBox(height: 24),
                _buildSummarySection(),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: const BottomNavBar(currentIndex: 0),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            // Header with avatar and name
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      //Navigator.pop(context);
                      //Get.toNamed('/profile');
                    },
                    child: Obx(
                      () => Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.orange.shade700,
                        ),
                        child: ClipOval(
                          child: controller.profileImageUrl.value.isNotEmpty
                              ? CachedNetworkImage(
                                  imageUrl: controller.profileImageUrl.value,
                                  fit: BoxFit.cover,
                                  fadeInDuration: const Duration(
                                    milliseconds: 200,
                                  ),
                                  placeholder: (context, url) => const Icon(
                                    Icons.person,
                                    size: 28,
                                    color: Colors.white,
                                  ),
                                  errorWidget: (context, url, error) =>
                                      const Icon(
                                        Icons.person,
                                        size: 28,
                                        color: Colors.white,
                                      ),
                                )
                              : const Icon(
                                  Icons.person,
                                  size: 28,
                                  color: Colors.white,
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(
                      () => Text(
                        controller.userName.value.isEmpty
                            ? 'User'
                            : controller.userName.value,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: Theme.of(context).dividerColor, height: 1),
            const SizedBox(height: 8),
            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_outline,
                    title: 'personal_details'.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/edit-profile');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.tune,
                    title: 'adjust_macronutrients'.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/adjust-macros');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.track_changes,
                    title: 'goal_current_weight'.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/goal-weight');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'weight_history'.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/weight-history');
                    },
                  ),
                  /*_buildDrawerItem(
                    context,
                    icon: Icons.handshake_outlined,
                    title: 'partner_program'.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/partner-program');
                    },
                  ),*/
                  _buildDrawerItem(
                    context,
                    icon: Icons.description_outlined,
                    title: 'terms_conditions'.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/terms-conditions');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.privacy_tip_outlined,
                    title: 'privacy_policy'.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/privacy-policy');
                    },
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.email_outlined,
                    title: 'support_email'.tr,
                    onTap: () {
                      Navigator.pop(context);
                      Get.toNamed('/support');
                    },
                  ),
                ],
              ),
            ),
            // Logout button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    // Handle logout
                    await controller.logout();
                  },
                  icon: const Icon(Icons.logout, color: Colors.white, size: 20),
                  label: Text(
                    'logout'.tr,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE57373),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22, color: Theme.of(context).iconTheme.color),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
      dense: true,
      visualDensity: const VisualDensity(vertical: 0),
    );
  }

  Widget _buildHeader() {
    return Builder(
      builder: (context) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                // Menu button to open drawer
                GestureDetector(
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: Icon(
                    Icons.menu,
                    size: 24,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
                const SizedBox(width: 16),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GetBuilder<ThemeController>(
                builder: (themeController) {
                  return Transform.scale(
                    scale: 0.8,
                    child: Switch(
                      value: themeController.isDarkMode,
                      onChanged: (_) => themeController.toggleTheme(),
                      activeThumbColor: const Color(0xFF00E3CC),
                      activeTrackColor: Colors.grey[800],
                      inactiveThumbColor: Colors.grey[600],
                      inactiveTrackColor: themeController.isDarkMode
                          ? Colors.grey[700]
                          : Colors.grey[300],
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  );
                },
              ),
              Builder(
                builder: (context) => IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.translate,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const LanguageSelectorDialog(),
                    );
                  },
                ),
              ),
              Builder(
                builder: (context) => IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  onPressed: () => Get.toNamed('/notification'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    final now = DateTime.now();
    final today = now.day;
    final currentMonth = [
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
    ][now.month - 1];

    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (index) {
              // Calculate date (middle item is today)
              final dayOffset = index - 3;
              final date = now.add(Duration(days: dayOffset));
              final dayNumber = date.day;
              final monthName = [
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
              ][date.month - 1];

              return Obx(() {
                final isSelected = controller.selectedDateIndex.value == index;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => controller.selectDate(index),
                    child: Container(
                      margin: EdgeInsets.only(right: index < 6 ? 4 : 0),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF00E3CC)
                            : (isDark
                                  ? const Color(0xFF2C2C2C)
                                  : const Color(0xFFCBF2F2)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              color: isSelected
                                  ? Colors.black
                                  : (isDark
                                        ? Colors.white70
                                        : const Color(0xFF007E7C)),
                            ),
                          ),
                          Text(
                            monthName,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: isSelected
                                  ? Colors.black
                                  : (isDark
                                        ? Colors.white70
                                        : const Color(0xFF007E7C)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              });
            }),
          ),
        );
      },
    );
  }

  Widget _buildCaloriesOverview() {
    return Builder(
      builder: (context) => Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'calories_overview'.tr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 30),
          // Semicircular gauge with proper spacing
          SizedBox(
            height: 160,
            child: Stack(
              children: [
                // Main gauge container
                Align(
                  alignment: Alignment.topCenter,
                  child: Obx(
                    () => SizedBox(
                      width: 300,
                      height: 150,
                      child: CustomPaint(
                        painter: DoubleRingGaugePainter(
                          outerProgress: controller.dailyCalories.value > 0
                              ? (controller.consumedCalories.value /
                                        controller.dailyCalories.value)
                                    .clamp(0.0, 1.0)
                              : 0.0,
                          innerProgress: controller.dailyCalories.value > 0
                              ? ((controller.dailyCalories.value -
                                            controller.consumedCalories.value) /
                                        controller.dailyCalories.value)
                                    .clamp(0.0, 1.0)
                              : 0.0,
                        ),
                      ),
                    ),
                  ),
                ),
                // Consumed label (top-left)
                Positioned(
                  left: 10,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(
                          builder: (context) => Text(
                            'consumed'.tr.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          controller.consumedCalories.value.toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Remaining label (top-right)
                Positioned(
                  right: 10,
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Builder(
                          builder: (context) => Text(
                            'remaining'.tr.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Text(
                          (controller.dailyCalories.value -
                                  controller.consumedCalories.value)
                              .toString(),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Goal label (bottom center)
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Obx(
                    () => Column(
                      children: [
                        Builder(
                          builder: (context) => Text(
                            'goal'.tr.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyLarge?.color,
                              letterSpacing: 1.0,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          controller.dailyCalories.value.toString(),
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) => Text(
            'meal_section'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(
          () => _buildMealCard(
            'breakfast'.tr,
            controller.getMealSummary('breakfast'),
            'https://images.unsplash.com/photo-1533089860892-a7c6f0a88666?w=400',
            'breakfast',
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _buildMealCard(
            'lunch'.tr,
            controller.getMealSummary('lunch'),
            'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400',
            'lunch',
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _buildMealCard(
            'snacks'.tr,
            controller.getMealSummary('snacks'),
            'https://images.unsplash.com/photo-1610832958506-aa56368176cf?w=400',
            'snacks',
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _buildMealCard(
            'dinner'.tr,
            controller.getMealSummary('dinner'),
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=400',
            'dinner',
          ),
        ),
      ],
    );
  }

  Widget _buildMealCard(
    String title,
    String subtitle,
    String imagePath,
    String mealType,
  ) {
    return GestureDetector(
      onTap: () => Get.to(
        () => MealItemsView(
          mealType: mealType,
          mealTitle: title,
        ),
      ),
      child: Builder(
        builder: (context) {
          // Determine placeholder color based on meal type
          Color placeholderColor;
          IconData placeholderIcon;

          // Normalize title for comparison
          final normalizedTitle = title.toLowerCase();

          if (normalizedTitle.contains('breakfast') ||
              normalizedTitle.contains('desayuno') ||
              normalizedTitle.contains('नाश्ता') ||
              normalizedTitle.contains('petit-déjeuner') ||
              normalizedTitle.contains('早餐')) {
            placeholderColor = Colors.blue.shade100;
            placeholderIcon = Icons.breakfast_dining;
          } else if (normalizedTitle.contains('lunch') ||
              normalizedTitle.contains('almuerzo') ||
              normalizedTitle.contains('दोपहर') ||
              normalizedTitle.contains('déjeuner') ||
              normalizedTitle.contains('午餐')) {
            placeholderColor = Colors.orange.shade100;
            placeholderIcon = Icons.lunch_dining;
          } else if (normalizedTitle.contains('snack') ||
              normalizedTitle.contains('bocadillo') ||
              normalizedTitle.contains('collation') ||
              normalizedTitle.contains('小吃')) {
            placeholderColor = Colors.brown.shade100;
            placeholderIcon = Icons.local_cafe;
          } else if (normalizedTitle.contains('dinner') ||
              normalizedTitle.contains('cena') ||
              normalizedTitle.contains('रात') ||
              normalizedTitle.contains('dîner') ||
              normalizedTitle.contains('晚餐')) {
            placeholderColor = Colors.blue.shade100;
            placeholderIcon = Icons.dinner_dining;
          } else {
            placeholderColor = Theme.of(context).dividerColor;
            placeholderIcon = Icons.restaurant;
          }

          return Container(
            height: 100,
            decoration: BoxDecoration(
              color:
                  Theme.of(context).cardTheme.color ??
                  Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Theme.of(context).dividerColor,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                // Image with rounded corners
                Container(
                  width: 80,
                  height: 80,
                  margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: placeholderColor,
                  ),
                  child: imagePath.isEmpty
                      ? Icon(placeholderIcon, size: 48, color: Colors.white70)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: imagePath,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Icon(
                              placeholderIcon,
                              size: 48,
                              color: Colors.white70,
                            ),
                            errorWidget: (context, url, error) => Icon(
                              placeholderIcon,
                              size: 48,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                ),
                // Text content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          title.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00E3CC),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF00E3CC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Arrow
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: Theme.of(context).iconTheme.color,
                    size: 16,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showAddStepsDialog(BuildContext context) {
    final TextEditingController stepsController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Add Steps'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: stepsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Number of Steps',
                hintText: 'e.g., 1000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.directions_walk),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final steps = int.tryParse(stepsController.text) ?? 0;

              if (steps > 0) {
                controller.addSteps(steps);
                Navigator.pop(context);
                Get.snackbar(
                  'Success',
                  '$steps steps added',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF00E3CC),
                  colorText: Colors.black,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter valid number of steps',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E3CC),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showAddMealDialog(
    BuildContext context,
    String mealType,
    String mealTitle,
  ) {
    final TextEditingController nameController = TextEditingController();
    final TextEditingController caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Add $mealTitle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              final calories = int.tryParse(caloriesController.text) ?? 0;

              if (name.isNotEmpty && calories > 0) {
                controller.addMeal(mealType, name, calories);
                Navigator.pop(context);
                Get.snackbar(
                  'Success',
                  'Meal added to $mealTitle',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: const Color(0xFF00E3CC),
                  colorText: Colors.black,
                );
              } else {
                Get.snackbar(
                  'Error',
                  'Please enter valid food name and calories',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00E3CC),
            ),
            child: const Text('Add', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Widget _buildSummarySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Builder(
          builder: (context) => Text(
            'summary'.tr,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.headlineSmall?.color,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => _showAddStepsDialog(Get.context!),
                child: Obx(
                  () => _buildSummaryCard(
                    controller.stepsDisplay,
                    'steps'.tr,
                    Icons.directions_walk,
                    const Color(0xFF00E3CC),
                    Colors.orange,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: GestureDetector(
                onTap: () => controller.addWaterGlass(),
                child: Obx(
                  () => _buildSummaryCard(
                    controller.waterProgress,
                    'water'.tr,
                    Icons.water_drop,
                    const Color(0xFF00E3CC),
                    Colors.blue,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Obx(
                () => _buildSummaryCard(
                  controller.consumedCalories.value.toString(),
                  'calories'.tr,
                  Icons.local_fire_department,
                  const Color(0xFF00E3CC),
                  Colors.red,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
    String value,
    String label,
    IconData icon,
    Color bgColor,
    Color iconColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Builder(
            builder: (context) => Text(
              label.toUpperCase(),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Icon(icon, size: 36, color: iconColor),
          const SizedBox(height: 8),
          Builder(
            builder: (context) => RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: [
                  TextSpan(
                    text: value.split(' ')[0],
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  if (label == 'steps'.tr)
                    TextSpan(
                      text: ' ${'steps'.tr}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  if (label == 'calories'.tr)
                    TextSpan(
                      text: ' kcal',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.normal,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for double-ring semicircular gauge
class DoubleRingGaugePainter extends CustomPainter {
  final double outerProgress;
  final double innerProgress;

  DoubleRingGaugePainter({
    required this.outerProgress,
    required this.innerProgress,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);

    // Outer ring (Consumed - dark gray)
    final outerRadius = size.width / 2;
    final outerStrokeWidth = 28.0;

    // Draw outer background (light gray)
    final outerBgPaint = Paint()
      ..color = const Color(0xFFD8D8D8)
      ..strokeWidth = outerStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: outerRadius - outerStrokeWidth / 2,
      ),
      3.14159, // π (180 degrees - start from left)
      3.14159, // π (180 degrees - full semicircle)
      false,
      outerBgPaint,
    );

    // Draw outer progress (dark gray - consumed)
    final outerPaint = Paint()
      ..color = const Color(0xFF3B3B3B)
      ..strokeWidth = outerStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: outerRadius - outerStrokeWidth / 2,
      ),
      3.14159, // Start from left
      3.14159 * outerProgress, // Progress sweep
      false,
      outerPaint,
    );

    // Inner ring (Remaining - sage green)
    final innerRadius = outerRadius - outerStrokeWidth - 12;
    final innerStrokeWidth = 28.0;

    // Draw inner background (light gray)
    final innerBgPaint = Paint()
      ..color = const Color(0xFFD8D8D8)
      ..strokeWidth = innerStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: innerRadius - innerStrokeWidth / 2,
      ),
      3.14159,
      3.14159,
      false,
      innerBgPaint,
    );

    // Draw inner progress (turquoise - remaining)
    final innerPaint = Paint()
      ..color = const Color(0xFF00E3CC)
      ..strokeWidth = innerStrokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    canvas.drawArc(
      Rect.fromCircle(
        center: center,
        radius: innerRadius - innerStrokeWidth / 2,
      ),
      3.14159,
      3.14159 * innerProgress,
      false,
      innerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Old painter kept for compatibility
class SemiCircularGaugePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool isOuter;

  SemiCircularGaugePainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    required this.isOuter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.butt;

    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;

    const startAngle = 3.14159;
    final sweepAngle = 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
