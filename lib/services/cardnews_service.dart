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

  // 좋아요 토글 → liked 여부 + 최신 카운트
  Future<({bool liked, int likeCount})> toggleLike(String id) async {
    final data = await apiPost<Map>('/cardnews/$id/like');
    return (
      liked:     data['liked']      as bool,
      likeCount: (data['like_count'] as num).toInt(),
    );
  }

  // 즐겨찾기 토글 → bookmarked 여부
  Future<bool> toggleBookmark(String id) async {
    final data = await apiPost<Map>('/cardnews/$id/bookmark');
    return data['bookmarked'] as bool;
  }
}
