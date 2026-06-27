// ════════════════════════════════════════════════════════
// catch_game_page.dart — 낚시 대전 (Flame 게임 엔진)
// 바구니 좌우 이동으로 떨어지는 아이템 받기
// ════════════════════════════════════════════════════════
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:provider/provider.dart';
import '../../../models/app_state.dart';
import '../../../services/game_service.dart';
import '../../../theme/app_theme.dart';

class CatchGame extends FlameGame with PanDetector, TapCallbacks {
  static const basketW = 70.0, basketH = 20.0;
  static const itemR = 14.0;

  late _Basket basket;
  final List<_FallingItem> _items = [];
  final _rng = Random();
  double _spawnT = 1.5;
  double _fallSpeed = 160;
  int score = 0;
  int misses = 0;
  static const maxMisses = 3;
  bool _over = false;
  bool _started = false;

  void Function(int score)? onGameOver;

  @override
  Color backgroundColor() => const Color(0xFF0A1628);

  @override
  Future<void> onLoad() async {
    basket = _Basket()..position = Vector2(size.x / 2 - basketW / 2, size.y - 60);
    add(basket);
  }

  @override
  void onTapDown(TapDownEvent event) { _started = true; }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    basket.position.x = (info.eventPosition.global.x - basketW / 2).clamp(0, size.x - basketW);
  }

  @override
  void update(double dt) {
    if (!_started || _over) return;
    super.update(dt);
    _fallSpeed = min(_fallSpeed + 5 * dt, 380);
    _spawnT -= dt;
    if (_spawnT <= 0) {
      final x = itemR + _rng.nextDouble() * (size.x - itemR * 2);
      final item = _FallingItem(type: _rng.nextInt(3))..position = Vector2(x, -itemR * 2);
      _items.add(item);
      add(item);
      _spawnT = 0.7 + _rng.nextDouble() * 0.8;
    }

    for (final item in List.from(_items)) {
      item.position.y += _fallSpeed * dt;
      // 바구니 충돌
      final iRect = Rect.fromCircle(center: Offset(item.position.x, item.position.y), radius: itemR);
      final bRect = Rect.fromLTWH(basket.position.x, basket.position.y, basketW, basketH);
      if (iRect.overlaps(bRect)) {
        score += item.type == 2 ? -10 : (10 + item.type * 5).toInt();
        item.removeFromParent(); _items.remove(item);
        continue;
      }
      // 바닥 이���
      if (item.position.y > size.y + 20) {
        if (item.type != 2) misses++;
        item.removeFromParent(); _items.remove(item);
        if (misses >= maxMisses) { _over = true; onGameOver?.call(score); }
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // HUD
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(text: '🎣 $score', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
    tp.layout(); tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, 16));
    // 미스 하트
    final hearts = List.generate(maxMisses, (i) => i < misses ? '🖤' : '❤️').join(' ');
    tp.text = TextSpan(text: hearts, style: const TextStyle(fontSize: 16));
    tp.layout(); tp.paint(canvas, Offset(size.x - tp.width - 12, 14));
  }
}

class _Basket extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final p = Paint()..color = AppColors.primary;
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, CatchGame.basketW, CatchGame.basketH), const Radius.circular(8)), p);
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(2, 2, CatchGame.basketW - 4, 7), const Radius.circular(6)), Paint()..color = Colors.white.withOpacity(0.25));
  }
}

class _FallingItem extends PositionComponent {
  final int type; // 0=물고기, 1=금화, 2=폭탄
  static const _emojis = ['🐟', '🪙', '💣'];
  static const _colors = [Color(0xFF0EA5E9), Color(0xFFFBBF24), Color(0xFFEF4444)];

  _FallingItem({required this.type});

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(CatchGame.itemR, CatchGame.itemR), CatchGame.itemR,
      Paint()..color = _colors[type].withOpacity(0.8));
    final tp = TextPainter(textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    tp.text = TextSpan(text: _emojis[type], style: const TextStyle(fontSize: 16));
    tp.layout();
    tp.paint(canvas, Offset(CatchGame.itemR - tp.width / 2, CatchGame.itemR - tp.height / 2));
  }
}

// ── Flutter 래퍼 ──────────────────────────────────────────
class CatchGamePage extends StatefulWidget {
  const CatchGamePage({super.key});
  @override
  State<CatchGamePage> createState() => _CatchGamePageState();
}

class _CatchGamePageState extends State<CatchGamePage> {
  late CatchGame _game;
  bool _over = false;
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _game = CatchGame()..onGameOver = (s) {
      final reward = min(max(s, 0) ~/ 15, 100);
      if (reward > 0) {
        final state = context.read<AppState>();
        if (state.apiEnabled) {
          GameService.instance.submitScore('catch', _score).then((res) {
            state.walletAmount = res.balance;
            state.addLedger('🎣', '낚시대전 보상', res.reward, 'earn');
            state.notifyListeners();
          }).catchError((_) => state.earn('🎣', '낚시대전 보상', reward));
        } else {
          context.read<AppState>().earn('🎣', '낚시대전 보상', reward);
        }
      }
      setState(() { _over = true; _score = s; });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1628),
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: _game),
            Positioned(top: 8, left: 8, child: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context))),
            if (_over)
              Container(
                color: Colors.black54,
                child: Center(child: Container(
                  margin: const EdgeInsets.all(40),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(color: const Color(0xFF0A1628), border: Border.all(color: AppColors.primary.withOpacity(0.4)), borderRadius: BorderRadius.circular(24)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('🎣 게임종료', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('점수: $_score', style: const TextStyle(color: Colors.white70)),
                    Text('보상: +₩${min(max(_score, 0) ~/ 15, 100)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      ElevatedButton(
                        onPressed: () { setState(() { _over = false; }); _initGame(); },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                        child: const Text('다시하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      ),
                      OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white30)),
                        child: const Text('나가기', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                      ),
                    ]),
                  ]),
                )),
              ),
            if (!_over && !_game._started)
              const Positioned(bottom: 60, left: 0, right: 0,
                child: Text('탭으로 시작 / 드래그로 바구니 이동\n🐟+10  🪙+15  💣-10', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12, height: 1.6))),
          ],
        ),
      ),
    );
  }
}
