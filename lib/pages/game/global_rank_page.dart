// ════════════════════════════════════════════════════════
// global_rank_page.dart — 전체 랭킹 (API 연동)
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import '../../services/game_service.dart';
import '../../theme/app_theme.dart';

class GlobalRankPage extends StatefulWidget {
  const GlobalRankPage({super.key});
  @override
  State<GlobalRankPage> createState() => _GlobalRankPageState();
}

class _GlobalRankPageState extends State<GlobalRankPage> {
  String _gameId = 'brick';
  late Future<List<Map<String, dynamic>>> _future;

  static const _games = [
    ('brick', '🧱 벽돌깨기'),
    ('jump',  '🏃 무한점프'),
    ('catch', '🎣 낚시대전'),
    ('snake', '🐍 뱀게임'),
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = GameService.instance.getRanking(_gameId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.text), onPressed: () => Navigator.pop(context)),
        title: const Text('🏆 전체 랭킹', style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
      ),
      body: Column(
        children: [
          // 게임 탭
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _games.map((g) {
                final active = _gameId == g.$1;
                return Expanded(child: GestureDetector(
                  onTap: () => setState(() { _gameId = g.$1; _load(); }),
                  child: Container(
                    margin: const EdgeInsets.only(right: 6),
                    padding: const EdgeInsets.symmetric(vertical: 7),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primaryDim : Colors.transparent,
                      border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(9),
                    ),
                    child: Text(g.$2, textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                            color: active ? AppColors.primary : AppColors.muted)),
                  ),
                ));
              }).toList(),
            ),
          ),
          // 랭킹 목록
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (ctx, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }
                if (snap.hasError || !snap.hasData || snap.data!.isEmpty) {
                  return _MockRanking(gameId: _gameId);
                }
                final list = snap.data!;
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final e = list[i];
                    final rank  = (e['rank'] as num).toInt();
                    final isTop = rank <= 3;
                    final badges = ['👑', '🥈', '🥉'];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: isTop ? AppColors.primaryDim : AppColors.card,
                        border: Border.all(color: isTop ? AppColors.primary.withOpacity(0.3) : AppColors.border),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(children: [
                        SizedBox(width: 32, child: Text(
                          isTop ? badges[rank - 1] : '$rank위',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: isTop ? 22 : 12, fontWeight: FontWeight.w900,
                              color: isTop ? AppColors.primary : AppColors.muted),
                        )),
                        const SizedBox(width: 12),
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Row(children: [
                            Text(e['nickname'] as String? ?? '???',
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.text)),
                            if (e['is_me'] == true) ...[
                              const SizedBox(width: 6),
                              Container(padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                                child: const Text('나', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
                            ],
                          ]),
                          Text('최고 점수', style: AppTheme.caption),
                        ])),
                        Text(
                          '${_fmt((e['score'] as num).toInt())}점',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15,
                              color: isTop ? AppColors.primary : AppColors.text),
                        ),
                      ]),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// API 오류 시 목 데이터 폴백
class _MockRanking extends StatelessWidget {
  final String gameId;
  const _MockRanking({required this.gameId});

  static const _mock = [
    ('마이밍킹', 1800, '👑'), ('절감마스터', 1650, '🥈'), ('월세헌터', 1500, '🥉'),
    ('걷기왕', 1300, ''), ('절약박사', 1100, ''), ('도전자A', 900, ''),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _mock.length,
      itemBuilder: (_, i) {
        final (name, score, badge) = _mock[i];
        final isTop = i < 3;
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isTop ? AppColors.primaryDim : AppColors.card,
            border: Border.all(color: isTop ? AppColors.primary.withOpacity(0.3) : AppColors.border),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            SizedBox(width: 32, child: Text(badge.isEmpty ? '${i+1}위' : badge,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: badge.isEmpty ? 12 : 22, fontWeight: FontWeight.w900,
                    color: isTop ? AppColors.primary : AppColors.muted))),
            const SizedBox(width: 12),
            Expanded(child: Text(name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.text))),
            Text('${score.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}점',
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15, color: isTop ? AppColors.primary : AppColors.text)),
          ]),
        );
      },
    );
  }
}
