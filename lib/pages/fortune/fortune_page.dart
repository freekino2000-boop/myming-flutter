// ════════════════════════════════════════════════════════
// fortune_page.dart — 오늘의 운세 (사주/타로)
// 생년월일 입력 → 카드 뒤집기 → 운세 결과
// ════════════════════════════════════════════════════════
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class FortunePage extends StatefulWidget {
  const FortunePage({super.key});
  @override
  State<FortunePage> createState() => _FortunePageState();
}

class _FortunePageState extends State<FortunePage> with SingleTickerProviderStateMixin {
  // form
  final _birthCtrl = TextEditingController();
  String _gender = '남성';
  String _birthTime = '모름';
  bool _showResult = false;
  bool _flipped = false;
  late AnimationController _flipCtrl;
  late Animation<double> _flipAnim;

  // 운세 결과 (랜덤)
  late _FortuneResult _result;

  static const _times = ['모름', '자시(23~01시)', '축시(01~03시)', '인시(03~05시)', '묘시(05~07시)', '진시(07~09시)', '사시(09~11시)', '오시(11~13시)', '미시(13~15시)', '신시(15~17시)', '유시(17~19시)', '술시(19~21시)', '해시(21~23시)'];

  @override
  void initState() {
    super.initState();
    _flipCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _flipAnim = Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _flipCtrl, curve: Curves.easeInOut));
    _result = _randomResult();
  }

  @override
  void dispose() {
    _flipCtrl.dispose();
    _birthCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_birthCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('생년월일 8자리를 입력해주세요 (예: 19950101)')));
      return;
    }
    _result = _randomResult();
    setState(() => _showResult = true);
    // 운세 조회 보상
    context.read<AppState>().earn('🔮', '오늘의 운세 조회', 5);
  }

  void _flip() {
    if (_flipped) return;
    _flipCtrl.forward();
    setState(() => _flipped = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0A0A1A),
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('🔮 오늘의 운세', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
      ),
      body: _showResult ? _ResultView(result: _result, flipped: _flipped, flipAnim: _flipAnim, onFlip: _flip) : _FormView(
        birthCtrl: _birthCtrl,
        gender: _gender, onGenderChange: (v) => setState(() => _gender = v),
        birthTime: _birthTime, times: _times, onTimeChange: (v) => setState(() => _birthTime = v!),
        onSubmit: _submit,
      ),
    );
  }
}

// ── 입력 폼 ───────────────────────────────────────────────
class _FormView extends StatelessWidget {
  final TextEditingController birthCtrl;
  final String gender;
  final void Function(String) onGenderChange;
  final String birthTime;
  final List<String> times;
  final void Function(String?) onTimeChange;
  final VoidCallback onSubmit;

  const _FormView({required this.birthCtrl, required this.gender, required this.onGenderChange, required this.birthTime, required this.times, required this.onTimeChange, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          border: Border.all(color: AppColors.border.withOpacity(0.3)),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('🔮', style: TextStyle(fontSize: 48))),
            const SizedBox(height: 16),
            Center(child: Text('사주 운세 보기', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900))),
            Center(child: Text('+₩5 적립', style: TextStyle(color: AppColors.primary.withOpacity(0.8), fontSize: 12))),
            const SizedBox(height: 24),

