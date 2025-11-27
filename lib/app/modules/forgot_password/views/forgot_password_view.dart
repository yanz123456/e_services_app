import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<ForgotPasswordController>();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screen,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Form(
                key: c.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  // HEADER BACK ARROW
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                      onPressed: () => Get.back(),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Illustration
                  Padding(
                    padding: AppSpacing.verticalMedium,
                    child: Image.asset('assets/images/4.png', height: 250, fit: BoxFit.contain),
                  ),

                  const SizedBox(height: 24),
                  Text(
                    'Forgot Password ?',
                    style: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w700, color: AppColors.textApp),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Don't worry! It happens. Please enter the email address associated with your account.",
                    style: GoogleFonts.poppins(color: AppColors.textApp, fontSize: 14),
                  ),
                  const SizedBox(height: 20),

                  // Email input styled like authentication view
                  _ForgotEmailField(controller: c.email, validator: c.validateEmail),

                  const SizedBox(height: 48),

                  // Submit
                  Obx(
                    () => SizedBox(
                      height: 52,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.brandingPrimaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: c.loading.value ? null : c.submit,
                        child: c.loading.value
                            ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text('Submit', style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ForgotEmailField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;
  const _ForgotEmailField({required this.controller, this.validator});

  OutlineInputBorder _outline(Color color) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: BorderSide(color: color),
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: TextInputType.emailAddress,
        textInputAction: TextInputAction.done,
        style: GoogleFonts.poppins(fontSize: 15, color: AppColors.brandingPrimaryTextColor),
        decoration: InputDecoration(
          hintText: 'Email',
          filled: true,
          fillColor: AppColors.inputBG,
          prefixIcon: Icon(Icons.alternate_email_rounded, color: AppColors.brandingPrimaryTextColor),
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          border: _outline(AppColors.inputBorder),
          enabledBorder: _outline(AppColors.inputOutline),
          focusedBorder: _outline(AppColors.inputOutlineFocusedBorder),
        ),
      ),
    );
  }
}
