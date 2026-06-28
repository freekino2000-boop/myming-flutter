// ════════════════════════════════════════════════════════
// home_page.dart — 홈 화면 (HTML 동기화)
// 월세절감 메인카드 / 만보기 / 오늘의보너스 / 오퍼월 인라인
// ════════════════════════════════════════════════════════
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pedometer/pedometer.dart';

import '../../config/features.dart';
import '../../models/app_state.dart';
import '../../models/offer_model.dart';
import '../../services/offerwall_service.dart';
import '../../theme/app_theme.dart';
import '../offerwall/offerwall_page.dart';
import 'widgets/pedometer_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/bill_history_entry.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  StreamSubscription<StepCount>? _stepSub;
  int _initialSteps = 0;
  bool _pedometerStarted = false;

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  @override
  void dispose() {
    _stepSub?.cancel();
    super.dispose();
  }

  void _initPedometer() {
    _stepSub = Pedometer.stepCountStream.listen(
      (StepCount event) {
        if (!mounted) return;
        final state = context.read<AppState>();
        if (!_pedometerStarted) {
          _initialSteps = event.steps;
          _pedometerStarted = true;
        }
        final todaySteps = event.steps - _initialSteps;
        state.steps = todaySteps;
        state.refresh();
      },
      onError: (error) => debugPrint('Pedometer error: $error'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── 앱바 ────────────────────────────────────────
            SliverAppBar(
              floating: true,
              backgroundColor: AppColors.surface,
              elevation: 0,
              centerTitle: false,
              automaticallyImplyLeading: false,
              title: Text('마이밍', style: AppTheme.headline2.copyWith(color: AppColors.primary, fontSize: 26)),
              actions: [
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/profile'),
                  icon: const CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primaryDim,
                    child: Text('👤', style: TextStyle(fontSize: 14)),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, '/shop'),
                  icon: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text('🎁', style: TextStyle(fontSize: 14)),
                  ),
                ),
                const SizedBox(width: 4),
              ],
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── 1. 월세 절감 포인트 메인 카드 ── 항상 표시
                  const _RentSavingCard(),

                  // ── 1-1. 고정비 등록하기 배너 ── Features.bill
                  if (Features.bill) ...[
                    const SizedBox(height: 12),
                    const _FixedCostBanner(),
                  ],

                  // ── 2. 만보기 카드 ── Features.pedometer
                  if (Features.pedometer) ...[
                    const SizedBox(height: 12),
                    const PedometerCard(),
                  ],

                  // ── 3. 절감머니 내역 진입 ── Features.bill
                  if (Features.bill) ...[
                    const SizedBox(height: 12),
                    const BillHistoryEntry(),
                  ],

                  // ── 4. 빠른 액션 (출석/행운뽑기/광고보너스)
                  //    내부 버튼도 features.dart로 제어됩니다
                  const SizedBox(height: 12),
                  const QuickActionSection(),

                  // ── 5. 고정비 절감 미션 인라인 ── Features.offerwall
                  if (Features.offerwall) ...[
                    const SizedBox(height: 16),
                    const _OfferwallInlineSection(),
                  ],

                  const SizedBox(height: 80),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 1-1. 고정비 등록하기 배너
// ══════════════════════════════════════════════════════════
class _FixedCostBanner extends StatelessWidget {
  const _FixedCostBanner();

  static const _items = [
    ('🏠', '월세'),
    ('📱', '통신비'),
    ('⚡', '공과금'),
    ('🔄', '구독료'),
    ('🛡', '보험료'),
  ];

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/bill'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('📋 고정비 등록하기',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.text)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('등록하기 ›',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            const Text('월세·통신비·공과금 등 고정 지출을 등록해 절감 현황을 파악하세요',
                style: TextStyle(fontSize: 11, color: AppColors.muted, height: 1.4)),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: _items.map((item) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryDim,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text('${item.$1} ${item.$2}',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 1. 월세 절감 포인트 메인 카드 (HTML homeMainCard 이식)
// ══════════════════════════════════════════════════════════
class _RentSavingCard extends StatelessWidget {
  const _RentSavingCard();

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<AppState>().walletAmount.floor();
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/shop'),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A4FA8), AppColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), blurRadius: 16, offset: const Offset(0, 6)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('🏠 이번 달 월세 절감 포인트',
                      style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        _fmt(wallet),
                        style: const TextStyle(color: Colors.white, fontSize: 34, fontWeight: FontWeight.w900),
                      ),
                      const SizedBox(width: 4),
                      const Text('원 ›', style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
                    ),
                    child: const Text('절감머니 내역 ›',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),
            ),
            // 금화 스택 SVG → Flutter 위젯으로 재현
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _GoldCoinStack(),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

class _GoldCoinStack extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 64,
      child: CustomPaint(painter: _CoinPainter()),
    );
  }
}

