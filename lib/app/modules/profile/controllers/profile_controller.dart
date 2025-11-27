import 'package:e_services_app/app/data/services/auth_services.dart';
import 'package:e_services_app/app/routes/app_pages.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final isLoggingOut = false.obs;

  Future<void> logout() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;
    try {
      await AuthService.logout();
      Get.offAllNamed(Routes.authentication);
    } finally {
      isLoggingOut.value = false;
    }
  }
}
