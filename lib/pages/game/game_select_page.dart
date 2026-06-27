// ════════════════════════════════════════════════════════
// game_select_page.dart — 게임 선택 (8개 랭킹게임)
// 앱 화이트/블루 톤앤매너 / 2×4 그리드 / 전체 RANK 뱃지
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'global_rank_page.dart';
import 'games/brick_game_page.dart';
import 'games/jump_game_page.dart';
import 'games/catch_game_page.dart';
import 'games/snake_game_page.dart';

class GameSelectPage extends StatelessWidget {
  const GameSelectPage({super.key});

  static const List<_GameInfo> _games = [
    _GameInfo(id: 'brick',    emoji: '🧱', title: '벽돌 깨기',  sub: 'RANK',  borderColor: Color(0xFFFF6B35), bgColor: Color(0xFFFFF0E8)),
    _GameInfo(id: 'jump',     emoji: '🏃', title: '무한점프',   sub: 'RANK',  borderColor: Color(0xFF2C7FFF), bgColor: Color(0xFFE8F0FF)),
    _GameInfo(id: 'puzzle',   emoji: '🧩', title: '퍼즐 맞추기', sub: 'RANK', borderColor: Color(0xFF8B5CF6), bgColor: Color(0xFFF0EAFF)),
    _GameInfo(id: 'catch',    emoji: '🎣', title: '낚시 대전',   sub: 'RANK', borderColor: Color(0xFF0EA5E9), bgColor: Color(0xFFE0F5FF)),
    _GameInfo(id: 'quiz',     emoji: '❓', title: '경제 퀴즈',   sub: 'RANK', borderColor: Color(0xFFF59E0B), bgColor: Color(0xFFFFF6D8)),
    _GameInfo(id: 'runner',   emoji: '🚀', title: '무한 러너',   sub: 'RANK', borderColor: Color(0xFF10B981), bgColor: Color(0xFFE8FBF2)),
    _GameInfo(id: 'shooting', emoji: '🎯', title: '슈팅 게임',   sub: 'RANK', borderColor: Color(0xFFEF4444), bgColor: Color(0xFFFFEBEB)),
    _GameInfo(id: 'card',     emoji: '🃏', title: '카드 배틀',   sub: 'RANK', borderColor: Color(0xFF6366F1), bgColor: Color(0xFFEFEFFF)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text('🎮 게임 선택', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GlobalRankPage())),
                    icon: const Text('🏆', style: TextStyle(fontSize: 14)),
                    label: const Text('랭킹', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/shop'),
                    icon: const Text('🎁', style: TextStyle(fontSize: 14)),
                    label: const Text('보상', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            // 게임 안내 배너
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primaryDim,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(children: [
                const Text('🎖', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                const Expanded(child: Text('모든 게임에서 랭킹에 도전하고\n리워드를 받으세요!',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary, height: 1.4))),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Text('1위 ₩500', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ]),
            ),

            const SizedBox(height: 12),

            // 게임 그리드
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: _games.length,
                itemBuilder: (context, i) => _GameCard(game: _games[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 게임 정보 모델 ─────────────────────────────────────────
class _GameInfo {
  final String id;
  final String emoji;
  final String title;
  final String sub;
  final Color borderColor;
  final Color bgColor;

  const _GameInfo({
    required this.id, required this.emoji, required this.title,
    required this.sub, required this.borderColor, required this.bgColor,
  });
}

// ── 게임 카드 ─────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final _GameInfo game;
  const _GameCard({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final routes = <String, Widget>{
          'brick':  const BrickGamePage(),
          'jump':   const JumpGamePage(),
          'catch':  const CatchGamePage(),
          'runner': const SnakeGamePage(),
        };
        final page = routes[game.id];
        if (page != null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${game.title} — 개발 예정 🚧'), duration: const Duration(seconds: 1)),
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: game.bgColor,
          border: Border.all(color: game.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: game.borderColor.withOpacity(0.15), blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Stack(
          children: [
            // 배경 데코
            Positioned(
              right: -10, bottom: -10,
              child: Text(game.emoji, style: TextStyle(fontSize: 70, color: game.borderColor.withOpacity(0.08))),
            ),
            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // RANK 뱃지
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: game.borderColor,
                      borderRadius: BorderRadius.circular(7),
                    ),
                    child: Text('RANK', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                  const Spacer(),
                  Text(game.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 6),
                  Text(game.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: game.borderColor)),
                  const SizedBox(height: 2),
                  Text('랭킹 도전', style: TextStyle(fontSize: 11, color: game.borderColor.withOpacity(0.7), fontWeight: FontWeight.w500)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
