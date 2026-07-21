import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/edit_profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<EditProfileController>(() => EditProfileController());
  }
}
