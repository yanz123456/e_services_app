class RequestModel {
  final int id;
  final String transactionId;
  final String remarks;
  final double amountToPay;
  final double amountPaid;
  final String? medium;
  final String? officeName;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const RequestModel({
    required this.id,
    required this.transactionId,
    required this.remarks,
    required this.amountToPay,
    required this.amountPaid,
    required this.createdAt,
    this.medium,
    this.officeName,
    this.updatedAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
        id: _toInt(json['id']),
        transactionId: (json['transaction_id'] ?? '').toString(),
        remarks: (json['remarks'] ?? '').toString(),
        amountToPay: _toDouble(json['amount_to_pay']),
        amountPaid: _toDouble(json['amount_paid']),
        medium: json['medium']?.toString(),
        officeName: json['office'] is Map ? (json['office']['description']?.toString()) : null,
        createdAt: _parseDate(json['created_at']),
        updatedAt: json['updated_at'] != null ? _parseDate(json['updated_at']) : null,
      );

  static int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) return DateTime.tryParse(value) ?? DateTime.now();
    return DateTime.now();
  }
}
