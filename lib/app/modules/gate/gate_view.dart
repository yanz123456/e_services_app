import 'package:e_services_app/app/data/services/auth_services.dart';
import 'package:e_services_app/app/modules/home/models/home_nav_config.dart';
import 'package:e_services_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class GateView extends StatefulWidget {
  const GateView({super.key});
  @override
  State<GateView> createState() => _GateViewState();
}

class _GateViewState extends State<GateView> {
  bool _navigating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _decide());
  }

  Future<void> _decide() async {
    if (_navigating) return;
    _navigating = true;
    try {
      final box = GetStorage();
      final seenOnboarding = box.read('seenOnboarding') == true;

      if (!seenOnboarding) {
        Get.offAllNamed(Routes.onboarding);
        return;
      }

      if (!AuthService.isLoggedIn) {
        Get.offAllNamed(Routes.authentication);
        return;
      }
      final where = await AuthService.postLoginGate();
      switch (where) {
        case PostLoginRoute.home:
          Get.offAllNamed(Routes.home);
          break;
        case PostLoginRoute.verifyEmail:
          Get.offAllNamed(Routes.verifyEmail);
          break;
        case PostLoginRoute.completeProfile:
          Get.offAllNamed(
            Routes.home,
            arguments: const HomeNavConfig(initialIndex: 3, lockedIndex: 3),
          );
          break;
      }
    } finally {
      _navigating = false;
    }
  }

  @override
  Widget build(BuildContext context) => const Scaffold(
    body: SafeArea(child: Center(child: CircularProgressIndicator())),
  );
}
