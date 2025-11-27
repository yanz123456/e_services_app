import 'package:e_services_app/app/routes/app_pages.dart';
import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/authentication_controller.dart';

class AuthenticationView extends GetView<AuthenticationController> {
  const AuthenticationView({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<AuthenticationController>();
    const double headerHeight = 350;
    const double overlap = 80;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double minHeight = (constraints.maxHeight - (headerHeight - overlap)).clamp(0, double.infinity);
            return Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: SizedBox(
                    height: headerHeight,
                    child: _AuthHeader(startColor: AppColors.authHeaderStart, endColor: AppColors.authHeaderEnd),
                  ),
                ),
                Positioned.fill(
                  top: headerHeight - overlap,
                  child: SingleChildScrollView(
                    padding: EdgeInsets.zero,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: minHeight),
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(22, 36, 22, 40),
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.only(topLeft: Radius.circular(72)),
                          boxShadow: [BoxShadow(color: Color(0x11000000), blurRadius: 26, offset: Offset(0, 12))],
                        ),
                        child: Form(
                          key: c.formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Login',
                                style: AppTypography.authTitle.copyWith(color: AppColors.textApp),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'Access your account to continue',
                                style: AppTypography.authSubtitle.copyWith(color: AppColors.textApp),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 18),
                              Obx(() {
                                final isP = c.usePwebss.value;
                                return Row(
                                  children: [
                                    Expanded(
                                      child: _ModeButton(
                                        label: 'Email',
                                        selected: !isP,
                                        onTap: () => c.usePwebss.value = false,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: _ModeButton(
                                        label: 'PWEBSS',
                                        selected: isP,
                                        onTap: () => c.usePwebss.value = true,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                              const SizedBox(height: 16),
                              Obx(
                                () => Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (!c.usePwebss.value) ...[
                                      _AuthField(
                                        controller: c.email,
                                        hint: 'Email',
                                        validator: c.validateEmail,
                                        icon: Icons.alternate_email_rounded,
                                        keyboardType: TextInputType.emailAddress,
                                      ),
                                    ] else ...[
                                      _DropdownField(
                                        label: 'Select Client Type',
                                        value: c.pwebssType.value,
                                        onChanged: (v) {
                                          if (v != null) c.pwebssType.value = v;
                                        },
                                        items: const [
                                          DropdownMenuItem(value: 'Student', child: Text('Student')),
                                          DropdownMenuItem(value: 'Applicant', child: Text('Applicant')),
                                        ],
                                      ),
                                      const SizedBox(height: 14),
                                      _AuthField(
                                        controller: c.requestorId,
                                        hint: 'Student / Applicant No.',
                                        validator: c.validateId,
                                        icon: Icons.badge_outlined,
                                        keyboardType: TextInputType.text,
                                      ),
                                    ],
                                    const SizedBox(height: 14),
                                    _AuthField(
                                      controller: c.password,
                                      hint: 'Password',
                                      validator: c.validatePassword,
                                      icon: Icons.lock_outline_rounded,
                                      obscure: true,
                                      toggleObscure: true,
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          FocusManager.instance.primaryFocus?.unfocus();
                                          Future.microtask(() => Get.toNamed(Routes.forgotPassword));
                                        },
                                        child: Text(
                                          'Forgot Password?',
                                          style: GoogleFonts.poppins(
                                            color: AppColors.inputOutlineFocusedBorder,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Obx(
                                () => FilledButton(
                                  style: FilledButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    backgroundColor: AppColors.brandingPrimaryColor,
                                    foregroundColor: AppColors.textWhiteStatic,
                                    textStyle: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w700),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  onPressed: c.isLoading.value ? null : c.submit,
                                  child: c.isLoading.value
                                      ? const SizedBox(
                                          height: 22,
                                          width: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : const Text('Login'),
                                ),
                              ),
                              const SizedBox(height: 20),
                              // Row(
                              //   children: [
                              //     Expanded(child: Divider(color: Colors.black.withOpacity(0.08), thickness: 1)),
                              //     const SizedBox(width: 12),
                              //     Text(
                              //       'Or',
                              //       style: GoogleFonts.poppins(
                              //         fontSize: 13,
                              //         color: const Color(0xFF6B7280),
                              //         fontWeight: FontWeight.w500,
                              //       ),
                              //     ),
                              //     const SizedBox(width: 12),
                              //     Expanded(child: Divider(color: Colors.black.withOpacity(0.08), thickness: 1)),
                              //   ],
                              // ),
                              // const SizedBox(height: 20),
                              // OutlinedButton.icon(
                              //   style: OutlinedButton.styleFrom(
                              //     minimumSize: const Size.fromHeight(52),
                              //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              //     side: const BorderSide(color: Color(0xFFE5E7EB)),
                              //     foregroundColor: const Color(0xFF1F2937),
                              //     textStyle: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600),
                              //   ),
                              //   onPressed: c.continueWithGoogle,
                              //   icon: Image.asset('assets/images/google-logo.png', height: 22, width: 22),
                              //   label: const Text('Continue with Google'),
                              // ),
                              // const SizedBox(height: 10),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _AuthHeader extends StatelessWidget {
  final Color startColor;
  final Color endColor;
  const _AuthHeader({required this.startColor, required this.endColor});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [startColor, endColor],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          Align(
            alignment: const Alignment(0, -0.2),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 150,
                  height: 150,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset('assets/images/pnu-logo.png', fit: BoxFit.contain),
                    ),
                  ),
                ),
                Text('PNU E-Services Portal', style: AppTypography.title.copyWith(color: AppColors.textWhiteStatic)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthField extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType keyboardType;
  final TextInputAction action;
  final bool obscure;
  final bool toggleObscure;
  final IconData icon;

  const _AuthField({
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType = TextInputType.text,
    this.action = TextInputAction.next,
    this.obscure = false,
    this.toggleObscure = false,
    required this.icon,
  });

  @override
  State<_AuthField> createState() => _AuthFieldState();
}

class _AuthFieldState extends State<_AuthField> {
  late bool _obscure;

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

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
        controller: widget.controller,
        validator: widget.validator,
        keyboardType: widget.keyboardType,
        textInputAction: widget.action,
        obscureText: _obscure,
        style: GoogleFonts.poppins(fontSize: 15, color: AppColors.brandingPrimaryTextColor),
        decoration: InputDecoration(
          hintText: widget.hint,
          filled: true,
          fillColor: AppColors.inputBG,
          prefixIcon: Icon(widget.icon, color: AppColors.brandingPrimaryTextColor),
          suffixIcon: widget.toggleObscure
              ? IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.brandingPrimaryTextColor,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                )
              : null,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          border: _outline(AppColors.inputBorder),
          enabledBorder: _outline(AppColors.inputOutline),
          focusedBorder: _outline(AppColors.inputOutlineFocusedBorder),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<DropdownMenuItem<String>> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({required this.label, required this.value, required this.items, required this.onChanged});

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
      child: DropdownButtonFormField<String>(
        value: value,
        items: items,
        onChanged: onChanged,
        decoration: InputDecoration(
          labelStyle: TextStyle(color: AppColors.brandingPrimaryTextColor),
          labelText: label,
          filled: true,
          fillColor: AppColors.inputBG,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
          border: _outline(AppColors.inputBorder),
          enabledBorder: _outline(AppColors.inputOutline),
          focusedBorder: _outline(AppColors.inputOutlineFocusedBorder),
        ),
        icon: Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.inputOutlineFocusedBorder),
        style: GoogleFonts.poppins(fontSize: 15, color: AppColors.brandingPrimaryTextColor),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ModeButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    const Color accent = Color(0xFF2563EB);
    const Color neutral = Color(0xFFF2F5FB);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 44,
      decoration: BoxDecoration(
        color: selected ? AppColors.brandingPrimaryColor : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandingPrimaryColor.withOpacity(0.18)),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: AppColors.brandingPrimaryColor.withOpacity(0.24),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              color: selected ? AppColors.textWhiteStatic : AppColors.textApp,
            ),
          ),
        ),
      ),
    );
  }
}
