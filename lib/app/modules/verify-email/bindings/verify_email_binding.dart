import 'package:e_services_app/app/modules/verify-email/controllers/verify_email_controller.dart';
import 'package:get/get.dart';

class VerifyEmailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<VerifyEmailController>(() => VerifyEmailController(), fenix: true);
  }
}
