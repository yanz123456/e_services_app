import 'package:e_services_app/app/modules/cart/views/cart_view.dart';
import 'package:e_services_app/app/modules/home/models/home_nav_config.dart';
import 'package:e_services_app/app/modules/home/views/widgets/home_dashboard.dart';
import 'package:e_services_app/app/modules/home/widgets/home_bottom_nav.dart';
import 'package:e_services_app/app/modules/profile/views/profile_view.dart';
import 'package:e_services_app/app/modules/requests/controllers/requests_controller.dart';
import 'package:e_services_app/app/modules/requests/models/request_status.dart';
import 'package:e_services_app/app/modules/requests/views/requests_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter/services.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final List<HomeNavItem> _items = const [
    HomeNavItem(label: 'Home', icon: Iconsax.home_2),
    HomeNavItem(label: 'Requests', icon: Iconsax.activity),
    HomeNavItem(label: 'Cart', icon: Iconsax.shopping_cart5),
    HomeNavItem(label: 'Profile', icon: Iconsax.user),
  ];

  late final HomeNavConfig _navConfig;
  late int _currentIndex;

  int? get _lockedIndex => _navConfig.lockedIndex;

  @override
  void initState() {
    super.initState();
    final args = Get.arguments;
    _navConfig = args is HomeNavConfig ? args : const HomeNavConfig();
    _currentIndex = _lockedIndex ?? _navConfig.initialIndex;
  }

  Widget _buildBody(BuildContext context) {
    switch (_currentIndex) {
      case 0:
        return HomeDashboard(onSummaryTap: _openRequests);
      case 1:
        return const RequestsView();
      case 2:
        return const CartView();
      case 3:
        return const ProfileView();
      default:
        return const SizedBox.shrink();
    }
  }

  void _handleNavChange(int index) {
    if (_lockedIndex != null && index != _lockedIndex) return;
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _openRequests(RequestStatus status) {
    final controller = Get.find<RequestsController>();
    setState(() => _currentIndex = 1);
    controller.setStatus(status);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isHome = _currentIndex == 0;
    final SystemUiOverlayStyle overlayStyle = isHome
        ? SystemUiOverlayStyle.light.copyWith(statusBarColor: Colors.transparent)
        : (theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light.copyWith(
                statusBarColor: Colors.transparent,
                statusBarIconBrightness: Brightness.light,
                statusBarBrightness: Brightness.dark,
              )
            : SystemUiOverlayStyle.dark.copyWith(
                statusBarColor: theme.colorScheme.surfaceContainerLowest,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light,
              ));

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: overlayStyle,
        child: Stack(
          children: [SafeArea(top: !isHome, bottom: true, child: _buildBody(context))],
        ),
      ),
      bottomNavigationBar: HomeBottomNavBar(
        items: _items,
        currentIndex: _currentIndex,
        lockedIndex: _lockedIndex,
        onChanged: _handleNavChange,
      ),
    );
  }
}
