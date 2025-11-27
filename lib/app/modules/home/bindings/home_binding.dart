import 'package:get/get.dart';

import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../requests/controllers/requests_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HomeController>(() => HomeController());
    if (!Get.isRegistered<ProfileController>()) {
      Get.lazyPut<ProfileController>(() => ProfileController(), fenix: true);
    }
    if (!Get.isRegistered<RequestsController>()) {
      Get.lazyPut<RequestsController>(() => RequestsController(), fenix: true);
    }
  }
}
