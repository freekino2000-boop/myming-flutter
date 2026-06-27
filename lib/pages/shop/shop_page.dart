// ════════════════════════════════════════════════════════
// shop_page.dart — 교환소
// 지갑(적립금/걸음수/월세절감) + 8개 카테고리 스크롤 탭 + 상품 목록
// ════════════════════════════════════════════════════════
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../theme/app_theme.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key});

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int _tabIndex = 0;

  static const List<_ShopTab> _tabs = [
    _ShopTab(icon: '⚡',  label: '부스터'),
    _ShopTab(icon: '🎫',  label: '이용권'),
    _ShopTab(icon: '💳',  label: '상품권'),
    _ShopTab(icon: '🏠',  label: '주거'),
    _ShopTab(icon: '🍔',  label: '식음료'),
    _ShopTab(icon: '💄',  label: '뷰티'),
    _ShopTab(icon: '📱',  label: '디지털'),
    _ShopTab(icon: '🎁',  label: '기타'),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final wallet = state.walletAmount.floor();
    final steps  = state.steps;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 앱바
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: AppColors.text),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Text('🛍 교환소', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.pushNamed(context, '/coupon'),
                    child: const Text('🎟 쿠폰함', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ],
              ),
            ),

            // 앱 체류 시간 카드
            const _DwellTimeCard(),

            // 지갑 박스
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A3A6B), Color(0xFF2C7FFF)]),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 적립 금액 (메인, 왼쪽 정렬)
                  const Text('💼 적립 금액', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    '₩${wallet.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                    style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900, fontFamily: 'RobotoMono'),
                  ),

                  const SizedBox(height: 12),

                  // 서브 2열
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.08), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        Expanded(child: _WalletSub(
                          icon: '👟',
                          label: '오늘 걸음수',
                          value: '${steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} 보',
                        )),
                        Container(width: 1, height: 36, color: Colors.white.withOpacity(0.15)),
                        Expanded(child: _WalletSub(
                          icon: '🏠',
                          label: '월세 절감',
                          value: '₩${wallet.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                        )),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // 진행바
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('월세 절감 목표 ₩5,000', style: TextStyle(color: Colors.white70, fontSize: 10)),
                      Text(
                        wallet >= 5000 ? '완료 🎉' : '₩${(5000 - wallet).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')} 남음',
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (wallet / 5000).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.white.withOpacity(0.15),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            // 카테고리 탭 (스크롤 칩)
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _tabs.length,
                itemBuilder: (context, i) => GestureDetector(
                  onTap: () => setState(() => _tabIndex = i),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: _tabIndex == i ? AppColors.primaryDim : AppColors.card,
                      border: Border.all(
                        color: _tabIndex == i ? AppColors.primary : AppColors.border,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${_tabs[i].icon} ${_tabs[i].label}',
                      style: TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700,
                        color: _tabIndex == i ? AppColors.primary : AppColors.muted,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // 상품 목록
            Expanded(child: _ShopItemList(tabIndex: _tabIndex, wallet: wallet)),
          ],
        ),
      ),
    );
  }
}

// ── 지갑 서브 수치 ─────────────────────────────────────────
class _WalletSub extends StatelessWidget {
  final String icon;
  final String label;
  final String value;

  const _WalletSub({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(icon, style: const TextStyle(fontSize: 18)),
      const SizedBox(height: 2),
      Text(label, style: const TextStyle(color: Colors.white60, fontSize: 9, fontWeight: FontWeight.w500)),
      const SizedBox(height: 2),
      Text(value, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900)),
    ]);
  }
}

// ── 상품 목록 (탭별) ───────────────────────────────────────
class _ShopItemList extends StatelessWidget {
  final int tabIndex;
  final int wallet;

  const _ShopItemList({required this.tabIndex, required this.wallet});

  static final List<List<_ShopItem>> _itemsByTab = [
    // 0: 부스터
    [
      _ShopItem(emoji: '🚀', name: '만보 부스트',     desc: '걸음당 리워드 2배 (24시간)', price: 200,  boosterEffect: 'manhwaBoost'),
      _ShopItem(emoji: '⚡', name: '속도 부스터 2x',  desc: '카드뉴스 리워드 2배',         price: 150,  boosterEffect: 'speed2x'),
      _ShopItem(emoji: '🌟', name: '속도 부스터 5x',  desc: '카드뉴스 리워드 5배 (1시간)', price: 500,  boosterEffect: 'speed5x'),
      _ShopItem(emoji: '🤖', name: '자동 수집기',     desc: '미션 자동 완료 (3건)',         price: 300,  boosterEffect: 'autoCollect'),
    ],
    // 1: 이용권
    [
      _ShopItem(emoji: '☕', name: '카페 이용권',     desc: '스타벅스 아메리카노 1잔', price: 4500),
      _ShopItem(emoji: '🎬', name: '영화관 이용권',   desc: 'CGV 일반관 1인',         price: 12000),
      _ShopItem(emoji: '🚇', name: '교통카드 충전',   desc: '5,000원 충전',            price: 5000),
      _ShopItem(emoji: '📚', name: '밀리의 서재',     desc: '1개월 구독권',            price: 9900),
    ],
    // 2: 상품권
    [
      _ShopItem(emoji: '🎁', name: '네이버페이 1천원',  desc: '즉시 발행',  price: 1000),
      _ShopItem(emoji: '🎁', name: '카카오페이 3천원',  desc: '즉시 발행',  price: 3000),
      _ShopItem(emoji: '🎁', name: '신세계 5천원',      desc: '즉시 발행',  price: 5000),
      _ShopItem(emoji: '🎁', name: '현금 환급 1만원',   desc: '계좌 입금',  price: 10000),
    ],
    // 3: 주거
    [
      _ShopItem(emoji: '🔌', name: '전기요금 2천원',   desc: '전기세 할인 쿠폰', price: 2000),
      _ShopItem(emoji: '💧', name: '수도요금 1천원',   desc: '수도세 할인 쿠폰', price: 1000),
      _ShopItem(emoji: '🏘', name: '임차 컨설팅',      desc: '1:1 법률 상담 30분', price: 5000),
      _ShopItem(emoji: '🔑', name: '이사 도움',        desc: '이사 업체 할인 쿠폰', price: 8000),
    ],
    // 4~7: 나머지 탭은 placeholder
    [_ShopItem(emoji: '🍕', name: '배달 할인 3천원', desc: '배달의민족 쿠폰', price: 3000)],
    [_ShopItem(emoji: '💄', name: '올리브영 3천원', desc: '올리브영 쿠폰', price: 3000)],
    [_ShopItem(emoji: '📱', name: '통신비 할인',    desc: 'SKT/KT/LGU+ 할인', price: 5000)],
    [_ShopItem(emoji: '🎲', name: '게임 아이템',    desc: '스페셜 아이템 박스', price: 500)],
  ];

