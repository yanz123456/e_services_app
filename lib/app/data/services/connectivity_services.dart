// connectivity_service.dart
import 'dart:async';
import 'package:get/get.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class ConnectivityService extends GetxService {
  final _connectivity = Connectivity();
  final _internet = InternetConnection();
  final RxnBool _device = RxnBool(null), _access = RxnBool(null);

  bool get hasStatus => _device.value != null && _access.value != null;
  bool get isOnline => _device.value == true && _access.value == true;

  StreamSubscription<bool>? _connSub;
  StreamSubscription<InternetStatus>? _netSub;

  static Future<ConnectivityService> ensure() => Get.putAsync<ConnectivityService>(() => ConnectivityService().init());

  Future<ConnectivityService> init() async {
    final now = await _connectivity.checkConnectivity();
    _device.value = now.isNotEmpty && now.first != ConnectivityResult.none;
    _access.value = await _internet.hasInternetAccess;

    _connSub = _connectivity.onConnectivityChanged
        .map((r) => r.isNotEmpty && r.first != ConnectivityResult.none)
        .distinct()
        .listen((v) async {
          _device.value = v;
          if (v) _access.value = await _internet.hasInternetAccess;
        });

    _netSub = _internet.onStatusChange.distinct().listen((s) => _access.value = s == InternetStatus.connected);

    return this;
  }

  @override
  void onClose() {
    _connSub?.cancel();
    _netSub?.cancel();
    super.onClose();
  }
}
