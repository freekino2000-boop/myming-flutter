import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/offer_model.dart';
import '../../services/ad_service.dart';
import '../../services/offerwall_service.dart';
import '../../theme/app_theme.dart';

class OfferwallPage extends StatefulWidget {
  const OfferwallPage({super.key});
  @override
  State<OfferwallPage> createState() => _OfferwallPageState();
}

class _OfferwallPageState extends State<OfferwallPage> {
  OfferCategory? _cat;  // null=전체
  int _tabType = 0;     // 0=전체, 1=추천, 2=간단, 3=고보상

  List<Offer> get _filtered {
    var list = _cat == null ? kOffers : kOffers.where((o) => o.category == _cat).toList();
    switch (_tabType) {
      case 1: list = list.where((o) => o.type == OfferType.recom).toList(); break;
      case 2: list = list.where((o) => o.type == OfferType.simple).toList(); break;
      case 3: list = list.where((o) => o.type == OfferType.high).toList(); break;
    }
    // 고보상 먼저 정렬
    list.sort((a, b) => b.reward.compareTo(a.reward));
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final wallet = state.walletAmount.floor();

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: Column(
          children: [
            // 앱바
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
              child: Row(children: [
                IconButton(icon: const Icon(Icons.arrow_back, color: AppColors.text), onPressed: () => Navigator.pop(context)),
                const Text('🎯 고정비 절감 미션', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(10)),
                  child: Text('₩${_fmt(wallet)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.primary)),
                ),
              ]),
            ),

            // 배너
            Container(
              margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF1A4FA8), AppColors.primary]),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(children: [
                const Text('🎯', style: TextStyle(fontSize: 26)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('고정비 줄이고 월세 절감!', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13)),
                  Text('미션 완료 시 최대 ₩8,000 적립', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                  child: const Text('누적 절감액', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),

            const SizedBox(height: 10),

            // 카테고리 탭 (스크롤)
            SizedBox(height: 34, child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _CatChip(label: '🔥 전체', active: _cat == null, onTap: () => setState(() => _cat = null)),
                ...OfferCategory.values.map((c) => _CatChip(label: c.label, active: _cat == c, onTap: () => setState(() => _cat = c))),
              ],
            )),

            const SizedBox(height: 8),

            // 타입 탭 행
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                _TypeTab(label: '전체',   active: _tabType == 0, onTap: () => setState(() => _tabType = 0)),
                const SizedBox(width: 6),
                _TypeTab(label: '🌟 추천', active: _tabType == 1, onTap: () => setState(() => _tabType = 1)),
                const SizedBox(width: 6),
                _TypeTab(label: '⚡ 간단', active: _tabType == 2, onTap: () => setState(() => _tabType = 2)),
                const SizedBox(width: 6),
                _TypeTab(label: '💰 고보상', active: _tabType == 3, onTap: () => setState(() => _tabType = 3)),
              ]),
            ),

            const SizedBox(height: 8),

            // 미션 목록
            Expanded(
              child: _filtered.isEmpty
                  ? Center(child: Text('해당하는 미션이 없습니다', style: AppTheme.caption))
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      itemCount: _filtered.length,
                      itemBuilder: (_, i) => _OfferCard(offer: _filtered[i], onTap: () => _openModal(context, _filtered[i])),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _openModal(BuildContext context, Offer offer) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => OfferModal(offer: offer, onComplete: () async {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${offer.name} 완료! ₩${_fmt(offer.reward)} 적립 🎉')));
      }),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ── 오퍼 카드 ─────────────────────────────────────────────
class _OfferCard extends StatelessWidget {
  final Offer offer;
  final VoidCallback onTap;
  const _OfferCard({required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final typeColor = offer.type == OfferType.high ? const Color(0xFFE06C00)
        : offer.type == OfferType.recom ? AppColors.primary : AppColors.muted;
    final typeLabel = offer.type == OfferType.high ? '💰 고보상'
        : offer.type == OfferType.recom ? '🌟 추천' : '⚡ 간단';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: offer.type == OfferType.high ? const Color(0xFFE06C00).withValues(alpha: 0.3) : AppColors.border),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Container(
              width: 48, height: 48,
              decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Text(offer.icon, style: const TextStyle(fontSize: 24))),
            ),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: typeColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(5)),
                  child: Text(typeLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: typeColor))),
                const SizedBox(width: 4),
                Text(offer.category.label, style: AppTheme.caption.copyWith(fontSize: 9)),
              ]),
              const SizedBox(height: 4),
              Text(offer.name, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: AppColors.text)),
              const SizedBox(height: 2),
              Text(offer.desc, style: AppTheme.caption.copyWith(fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('+₩${_fmt(offer.reward)}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.primary)),
              if (offer.clicked)
                const Text('완료', style: TextStyle(fontSize: 10, color: AppColors.muted))
              else
                const Text('참여하기 ›', style: TextStyle(fontSize: 10, color: AppColors.primary)),
            ]),
          ]),
        ),
      ),
    );
  }

  String _fmt(int n) => n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
}

