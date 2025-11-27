import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AppText extends StatefulWidget {
  final TextEditingController controller;
  final String? label, hint, initialValue;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final VoidCallback? onTap;
  final TextInputType keyboard;
  final TextInputAction action;
  final bool obscure, toggleObscure, enabled, readOnly;
  final bool autocorrect, suggestions;
  final TextCapitalization caps;
  final int maxLines;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefixIcon, suffixIcon;

  const AppText({
    super.key,
    required this.controller,
    this.label,
    this.hint,
    this.initialValue,
    this.validator,
    this.onChanged,
    this.onTap,
    this.keyboard = TextInputType.text,
    this.action = TextInputAction.next,
    this.obscure = false,
    this.toggleObscure = false,
    this.enabled = true,
    this.readOnly = false,
    this.autocorrect = false,
    this.suggestions = false,
    this.caps = TextCapitalization.none,
    this.maxLines = 1,
    this.inputFormatters,
    this.prefixIcon,
    this.suffixIcon,
  });

  /// Quick factories
  factory AppText.email({
    Key? key,
    required TextEditingController controller,
    String? hint = 'Email',
    String? Function(String?)? validator,
    Widget? prefixIcon = const Icon(Icons.alternate_email_rounded),
  }) => AppText(
    key: key,
    controller: controller,
    hint: hint,
    validator: validator,
    keyboard: TextInputType.emailAddress,
    prefixIcon: prefixIcon,
  );

  factory AppText.password({
    Key? key,
    required TextEditingController controller,
    String? hint = 'Password',
    String? Function(String?)? validator,
    Widget? prefixIcon = const Icon(Icons.lock_outline_rounded),
  }) => AppText(
    key: key,
    controller: controller,
    hint: hint,
    validator: validator,
    obscure: true,
    toggleObscure: true,
    prefixIcon: prefixIcon,
  );

  factory AppText.pwebssId({
    Key? key,
    required TextEditingController controller,
    String? hint = 'Student / Applicant No.',
    String? Function(String?)? validator,
    Widget? prefixIcon = const Icon(Icons.badge_outlined),
  }) => AppText(
    key: key,
    controller: controller,
    hint: hint,
    validator: validator,
    keyboard: TextInputType.text,
    prefixIcon: prefixIcon,
  );

  @override
  State<AppText> createState() => _AppTextState();
}

class _AppTextState extends State<AppText> {
  late bool _obscure;

  // === Shared styles from your login page ===
  TextStyle get _hintStyle => GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF9CA3AF));

  InputBorder get _uBorder => const UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFE5E7EB)));

  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
    if (widget.initialValue != null && widget.controller.text.isEmpty) {
      widget.controller.text = widget.initialValue!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      onTap: widget.onTap,
      validator: widget.validator,
      onChanged: widget.onChanged,
      keyboardType: widget.keyboard,
      textInputAction: widget.action,
      obscureText: _obscure,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      autocorrect: widget.autocorrect,
      enableSuggestions: widget.suggestions,
      textCapitalization: widget.caps,
      maxLines: widget.maxLines,
      inputFormatters: widget.inputFormatters,
      style: GoogleFonts.poppins(fontSize: 15), // uniform text style
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        hintStyle: _hintStyle,
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.toggleObscure
            ? IconButton(
                icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : widget.suffixIcon,
        enabledBorder: _uBorder,
        focusedBorder: _uBorder,
        errorBorder: _uBorder,
        focusedErrorBorder: _uBorder,
        contentPadding: AppSpacing.inputContent,
      ),
    );
  }
}
