// ════════════════════════════════════════════════════════
// article_view_page.dart — 기사 상세 보기
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/card_news_model.dart';
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

  @override
  void initState() {
    super.initState();
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
        title: Text(widget.news.category.label, style: const TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(widget.news.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: widget.news.isBookmarked ? AppColors.primary : AppColors.muted),
            onPressed: () {},
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
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: _catColor(widget.news.category).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(widget.news.category.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _catColor(widget.news.category))),
                ),
                const SizedBox(width: 8),
                Text(widget.news.time, style: AppTheme.caption),
                if (widget.news.isNew) ...[
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: const Color(0x1AFF4B4B), borderRadius: BorderRadius.circular(5)), child: const Text('NEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFFF4B4B)))),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // 키워드
            Wrap(
              spacing: 6, runSpacing: 4,
              children: widget.news.keywords.map((k) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(7)),
                child: Text('#$k', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              )).toList(),
            ),

            const SizedBox(height: 16),

            // 헤드라인
            Text(widget.news.headline, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text, height: 1.4)),

            const SizedBox(height: 16),

            // 수치 박스
            if (widget.news.stat.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(color: AppColors.primaryDim, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 24)),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('주요 수치', style: TextStyle(fontSize: 10, color: AppColors.muted, fontWeight: FontWeight.w700)),
                        Text(widget.news.stat, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 20),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),

            // 요약
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(14)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('💡 요약', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(widget.news.summary, style: AppTheme.body.copyWith(height: 1.6)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 본문
            Text(widget.news.content, style: AppTheme.body.copyWith(height: 1.8, fontSize: 14)),

            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),

            // 반응 + 공유
            Row(
              children: [
                _ReactButton(icon: '❤️', count: '${widget.news.likesCount}', onTap: () {}),
                const SizedBox(width: 12),
                _ReactButton(icon: '🔖', count: '${widget.news.bookmarksCount}', onTap: () {}),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Text('🔗', style: TextStyle(fontSize: 16)),
                  label: const Text('공유', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
                ),
              ],
            ),

            const SizedBox(height: 80),
          ],
        ),
      ),

      // 하단 상태 바
      bottomNavigationBar: _StatusBar(isRead: isRead),
    );
  }
}

class _ReactButton extends StatelessWidget {
  final String icon;
  final String count;
  final VoidCallback onTap;

  const _ReactButton({required this.icon, required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 4),
        Text(count, style: AppTheme.caption.copyWith(fontSize: 13, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}

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
          border: Border.all(color: isRead ? AppColors.border : AppColors.primary.withOpacity(0.3)),
        ),
        child: Text(
          isRead ? '✅ 이미 읽은 기사 (+₩10 완료)' : '⬇️ 기사를 끝까지 읽으면 ₩10 자동 적립',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: isRead ? AppColors.muted : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
