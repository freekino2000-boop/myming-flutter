import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../models/app_state.dart';
import '../../models/card_news_model.dart';
import '../../services/cardnews_service.dart';
import '../../theme/app_theme.dart';

class ArticleViewPage extends StatefulWidget {
  final CardNews news;
  const ArticleViewPage({super.key, required this.news});

  @override
  State<ArticleViewPage> createState() => _ArticleViewPageState();
}

class _ArticleViewPageState extends State<ArticleViewPage> {
  final _scrollController = ScrollController();
  bool _earned = false;

  late bool _isLiked;
  late bool _isBookmarked;
  late int  _likesCount;

  @override
  void initState() {
    super.initState();
    _isLiked      = widget.news.isLiked;
    _isBookmarked = widget.news.isBookmarked;
    _likesCount   = widget.news.likesCount;

    if (!widget.news.isRead) {
      _scrollController.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_earned || widget.news.isRead) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent * 0.9) {
      _markRead();
    }
  }

  void _markRead() {
    if (_earned || widget.news.isRead) return;
    setState(() {
      _earned = true;
      widget.news.isRead = true;
    });
    final state = context.read<AppState>();
    state.readCNArticle(widget.news.id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('₩10 적립! 기사를 다 읽었어요 🎉'), duration: Duration(seconds: 2)),
    );
  }

  // ── 좋아요 ────────────────────────────────────────────────
  Future<void> _toggleLike() async {
    final prev      = _isLiked;
    final prevCount = _likesCount;
    setState(() {
      _isLiked    = !_isLiked;
      _likesCount += _isLiked ? 1 : -1;
      widget.news.isLiked    = _isLiked;
      widget.news.likesCount = _likesCount;
    });

    final state = context.read<AppState>();
    if (state.apiEnabled) {
      try {
        final res = await CardNewsService.instance.toggleLike(widget.news.id);
        setState(() {
          _isLiked    = res.liked;
          _likesCount = res.likeCount;
          widget.news.isLiked    = res.liked;
          widget.news.likesCount = res.likeCount;
        });
      } catch (_) {
        setState(() {
          _isLiked    = prev;
          _likesCount = prevCount;
          widget.news.isLiked    = prev;
          widget.news.likesCount = prevCount;
        });
      }
    }
  }

  // ── 즐겨찾기 (하단 + 우상단 공통) ───────────────────────
  Future<void> _toggleBookmark() async {
    final prev = _isBookmarked;
    setState(() {
      _isBookmarked           = !_isBookmarked;
      widget.news.isBookmarked = _isBookmarked;
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(_isBookmarked ? '즐겨찾기에 추가됐습니다 🔖' : '즐겨찾기에서 제거됐습니다'),
      duration: const Duration(seconds: 1),
    ));

    final state = context.read<AppState>();
    if (state.apiEnabled) {
      try {
        final bookmarked = await CardNewsService.instance.toggleBookmark(widget.news.id);
        setState(() {
          _isBookmarked           = bookmarked;
          widget.news.isBookmarked = bookmarked;
        });
      } catch (_) {
        setState(() {
          _isBookmarked           = prev;
          widget.news.isBookmarked = prev;
        });
      }
    }
  }

  // ── 공유하기 바텀시트 ─────────────────────────────────────
  void _showShareSheet() {
    final url  = 'https://myming.app/news/${widget.news.id}';
    final text = '${widget.news.headline}\n\n$url';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            const Text('공유하기', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 링크 복사
                _ShareBtn(
                  icon: Icons.link_rounded,
                  label: '링크 복사',
                  color: const Color(0xFF5C6BC0),
                  onTap: () async {
                    Navigator.pop(context);
                    await Clipboard.setData(ClipboardData(text: url));
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('링크가 복사됐습니다 📋'), duration: Duration(seconds: 2)),
                    );
                  },
                ),
                const SizedBox(width: 24),
                // 카카오톡 공유 (시스템 공유 다이얼로그 — 카카오톡 포함)
                _ShareBtn(
                  icon: Icons.chat_bubble_rounded,
                  label: '카카오톡',
                  color: const Color(0xFFFEE500),
                  iconColor: const Color(0xFF191600),
                  onTap: () async {
                    Navigator.pop(context);
                    await Share.share(text, subject: widget.news.headline);
                  },
                ),
                const SizedBox(width: 24),
                // 더보기 (시스템 공유)
                _ShareBtn(
                  icon: Icons.ios_share_rounded,
                  label: '더보기',
                  color: AppColors.primary,
                  onTap: () async {
                    Navigator.pop(context);
                    await Share.share(text, subject: widget.news.headline);
                  },
                ),
              ],
            ),
          ],
        ),
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

  @override
  Widget build(BuildContext context) {
    final isRead = widget.news.isRead;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.news.category.label,
            style: const TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w700)),
        actions: [
          // 우상단 즐겨찾기 버튼 (하단과 동일 상태)
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? AppColors.primary : AppColors.muted,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 + 시간
            Row(children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: _catColor(widget.news.category).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(widget.news.category.label,
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                        color: _catColor(widget.news.category))),
              ),
              const SizedBox(width: 8),
              Text(widget.news.time, style: AppTheme.caption),
              if (widget.news.isNew) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0x1AFF4B4B), borderRadius: BorderRadius.circular(5)),
                  child: const Text('NEW',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFFF4B4B))),
                ),
              ],
            ]),

            const SizedBox(height: 12),

            // 키워드
            Wrap(
              spacing: 6, runSpacing: 4,
              children: widget.news.keywords.map((k) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(7)),
                child: Text('#$k',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              )).toList(),
            ),

            const SizedBox(height: 16),

            // 헤드라인
            Text(widget.news.headline,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900,
                    color: AppColors.text, height: 1.4)),

            const SizedBox(height: 16),

            // 수치 박스
            if (widget.news.stat.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryDim,
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(children: [
                  const Text('📊', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('주요 수치',
                        style: TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w700)),
                    Text(widget.news.stat,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  ]),
                ]),
              ),

            const SizedBox(height: 20),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),

            // 요약
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('💡 요약',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
                const SizedBox(height: 8),
                Text(widget.news.summary, style: AppTheme.body.copyWith(height: 1.6)),
              ]),
            ),

            const SizedBox(height: 20),

            // 본문
            Text(widget.news.content, style: AppTheme.body.copyWith(height: 1.8, fontSize: 14)),

            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),

            // 반응 바 (좋아요 · 즐겨찾기 · 공유)
            Row(children: [
              // 좋아요
              _ReactionBtn(
                icon: _isLiked ? '❤️' : '🤍',
                count: '$_likesCount',
                active: _isLiked,
                onTap: _toggleLike,
              ),
              const SizedBox(width: 12),
              // 즐겨찾기
              _ReactionBtn(
                icon: _isBookmarked ? '🔖' : '🔖',
                count: '${widget.news.bookmarksCount}',
                active: _isBookmarked,
                onTap: _toggleBookmark,
              ),
              const Spacer(),
              // 공유하기
              TextButton.icon(
                onPressed: _showShareSheet,
                icon: const Icon(Icons.ios_share_rounded, size: 16, color: AppColors.muted),
                label: const Text('공유',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
              ),
            ]),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // 하단 상태 바
      bottomNavigationBar: _StatusBar(isRead: isRead),
    );
  }
}

