// ════════════════════════════════════════════════════════
// article_view_page.dart — 기사 상세 보기
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/card_news_model.dart';
import '../../theme/app_theme.dart';

class ArticleViewPage extends StatelessWidget {
  final CardNews news;
  const ArticleViewPage({super.key, required this.news});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.card,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(news.category.label, style: const TextStyle(fontSize: 14, color: AppColors.muted, fontWeight: FontWeight.w700)),
        actions: [
          IconButton(
            icon: Icon(news.isBookmarked ? Icons.bookmark : Icons.bookmark_border, color: news.isBookmarked ? AppColors.primary : AppColors.muted),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 카테고리 + 시간
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                  decoration: BoxDecoration(color: _catColor(news.category).withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: Text(news.category.label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: _catColor(news.category))),
                ),
                const SizedBox(width: 8),
                Text(news.time, style: AppTheme.caption),
                if (news.isNew) ...[
                  const SizedBox(width: 6),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: const Color(0x1AFF4B4B), borderRadius: BorderRadius.circular(5)), child: const Text('NEW', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Color(0xFFFF4B4B)))),
                ],
              ],
            ),

            const SizedBox(height: 12),

            // 키워드
            Wrap(
              spacing: 6, runSpacing: 4,
              children: news.keywords.map((k) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
                decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(7)),
                child: Text('#$k', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              )).toList(),
            ),

            const SizedBox(height: 16),

            // 헤드라인
            Text(news.headline, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.text, height: 1.4)),

            const SizedBox(height: 16),

            // 수치 박스
            if (news.stat.isNotEmpty)
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
                        Text(news.stat, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.primary)),
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
                  Text(news.summary, style: AppTheme.body.copyWith(height: 1.6)),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // 본문
            Text(news.content, style: AppTheme.body.copyWith(height: 1.8, fontSize: 14)),

            const SizedBox(height: 24),
            const Divider(color: AppColors.border),
            const SizedBox(height: 16),

            // 반응 + 공유
            Row(
              children: [
                _ReactButton(icon: '❤️', count: '${news.likesCount}', onTap: () {}),
                const SizedBox(width: 12),
                _ReactButton(icon: '🔖', count: '${news.bookmarksCount}', onTap: () {}),
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

      // 하단 적립 바
      bottomNavigationBar: _EarnBar(isRead: news.isRead),
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

class _EarnBar extends StatelessWidget {
  final bool isRead;
  const _EarnBar({required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      color: AppColors.card,
      child: ElevatedButton(
        onPressed: isRead ? null : () {
          // TODO: 광고 SDK 호출 → 완료 콜백에서 earn() 처리
          context.read<AppState>().earn('📰', '기사 읽기 적립', 10);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('₩10 적립! 기사를 다 읽었어요 🎉'), duration: Duration(seconds: 2)),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: isRead ? AppColors.surface : AppColors.primary,
          foregroundColor: isRead ? AppColors.muted : Colors.white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          elevation: 0,
        ),
        child: Text(
          isRead ? '✅ 이미 읽은 기사 (+₩10 완료)' : '📺 광고 보고 ₩10 받기',
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900),
        ),
      ),
    );
  }
}
