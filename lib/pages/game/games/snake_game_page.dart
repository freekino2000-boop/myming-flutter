// ═══════════════��════════════════════════════════════════
// snake_game_page.dart — 뱀 게임 (Flutter CustomPainter)
// 방향키/스와이프 조작 / 먹이 먹으면 몸 늘어남 / 랭킹 보상
// ════════════════════════════════════════════════════════
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/app_state.dart';
import '../../../services/game_service.dart';
import '../../../theme/app_theme.dart';

const _cols = 20;
const _rows = 30;

class SnakeGamePage extends StatefulWidget {
  const SnakeGamePage({super.key});
  @override
  State<SnakeGamePage> createState() => _SnakeGamePageState();
}

class _SnakeGamePageState extends State<SnakeGamePage> {
  List<_Pt> _snake = [const _Pt(10, 15), const _Pt(10, 16), const _Pt(10, 17)];
  _Pt _dir = const _Pt(0, -1);
  _Pt _nextDir = const _Pt(0, -1);
  _Pt _food = const _Pt(5, 10);
  int _score = 0;
  bool _over = false;
  bool _paused = false;
  bool _started = false;
  Timer? _timer;
  final _rng = Random();
  Offset? _swipeStart;

  @override
  void initState() {
    super.initState();
    _placeFood();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    _started = true;
    _timer = Timer.periodic(const Duration(milliseconds: 150), (_) => _tick());
  }

  void _tick() {
    if (_paused || _over || !_started) return;
    setState(() {
      _dir = _nextDir;
      final head = _Pt(_snake.first.x + _dir.x, _snake.first.y + _dir.y);
      // 벽/자기몸 충돌
      if (head.x < 0 || head.x >= _cols || head.y < 0 || head.y >= _rows || _snake.contains(head)) {
        _over = true;
        _timer?.cancel();
        final reward = min(_score * 3, 150);
        if (reward > 0) {
          final state = context.read<AppState>();
          if (state.apiEnabled) {
            GameService.instance.submitScore('snake', _score).then((res) {
              state.walletAmount = res.balance;
              state.addLedger('🐍', '뱀게임 보상', res.reward, 'earn');
              state.notifyListeners();
            }).catchError((_) => state.earn('🐍', '뱀게임 보상', reward));
          } else {
            context.read<AppState>().earn('🐍', '뱀게임 보상', reward);
          }
        }
        return;
      }
      _snake = [head, ..._snake];
      if (head == _food) { _score++; _placeFood(); }
      else _snake.removeLast();
    });
  }

  void _placeFood() {
    _Pt p;
    do { p = _Pt(_rng.nextInt(_cols), _rng.nextInt(_rows)); } while (_snake.contains(p));
    _food = p;
  }

  void _setDir(int dx, int dy) {
    if (dx == -_dir.x && dy == -_dir.y) return;
    _nextDir = _Pt(dx, dy);
    if (!_started) _start();
  }

