import 'package:e_services_app/app/data/services/request_service.dart';
import 'package:e_services_app/app/modules/requests/models/request_model.dart';
import 'package:e_services_app/app/modules/requests/models/request_status.dart';
import 'package:e_services_app/utils/error_utils.dart';
import 'package:get/get.dart';

class RequestsController extends GetxController {
  final isLoading = false.obs;
  final errorMessage = RxnString();
  final requests = <RequestModel>[].obs;
  final selectedStatus = RequestStatus.all.obs;

  @override
  void onInit() {
    super.onInit();
    fetchRequests();
  }

  Future<void> fetchRequests({RequestStatus? status}) async {
    final target = status ?? selectedStatus.value;
    selectedStatus.value = target;
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await RequestService.fetchRequests(target);
      requests.assignAll(data);
    } catch (e) {
      final msg = resolveErrorMessage(err: e);
      errorMessage.value = msg;
      showErrorSnack(err: e, message: msg);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refresh() async {
    await fetchRequests();
  }

  void setStatus(RequestStatus status) {
    if (status == selectedStatus.value) return;
    fetchRequests(status: status);
  }
}
