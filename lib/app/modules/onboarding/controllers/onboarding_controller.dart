import 'package:e_services_app/app/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../data/models/onboarding_model.dart';

class OnboardingController extends GetxController {
  final currentPage = 0.obs;
  final _box = GetStorage();

  final onboardingList = <OnboardingModel>[
    OnboardingModel(
      image: 'assets/images/1.png',
      title: 'Welcome to E-Services',
      description: 'Access your university services with ease and convenience.',
    ),
    OnboardingModel(
      image: 'assets/images/2.png',
      title: 'Manage Transactions',
      description: 'Submit, track and manage your requests online.',
    ),
    OnboardingModel(
      image: 'assets/images/3.png',
      title: 'Stay Updated',
      description: 'Get instant updates about your applications and status.',
    ),
  ];

  void next(PageController pc) {
    if (currentPage.value == onboardingList.length - 1) {
      complete();
    } else {
      pc.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
    }
  }

  void skip() => complete();

  void complete() {
    _box.write('seenOnboarding', true);
    Get.offAllNamed(Routes.authentication);
  }
}