  void _onSwipe(Offset delta) {
    if (delta.dx.abs() > delta.dy.abs()) {
      _setDir(delta.dx > 0 ? 1 : -1, 0);
    } else {
      _setDir(0, delta.dy > 0 ? 1 : -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1F0D),
      body: SafeArea(
        child: Stack(
          children: [
            // 메인 레이아웃
            Column(
              children: [
                // 상단 HUD
                Container(
                  color: const Color(0xFF0D1F0D),
                  padding: const EdgeInsets.fromLTRB(8, 4, 16, 4),
                  child: Row(children: [
                    IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () { _timer?.cancel(); Navigator.pop(context); }),
                    const Text('🐍 뱀 게임', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
                    const Spacer(),
                    Text('🍎 $_score', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
                    const SizedBox(width: 12),
                    IconButton(icon: Icon(_paused ? Icons.play_arrow : Icons.pause, color: Colors.white), onPressed: () => setState(() => _paused = !_paused)),
                  ]),
                ),
                // 게임 캔버스
                Expanded(
                  child: GestureDetector(
                    onPanStart: (d) { _swipeStart = d.localPosition; if (!_started) _start(); },
                    onPanUpdate: (d) {
                      if (_swipeStart != null) {
                        final delta = d.localPosition - _swipeStart!;
                        if (delta.distance > 20) { _onSwipe(delta); _swipeStart = d.localPosition; }
                      }
                    },
                    child: CustomPaint(
                      painter: _SnakePainter(snake: _snake, food: _food),
                      child: Container(),
                    ),
                  ),
                ),
                // 방향키
                Container(
                  color: const Color(0xFF0D1F0D),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Column(children: [
                    _DirBtn(icon: Icons.arrow_upward, onTap: () => _setDir(0, -1)),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      _DirBtn(icon: Icons.arrow_back, onTap: () => _setDir(-1, 0)),
                      const SizedBox(width: 52),
                      _DirBtn(icon: Icons.arrow_forward, onTap: () => _setDir(1, 0)),
                    ]),
                    _DirBtn(icon: Icons.arrow_downward, onTap: () => _setDir(0, 1)),
                  ]),
                ),
              ],
            ),

            // 게임오버 오버레이 (Stack 위에 정확히 올라감)
            if (_over)
              Positioned.fill(
                child: Container(
                  color: Colors.black54,
                  child: Center(child: Container(
                    margin: const EdgeInsets.all(40),
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: const Color(0xFF0D1F0D), border: Border.all(color: const Color(0xFF27AE60).withOpacity(0.5)), borderRadius: BorderRadius.circular(24)),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Text('💀 게임오버', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 8),
                      Text('먹은 먹이: $_score개', style: const TextStyle(color: Colors.white70)),
                      Text('보상: +₩${min(_score * 3, 150)}', style: const TextStyle(color: Color(0xFF27AE60), fontWeight: FontWeight.w700)),
                      const SizedBox(height: 20),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                        ElevatedButton(
                          onPressed: () { setState(() { _snake = [const _Pt(10, 15), const _Pt(10, 16), const _Pt(10, 17)]; _dir = const _Pt(0, -1); _nextDir = const _Pt(0, -1); _score = 0; _over = false; _started = false; }); _placeFood(); },
                          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF27AE60)),
                          child: const Text('다시하기', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                        ),
                        OutlinedButton(
                          onPressed: () { _timer?.cancel(); Navigator.pop(context); },
                          style: OutlinedButton.styleFrom(side: const BorderSide(color: Colors.white30)),
                          child: const Text('나가기', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
                        ),
                      ]),
                    ]),
                  )),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Pt {
  final int x, y;
  const _Pt(this.x, this.y);
  @override bool operator ==(Object o) => o is _Pt && o.x == x && o.y == y;
  @override int get hashCode => Object.hash(x, y);
}

class _SnakePainter extends CustomPainter {
  final List<_Pt> snake;
  final _Pt food;
  const _SnakePainter({required this.snake, required this.food});

  @override
  void paint(Canvas canvas, Size size) {
    final cw = size.width / _cols;
    final ch = size.height / _rows;
    // 그리드 배경
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), Paint()..color = const Color(0xFF0D1F0D));

    // 뱀
    for (int i = 0; i < snake.length; i++) {
      final p = snake[i];
      final isHead = i == 0;
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(p.x * cw + 1, p.y * ch + 1, cw - 2, ch - 2), Radius.circular(isHead ? 5 : 3)),
        Paint()..color = isHead ? const Color(0xFF27AE60) : const Color(0xFF1DD1A1),
      );
      if (isHead) {
        // 눈
        canvas.drawCircle(Offset(p.x * cw + cw * 0.3, p.y * ch + ch * 0.35), 2, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(p.x * cw + cw * 0.7, p.y * ch + ch * 0.35), 2, Paint()..color = Colors.white);
      }
    }

    // 먹이
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = const TextSpan(text: '🍎', style: TextStyle(fontSize: 14));
    tp.layout();
    tp.paint(canvas, Offset(food.x * cw + (cw - tp.width) / 2, food.y * ch + (ch - tp.height) / 2));
  }

  @override
  bool shouldRepaint(_SnakePainter old) => true;
}

class _DirBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _DirBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 52, height: 52, margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: Colors.white70, size: 24),
      ),
    );
  }
}
