import 'api_client.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  Future<Map<String, dynamic>> getMe() async {
    return Map<String, dynamic>.from(await apiGet('/users/me'));
  }

  // 홈 요약: 잔액 + 오늘 걸음수 + 출석 여부
  Future<Map<String, dynamic>> getSummary() async {
    return Map<String, dynamic>.from(await apiGet('/users/summary'));
  }

  Future<Map<String, dynamic>> updateProfile({
    String? nickname,
    String? birthDate,
    String? gender,
    String? city,
  }) async {
    return Map<String, dynamic>.from(await apiPut('/users/me', data: {
      if (nickname  != null) 'nickname':   nickname,
      if (birthDate != null) 'birth_date': birthDate,
      if (gender    != null) 'gender':     gender,
      if (city      != null) 'city':       city,
    }));
  }
}
