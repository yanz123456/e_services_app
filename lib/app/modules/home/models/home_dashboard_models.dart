import 'package:e_services_app/app/modules/requests/models/request_status.dart';

class HomeDashboardData {
  final RequestCounts requestCounts;
  final List<ProfileModel> profiles;
  final ProfileModel activeProfile;
  final List<TransactionModel> transactions;
  final List<PackageModel> packages;
  final List<OfficeModel> offices;

  const HomeDashboardData({
    required this.requestCounts,
    required this.profiles,
    required this.activeProfile,
    required this.transactions,
    required this.packages,
    required this.offices,
  });

  factory HomeDashboardData.fromJson(Map<String, dynamic> json) {
    final profilesJson = (json['profiles'] as List?) ?? const [];
    final transactionsJson = (json['transactions'] as List?) ?? const [];
    final packagesJson = (json['packages'] as List?) ?? const [];
    final officesJson = (json['offices'] as List?) ?? const [];

    final profiles = profilesJson.map((e) => ProfileModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    final activeProfileJson = (json['active_profile'] as Map?) ?? <String, dynamic>{};

    return HomeDashboardData(
      requestCounts: RequestCounts.fromJson(Map<String, dynamic>.from((json['request_counts'] as Map?) ?? {})),
      profiles: profiles,
      activeProfile: ProfileModel.fromJson(Map<String, dynamic>.from(activeProfileJson)),
      transactions: transactionsJson
          .map((e) => TransactionModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
      packages:
          packagesJson.map((e) => PackageModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
      offices: officesJson.map((e) => OfficeModel.fromJson(Map<String, dynamic>.from(e as Map))).toList(),
    );
  }
}

class RequestCounts {
  final int pending;
  final int accepted;
  final int declined;
  final int paid;
  final int processed;
  final int completed;

  const RequestCounts({
    required this.pending,
    required this.accepted,
    required this.declined,
    required this.paid,
    required this.processed,
    required this.completed,
  });

  factory RequestCounts.fromJson(Map<String, dynamic> json) => RequestCounts(
        pending: _toInt(json['pendingCount']),
        accepted: _toInt(json['acceptedCount']),
        declined: _toInt(json['declinedCount']),
        paid: _toInt(json['paidCount']),
        processed: _toInt(json['processedCount']),
        completed: _toInt(json['completedCount']),
      );

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  List<RequestCountTile> get tiles => [
        RequestCountTile(label: 'Pending', value: pending, status: RequestStatus.pending),
        RequestCountTile(label: 'Accepted', value: accepted, status: RequestStatus.accepted),
        RequestCountTile(label: 'Declined', value: declined, status: RequestStatus.declined),
        RequestCountTile(label: 'Paid', value: paid, status: RequestStatus.paid),
        RequestCountTile(label: 'Processing', value: processed, status: RequestStatus.processed),
        RequestCountTile(label: 'Completed', value: completed, status: RequestStatus.completed),
      ];
}

class RequestCountTile {
  final String label;
  final int value;
  final RequestStatus status;
  const RequestCountTile({required this.label, required this.value, required this.status});
}

class ProfileModel {
  final int id;
  final String clientType;
  final String firstname;
  final String middlename;
  final String lastname;
  final String? studentNumber;
  final String? applicantNumber;
  final String? contactNumber;
  final String? programDegree;
  final String? cityAddress;
  final String? permanentAddress;

  const ProfileModel({
    required this.id,
    required this.clientType,
    required this.firstname,
    required this.middlename,
    required this.lastname,
    this.studentNumber,
    this.applicantNumber,
    this.contactNumber,
    this.programDegree,
    this.cityAddress,
    this.permanentAddress,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? 0}') ?? 0,
        clientType: (json['client_type'] ?? '').toString(),
        firstname: (json['firstname'] ?? '').toString(),
        middlename: (json['middlename'] ?? '').toString(),
        lastname: (json['lastname'] ?? '').toString(),
        studentNumber: (json['student_number'] ?? json['studentNumber'])?.toString(),
        applicantNumber: (json['applicant_number'] ?? json['applicantNumber'])?.toString(),
        contactNumber: json['contact_number']?.toString(),
        programDegree: json['program_degree']?.toString(),
        cityAddress: json['city_address']?.toString(),
        permanentAddress: json['permanent_address']?.toString(),
      );

  String get displayName => [firstname, middlename, lastname].where((e) => e.trim().isNotEmpty).join(' ').trim();

  String get identifier => studentNumber?.trim().isNotEmpty == true
      ? 'Student #$studentNumber'
      : (applicantNumber?.trim().isNotEmpty == true ? 'Applicant #$applicantNumber' : 'ID #$id');
}

class OfficeModel {
  final int id;
  final String description;
  final String? code;

  const OfficeModel({required this.id, required this.description, this.code});

  factory OfficeModel.fromJson(Map<String, dynamic> json) => OfficeModel(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? 0}') ?? 0,
        description: (json['description'] ?? '').toString(),
        code: json['office_code']?.toString(),
      );
}

class TransactionModel {
  final String accountCode;
  final String description;
  final double amount;
  final String? unit;
  final String? category;
  final String? transactionType;
  final String? availableTo;
  final bool withDocumentaryStamp;
  final OfficeModel? office;

  const TransactionModel({
    required this.accountCode,
    required this.description,
    required this.amount,
    this.unit,
    this.category,
    this.transactionType,
    this.availableTo,
    this.withDocumentaryStamp = false,
    this.office,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) => TransactionModel(
        accountCode: (json['account_code'] ?? '').toString(),
        description: (json['description'] ?? '').toString(),
        amount: _toDouble(json['amount']),
        unit: json['unit']?.toString(),
        category: json['category']?.toString(),
        transactionType: json['transaction_type']?.toString(),
        availableTo: json['available_to']?.toString(),
        withDocumentaryStamp: json['with_documentary_stamp'] == 1 || json['with_documentary_stamp'] == true,
        office: json['office'] is Map ? OfficeModel.fromJson(Map<String, dynamic>.from(json['office'] as Map)) : null,
      );

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }
}

class PackageModel {
  final int? id;
  final String? packageId;
  final String name;
  final String? inclusions;
  final String? remarks;
  final OfficeModel? office;

  const PackageModel({
    this.id,
    this.packageId,
    required this.name,
    this.inclusions,
    this.remarks,
    this.office,
  });

  factory PackageModel.fromJson(Map<String, dynamic> json) => PackageModel(
        id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id'] ?? 0}'),
        packageId: json['package_id']?.toString(),
        name: (json['package_name'] ?? '').toString(),
        inclusions: json['inclusions']?.toString(),
        remarks: json['remarks']?.toString(),
        office: json['office'] is Map ? OfficeModel.fromJson(Map<String, dynamic>.from(json['office'] as Map)) : null,
      );
}
