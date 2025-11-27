import 'package:e_services_app/app/data/services/theme_service.dart';
import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Get.find<ThemeService>();
    return Padding(
      padding: AppSpacing.page,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            child: Obx(() {
              final isDark = themeService.rxThemeMode.value == ThemeMode.dark;
              return SwitchListTile(
                title: const Text('Dark Mode'),
                subtitle: const Text('Reduce glare with a darker palette'),
                value: isDark,
                onChanged: (value) => themeService.toggleTheme(value),
              );
            }),
          ),
          const SizedBox(height: 24),
          Text(
            'Manage your account details, security, and preferences here.',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Obx(() {
            final isLoading = controller.isLoggingOut.value;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : controller.logout,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Logout'),
              ),
            );
          }),
        ],
      ),
    );
  }
}
