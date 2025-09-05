import 'package:get/get.dart';
import '../../../data/models/onboarding_model.dart';

class OnboardingController extends GetxController {
  var currentPage = 0.obs;

  List<OnboardingModel> onboardingList = [
    OnboardingModel(
      image: 'assets/images/onboarding1.png',
      title: 'Welcome to E-Services',
      description: 'Access your university services with ease and convenience.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding2.png',
      title: 'Manage Transactions',
      description: 'Submit, track and manage your requests online.',
    ),
    OnboardingModel(
      image: 'assets/images/onboarding3.png',
      title: 'Stay Updated',
      description: 'Get instant updates about your applications and status.',
    ),
  ];
}
