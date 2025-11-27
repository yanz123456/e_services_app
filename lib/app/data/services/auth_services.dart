import 'package:e_services_app/app/data/models/authentication_model.dart';
import 'package:e_services_app/app/routes/app_pages.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';
import '../providers/api_provider.dart';

enum PostLoginRoute { home, verifyEmail, completeProfile }

class AuthService {
  AuthService._();
  static final _box = GetStorage();
  static const _kToken = 'auth_token', _kUser = 'auth_user';

  static String? get token => _box.read<String>(_kToken);
  static bool get isLoggedIn => (token ?? '').isNotEmpty;

  static UserModel? get user {
    final m = _box.read(_kUser);
    return (m is Map && m.isNotEmpty) ? UserModel.fromJson(Map<String, dynamic>.from(m)) : null;
  }

  static Future<void> bootstrap() async {
    _setAuthHeader(token);
    _installInterceptor(ApiProvider.dio);
  }

  static Future<void> saveToken(String? t) async {
    if (t == null || t.isEmpty) {
      await _box.remove(_kToken);
      _setAuthHeader(null);
      return;
    }
    await _box.write(_kToken, t);
    _setAuthHeader(t);
  }

  static Future<void> saveUser(UserModel? u) async {
    if (u == null) {
      await _box.remove(_kUser);
    } else {
      await _box.write(_kUser, {'id': u.id, 'name': u.name, 'email': u.email});
    }
  }

  static void _setAuthHeader(String? t) {
    final d = ApiProvider.dio;
    if (t == null || t.isEmpty) {
      d.options.headers.remove('Authorization');
    } else {
      d.options.headers['Authorization'] = 'Bearer $t';
    }
  }

  static void _installInterceptor(Dio d) {
    if (d.interceptors.any((i) => i is _AuthInterceptor)) return;
    d.interceptors.add(_AuthInterceptor());
  }

  static Future<LoginResponse> login(LoginRequest req) async {
    final res = await ApiProvider.dio.post('/api/login', data: req.toJson());
    if (res.statusCode == 200) {
      final lr = LoginResponse.fromJson(res.data);
      await saveToken(lr.token);
      await saveUser(lr.user);
      return lr;
    }
    throw DioException(
      requestOptions: res.requestOptions,
      response: res,
      message: (res.data is Map ? res.data['message'] : res.statusMessage)?.toString(),
    );
  }

  static Future<void> logout({bool remote = true}) async {
    try {
      if (remote && isLoggedIn) {
        await ApiProvider.dio.post('/api/logout');
      }
    } catch (_) {}
    await saveToken(null);
    await saveUser(null);
  }

  static Future<UserModel?> currentUser() async {
    if (!isLoggedIn) return null;
    final res = await ApiProvider.dio.get('/api/me');
    if (res.statusCode == 200) {
      final u = UserModel.fromJson(res.data);
      await saveUser(u);
      return u;
    }
    return user;
  }

  // ====== NEW: call protected /api/me (behind api.verified.email + api.user.complete.form) ======
  static Future<PostLoginRoute> postLoginGate() async {
    final r = await ApiProvider.dio.get('/api/me');
    final sc = r.statusCode ?? 0;
    final code = (r.data is Map) ? (r.data['code']?.toString()) : null;
    if (sc == 200) return PostLoginRoute.home;
    if (sc == 403 && code == 'email_unverified') return PostLoginRoute.verifyEmail;
    if ((sc == 428 || sc == 409) && code == 'profile_incomplete') return PostLoginRoute.completeProfile;
    return PostLoginRoute.home; // fallback
  }

  static void ensureLoggedIn() {
    if (!isLoggedIn) throw StateError('Not authenticated');
  }

  static Future<void> resendVerification() async {
    await ApiProvider.dio.post('/api/email/resend');
  }

  static Future<bool> checkVerified() async {
    final r = await ApiProvider.dio.get('/api/me');
    return (r.statusCode ?? 0) == 200;
  }

  static Future<void> forgotPassword(String identifier) async {
    await ApiProvider.dio.post('/api/password/forgot', data: {'identifier': identifier});
    // change field/endpoint if your API expects { email: ... } or a different route
  }
}

class _AuthInterceptor extends Interceptor {
  static bool _navBusy = false;

  @override
  void onRequest(RequestOptions o, RequestInterceptorHandler h) {
    final t = AuthService.token;
    if (t != null && t.isNotEmpty) o.headers['Authorization'] = 'Bearer $t';
    h.next(o);
  }

  @override
  void onResponse(Response r, ResponseInterceptorHandler h) async {
    final sc = r.statusCode ?? 0;
    final code = (r.data is Map) ? r.data['code']?.toString() : null;

    if (sc == 401) {
      await AuthService.logout(remote: false);
    }

    if (sc == 403 && code == 'email_unverified') {
      // No isNavigating check – just use a simple guard + route equality
      if (!_navBusy && Get.currentRoute != Routes.verifyEmail) {
        _navBusy = true;
        Future.microtask(() => Get.offAllNamed(Routes.verifyEmail)).whenComplete(() => _navBusy = false);
      }
    }

    // Optional: handle incomplete profile similarly
    // if ((sc == 428 || sc == 409) && code == 'profile_incomplete' && Get.currentRoute != Routes.completeProfile) { ... }

    h.next(r);
  }

  @override
  void onError(DioException e, ErrorInterceptorHandler h) async {
    if (e.response?.statusCode == 401) {
      await AuthService.logout(remote: false);
    }
    h.next(e);
  }
}
