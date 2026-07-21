import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class MealItemsView extends StatelessWidget {
  const MealItemsView({
    super.key,
    required this.mealType,
    required this.mealTitle,
  });

  final String mealType;
  final String mealTitle;

  HomeController get controller => Get.find<HomeController>();

  List<Map<String, dynamic>> _getMealList() {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return controller.breakfastMeals;
      case 'lunch':
        return controller.lunchMeals;
      case 'snacks':
        return controller.snackMeals;
      case 'dinner':
        return controller.dinnerMeals;
      default:
        return <Map<String, dynamic>>[];
    }
  }

  void _showAddMealDialog(BuildContext context) {
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

  void _showEditMealDialog(BuildContext context, int index, Map<String, dynamic> meal) {
    final TextEditingController nameController = TextEditingController(text: meal['name']);
    final TextEditingController caloriesController = TextEditingController(text: meal['calories'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Edit $mealTitle'),
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
                controller.editMeal(mealType, index, name, calories);
                Navigator.pop(context);
                Get.snackbar(
                  'Success',
                  'Meal updated',
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
            child: const Text('Update', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Meal'),
        content: Text('Are you sure you want to delete this meal item from $mealTitle?'),
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
              controller.deleteMeal(mealType, index);
              Navigator.pop(context);
              Get.snackbar(
                'Success',
                'Meal deleted',
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: const Color(0xFF00E3CC),
                colorText: Colors.black,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE57373),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        title: Text(
          mealTitle,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'View and manage your $mealTitle items',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 20),
            Obx(
              () {
                final meals = _getMealList();
                if (meals.isEmpty) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        'No items added yet for $mealTitle.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                  );
                }

                return Expanded(
                  child: ListView.separated(
                    itemCount: meals.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final meal = meals[index];
                      return Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1.2,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    meal['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Theme.of(context).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '${meal['calories']} cal',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: Theme.of(context).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            PopupMenuButton(
                              icon: Icon(
                                Icons.more_vert,
                                color: Theme.of(context).iconTheme.color,
                              ),
                              onSelected: (value) {
                                if (value == 'edit') {
                                  _showEditMealDialog(context, index, meal);
                                } else if (value == 'delete') {
                                  _showDeleteConfirmDialog(context, index);
                                }
                              },
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'edit',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.edit, size: 18, color: Color(0xFF00E3CC)),
                                      const SizedBox(width: 12),
                                      const Text('Edit'),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'delete',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.delete, size: 18, color: Color(0xFFE57373)),
                                      const SizedBox(width: 12),
                                      const Text('Delete'),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                  width: 1.2,
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Obx(
                    () => Text(
                      'Total: ${controller.getMealCalories(mealType)} cal',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _showAddMealDialog(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E3CC),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text(
                      'Add item',
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
