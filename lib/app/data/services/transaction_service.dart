import 'package:dio/dio.dart';
import 'package:e_services_app/app/data/providers/api_provider.dart';
import 'package:e_services_app/app/modules/home/models/home_dashboard_models.dart';

class TransactionService {
  TransactionService._();

  static Future<HomeDashboardData> fetchDashboard({int? profileId}) async {
    final res = await ApiProvider.dio.get(
      '/api/transactions',
      queryParameters: profileId != null ? {'user_data_id': profileId} : null,
    );
    if ((res.statusCode ?? 0) == 200) {
      final data = res.data is Map ? (res.data['data'] ?? res.data) : null;
      if (data is Map) {
        return HomeDashboardData.fromJson(Map<String, dynamic>.from(data));
      }
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: (res.data is Map ? res.data['message'] : res.statusMessage)?.toString(),
    );
  }

  static Future<ProfileModel> switchProfile(int profileId) async {
    final res = await ApiProvider.dio.post(
      '/api/transactions/transact-using',
      data: {'user_data_id': profileId},
    );
    if ((res.statusCode ?? 0) == 200) {
      final data = res.data is Map ? (res.data['data'] ?? res.data) : null;
      if (data is Map && data['active_profile'] is Map) {
        return ProfileModel.fromJson(Map<String, dynamic>.from(data['active_profile'] as Map));
      }
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: (res.data is Map ? res.data['message'] : res.statusMessage)?.toString(),
    );
  }
}
