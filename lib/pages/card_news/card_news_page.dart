import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' hide AppState;
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/card_news_model.dart';
import '../../services/ad_service.dart';
import '../../services/cardnews_service.dart';
import '../../theme/app_theme.dart';
import 'article_view_page.dart';

class CardNewsPage extends StatefulWidget {
  const CardNewsPage({super.key});

  @override
  State<CardNewsPage> createState() => _CardNewsPageState();
}

class _CardNewsPageState extends State<CardNewsPage> {
  NewsCategory? _filter;
  int _prevTabTrigger = 0;

  // API 모드일 때 서버에서 받은 목록
  List<CardNews>? _apiNewsList;
  bool _loading = false;

  BannerAd? _bannerAd;
  bool _bannerLoaded = false;

  // 현재 활성 목록 (API 우선, 없으면 목데이터)
  List<CardNews> get _allNews => _apiNewsList ?? kCardNewsList;

  List<CardNews> get _top3 {
    final list = _filter == null ? _allNews : _allNews.where((n) => n.category == _filter).toList();
    return list.where((n) => n.tier == NewsTier.top3).toList()
      ..sort((a, b) => (a.rank ?? 9).compareTo(b.rank ?? 9));
  }

  List<CardNews> get _weekly {
    final list = _filter == null ? _allNews : _allNews.where((n) => n.category == _filter).toList();
    return list.where((n) => n.tier == NewsTier.weekly).toList();
  }

  Future<void> _loadFromApi() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final news = await CardNewsService.instance.getList();
      if (mounted) setState(() { _apiNewsList = news; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _bannerAd = AdService.instance.createBannerAd(
      onLoaded: () { if (mounted) setState(() => _bannerLoaded = true); },
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // apiEnabled 상태가 true면 최초 1회 서버에서 로드
    if (context.read<AppState>().apiEnabled && _apiNewsList == null) {
      _loadFromApi();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final trigger = state.cardNewsTabTrigger;
    if (trigger != _prevTabTrigger) {
      _prevTabTrigger = trigger;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _filter = null);
      });
    }

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Flexible(
              child: Text('마이밍뉴스',
                  style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text, fontSize: 17),
                  overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('LIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.primary)),
            ),
          ],
        ),
        actions: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 72),
            child: TextButton(
              onPressed: () => Navigator.pushNamed(context, '/shop'),
              child: const Text('🎁 교환소',
                  style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13),
                  overflow: TextOverflow.ellipsis),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 배너 ──────────────────────────────────
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF1A4FA8), AppColors.primary],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('마이밍뉴스',
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: double.infinity,
                          child: Text(
                            '기사 3건 읽으면 +₩30 보너스!\n오늘의 핵심 경제·부동산 이슈를 빠르게 확인하세요 📊',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12, height: 1.5),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── 미션 바 ───────────────────────────────
                  GestureDetector(
                    onTap: () {
                      if (state.cnMissionDone) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('오늘의 미션을 이미 완료했습니다! ✅')));
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          const Text('🎯', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 10),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('오늘의 미션', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900)),
                              Text(
                                state.cnMissionDone
                                  ? '완료! 🎉 보너스 ₩30 적립됨'
                                  : '기사 3건 읽기 (${state.cnReadCount}/3 완료)',
                                style: AppTheme.caption,
                              ),
                            ],
                          )),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: state.cnMissionDone ? Colors.grey.shade100 : AppColors.primaryDim,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              state.cnMissionDone ? '완료' : '+₩30 받기',
                              style: TextStyle(
                                fontSize: 11, fontWeight: FontWeight.w700,
                                color: state.cnMissionDone ? AppColors.muted : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // ── 카테고리 탭 ───────────────────────────
                  SizedBox(
                    height: 36,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _CatChip(label: '🔥 전체',   selected: _filter == null,       onTap: () => setState(() => _filter = null)),
                        _CatChip(label: '💰 경제',   selected: _filter == NewsCategory.economy,  onTap: () => setState(() => _filter = NewsCategory.economy)),
                        _CatChip(label: '🏠 부동산', selected: _filter == NewsCategory.realty,   onTap: () => setState(() => _filter = NewsCategory.realty)),
                        _CatChip(label: '📢 이슈',   selected: _filter == NewsCategory.issue,    onTap: () => setState(() => _filter = NewsCategory.issue)),
                        _CatChip(label: '🏘 임차',   selected: _filter == NewsCategory.tenancy,  onTap: () => setState(() => _filter = NewsCategory.tenancy)),
                      ],
                    ),
                  ),

                  // ── 일간 탑3 ──────────────────────────────
                  if (_top3.isNotEmpty) ...[
                    const _SectionHeader(badge: '🔥 오늘의 탑3', desc: '가장 많이 읽은 기사', accent: Color(0xFFFF4B4B)),
                    ..._top3.map((news) => _Top3Card(news: news, onRead: () => _onRead(context, news))),
                  ],

                  // ── 배너 광고 ─────────────────────────────
                  if (_bannerLoaded && _bannerAd != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: SizedBox(
                        width: _bannerAd!.size.width.toDouble(),
                        height: _bannerAd!.size.height.toDouble(),
                        child: AdWidget(ad: _bannerAd!),
                      ),
                    ),

                  // ── 주간 핫뉴스 ───────────────────────────
                  if (_weekly.isNotEmpty) ...[
                    const _SectionHeader(badge: '📅 주간 핫뉴스', desc: '이번 주 화제의 뉴스', accent: AppColors.primary),
                    Container(
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      decoration: AppTheme.cardDecoration,
                      child: Column(
                        children: _weekly.map((news) => _WeeklyCard(
                          news: news, isLast: news == _weekly.last,
                          onRead: () => _onRead(context, news),
                        )).toList(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onRead(BuildContext context, CardNews news) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => ArticleViewPage(news: news)));
    if (mounted) setState(() {});
  }
}