class _CoinPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    void drawCoin(double cx, double cy, double rx, double ry, Color top, Color side) {
      // 옆면
      final sidePaint = Paint()..color = side;
      canvas.drawRect(Rect.fromLTWH(cx - rx, cy, rx * 2, ry * 0.8), sidePaint);
      // 아랫면
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy + ry * 0.8), width: rx * 2, height: ry), sidePaint);
      // 윗면
      final topPaint = Paint()..color = top;
      canvas.drawOval(Rect.fromCenter(center: Offset(cx, cy), width: rx * 2, height: ry), topPaint);
    }

    // 뒤 스택
    drawCoin(w * 0.72, h * 0.35, w * 0.22, h * 0.13, const Color(0xFFF5C842), const Color(0xFFDDA00A));
    // 중간 스택
    drawCoin(w * 0.50, h * 0.52, w * 0.22, h * 0.13, const Color(0xFFFFE07A), const Color(0xFFDDA00A));
    // 앞 코인 (크게)
    drawCoin(w * 0.80, h * 0.68, w * 0.20, h * 0.12, const Color(0xFFFFD043), const Color(0xFFB38000));

    // ₩ 텍스트
    final tp = TextPainter(
      text: const TextSpan(
        text: '₩',
        style: TextStyle(color: Color(0xFFB38000), fontSize: 10, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w * 0.73, h * 0.62));
  }

  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════
// 5. 고정비 절감 미션 인라인 섹션 (HTML owFilterBar + owInlineList)
// ══════════════════════════════════════════════════════════
class _OfferwallInlineSection extends StatefulWidget {
  const _OfferwallInlineSection();

  @override
  State<_OfferwallInlineSection> createState() => _OfferwallInlineSectionState();
}

class _OfferwallInlineSectionState extends State<_OfferwallInlineSection> {
  OfferCategory? _cat; // null = 전체

  static const _cats = [
    (null,                     '🔥 전체'),
    (OfferCategory.rent,       '🏠 월세'),
    (OfferCategory.telecom,    '📱 통신비'),
    (OfferCategory.utility,    '⚡ 공과금'),
    (OfferCategory.subscribe,  '🔄 구독료'),
    (OfferCategory.manage,     '🏢 관리비'),
    (OfferCategory.insurance,  '🛡 보험료'),
    (OfferCategory.transit,    '🚇 교통비'),
  ];

  List<Offer> get _filtered => _cat == null
      ? kOffers
      : kOffers.where((o) => o.category == _cat).toList();

  void _openModal(BuildContext context, Offer offer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => OfferModal(
        offer: offer,
        onComplete: () async {
          setState(() => offer.clicked = true);
          Navigator.pop(context);
          final state = context.read<AppState>();
          if (state.apiEnabled) {
            try {
              final res = await OfferwallService.instance.complete(offer.id);
              state.walletAmount = res.balance;
              state.addLedger(offer.icon, offer.name, res.reward, 'earn');
              state.refresh();
            } catch (_) {
              state.earn(offer.icon, offer.name, offer.reward);
            }
          } else {
            state.earn(offer.icon, offer.name, offer.reward);
          }
          if (!context.mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('${offer.name} 완료! ₩${offer.reward} 적립 🎉')));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 섹션 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('고정비 절감 미션',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.text)),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, '/offerwall'),
              child: const Text('전체보기 ›',
                  style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // 카테고리 필터 탭 (HTML owFilterBar)
        SizedBox(
          height: 34,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _cats.length,
            itemBuilder: (_, i) {
              final (cat, label) = _cats[i];
              final active = _cat == cat;
              return GestureDetector(
                onTap: () => setState(() => _cat = cat),
                child: Container(
                  margin: const EdgeInsets.only(right: 7),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primaryDim : AppColors.card,
                    border: Border.all(
                        color: active ? AppColors.primary : AppColors.border, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(label,
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: active ? AppColors.primary : AppColors.muted)),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),

        // 미션 목록 (HTML owInlineList)
        ..._filtered.map((offer) => _OfferwallInlineCard(
          offer: offer,
          onTap: () => _openModal(context, offer),
        )),
      ],
    );
  }
}

class _OfferwallInlineCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onTap;
  const _OfferwallInlineCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = offer.type == OfferType.high
        ? const Color(0xFFE06C00)
        : offer.type == OfferType.recom
            ? AppColors.primary
            : AppColors.muted;
    final typeLabel = offer.type == OfferType.high
        ? '💰 고보상'
        : offer.type == OfferType.recom
            ? '🌟 추천'
            : '⚡ 간단';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(
              color: offer.type == OfferType.high
                  ? const Color(0xFFE06C00).withValues(alpha: 0.25)
                  : AppColors.border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                  color: AppColors.primaryDim, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(offer.icon, style: const TextStyle(fontSize: 22))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4)),
                      child: Text(typeLabel,
                          style: TextStyle(
                              fontSize: 9, fontWeight: FontWeight.w700, color: typeColor)),
                    ),
                    const SizedBox(width: 4),
                    Text(offer.category.label, style: AppTheme.caption.copyWith(fontSize: 9)),
                  ]),
                  const SizedBox(height: 3),
                  Text(offer.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text)),
                  Text(offer.desc,
                      style: AppTheme.caption.copyWith(fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('+₩${_fmt(offer.reward)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: AppColors.primary)),
                if (offer.clicked)
                  const Text('완료', style: TextStyle(fontSize: 10, color: AppColors.muted))
                else
                  const Text('참여하기 ›',
                      style: TextStyle(fontSize: 10, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}
