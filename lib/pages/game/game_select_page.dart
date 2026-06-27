// ════════════════════════════════════════════════════════
// game_select_page.dart — 게임 선택 (HTML5 WebView 8개)
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import 'global_rank_page.dart';
import 'games/webview_game_page.dart';

class GameSelectPage extends StatelessWidget {
  const GameSelectPage({super.key});

  // HTML 기준 순서·이름·이모지·색상·최대보상
  static const List<_GameInfo> _games = [
    _GameInfo(id: 'brick',  emoji: '🧱', title: '벽돌깨기',  maxReward: '+₩90', borderColor: Color(0xFFFF6B35), bgColor: Color(0xFFFFF0E8), webview: true),
    _GameInfo(id: 'jump',   emoji: '🏃', title: '러너',      maxReward: '+₩70', borderColor: Color(0xFF2C7FFF), bgColor: Color(0xFFE8F0FF), webview: true),
    _GameInfo(id: 'catch',  emoji: '🎯', title: '코인받기',  maxReward: '+₩80', borderColor: Color(0xFFF5A623), bgColor: Color(0xFFFFF6E8), webview: true),
    _GameInfo(id: 'snake',  emoji: '🐍', title: '뱀 게임',   maxReward: '+₩32', borderColor: Color(0xFF27AE60), bgColor: Color(0xFFE8FBF0), webview: true),
    _GameInfo(id: 'tap',    emoji: '⚡', title: '탭 배틀',   maxReward: '+₩50', borderColor: Color(0xFF2C7FFF), bgColor: Color(0xFFE8F0FF), webview: true),
    _GameInfo(id: 'quiz',   emoji: '🃏', title: '퀴즈왕',    maxReward: '+₩50', borderColor: Color(0xFFFF9F43), bgColor: Color(0xFFFFF6D8), webview: true),
    _GameInfo(id: 'memory', emoji: '🧩', title: '카드매칭',  maxReward: '+₩60', borderColor: Color(0xFF8E44AD), bgColor: Color(0xFFF5EAFF), webview: true),
    _GameInfo(id: 'reflex', emoji: '🎯', title: '반응속도',  maxReward: '+₩40', borderColor: Color(0xFF00A8B5), bgColor: Color(0xFFE0F9FA), webview: true),
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
                  const Text('🎮 게임 선택',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const GlobalRankPage())),
                    icon: const Text('🏆', style: TextStyle(fontSize: 14)),
                    label: const Text('랭킹',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                  TextButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/shop'),
                    icon: const Text('🎁', style: TextStyle(fontSize: 14)),
                    label: const Text('보상',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
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
                const Expanded(
                  child: Text('모든 게임에서 랭킹에 도전하고\n리워드를 받으세요!',
                      style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w700,
                          color: AppColors.primary, height: 1.4)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                      color: AppColors.primary, borderRadius: BorderRadius.circular(10)),
                  child: const Text('1위 ₩500',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
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
  final String maxReward;
  final Color borderColor;
  final Color bgColor;
  final bool webview;

  const _GameInfo({
    required this.id, required this.emoji, required this.title,
    required this.maxReward, required this.borderColor, required this.bgColor,
    required this.webview,
  });
}

// ── 게임 카드 ─────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final _GameInfo game;
  const _GameCard({super.key, required this.game});

  static const _assetMap = {
    'brick':  'assets/games/brick_breaker.html',
    'jump':   'assets/games/runner_game.html',
    'catch':  'assets/games/coin_catch.html',
    'snake':  'assets/games/snake_game.html',
    'tap':    'assets/games/tap_battle.html',
    'quiz':   'assets/games/quiz_king.html',
    'memory': 'assets/games/memory_match.html',
    'reflex': 'assets/games/reflex_test.html',
  };

  void _onTap(BuildContext context) {
    final asset = _assetMap[game.id];
    if (asset == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => WebViewGamePage(
          gameId: game.id,
          emoji: game.emoji,
          title: game.title,
          assetPath: asset,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _onTap(context),
      child: Container(
        decoration: BoxDecoration(
          color: game.bgColor,
          border: Border.all(color: game.borderColor, width: 1.5),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
                color: game.borderColor.withOpacity(0.15),
                blurRadius: 8, offset: const Offset(0, 3))
          ],
        ),
        child: Stack(
          children: [
            // 배경 데코
            Positioned(
              right: -10, bottom: -10,
              child: Text(game.emoji,
                  style: TextStyle(fontSize: 70, color: game.borderColor.withOpacity(0.08))),
            ),
            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 뱃지 (WebView는 WEB, Flame은 RANK)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                        color: game.borderColor, borderRadius: BorderRadius.circular(7)),
                    child: Text(
                      game.webview ? 'WEB' : 'RANK',
                      style: const TextStyle(
                          fontSize: 10, fontWeight: FontWeight.w900, color: Colors.white),
                    ),
                  ),
                  const Spacer(),
                  Text(game.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 6),
                  Text(game.title,
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w900, color: game.borderColor)),
                  const SizedBox(height: 2),
                  Text('최대 ${game.maxReward}',
                      style: TextStyle(
                          fontSize: 11,
                          color: game.borderColor.withOpacity(0.7),
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
