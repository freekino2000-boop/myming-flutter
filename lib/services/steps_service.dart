import 'api_client.dart';

class StepsService {
  StepsService._();
  static final StepsService instance = StepsService._();

  Future<int> getToday() async {
    final data = await apiGet<Map>('/steps/today');
    return (data['steps'] as num).toInt();
  }

  // 걸음수 동기화 → 증분 자동 적립, 최신 잔액 반환
  Future<({int steps, double balance})> sync(int steps) async {
    final data = await apiPost<Map>('/steps/sync', data: {'steps': steps});
    return (
      steps:   (data['steps']   as num).toInt(),
      balance: (data['balance'] as num).toDouble(),
    );
  }
}
