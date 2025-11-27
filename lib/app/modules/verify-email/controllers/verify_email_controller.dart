// verify_email_controller.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:e_services_app/app/data/services/auth_services.dart';
import 'package:e_services_app/utils/error_utils.dart';
import 'package:e_services_app/app/routes/app_pages.dart';

class VerifyEmailController extends GetxController {
  final sending = false.obs, checking = false.obs, cooldown = 0.obs;
  Timer? _t;

  // Toggle this if you want to auto-send silently without locking the button.
  final bool autoSendOnOpen = false;

  String get email => AuthService.user?.email ?? '';

  @override
  void onReady() {
    super.onReady();
    if (autoSendOnOpen) _send(auto: true); // no cooldown, doesn't disable button
  }

  Future<void> resend() => _send(auto: false);

  Future<void> _send({required bool auto}) async {
    // For manual resend, respect sending/cooldown. For auto, don't block UI.
    if (!auto && (sending.value || cooldown.value > 0)) return;

    if (!auto) sending.value = true;
    try {
      await AuthService.resendVerification();
      // Only start cooldown after a **manual** resend
      if (!auto) _startCooldown(90); // or 60/30 as you like
    } catch (e) {
      showErrorSnack(err: e, title: 'Failed to send');
    } finally {
      if (!auto) sending.value = false;
    }
  }

  void _startCooldown(int seconds) {
    cooldown.value = seconds;
    _t?.cancel();
    _t = Timer.periodic(const Duration(seconds: 1), (t) {
      if (cooldown.value <= 1) {
        t.cancel();
        cooldown.value = 0;
      } else {
        cooldown.value--;
      }
    });
  }

  String get countdownText {
    final s = cooldown.value, m = s ~/ 60, ss = (s % 60).toString().padLeft(2, '0');
    return '$m:$ss min left';
  }

  Future<void> iveVerified() async {
    checking.value = true;
    try {
      final ok = await AuthService.checkVerified();
      if (ok)
        Get.offAllNamed(Routes.home);
      else
        showErrorSnack(message: 'Not verified yet. Please tap the link in your email.');
    } catch (e) {
      showErrorSnack(err: e, title: 'Check failed');
    } finally {
      checking.value = false;
    }
  }

  @override
  void onClose() {
    _t?.cancel();
    super.onClose();
  }
}
