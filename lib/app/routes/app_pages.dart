import 'package:e_services_app/app/modules/authentication/bindings/authentication_binding.dart';
import 'package:e_services_app/app/modules/authentication/views/authentication_view.dart';
import 'package:e_services_app/app/modules/forgot_password/bindings/forgot_password_binding.dart';
import 'package:e_services_app/app/modules/forgot_password/views/forgot_password_view.dart';
import 'package:e_services_app/app/modules/gate/gate_view.dart';
import 'package:e_services_app/app/modules/home/bindings/home_binding.dart';
import 'package:e_services_app/app/modules/home/views/home_view.dart';
import 'package:e_services_app/app/modules/verify-email/bindings/verify_email_binding.dart';
import 'package:e_services_app/app/modules/verify-email/views/verify_email_view.dart';
import 'package:get/get.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const initial = Routes.onboarding;

  static final routes = [
    GetPage(name: Routes.gate, page: () => const GateView()),
    GetPage(name: Routes.onboarding, page: () => const OnboardingView(), binding: OnboardingBinding()),
    GetPage(name: Routes.authentication, page: () => AuthenticationView(), binding: AuthenticationBinding()),
    GetPage(name: Routes.home, page: () => const HomeView(), binding: HomeBinding()),
    GetPage(name: Routes.forgotPassword, page: () => ForgotPasswordView(), binding: ForgotPasswordBinding()),
    GetPage(name: Routes.verifyEmail, page: () => VerifyEmailView(), binding: VerifyEmailBinding()),
  ];
}
