import 'package:dio/dio.dart';
import 'package:e_services_app/app/config/app_config.dart';

class ApiProvider {
  ApiProvider._();
  static final dio = Dio(
    BaseOptions(
      baseUrl: AppConfig.apiBaseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Accept': 'application/json'},
      validateStatus: (s) => s != null && s >= 200 && s < 500,
    ),
  );
}
