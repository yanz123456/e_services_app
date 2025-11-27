import 'package:e_services_app/app/config/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class AppSpacing {
  AppSpacing._();

  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 24, vertical: 12);
  static const EdgeInsets page = EdgeInsets.all(16);
  static const EdgeInsets banner = EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  static const EdgeInsets navBar = EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const EdgeInsets navItem = EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const EdgeInsets inlineLabel = EdgeInsets.symmetric(horizontal: 14);
  static const EdgeInsets inputContent = EdgeInsets.symmetric(vertical: 16);
  static const EdgeInsets dotMargin = EdgeInsets.symmetric(horizontal: 4);
  static const EdgeInsets verticalMedium = EdgeInsets.symmetric(vertical: 8);
}

class AppColors {
  AppColors._();

  static const Color _brandLight = AppPalette.primary;
  static const Color _brandDark = Color(0xFF93C5FD);

  static const Color _accentLight = AppPalette.secondary;
  static const Color _accentDark = Color(0xFF8EA4FF);

  static const Color _backgroundLight = AppPalette.background;
  static const Color _backgroundDark = Color(0xFF0F172A);

  static const Color _authHeaderStartLight = Color(0xFF1E3A8A);
  static const Color _authHeaderStartDark = Color(0xFF0B213F);

  static const Color _authHeaderEndLight = Color(0xFF2563EB);
  static const Color _authHeaderEndDark = Color.fromARGB(255, 82, 89, 108);

  static const Color _textLight = Color(0xFF0F172A);
  static const Color _textDark = AppPalette.background;

  static const Color _brandingPrimaryColorLight = AppPalette.primary;
  static const Color _brandingPrimaryColorDark = Color.fromARGB(255, 82, 89, 108);

  static const Color _brandingPrimaryTextLight = AppPalette.primary;
  static const Color _brandingPrimaryTextDark = AppPalette.background;

  static bool get _isDark => Get.isDarkMode;

  static Color get staticWhite => Colors.white;
  static Color get textWhiteStatic => AppPalette.background;
  static Color get textStatic => const Color(0xFF0F172A);
  static Color get subTextStatic => const Color(0xFF6B7280);
  static Color get brand => _isDark ? _brandDark : _brandLight;
  static Color get accent => _isDark ? _accentDark : _accentLight;
  static Color get background => _isDark ? _backgroundDark : _backgroundLight;
  static Color get authHeaderStart => _isDark ? _authHeaderStartDark : _authHeaderStartLight;
  static Color get authHeaderEnd => _isDark ? _authHeaderEndDark : _authHeaderEndLight;
  static Color get textApp => _isDark ? _textDark : _textLight;
  static Color get brandingPrimaryColor => _isDark ? _brandingPrimaryColorDark : _brandingPrimaryColorLight;
  static Color get brandingPrimaryTextColor => _isDark ? _brandingPrimaryTextDark : _brandingPrimaryTextLight;
  static Color get inputBG => _isDark ? _brandingPrimaryColorDark : Colors.white;
  static Color get inputBorder => _isDark ? _brandingPrimaryColorDark : Color(0xFFE5E7EB);
  static Color get inputOutline => _isDark ? _brandingPrimaryColorDark : Color(0xFFE5E7EB);
  static Color get inputOutlineFocusedBorder => _isDark ? _textDark : _brandingPrimaryTextLight;

  static Color primary(BuildContext context) => Theme.of(context).colorScheme.primary;
  static Color mutedSurface(BuildContext context, {double alpha = 0.55}) =>
      Theme.of(context).colorScheme.onSurface.withValues(alpha: alpha);
  static Color disabled(BuildContext context) => mutedSurface(context, alpha: 0.3);
  static Color shadow(BuildContext context, {double alpha = 0.08}) =>
      Theme.of(context).colorScheme.shadow.withValues(alpha: alpha);
}

class AppTypography {
  AppTypography._();

  static TextStyle get authTitle => GoogleFonts.poppins(fontSize: 26, fontWeight: FontWeight.w700);
  static TextStyle get authSubtitle => GoogleFonts.poppins(fontSize: 14);
  static TextStyle get title => GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600, color: Colors.white);
}
