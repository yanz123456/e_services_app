import 'dart:math' as math;

import 'package:e_services_app/app/data/services/transaction_service.dart';
import 'package:e_services_app/app/modules/home/models/home_dashboard_models.dart';
import 'package:e_services_app/utils/error_utils.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  static const int _pageSize = 10;

  final isLoading = false.obs;
  final isRefreshing = false.obs;
  final errorMessage = RxnString();
  final tabIndex = 0.obs;
  final switchingProfileId = RxnInt();

  final profiles = <ProfileModel>[].obs;
  final transactions = <TransactionModel>[].obs;
  final packages = <PackageModel>[].obs;
  final offices = <OfficeModel>[].obs;
  final requestCounts = Rxn<RequestCounts>();
  final activeProfile = Rxn<ProfileModel>();
  final searchQuery = ''.obs;
  final selectedOfficeId = RxnInt();
  final visibleTransactionCount = _pageSize.obs;
  final showFilters = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDashboard();
  }

  Future<void> fetchDashboard({int? userDataId, bool showLoader = true}) async {
    if (isLoading.value || isRefreshing.value) return;
    errorMessage.value = null;

    if (showLoader) {
      isLoading.value = true;
    } else {
      isRefreshing.value = true;
    }

    try {
      final data = await TransactionService.fetchDashboard(profileId: userDataId);
      profiles.assignAll(data.profiles);
      activeProfile.value = data.activeProfile;
      requestCounts.value = data.requestCounts;
      transactions.assignAll(data.transactions);
      packages.assignAll(data.packages);
      offices.assignAll(data.offices);
      selectedOfficeId.value = null;
      searchQuery.value = '';
      _resetPagination();
    } catch (e) {
      final msg = resolveErrorMessage(err: e);
      errorMessage.value = msg;
      showErrorSnack(err: e, message: msg);
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  Future<void> refresh() async {
    await fetchDashboard(userDataId: activeProfile.value?.id, showLoader: false);
  }

  Future<void> selectProfile(ProfileModel profile) async {
    if (profile.id == activeProfile.value?.id) return;
    switchingProfileId.value = profile.id;
    try {
      await TransactionService.switchProfile(profile.id);
      await fetchDashboard(userDataId: profile.id, showLoader: false);
    } catch (e) {
      final msg = resolveErrorMessage(err: e);
      showErrorSnack(err: e, message: msg);
    } finally {
      switchingProfileId.value = null;
    }
  }

  void selectTab(int index) {
    if (tabIndex.value == index) return;
    tabIndex.value = index;
  }

  void setSearch(String value) {
    searchQuery.value = value;
    _resetPagination();
  }

  void setOfficeFilter(int? officeId) {
    selectedOfficeId.value = officeId;
    _resetPagination();
  }

  void toggleFilters() => showFilters.value = !showFilters.value;
  void hideFilters() => showFilters.value = false;

  List<TransactionModel> get filteredTransactions {
    final query = searchQuery.value.toLowerCase();
    final officeId = selectedOfficeId.value;
    final source = List<TransactionModel>.from(transactions);
    return source.where((t) {
      final matchesQuery = query.isEmpty ||
          t.description.toLowerCase().contains(query) ||
          (t.office?.description.toLowerCase().contains(query) ?? false);
      final matchesOffice = officeId == null || t.office?.id == officeId;
      return matchesQuery && matchesOffice;
    }).toList();
  }

  List<TransactionModel> get paginatedTransactions {
    final filtered = filteredTransactions;
    if (filtered.isEmpty) return filtered;
    final takeCount = math.min(filtered.length, visibleTransactionCount.value);
    return filtered.take(takeCount).toList();
  }

  bool get canLoadMoreTransactions => visibleTransactionCount.value < filteredTransactions.length;

  void loadMoreTransactions() {
    if (!canLoadMoreTransactions) return;
    final filteredLength = filteredTransactions.length;
    visibleTransactionCount.value = math.min(filteredLength, visibleTransactionCount.value + _pageSize);
  }

  void _resetPagination() {
    visibleTransactionCount.value = _pageSize;
  }

  List<dynamic> get currentItems => tabIndex.value == 0 ? paginatedTransactions : packages;
}
