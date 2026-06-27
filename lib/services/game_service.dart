import 'api_client.dart';

class GameService {
  GameService._();
  static final GameService instance = GameService._();

  // 게임별 랭킹 (상위 20명)
  Future<List<Map<String, dynamic>>> getRanking(String gameId) async {
    final data = await apiGet<Map>('/games/ranking/$gameId');
    return List<Map<String, dynamic>>.from(
      (data['ranking'] as List).map((e) => Map<String, dynamic>.from(e as Map)),
    );
  }

  // 점수 제출 → 보상 + 잔액 반환
  Future<({int reward, double balance})> submitScore(String gameId, int score) async {
    final data = await apiPost<Map>('/games/score', data: {
      'game_id': gameId,
      'score':   score,
    });
    return (
      reward:  (data['reward']  as num).toInt(),
      balance: (data['balance'] as num).toDouble(),
    );
  }
}
