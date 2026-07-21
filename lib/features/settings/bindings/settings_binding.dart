import 'package:get/get.dart';
import '../controllers/settings_controller.dart';
import '../controllers/weight_history_controller.dart';
import '../controllers/goal_weight_controller.dart';
import '../controllers/macronutrients_controller.dart';
import '../controllers/partner_program_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(() => SettingsController());
    Get.lazyPut<WeightHistoryController>(() => WeightHistoryController());
    Get.lazyPut<GoalWeightController>(() => GoalWeightController());
    Get.lazyPut<MacronutrientsController>(() => MacronutrientsController());
    Get.lazyPut<PartnerProgramController>(() => PartnerProgramController());
  }
}
