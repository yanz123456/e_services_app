import 'package:e_services_app/app/routes/app_pages.dart';
import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/verify_email_controller.dart';

class VerifyEmailView extends GetView<VerifyEmailController> {
  const VerifyEmailView({super.key});

  void _handleBack(BuildContext context) {
    FocusManager.instance.primaryFocus?.unfocus();
    final nav = Navigator.of(context);
    if (nav.canPop()) {
      nav.pop();
    } else {
      // no previous route in stack (e.g., came via offAllNamed) → go to Login
      Future.microtask(() => Get.offAllNamed(Routes.authentication));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scheme = t.colorScheme;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header back arrow (like your Forgot Password screen)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => _handleBack(context)),
                ),

                const SizedBox(height: 8),

                // Illustration (keep size similar to Forgot Password)
                Padding(
                  padding: AppSpacing.verticalMedium,
                    child: Image.asset('assets/images/verify-email.png', height: 250, fit: BoxFit.contain),
                ),

                const SizedBox(height: 24),

                // Title & subtitle
                Center(
                  child: Text(
                    'Verification code',
                    style: t.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    'A verification link has been sent to',
                    style: t.textTheme.bodyMedium?.copyWith(color: t.hintColor),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    controller.email,
                    style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 24),
                const SizedBox(height: 8),

                // Primary action
                Obx(
                  () => SizedBox(
                    height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: scheme.primary,
                          foregroundColor: scheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: controller.checking.value ? null : controller.iveVerified,
                      child: controller.checking.value
                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Text('Verify'),
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Resend + countdown (keep this reactive only)
                Obx(
                  () => Column(
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: (controller.sending.value || controller.cooldown.value > 0)
                            ? null
                            : controller.resend,
                        child: controller.sending.value
                            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Resend Code'),
                      ),
                      const SizedBox(height: 6),
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 150),
                        opacity: controller.cooldown.value > 0 ? 1 : 0,
                        child: Text(
                          controller.cooldown.value > 0 ? controller.countdownText : '',
                          style: t.textTheme.bodySmall?.copyWith(color: t.hintColor),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
