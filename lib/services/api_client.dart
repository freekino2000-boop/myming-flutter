import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── 환경별 Base URL ───────────────────────────────────────
// Android 에뮬레이터 : 10.0.2.2 (호스트 루프백)
// iOS 시뮬레이터     : localhost
// 실기기(개발)       : 실제 서버 IP로 교체
String get kBaseUrl {
  if (kDebugMode) {
    if (kIsWeb) return 'http://localhost:3000/api';
    if (Platform.isIOS) return 'http://localhost:3000/api';
    return 'http://10.0.2.2:3000/api';
  }
  return 'https://myming2-api.onrender.com/api';
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  late final Dio _dio;
  bool _initialized = false;

  Dio get dio {
    if (!_initialized) _setup();
    return _dio;
  }

  void _setup() {
    _dio = Dio(BaseOptions(
      baseUrl: kBaseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ));

    _dio.interceptors.add(_AuthInterceptor(_dio));

    // 개발 빌드에서만 요청 로그 출력
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(requestBody: true, responseBody: false, error: true),
      );
    }

    _initialized = true;
  }
}

// JWT 자동 첨부 + 만료 시 refresh
class _AuthInterceptor extends Interceptor {
  final Dio _dio;
  bool _refreshing = false;

  _AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('access_token');
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_refreshing) {
      _refreshing = true;
      try {
        final prefs        = await SharedPreferences.getInstance();
        final refreshToken = prefs.getString('refresh_token');
        if (refreshToken == null) { _refreshing = false; return handler.next(err); }

        final resp = await Dio().post('$kBaseUrl/auth/refresh', data: {'refreshToken': refreshToken});
        final newToken = resp.data['accessToken'] as String;
        await prefs.setString('access_token', newToken);

        // 원래 요청 재시도
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer $newToken';
        final retry = await _dio.fetch(opts);
        _refreshing = false;
        return handler.resolve(retry);
      } catch (_) {
        _refreshing = false;
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('access_token');
        await prefs.remove('refresh_token');
      }
    }
    handler.next(err);
  }
}

// ── 편의 래퍼 ─────────────────────────────────────────────
final _dio = ApiClient.instance.dio;

Future<T> apiGet<T>(String path, {Map<String, dynamic>? params}) async {
  final res = await _dio.get(path, queryParameters: params);
  return res.data as T;
}

Future<T> apiPost<T>(String path, {dynamic data}) async {
  final res = await _dio.post(path, data: data);
  return res.data as T;
}

Future<T> apiPut<T>(String path, {dynamic data}) async {
  final res = await _dio.put(path, data: data);
  return res.data as T;
}
