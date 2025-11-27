import 'package:e_services_app/app/data/models/authentication_model.dart';
import 'package:e_services_app/app/data/services/auth_services.dart';
import 'package:e_services_app/app/modules/home/models/home_nav_config.dart';
import 'package:e_services_app/utils/error_utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class AuthenticationController extends GetxController {
  final email = TextEditingController(), password = TextEditingController(), requestorId = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final isLoading = false.obs, obscure = true.obs, remember = true.obs;
  final usePwebss = false.obs, pwebssType = 'Student'.obs;

  String? validateEmail(String? v) {
    if (!usePwebss.value) {
      if (v == null || v.trim().isEmpty) return 'Email is required';
      final r = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
      if (!r.hasMatch(v)) return 'Invalid email';
    }
    return null;
  }

  String? validatePassword(String? v) => (v == null || v.length < 6) ? 'At least 6 characters' : null;
  String? validateId(String? v) =>
      usePwebss.value && (v == null || v.isEmpty) ? 'Student/Applicant No. is required' : null;

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    isLoading.value = true;
    try {
      final req = usePwebss.value
          ? LoginRequest(
              loginType: 'valuePwebss',
              requestorId: requestorId.text.trim(),
              password: password.text,
              type: pwebssType.value,
              remember: remember.value,
            )
          : LoginRequest(email: email.text.trim(), password: password.text, remember: remember.value);

      final res = await AuthService.login(req);
      isLoading.value = false;

      if (res.token != null) {
        final gate = await AuthService.postLoginGate();
        switch (gate) {
          case PostLoginRoute.home:
            Get.offAllNamed(Routes.home);
            break;
          case PostLoginRoute.verifyEmail:
            Get.offAllNamed(Routes.verifyEmail);
            break;
          case PostLoginRoute.completeProfile:
            Get.offAllNamed(Routes.home, arguments: const HomeNavConfig(initialIndex: 3, lockedIndex: 3));
            break;
        }
      } else if (res.action == 'SET_EMAIL_ADDRESS') {
        showErrorSnack(message: 'Please set your email address', title: 'Action Required', replace: true);
      } else {
        showErrorSnack(message: 'Unexpected Response.', title: 'Login Failed', replace: true);
      }
    } catch (e) {
      isLoading.value = false;
      showErrorSnack(err: e, title: 'Login Failed', replace: true);
    }
  }

  Future<void> continueWithGoogle() async {
    showErrorSnack(message: 'Google sign-in is coming soon.', title: 'Not yet available');
  }

  @override
  void onClose() {
    email.dispose();
    password.dispose();
    requestorId.dispose();
    super.onClose();
  }
}
