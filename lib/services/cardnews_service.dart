import 'api_client.dart';

class CardNewsService {
  CardNewsService._();
  static final CardNewsService instance = CardNewsService._();

  Future<List<Map<String, dynamic>>> getList({String? category}) async {
    final list = await apiGet<List>('/cardnews', params: {
      if (category != null) 'category': category,
    });
    return list.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  // 기사 읽기 → 보상 + 최신 잔액
  Future<({int reward, bool missionBonus, int readCount, double balance})> read(String id) async {
    final data = await apiPost<Map>('/cardnews/$id/read');
    return (
      reward:       (data['reward']       as num).toInt(),
      missionBonus: data['mission_bonus'] as bool? ?? false,
      readCount:    (data['read_count']   as num).toInt(),
      balance:      (data['balance']      as num).toDouble(),
    );
  }

  Future<({int readCount, bool missionDone})> getMissionStatus() async {
    final data = await apiGet<Map>('/cardnews/mission/status');
    return (
      readCount:   (data['read_count'] as num).toInt(),
      missionDone: data['mission_done'] as bool,
    );
  }
}
