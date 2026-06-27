// ════════════════════════════════════════════════════════
// brick_game_page.dart — 벽돌 깨기 (Flame 게임 엔진)
// 패들 드래그 조작 / 레벨 시스템 / 랭킹 적립
// ════════════════════════════════════════════════════════
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/collisions.dart';
import 'package:provider/provider.dart';
import '../../../models/app_state.dart';
import '../../../services/game_service.dart';
import '../../../theme/app_theme.dart';

// ── Flame 게임 클래스 ──────────────────────────────────────
class BrickGame extends FlameGame with HasCollisionDetection, TapCallbacks, PanDetector {
  static const cols = 8;
  static const rows = 5;
  static const brickW = 40.0;
  static const brickH = 16.0;
  static const brickGap = 3.0;
  static const paddleW = 70.0;
  static const paddleH = 10.0;
  static const ballR = 7.0;
  static const paddleSpeed = 420.0;

  late _Paddle paddle;
  late _Ball ball;
  int score = 0;
  int lives = 3;
  int level = 1;
  bool paused = false;
  bool _started = false;
  void Function(int score, int level)? onGameOver;
  void Function(int level)? onClear;

  @override
  Color backgroundColor() => const Color(0xFF0D1B2A);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _buildLevel();
  }

  void _buildLevel() {
    removeAll(children.whereType<_Brick>());
    removeAll(children.whereType<_Paddle>());
    removeAll(children.whereType<_Ball>());

    // 패들
    paddle = _Paddle()
      ..position = Vector2(size.x / 2 - paddleW / 2, size.y - 50);
    add(paddle);

    // 공
    ball = _Ball(level: level)
      ..position = Vector2(size.x / 2, size.y - 70);
    add(ball);

    // 벽돌
    final totalW = cols * (brickW + brickGap) - brickGap;
    final startX = (size.x - totalW) / 2;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        add(_Brick(
          row: r, col: c,
          position: Vector2(startX + c * (brickW + brickGap), 50 + r * (brickH + brickGap)),
          onBreak: () => score += (level * 10),
        ));
      }
    }
  }

  @override
  void onPanUpdate(DragUpdateInfo info) {
    paddle.position.x = (info.eventPosition.global.x - paddleW / 2).clamp(0, size.x - paddleW);
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (!_started) { _started = true; ball.launch(); }
    else paused = !paused;
  }

  @override
  void update(double dt) {
    if (!paused) super.update(dt);
    // 공 바닥 이탈
    if (ball.position.y > size.y + 20) {
      lives--;
      if (lives <= 0) { onGameOver?.call(score, level); }
      else { ball.position = Vector2(paddle.position.x + paddleW / 2, size.y - 70); ball.reset(); _started = false; }
    }
    // 클리어 감지
    if (children.whereType<_Brick>().isEmpty) { onClear?.call(level); }
  }
}

class _Paddle extends PositionComponent with CollisionCallbacks {
  _Paddle() : super(size: Vector2(BrickGame.paddleW, BrickGame.paddleH));
  @override
  Future<void> onLoad() async {
    add(RectangleHitbox());
  }
  @override
  void render(Canvas canvas) {
    canvas.drawRRect(RRect.fromRectAndRadius(size.toRect(), const Radius.circular(5)),
      Paint()..color = AppColors.primary);
  }
}

class _Ball extends PositionComponent with CollisionCallbacks, HasGameRef<BrickGame> {
  final int level;
  Vector2 _vel = Vector2.zero();
  bool _launched = false;

  _Ball({required this.level}) : super(size: Vector2.all(BrickGame.ballR * 2));

  void launch() {
    final speed = 200.0 + level * 30;
    _vel = Vector2(speed * 0.7, -speed);
    _launched = true;
  }

  void reset() { _vel = Vector2.zero(); _launched = false; }

  @override
  Future<void> onLoad() async { add(CircleHitbox()); }

