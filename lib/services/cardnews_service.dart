import 'dart:convert';
import '../models/card_news_model.dart';
import 'api_client.dart';

class CardNewsService {
  CardNewsService._();
  static final CardNewsService instance = CardNewsService._();

  // ── API 응답 → CardNews 객체 변환 ─────────────────────────
  static CardNews fromJson(Map<String, dynamic> d) {
    // keywords: DB에 JSON 문자열로 저장 → List<String>
    List<String> keywords = [];
    try {
      final raw = d['keywords'];
      if (raw is List) {
        keywords = raw.cast<String>();
      } else if (raw is String && raw.isNotEmpty) {
        keywords = (jsonDecode(raw) as List).cast<String>();
      }
    } catch (_) {}

    final category = {
      'economy': NewsCategory.economy,
      'realty':  NewsCategory.realty,
      'issue':   NewsCategory.issue,
      'tenancy': NewsCategory.tenancy,
    }[(d['category'] as String?) ?? 'economy'] ?? NewsCategory.economy;

    final tier = ((d['tier'] as String?) ?? 'weekly') == 'top3'
        ? NewsTier.top3
        : NewsTier.weekly;

    // published_at → "N시간 전" 형식
    final published = DateTime.tryParse((d['published_at'] as String?) ?? '');
    String time = '방금 전';
    if (published != null) {
      final diff = DateTime.now().difference(published);
      if (diff.inDays >= 1)       time = '${diff.inDays}일 전';
      else if (diff.inHours >= 1) time = '${diff.inHours}시간 전';
      else                        time = '${diff.inMinutes}분 전';
    }

    final news = CardNews(
      id:        d['id'] as String,
      tier:      tier,
      rank:      d['rank'] as int?,
      category:  category,
      emoji:     (d['emoji'] as String?) ?? '📰',
      keywords:  keywords,
      stat:      (d['stat'] as String?) ?? '',
      headline:  (d['title'] as String?) ?? '',
      summary:   (d['summary'] as String?) ?? '',
      content:   (d['body'] as String?) ?? '',
      time:      time,
      likes:     (d['like_count'] as num?)?.toInt()
                 ?? (d['likes'] as num?)?.toInt() ?? 0,
      bookmarks: (d['bookmark_count'] as num?)?.toInt()
                 ?? (d['scraps'] as num?)?.toInt() ?? 0,
      isNew:     published != null &&
                 DateTime.now().difference(published).inHours < 12,
    );
    news.isRead       = (d['is_read']       as bool?) ?? false;
    news.isLiked      = (d['is_liked']      as bool?) ?? false;
    news.isBookmarked = (d['is_bookmarked'] as bool?) ?? false;
    return news;
  }

  // ── 카드뉴스 목록 ─────────────────────────────────────────
  Future<List<CardNews>> getList({String? category}) async {
    final list = await apiGet<List>('/cardnews', params: {
      if (category != null) 'category': category,
    });
    return list
        .map((e) => fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  // ── 기사 읽기 → 보상 + 최신 잔액 ─────────────────────────
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

  // ── 좋아요 토글 ───────────────────────────────────────────
  Future<({bool liked, int likeCount})> toggleLike(String id) async {
    final data = await apiPost<Map>('/cardnews/$id/like');
    return (
      liked:     data['liked']       as bool,
      likeCount: (data['like_count'] as num).toInt(),
    );
  }

  // ── 즐겨찾기 토글 ─────────────────────────────────────────
  Future<bool> toggleBookmark(String id) async {
    final data = await apiPost<Map>('/cardnews/$id/bookmark');
    return data['bookmarked'] as bool;
  }
}
