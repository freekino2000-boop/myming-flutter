// ════════════════════════════════════════════════════════
// global_rank_page.dart — 전체 랭킹 페이지
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class GlobalRankPage extends StatelessWidget {
  const GlobalRankPage({super.key});

  static const List<_RankEntry> _mockData = [
    _RankEntry(rank: 1,  name: '홍길동', score: 98200, game: '벽돌 깨기', badge: '👑'),
    _RankEntry(rank: 2,  name: '김민준', score: 84100, game: '무한점프',  badge: '🥈'),
    _RankEntry(rank: 3,  name: '이서연', score: 72300, game: '퍼즐',      badge: '🥉'),
    _RankEntry(rank: 4,  name: '박지훈', score: 65900, game: '낚시 대전', badge: ''),
    _RankEntry(rank: 5,  name: '최수아', score: 58400, game: '경제 퀴즈', badge: ''),
    _RankEntry(rank: 6,  name: '정은우', score: 51200, game: '무한 러너', badge: ''),
    _RankEntry(rank: 7,  name: '강다현', score: 44700, game: '슈팅',      badge: ''),
    _RankEntry(rank: 8,  name: '조민서', score: 38100, game: '카드 배틀', badge: ''),
    _RankEntry(rank: 9,  name: '윤현수', score: 31600, game: '벽돌 깨기', badge: ''),
    _RankEntry(rank: 10, name: '임지우', score: 24300, game: '무한점프',  badge: ''),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('🏆 전체 랭킹', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _mockData.length,
        itemBuilder: (context, i) {
          final e = _mockData[i];
          final isTop3 = e.rank <= 3;
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isTop3 ? AppColors.primaryDim : AppColors.card,
              border: Border.all(color: isTop3 ? AppColors.primary.withOpacity(0.3) : AppColors.border),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 32,
                  child: Text(
                    e.badge.isEmpty ? '${e.rank}위' : e.badge,
                    style: TextStyle(
                      fontSize: e.badge.isEmpty ? 12 : 22,
                      fontWeight: FontWeight.w900,
                      color: isTop3 ? AppColors.primary : AppColors.muted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(e.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.text)),
                      Text(e.game, style: AppTheme.caption),
                    ],
                  ),
                ),
                Text(
                  '${e.score.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}점',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isTop3 ? AppColors.primary : AppColors.text),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RankEntry {
  final int rank;
  final String name;
  final int score;
  final String game;
  final String badge;
  const _RankEntry({required this.rank, required this.name, required this.score, required this.game, required this.badge});
}