  @override
  void update(double dt) {
    if (!_launched) return;
    final g = gameRef as BrickGame;
    position += _vel * dt;
    // 벽 반사
    if (position.x <= 0) { position.x = 0; _vel.x = _vel.x.abs(); }
    if (position.x + BrickGame.ballR * 2 >= g.size.x) { position.x = g.size.x - BrickGame.ballR * 2; _vel.x = -_vel.x.abs(); }
    if (position.y <= 0) { position.y = 0; _vel.y = _vel.y.abs(); }
    // 패들 반사
    if (_vel.y > 0) {
      final pdl = g.paddle;
      final bRect = Rect.fromLTWH(position.x, position.y, BrickGame.ballR * 2, BrickGame.ballR * 2);
      final pRect = Rect.fromLTWH(pdl.position.x, pdl.position.y, BrickGame.paddleW, BrickGame.paddleH);
      if (bRect.overlaps(pRect)) {
        _vel.y = -_vel.y.abs();
        final hitX = (position.x + BrickGame.ballR) - (pdl.position.x + BrickGame.paddleW / 2);
        _vel.x = hitX * 5;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(Offset(BrickGame.ballR, BrickGame.ballR), BrickGame.ballR,
      Paint()..color = Colors.white);
  }
}

class _Brick extends PositionComponent with CollisionCallbacks {
  final int row;
  final int col;
  final VoidCallback onBreak;
  static const _colors = [Color(0xFFFF6B35), Color(0xFFFF9F43), Color(0xFFFECA57), Color(0xFF1DD1A1), Color(0xFF2C7FFF)];

  _Brick({required this.row, required this.col, required Vector2 position, required this.onBreak})
      : super(position: position, size: Vector2(BrickGame.brickW, BrickGame.brickH));

  @override
  Future<void> onLoad() async { add(RectangleHitbox()); }

  @override
  void onCollisionStart(Set<Vector2> points, PositionComponent other) {
    if (other is _Ball) {
      other._vel.y = -other._vel.y;
      onBreak();
      removeFromParent();
    }
    super.onCollisionStart(points, other);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(size.toRect(), const Radius.circular(3)),
      Paint()..color = _colors[row % _colors.length],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(1, 1, size.x - 2, size.y / 2 - 1), const Radius.circular(3)),
      Paint()..color = Colors.white.withOpacity(0.2),
    );
  }
}

// ── Flutter 위젯 래퍼 ─────────────────────────────────────
class BrickGamePage extends StatefulWidget {
  const BrickGamePage({super.key});
  @override
  State<BrickGamePage> createState() => _BrickGamePageState();
}

class _BrickGamePageState extends State<BrickGamePage> {
  late BrickGame _game;
  bool _gameOver = false;
  bool _cleared = false;
  int _score = 0;
  int _level = 1;

  @override
  void initState() {
    super.initState();
    _game = BrickGame()
      ..onGameOver = (s, l) { setState(() { _score = s; _level = l; _gameOver = true; _earn(s); }); }
      ..onClear = (l) { setState(() { _level = l; _cleared = true; _earn(_score); }); };
  }

  void _earn(int score) {
    final reward = min(score ~/ 10, 200);
    if (reward <= 0) return;
    final state = context.read<AppState>();
    if (state.apiEnabled) {
      GameService.instance.submitScore('brick', score).then((res) {
        state.walletAmount = res.balance;
        state.addLedger('🧱', '벽돌깨기 보상', res.reward, 'earn');
        state.notifyListeners();
      }).catchError((_) => state.earn('🧱', '벽돌깨기 보상', reward));
    } else {
      state.earn('🧱', '벽돌깨기 보상', reward);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      body: SafeArea(
        child: Stack(
          children: [
            GameWidget(game: _game),
            // HUD
            Positioned(
              top: 8, left: 16, right: 16,
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
                Text('Lv.$_level', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const Spacer(),
                Text('💯 $_score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                const SizedBox(width: 12),
                Text('❤️ ${_game.lives}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
              ]),
            ),
            // 게임오버 / 클리어 오버레이
            if (_gameOver || _cleared)
              _ResultOverlay(
                title: _cleared ? '🎉 클리어!' : '💀 게임오버',
                score: _score,
                onRetry: () { setState(() { _gameOver = false; _cleared = false; _score = 0; _level = 1; _game = BrickGame()..onGameOver = (s, l) { setState(() { _score = s; _level = l; _gameOver = true; _earn(s); }); }..onClear = (l) { setState(() { _level = l + 1; _cleared = true; _earn(_score); }); }; }); },
                onHome: () => Navigator.pop(context),
              ),
            // 시작 안내
            if (!_gameOver && !_cleared && !_game._started)
              const Positioned(
                bottom: 80,
                left: 0, right: 0,
                child: Text('화면을 탭하면 시작 / 패들을 드래그로 조작', textAlign: TextAlign.center, style: TextStyle(color: Colors.white60, fontSize: 12)),
              ),
          ],
        ),
      ),
    );
  }
}

class _ResultOverlay extends StatelessWidget {
  final String title;
  final int score;
  final VoidCallback onRetry;
  final VoidCallback onHome;

  const _ResultOverlay({required this.title, required this.score, required this.onRetry, required this.onHome});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.all(40),
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(color: const Color(0xFF1A1A2E), borderRadius: BorderRadius.circular(24)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('점수: $score', style: const TextStyle(color: Colors.white70, fontSize: 16)),
            Text('보상: +₩${min(score ~/ 10, 200)}', style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              ElevatedButton(onPressed: onRetry, style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary), child: const Text('다시하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
              OutlinedButton(onPressed: onHome, style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white30)), child: const Text('나가기', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700))),
            ]),
          ]),
        ),
      ),
    );
  }
}