  @override
  Widget build(BuildContext context) {
    final items = tabIndex < _itemsByTab.length ? _itemsByTab[tabIndex] : <_ShopItem>[];

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
      itemCount: items.length,
      itemBuilder: (context, i) {
        final item = items[i];
        final canBuy = wallet >= item.price;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: AppTheme.cardDecoration,
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 26))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.text)),
                    const SizedBox(height: 2),
                    Text(item.desc, style: AppTheme.caption),
                    const SizedBox(height: 4),
                    Text('₩${item.price.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.primary)),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: canBuy ? () {
                  final state = context.read<AppState>();
                  if (item.boosterEffect != null) {
                    state.buyBooster(item.boosterEffect!, item.name, item.price);
                  } else {
                    state.spend(item.price);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${item.name} 구매 완료! 🎉'), duration: const Duration(seconds: 2)),
                  );
                } : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: canBuy ? AppColors.primary : AppColors.border,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  elevation: 0,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(canBuy ? '구매' : '부족', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── 앱 체류 시간 카드 ─────────────────────────────────────
class _DwellTimeCard extends StatefulWidget {
  const _DwellTimeCard();
  @override
  State<_DwellTimeCard> createState() => _DwellTimeCardState();
}

class _DwellTimeCardState extends State<_DwellTimeCard> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  String _fmtDuration(int totalSecs) {
    final h = totalSecs ~/ 3600;
    final m = (totalSecs % 3600) ~/ 60;
    final s = totalSecs % 60;
    if (h > 0) {
      return '$h시간 ${m.toString().padLeft(2, '0')}분 ${s.toString().padLeft(2, '0')}초';
    }
    return '${m.toString().padLeft(2, '0')}분 ${s.toString().padLeft(2, '0')}초';
  }

  String _daysSince(String dateStr) {
    final first = DateTime.tryParse(dateStr);
    if (first == null) return '';
    return 'D+${DateTime.now().difference(first).inDays}';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final total   = state.totalSecondsWithCurrent;
    final session = state.currentSessionSeconds;
    final first   = state.firstAccessDate;
    // 오늘 목표: 현재 세션 30분
    final progress = (session / 1800).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 행
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('⏱ 앱 체류 시간',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.text)),
              if (first != null)
                Row(children: [
                  Text(first,
                      style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                        color: AppColors.primaryDim,
                        borderRadius: BorderRadius.circular(6)),
                    child: Text(_daysSince(first),
                        style: const TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                  ),
                ]),
            ],
          ),

          const SizedBox(height: 10),

          // 누적 시간 크게 + 현재 세션
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                _fmtDuration(total),
                style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.primary,
                    fontFamily: 'RobotoMono'),
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('현재 세션',
                      style: TextStyle(fontSize: 9, color: AppColors.muted)),
                  const SizedBox(height: 1),
                  Text(
                    _fmtDuration(session),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.text),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 3),
          const Text('총 누적 체류',
              style: TextStyle(fontSize: 10, color: AppColors.muted)),

          const SizedBox(height: 10),

          // 오늘 목표 진행바
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('오늘 목표 30분',
                  style: TextStyle(fontSize: 10, color: AppColors.muted)),
              Text(
                session >= 1800 ? '달성 완료 🎉' : '${session ~/ 60}분 / 30분',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: session >= 1800 ? AppColors.primary : AppColors.muted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              backgroundColor: AppColors.border,
              valueColor: const AlwaysStoppedAnimation(AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShopTab {
  final String icon;
  final String label;
  const _ShopTab({required this.icon, required this.label});
}

class _ShopItem {
  final String emoji;
  final String name;
  final String desc;
  final int price;
  final String? boosterEffect; // 'manhwaBoost' | 'speed2x' | 'speed5x' | 'autoCollect'
  const _ShopItem({required this.emoji, required this.name, required this.desc, required this.price, this.boosterEffect});
}
