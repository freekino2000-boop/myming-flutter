// ════════════════════════════════════════════════════════
// jump_game_page.dart — 무한 점프 러너 (Flame 게임 엔진)
// 캐릭터 점프 / 장애물 회피 / 코인 수집 / 거리 점수
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

class JumpGame extends FlameGame with TapCallbacks {
  static const double gravity = 1200;
  static const double jumpForce = -520;
  static const double groundY = 0.75; // size.y 의 75%
  static const double charW = 28, charH = 36;
  static const double obsW = 22, obsH = 40;
  static const double coinR = 10;

  // ignore: library_private_types_in_public_api
  late _Runner runner;
  double _speed = 220;
  double _dist = 0;
  int coins = 0;
  bool _started = false;
  bool _over = false;
  final _rng = Random();
  double _nextObs = 2.0;
  double _nextCoin = 1.5;
  final List<_Obstacle> _obs = [];
  final List<_Coin> _coins = [];

  void Function(int dist, int coins)? onGameOver;

  @override
  Color backgroundColor() => const Color(0xFF0D2137);

  @override
  Future<void> onLoad() async {
    runner = _Runner()..position = Vector2(60, size.y * groundY - charH);
    add(runner);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_started) {
      _started = true;
    } else {
      runner.jump();
    }
  }

  @override
  void update(double dt) {
    if (!_started || _over) return;
    super.update(dt);
    _dist += _speed * dt;
    _speed = min(_speed + 8 * dt, 480);

    // 장애물 스폰
    _nextObs -= dt;
    if (_nextObs <= 0) {
      final obs = _Obstacle()..position = Vector2(size.x + 20, size.y * groundY - obsH);
      _obs.add(obs);
      add(obs);
      _nextObs = 1.2 + _rng.nextDouble() * 1.8;
    }

    // 코인 스폰
    _nextCoin -= dt;
    if (_nextCoin <= 0) {
      final coinH = size.y * groundY - charH * 1.5 - _rng.nextDouble() * charH;
      final c = _Coin()..position = Vector2(size.x + 20, coinH);
      _coins.add(c);
      add(c);
      _nextCoin = 0.8 + _rng.nextDouble() * 1.2;
    }

    final floor = size.y * groundY;

    // 장애물 이동 + 충돌
    for (final obs in List.from(_obs)) {
      obs.position.x -= _speed * dt;
      if (obs.position.x < -obsW) { obs.removeFromParent(); _obs.remove(obs); }
      final rRect = Rect.fromLTWH(runner.position.x + 2, runner.position.y + 2, charW - 4, charH - 4);
      final oRect = Rect.fromLTWH(obs.position.x, obs.position.y, obsW, obsH);
      if (rRect.overlaps(oRect)) { _over = true; onGameOver?.call(_dist.toInt(), coins); return; }
    }

    // 코인 이동 + 수집
    for (final c in List.from(_coins)) {
      c.position.x -= _speed * dt;
      if (c.position.x < -20) { c.removeFromParent(); _coins.remove(c); }
      final rRect = Rect.fromLTWH(runner.position.x, runner.position.y, charW, charH);
      final cRect = Rect.fromLTWH(c.position.x - coinR, c.position.y - coinR, coinR * 2, coinR * 2);
      if (rRect.overlaps(cRect)) { coins++; c.removeFromParent(); _coins.remove(c); }
    }

    // 지면 HUD
    runner.floorY = floor;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    // 지면 선
    canvas.drawLine(
      Offset(0, size.y * groundY), Offset(size.x, size.y * groundY),
      Paint()..color = Colors.white24..strokeWidth = 2,
    );
    // HUD
    _drawHud(canvas);
  }

  void _drawHud(Canvas canvas) {
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(text: '${_dist.toInt()}m', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));
    tp.layout();
    tp.paint(canvas, Offset(size.x / 2 - tp.width / 2, 16));
    tp.text = TextSpan(text: '🪙 $coins', style: const TextStyle(color: Colors.amber, fontSize: 14, fontWeight: FontWeight.bold));
    tp.layout();
    tp.paint(canvas, const Offset(16, 20));
  }
}

