import 'package:shared_preferences/shared_preferences.dart';
import 'api_client.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // 로그인 여부
  Future<bool> get isLoggedIn async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('access_token') != null;
  }

  // 저장된 사용자 ID
  Future<String?> get userId async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('user_id');
  }

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String nickname,
  }) async {
    final data = await apiPost<Map>('/auth/register', data: {
      'email': email,
      'password': password,
      'nickname': nickname,
    });
    await _saveTokens(data);
    return Map<String, dynamic>.from(data);
  }

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final data = await apiPost<Map>('/auth/login', data: {
      'email': email,
      'password': password,
    });
    await _saveTokens(data);
    return Map<String, dynamic>.from(data);
  }

  // 소셜 로그인 (카카오/구글 SDK가 제공한 사용자 정보를 전달)
  Future<Map<String, dynamic>> socialLogin({
    required String provider,
    required String socialId,
    required String nickname,
    String? email,
  }) async {
    final data = await apiPost<Map>('/auth/social', data: {
      'provider': provider,
      'socialId': socialId,
      'nickname': nickname,
      if (email != null) 'email': email,
    });
    await _saveTokens(data);
    return Map<String, dynamic>.from(data);
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString('refresh_token');
    try {
      await apiPost('/auth/logout', data: {'refreshToken': refreshToken});
    } catch (_) {}
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('user_id');
  }

  Future<void> _saveTokens(Map data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token',  data['accessToken']  as String);
    await prefs.setString('refresh_token', data['refreshToken'] as String);
    final user = data['user'] as Map?;
    if (user != null) {
      await prefs.setString('user_id', user['id'] as String);
    }
  }
}