// ── 오퍼 상세 모달 ────────────────────────────────────────
class OfferModal extends StatefulWidget {
  final Offer offer;
  final VoidCallback onComplete;
  const OfferModal({super.key, required this.offer, required this.onComplete});
  @override
  State<OfferModal> createState() => _OfferModalState();
}

class _OfferModalState extends State<OfferModal> {
  int _step = 0; // 0=설명, 1=진행중, 2=완료
  bool _adLoading = false;

  Future<void> _startMission() async {
    if (widget.offer.id == 'ow_ad_watch') {
      setState(() => _adLoading = true);
      final rewarded = await AdService.instance.showRewardedAd(
        onRewarded: () {
          if (mounted) setState(() { _step = 2; _adLoading = false; });
        },
      );
      if (!rewarded && mounted) setState(() => _adLoading = false);
    } else {
      setState(() => _step = 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final o = widget.offer;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(o.icon, style: const TextStyle(fontSize: 44)),
            const SizedBox(height: 12),
            Text(o.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.text), textAlign: TextAlign.center),
            const SizedBox(height: 6),
            Text(o.desc, style: AppTheme.caption.copyWith(height: 1.5), textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: AppColors.primaryDim, borderRadius: BorderRadius.circular(14)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🎁 미션 완료 시 보상', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 8),
                Text('+₩${o.reward.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary)),
              ]),
            ),
            const SizedBox(height: 18),
            if (_step == 0)
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  onPressed: _adLoading ? null : () => _startMission(),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: _adLoading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : Text(widget.offer.id == 'ow_ad_watch' ? '🎥 광고 보고 보상 받기' : '미션 참여하기',
                          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 15)),
                ),
              )
            else if (_step == 1)
              Column(children: [
                const CircularProgressIndicator(color: AppColors.primary),
                const SizedBox(height: 12),
                const Text('미션 진행 중...', style: TextStyle(color: AppColors.muted)),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => setState(() => _step = 2),
                  child: const Text('미션 완료 확인', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ])
            else
              SizedBox(width: double.infinity,
                child: ElevatedButton(
                  onPressed: o.clicked ? null : widget.onComplete,
                  style: ElevatedButton.styleFrom(backgroundColor: o.clicked ? AppColors.border : const Color(0xFF27AE60), minimumSize: const Size(0, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(o.clicked ? '이미 완료된 미션입니다' : '✅ 보상 받기', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, fontSize: 15)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── 유틸 위젯 ─────────────────────────────────────────────
class _CatChip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _CatChip({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 7),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDim : AppColors.card,
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: active ? AppColors.primary : AppColors.muted)),
      ),
    );
  }
}

class _TypeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TypeTab({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return Expanded(child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDim : Colors.transparent,
          border: Border.all(color: active ? AppColors.primary : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? AppColors.primary : AppColors.muted)),
      ),
    ));
  }
}