class _Runner extends PositionComponent {
  double _vy = 0;
  bool _onGround = true;
  double floorY = 0;
  bool _jumping = false;
  double _animT = 0;

  void jump() {
    if (_onGround) { _vy = JumpGame.jumpForce; _onGround = false; _jumping = true; }
  }

  @override
  void update(double dt) {
    _animT += dt;
    if (!_onGround) {
      _vy += JumpGame.gravity * dt;
      position.y += _vy * dt;
    }
    if (floorY > 0 && position.y + JumpGame.charH >= floorY) {
      position.y = floorY - JumpGame.charH;
      _vy = 0;
      _onGround = true;
      _jumping = false;
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = AppColors.primary;
    // 몸통
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(4, 6, JumpGame.charW - 8, JumpGame.charH - 6), const Radius.circular(6)), paint);
    // 머리
    canvas.drawCircle(const Offset(JumpGame.charW / 2, 4), 8, paint..color = AppColors.primary.withValues(alpha: 0.9));
    // 다리 (달리기 애니메이션)
    if (!_jumping) {
      final legOffset = (sin(_animT * 12) * 4).toInt().toDouble();
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(6, JumpGame.charH - 8, 6, 8 + legOffset), const Radius.circular(3)), Paint()..color = AppColors.primary);
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(16, JumpGame.charH - 8, 6, 8 - legOffset), const Radius.circular(3)), Paint()..color = AppColors.primary);
    }
  }
}

class _Obstacle extends PositionComponent {
  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = const Color(0xFFEF4444);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(0, 0, JumpGame.obsW, JumpGame.obsH), const Radius.circular(4)), paint);
    // 하이라이트
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(2, 2, JumpGame.obsW - 4, 8), const Radius.circular(3)), Paint()..color = Colors.white.withValues(alpha: 0.2));
  }
}

class _Coin extends PositionComponent {
  double _t = 0;
  @override
  void update(double dt) { _t += dt; }
  @override
  void render(Canvas canvas) {
    final y = sin(_t * 4) * 3;
    canvas.drawCircle(Offset(JumpGame.coinR, JumpGame.coinR + y), JumpGame.coinR, Paint()..color = Colors.amber);
    canvas.drawCircle(Offset(JumpGame.coinR, JumpGame.coinR + y), JumpGame.coinR - 3, Paint()..color = const Color(0xFFFFA000));
  }
}

// ── Flutter 래퍼 ──────────────────────────────────────────
class JumpGamePage extends StatefulWidget {
  const JumpGamePage({super.key});
  @override
  State<JumpGamePage> createState() => _JumpGamePageState();
}

class _JumpGamePageState extends State<JumpGamePage> {
  late JumpGame _game;
  bool _over = false;
  int _dist = 0;
  int _coins = 0;

  @override
  void initState() {
    super.initState();
    _initGame();
  }

  void _initGame() {
    _game = JumpGame()..onGameOver = (d, c) {
      final reward = min(d ~/ 20 + c * 5, 150);
      if (reward > 0) {
        final state = context.read<AppState>();
        if (state.apiEnabled) {
          final score = d ~/ 20 + _coins * 5;
          GameService.instance.submitScore('jump', score).then((res) {
            state.walletAmount = res.balance;
            state.addLedger('🏃', '무한점프 보상', res.reward, 'earn');
            state.refresh();
          }).catchError((_) { state.earn('🏃', '무한점프 보상', reward); });
        } else {
          context.read<AppState>().earn('🏃', '무한점프 보상', reward);
        }
      }
      setState(() { _over = true; _dist = d; _coins = c; });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D2137),
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
                  decoration: BoxDecoration(color: const Color(0xFF0D2137), border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)), borderRadius: BorderRadius.circular(24)),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    const Text('💀 게임오버', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 8),
                    Text('거리: ${_dist}m', style: const TextStyle(color: Colors.white70)),
                    Text('코인: $_coins', style: const TextStyle(color: Colors.amber)),
                    Text('보상: +₩${min(_dist ~/ 20 + _coins * 5, 150)}', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
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
                child: Text('탭하면 시작 / 점프', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12))),
          ],
        ),
      ),
    );
  }
}