            _Label('생년월일 (8자리)'),
            const SizedBox(height: 6),
            TextField(
              controller: birthCtrl,
              keyboardType: TextInputType.number,
              maxLength: 8,
              style: const TextStyle(color: Colors.white, fontSize: 16, letterSpacing: 2),
              decoration: InputDecoration(
                hintText: '19950105',
                hintStyle: TextStyle(color: Colors.white30),
                filled: true, fillColor: const Color(0xFF0F0F1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border.withOpacity(0.3))),
                counterStyle: const TextStyle(color: Colors.white30),
              ),
            ),

            const SizedBox(height: 12),
            _Label('성별'),
            const SizedBox(height: 6),
            Row(children: ['남성', '여성'].map((g) => GestureDetector(
              onTap: () => onGenderChange(g),
              child: Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: gender == g ? AppColors.primary : const Color(0xFF0F0F1A),
                  border: Border.all(color: gender == g ? AppColors.primary : AppColors.border.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(g, style: TextStyle(color: gender == g ? Colors.white : Colors.white60, fontWeight: FontWeight.w700)),
              ),
            )).toList()),

            const SizedBox(height: 12),
            _Label('태어난 시간 (선택)'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: birthTime,
              items: times.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 13)))).toList(),
              onChanged: onTimeChange,
              dropdownColor: const Color(0xFF1A1A2E),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                filled: true, fillColor: const Color(0xFF0F0F1A),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border.withOpacity(0.3))),
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSubmit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary, minimumSize: const Size(0, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: const Text('🔮 운세 보기', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── 운세 결과 ─────────────────────────────────────────────
class _ResultView extends StatelessWidget {
  final _FortuneResult result;
  final bool flipped;
  final Animation<double> flipAnim;
  final VoidCallback onFlip;

  const _ResultView({required this.result, required this.flipped, required this.flipAnim, required this.onFlip});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // 카드 뒤집기
          GestureDetector(
            onTap: onFlip,
            child: AnimatedBuilder(
              animation: flipAnim,
              builder: (_, child) {
                final angle = flipAnim.value * pi;
                final isFront = angle < pi / 2;
                return Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.identity()..rotateY(angle),
                  child: Container(
                    width: 200, height: 280,
                    decoration: BoxDecoration(
                      color: isFront ? const Color(0xFF1A1A2E) : const Color(0xFF0A2E1A),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Center(child: isFront
                        ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            const Text('🌙', style: TextStyle(fontSize: 56)),
                            const SizedBox(height: 12),
                            const Text('탭해서 운세 확인', style: TextStyle(color: Colors.white60, fontSize: 12)),
                          ])
                        : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            Text(result.emoji, style: const TextStyle(fontSize: 56)),
                            const SizedBox(height: 8),
                            Text(result.grade, style: TextStyle(color: AppColors.primary, fontSize: 18, fontWeight: FontWeight.w900)),
                          ])),
                  ),
                );
              },
            ),
          ),

          if (flipped && flipAnim.value > 0.9) ...[
            const SizedBox(height: 24),
            // 운세 내용
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: const Color(0xFF1A1A2E), border: Border.all(color: AppColors.border.withOpacity(0.3)), borderRadius: BorderRadius.circular(20)),
              child: Column(
                children: [
                  Text(result.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                  const SizedBox(height: 12),
                  Text(result.content, style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.7)),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: result.categories.entries.map((e) => _FortuneStat(label: e.key, score: e.value)).toList()),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                    child: Row(children: [
                      const Text('🍀', style: TextStyle(fontSize: 20)),
                      const SizedBox(width: 10),
                      Expanded(child: Text('오늘의 행운 아이템: ${result.luckyItem}', style: TextStyle(color: AppColors.primary.withOpacity(0.9), fontSize: 12, fontWeight: FontWeight.w700))),
                    ]),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('← 돌아가기', style: TextStyle(color: Colors.white60, fontWeight: FontWeight.w700)),
            ),
          ],
        ],
      ),
    );
  }
}

class _FortuneStat extends StatelessWidget {
  final String label;
  final int score;
  const _FortuneStat({required this.label, required this.score});
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 10)),
      const SizedBox(height: 4),
      Text('$score점', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16)),
    ]);
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w700));
}

// ── 운세 결과 데이터 ──────────────────────────────────────
class _FortuneResult {
  final String emoji;
  final String grade;
  final String title;
  final String content;
  final Map<String, int> categories;
  final String luckyItem;

  const _FortuneResult({required this.emoji, required this.grade, required this.title, required this.content, required this.categories, required this.luckyItem});
}

_FortuneResult _randomResult() {
  final rng = Random();
  final results = [
    _FortuneResult(emoji: '☀️', grade: '대길 (大吉)', title: '오늘은 빛나는 하루!', content: '오늘은 당신에게 행운이 가득한 날입니다. 새로운 도전을 두려워하지 마세요. 재물운이 강하게 흐르며, 마이밍으로 절감한 금액이 배로 돌아올 수 있습니다.', categories: {'재물운': 90, '건강운': 85, '연애운': 78, '직장운': 88}, luckyItem: '🟡 황금색 아이템 or 지갑'),
    _FortuneResult(emoji: '🌤', grade: '길 (吉)', title: '좋은 기운이 흐르는 날', content: '작은 행운들이 겹치는 날입니다. 오늘 지출을 줄이면 더 큰 보상으로 돌아옵니다. 꾸준히 걷고 미션을 완료하면 월세 절감이 순조롭습니다.', categories: {'재물운': 75, '건강운': 80, '연애운': 68, '직장운': 72}, luckyItem: '💙 파란색 물건 or 물 한 잔'),
    _FortuneResult(emoji: '☁️', grade: '보통', title: '평온한 흐름의 하루', content: '오늘은 평범하지만 안정적인 하루입니다. 큰 결정은 내일로 미루는 것이 좋습니다. 만보기를 꾸준히 채우면 작은 행운이 따를 것입니다.', categories: {'재물운': 60, '건강운': 65, '연애운': 55, '직장운': 62}, luckyItem: '🟢 초록색 식물 or 산책'),
    _FortuneResult(emoji: '🌙', grade: '중길 (中吉)', title: '조용한 기운의 날', content: '지금은 때를 기다리는 시간입니다. 무리한 지출을 피하고 적립금을 쌓는 데 집중하세요. 꾸준함이 최고의 전략입니다.', categories: {'재물운': 68, '건강운': 72, '연애운': 60, '직장운': 70}, luckyItem: '⚪ 흰색 또는 은색 아이템'),
  ];
  return results[rng.nextInt(results.length)];
}
