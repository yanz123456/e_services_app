// main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

import 'package:e_services_app/app/data/services/auth_services.dart';
import 'package:e_services_app/app/data/services/connectivity_services.dart';
import 'package:e_services_app/app/data/services/theme_service.dart';

import 'app/config/theme/app_theme.dart';
import 'app/modules/no_internet/views/no_internet_view.dart';
import 'app/routes/app_pages.dart';
import 'app/widgets/pnu_loader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  await AuthService.bootstrap(); // reapplies token header + interceptor

  // GetStorage().write('seenOnboarding', false);

  // debugPrint("bryan ${GetStorage().read('seenOnboarding')}");

  // init services before UI
  await Get.putAsync<ConnectivityService>(() => ConnectivityService().init());
  await Get.putAsync<ThemeService>(() async => ThemeService().init());

  // Toggle this to force dark mode for quick testing
  Get.changeThemeMode(ThemeMode.light);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final conn = Get.find<ConnectivityService>();
    final themeService = Get.find<ThemeService>();
    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: Routes.gate,
        getPages: AppPages.routes,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: themeService.rxThemeMode.value,
        builder: (context, child) => Obx(() {
          if (!conn.hasStatus) return const PnuLoader();
          if (!conn.isOnline) return const NoInternetView(); // offline gate
          return child ?? const SizedBox.shrink();
        }),
      ),
    );
  }
}
