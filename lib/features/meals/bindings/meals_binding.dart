import 'package:get/get.dart';
import '../controllers/meals_controller.dart';

class MealsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MealsController>(() => MealsController());
  }
}