// ── 반응 버튼 ─────────────────────────────────────────────
class _ReactionBtn extends StatelessWidget {
  final String icon;
  final String count;
  final bool active;
  final VoidCallback onTap;

  const _ReactionBtn({required this.icon, required this.count,
      required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDim : AppColors.card,
          border: Border.all(color: active ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 5),
          Text(count,
              style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: active ? AppColors.primary : AppColors.muted,
              )),
        ]),
      ),
    );
  }
}

// ── 공유 버튼 아이템 ──────────────────────────────────────
class _ShareBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color? iconColor;
  final VoidCallback onTap;

  const _ShareBtn({required this.icon, required this.label,
      required this.color, this.iconColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(
          width: 56, height: 56,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: Icon(icon, color: iconColor ?? Colors.white, size: 26),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.text)),
      ]),
    );
  }
}

// ── 하단 상태 바 ──────────────────────────────────────────
class _StatusBar extends StatelessWidget {
  final bool isRead;
  const _StatusBar({required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      color: AppColors.card,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isRead ? AppColors.surface : AppColors.primaryDim,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
              color: isRead ? AppColors.border : AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Text(
          isRead ? '✅ 이미 읽은 기사 (+₩10 완료)' : '⬇️ 기사를 끝까지 읽으면 ₩10 자동 적립',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w700,
            color: isRead ? AppColors.muted : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
