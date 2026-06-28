// ════════════════════════════════════════════════════════
// game_select_page.dart — 게임 선택 (인기순 자동 정렬)
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/game_service.dart';
import 'global_rank_page.dart';
import 'games/webview_game_page.dart';

// ── 게임 정보 모델 ─────────────────────────────────────────
class _GameInfo {
  final String id;
  final String emoji;
  final String title;
  final String maxReward;
  final Color borderColor;
  final Color bgColor;

  const _GameInfo({
    required this.id, required this.emoji, required this.title,
    required this.maxReward, required this.borderColor, required this.bgColor,
  });
}

// 기본 목록 (초기 순서 = 인기 데이터 없을 때 폴백)
const List<_GameInfo> _kAllGames = [
  _GameInfo(id: 'brick',  emoji: '🧱', title: '벽돌깨기', maxReward: '+₩90', borderColor: Color(0xFFFF6B35), bgColor: Color(0xFFFFF0E8)),
  _GameInfo(id: 'jump',   emoji: '🏃', title: '러너',     maxReward: '+₩70', borderColor: Color(0xFF2C7FFF), bgColor: Color(0xFFE8F0FF)),
  _GameInfo(id: 'catch',  emoji: '🎯', title: '코인받기', maxReward: '+₩80', borderColor: Color(0xFFF5A623), bgColor: Color(0xFFFFF6E8)),
  _GameInfo(id: 'snake',  emoji: '🐍', title: '뱀 게임',  maxReward: '+₩32', borderColor: Color(0xFF27AE60), bgColor: Color(0xFFE8FBF0)),
  _GameInfo(id: 'tap',    emoji: '⚡', title: '탭 배틀',  maxReward: '+₩50', borderColor: Color(0xFF2C7FFF), bgColor: Color(0xFFE8F0FF)),
  _GameInfo(id: 'quiz',   emoji: '🃏', title: '퀴즈왕',   maxReward: '+₩50', borderColor: Color(0xFFFF9F43), bgColor: Color(0xFFFFF6D8)),
  _GameInfo(id: 'memory', emoji: '🧩', title: '카드매칭', maxReward: '+₩60', borderColor: Color(0xFF8E44AD), bgColor: Color(0xFFF5EAFF)),
  _GameInfo(id: 'reflex', emoji: '🎯', title: '반응속도', maxReward: '+₩40', borderColor: Color(0xFF00A8B5), bgColor: Color(0xFFE0F9FA)),
];

// ── 페이지 ────────────────────────────────────────────────
class GameSelectPage extends StatefulWidget {
  final bool isInTab;
  const GameSelectPage({super.key, this.isInTab = false});

  @override
  State<GameSelectPage> createState() => _GameSelectPageState();
}

class _GameSelectPageState extends State<GameSelectPage> {
  List<_GameInfo> _games = List.of(_kAllGames);
  // game_id → play_count (1위=1, 공동 순위 가능)
  Map<String, int> _playCount = {};
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadPopularity();
  }

  Future<void> _loadPopularity() async {
    final counts = await GameService.instance.getPopularity();
    if (!mounted) return;
    if (counts.isEmpty) { setState(() => _loaded = true); return; }

    final sorted = List.of(_kAllGames)
      ..sort((a, b) {
        final ca = counts[a.id] ?? 0;
        final cb = counts[b.id] ?? 0;
        return cb.compareTo(ca); // 내림차순
      });

    setState(() {
      _games     = sorted;
      _playCount = counts;
      _loaded    = true;
    });
  }

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
                  if (!widget.isInTab)
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.text),
                      onPressed: () => Navigator.pop(context),
                    )
                  else
                    const SizedBox(width: 12),
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

            // 배너
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

            // 인기순 안내 칩
            if (_loaded && _playCount.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF0E8),
                        border: Border.all(color: const Color(0xFFFF6B35).withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('🔥', style: TextStyle(fontSize: 12)),
                          SizedBox(width: 4),
                          Text('인기순 정렬',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFFF6B35))),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 10),

            // 게임 그리드
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10,
                  childAspectRatio: 1.0,
                ),
                itemCount: _games.length,
                itemBuilder: (context, i) => _GameCard(
                  game: _games[i],
                  rank: _playCount.isNotEmpty ? i + 1 : null,
                  playCount: _playCount[_games[i].id],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 게임 카드 ─────────────────────────────────────────────
class _GameCard extends StatelessWidget {
  final _GameInfo game;
  final int? rank;        // 인기 순위 (1~8), null이면 미표시
  final int? playCount;

  const _GameCard({required this.game, this.rank, this.playCount});

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
                color: game.borderColor.withValues(alpha: 0.15),
                blurRadius: 8, offset: const Offset(0, 3))
          ],
        ),
        child: Stack(
          children: [
            // 배경 데코
            Positioned(
              right: -10, bottom: -10,
              child: Text(game.emoji,
                  style: TextStyle(fontSize: 70, color: game.borderColor.withValues(alpha: 0.08))),
            ),

            // 인기 순위 배지 (1~3위)
            if (rank != null && rank! <= 3)
              Positioned(
                top: 10, right: 10,
                child: Container(
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: rank == 1
                        ? const Color(0xFFFFD700)
                        : rank == 2
                            ? const Color(0xFFC0C0C0)
                            : const Color(0xFFCD7F32),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text('$rank',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                  ),
                ),
              ),

            // 콘텐츠
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(game.emoji, style: const TextStyle(fontSize: 36)),
                  const SizedBox(height: 6),
                  Text(game.title,
                      style: TextStyle(
                          fontSize: 14, fontWeight: FontWeight.w900, color: game.borderColor)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text('최대 ${game.maxReward}',
                          style: TextStyle(
                              fontSize: 11,
                              color: game.borderColor.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600)),
                      if (playCount != null && playCount! > 0) ...[
                        const SizedBox(width: 6),
                        Text('· ${_formatCount(playCount!)}회',
                            style: TextStyle(
                                fontSize: 10,
                                color: game.borderColor.withValues(alpha: 0.5),
                                fontWeight: FontWeight.w500)),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatCount(int n) {
    if (n >= 10000) return '${(n / 10000).toStringAsFixed(1)}만';
    if (n >= 1000)  return '${(n / 1000).toStringAsFixed(1)}천';
    return '$n';
  }
}
