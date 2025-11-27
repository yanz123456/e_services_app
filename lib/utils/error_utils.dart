import 'package:dio/dio.dart';
import 'package:get/get.dart';

String _resolveError({Object? err, String? message, String fallback = 'Something went wrong. Please try again.'}) {
  if (message != null && message.trim().isNotEmpty) return message;
  if (err is DioException) {
    final t = err.type, d = err.response?.data;
    if (t == DioExceptionType.connectionTimeout ||
        t == DioExceptionType.sendTimeout ||
        t == DioExceptionType.receiveTimeout)
      return 'Connection timed out. Please check your internet.';
    if (t == DioExceptionType.connectionError) return 'No internet connection. Please try again.';
    if (t == DioExceptionType.cancel) return 'Request was cancelled.';
    if (t == DioExceptionType.badCertificate) return 'Secure connection failed.';
    if (t == DioExceptionType.badResponse) {
      if (d is Map && d['message'] is String && d['message'].toString().trim().isNotEmpty) return d['message'];
      if (d is Map && d['error'] is String && d['error'].toString().trim().isNotEmpty) return d['error'];
      if (d is Map && d['errors'] is Map && (d['errors'] as Map).isNotEmpty) {
        final first = (d['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
      if (d is String && d.trim().isNotEmpty) return d;
      return 'Server returned an error (${err.response?.statusCode ?? 'unknown'}).';
    }
    if (d is Map && d['message'] is String && d['message'].toString().trim().isNotEmpty) return d['message'];
    if (d is String && d.trim().isNotEmpty) return d;
  }
  return fallback;
}

String resolveErrorMessage({Object? err, String? message, String fallback = 'Something went wrong. Please try again.'}) =>
    _resolveError(err: err, message: message, fallback: fallback);

void hideSnackbars() {
  if (Get.isSnackbarOpen) Get.closeAllSnackbars(); // or Get.closeCurrentSnackbar();
}

void showErrorSnack({
  Object? err,
  String? message,
  String title = 'Error',
  int seconds = 4,
  String fallback = 'Something went wrong. Please try again.',
  bool replace = true, // <-- close current snackbars first
}) {
  if (replace) hideSnackbars();
  Get.snackbar(
    title,
    _resolveError(err: err, message: message, fallback: fallback),
    snackPosition: SnackPosition.BOTTOM,
    duration: Duration(seconds: seconds),
  );
}
