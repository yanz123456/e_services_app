import 'package:e_services_app/utils/ui_tokens.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final pageController = PageController();

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Optional: Skip button
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: controller.skip,
                style: TextButton.styleFrom(foregroundColor: AppColors.brandingPrimaryTextColor),
                child: const Text('Skip'),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: controller.onboardingList.length,
                onPageChanged: (index) => controller.currentPage.value = index,
                itemBuilder: (context, index) {
                  final item = controller.onboardingList[index];
                  return Padding(
                    padding: AppSpacing.page,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(item.image, height: 300),
                        const SizedBox(height: 40),
                        Text(
                          item.title,
                          style: TextStyle(color: AppColors.textApp, fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          item.description,
                          style: TextStyle(color: AppColors.textApp, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.onboardingList.length,
                  (index) => Container(
                    margin: AppSpacing.dotMargin,
                    width: controller.currentPage.value == index ? 12 : 8,
                    height: controller.currentPage.value == index ? 12 : 8,
                    decoration: BoxDecoration(
                      color: controller.currentPage.value == index ? AppColors.brandingPrimaryColor : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Obx(
                () => SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandingPrimaryColor),
                    onPressed: () => controller.next(pageController),
                    child: Text(
                      controller.currentPage.value == controller.onboardingList.length - 1 ? 'Get Started' : 'Next',
                      style: TextStyle(color: AppColors.textWhiteStatic),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
