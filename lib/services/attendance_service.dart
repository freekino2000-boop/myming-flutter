import 'api_client.dart';

class AttendanceService {
  AttendanceService._();
  static final AttendanceService instance = AttendanceService._();

  // 이번 달 출석 날짜 목록 + 오늘 출석 여부
  Future<({List<String> dates, bool attendedToday})> getMonth() async {
    final data = await apiGet<Map>('/attendance');
    return (
      dates:        List<String>.from(data['dates'] as List),
      attendedToday: data['attended_today'] as bool,
    );
  }

  // 출석 체크 → 보상 + 최신 잔액 반환
  Future<({int reward, double balance})> check() async {
    final data = await apiPost<Map>('/attendance/check');
    return (
      reward:  (data['reward']  as num).toInt(),
      balance: (data['balance'] as num).toDouble(),
    );
  }
}
