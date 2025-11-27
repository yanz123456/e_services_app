import 'package:dio/dio.dart';
import 'package:e_services_app/app/data/providers/api_provider.dart';
import 'package:e_services_app/app/modules/requests/models/request_model.dart';
import 'package:e_services_app/app/modules/requests/models/request_status.dart';

class RequestService {
  RequestService._();

  static Future<List<RequestModel>> fetchRequests(RequestStatus status) async {
    final res = await ApiProvider.dio.get(status.path);
    if ((res.statusCode ?? 0) == 200) {
      final data = res.data is Map ? (res.data['data'] ?? res.data) : null;
      final list = data is Map ? data['requests'] : null;
      if (list is List) {
        return list
            .whereType<Map>()
            .map((item) => RequestModel.fromJson(Map<String, dynamic>.from(item)))
            .toList();
      }
      return const [];
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: (res.data is Map ? res.data['message'] : res.statusMessage)?.toString(),
    );
  }
}
