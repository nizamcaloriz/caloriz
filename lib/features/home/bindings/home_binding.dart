import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/nutrition_service.dart';
import '../../../core/services/ai_service.dart';
import '../controllers/home_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize services if not already done
    if (!Get.isRegistered<AuthService>()) {
      Get.put(AuthService());
    }
    if (!Get.isRegistered<NutritionService>()) {
      Get.put(NutritionService());
    }
    if (!Get.isRegistered<AIService>()) {
      Get.put(AIService());
    }
    
    Get.lazyPut<HomeController>(() => HomeController());
  }
}