// ── 섹션 헤더 ─────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String badge;
  final String desc;
  final Color accent;

  const _SectionHeader({required this.badge, required this.desc, required this.accent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              border: Border.all(color: accent.withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(badge, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: accent)),
          ),
          const SizedBox(width: 8),
          Text(desc, style: AppTheme.caption),
        ],
      ),
    );
  }
}

// ── 카테고리 칩 ───────────────────────────────────────────
class _CatChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _CatChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryDim : AppColors.card,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w700,
          color: selected ? AppColors.primary : AppColors.muted,
        )),
      ),
    );
  }
}

// ── Top3 카드 ─────────────────────────────────────────────
class _Top3Card extends StatelessWidget {
  final CardNews news;
  final VoidCallback onRead;

  const _Top3Card({required this.news, required this.onRead});

  @override
  Widget build(BuildContext context) {
    final rankColors = [null, const Color(0xFFFFD700), const Color(0xFFC0C0C0), const Color(0xFFCD7F32)];
    final rankTextColors = [null, const Color(0xFF7A5C00), Colors.grey.shade600, Colors.white];
    final r = news.rank ?? 1;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 행
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 0),
            child: Row(
              children: [
                CircleAvatar(radius: 14, backgroundColor: rankColors[r], child: Text('$r', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: rankTextColors[r]))),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: _catColor(news.category).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(6)),
                  child: Text(news.category.label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _catColor(news.category))),
                ),
                if (news.isNew) ...[
                  const SizedBox(width: 4),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: const Color(0x1AFF4B4B), borderRadius: BorderRadius.circular(5)), child: const Text('NEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFFF4B4B)))),
                ],
                const Spacer(),
                Text(news.time, style: AppTheme.caption),
              ],
            ),
          ),
          // 키워드
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Wrap(spacing: 5, children: news.keywords.map((k) => Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(5)), child: Text('#$k', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary)))).toList()),
          ),
          // 헤드라인
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
            child: Text(news.headline, style: AppTheme.headline2.copyWith(fontSize: 15), maxLines: 2, overflow: TextOverflow.ellipsis),
          ),
          // 수치 박스
          if (news.stat.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primaryDim, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                child: Text('📊 ${news.stat}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ),
            ),
          // 하단 버튼
          const Divider(height: 20, thickness: 1, indent: 14, endIndent: 14, color: AppColors.border),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  _ReactBtn('❤️', '${news.likesCount}'),
                  const SizedBox(width: 8),
                  _ReactBtn('🔖', '${news.bookmarksCount}'),
                ]),
                ElevatedButton(
                  onPressed: onRead,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: news.isRead ? AppColors.surface : AppColors.primary,
                    foregroundColor: news.isRead ? AppColors.primary : Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    elevation: 0,
                  ),
                  child: Text(news.isRead ? '📖 다시 보기' : '📺 광고보고 읽기 +₩10', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _catColor(NewsCategory cat) {
    switch (cat) {
      case NewsCategory.economy:  return AppColors.economy;
      case NewsCategory.realty:   return AppColors.realty;
      case NewsCategory.issue:    return AppColors.issue;
      case NewsCategory.tenancy:  return AppColors.tenancy;
    }
  }
}

class _ReactBtn extends StatelessWidget {
  final String icon;
  final String count;
  const _ReactBtn(this.icon, this.count);
  @override
  Widget build(BuildContext context) => Row(children: [Text(icon, style: const TextStyle(fontSize: 14)), const SizedBox(width: 3), Text(count, style: AppTheme.caption)]);
}

// ── 주간 카드 (리스트형) ──────────────────────────────────
class _WeeklyCard extends StatelessWidget {
  final CardNews news;
  final bool isLast;
  final VoidCallback onRead;

  const _WeeklyCard({required this.news, required this.isLast, required this.onRead});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onRead,
      child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 타일
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(news.emoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 12),
              // 본문
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), decoration: BoxDecoration(color: _catColor(news.category).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(5)), child: Text(news.category.label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _catColor(news.category)))),
                      const SizedBox(width: 6),
                      Text(news.time, style: AppTheme.caption.copyWith(fontSize: 10)),
                    ]),
                    const SizedBox(height: 4),
                    Wrap(spacing: 4, children: news.keywords.take(3).map((k) => Text('#$k', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.primary))).toList()),
                    const SizedBox(height: 4),
                    Text(news.headline, style: AppTheme.body.copyWith(fontWeight: FontWeight.w700, fontSize: 13), maxLines: 2, overflow: TextOverflow.ellipsis),
                    if (news.stat.isNotEmpty) Text('📊 ${news.stat}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.realty)),
                  ],
                ),
              ),
              // 읽기 버튼
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: onRead,
                style: ElevatedButton.styleFrom(
                  backgroundColor: news.isRead ? AppColors.surface : AppColors.primary,
                  foregroundColor: news.isRead ? AppColors.primary : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(news.isRead ? '다시보기' : '+₩10', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
        if (!isLast) const Divider(height: 1, thickness: 1, color: AppColors.border),
      ],
      ),
    );
  }

  Color _catColor(NewsCategory cat) {
    switch (cat) {
      case NewsCategory.economy:  return AppColors.economy;
      case NewsCategory.realty:   return AppColors.realty;
      case NewsCategory.issue:    return AppColors.issue;
      case NewsCategory.tenancy:  return AppColors.tenancy;
    }
  }
}
