import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:e_services_app/app/data/services/auth_services.dart';
import 'package:e_services_app/utils/error_utils.dart';

class ForgotPasswordController extends GetxController {
  final formKey = GlobalKey<FormState>();
  final email = TextEditingController();
  final loading = false.obs;

  String? validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final r = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!r.hasMatch(v.trim())) return 'Invalid email';
    return null;
  }

  Future<void> submit() async {
    if (!(formKey.currentState?.validate() ?? false)) return;
    FocusManager.instance.primaryFocus?.unfocus();
    loading.value = true;
    try {
      await AuthService.forgotPassword(email.text.trim()); // implement in service
      Get.snackbar(
        'Submitted',
        'Check your email for reset instructions',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 4),
      );
      Get.back(); // return to Login
    } catch (e) {
      showErrorSnack(err: e, title: 'Request failed');
    } finally {
      loading.value = false;
    }
  }

  @override
  void onClose() {
    email.dispose();
    super.onClose();
  }
}
