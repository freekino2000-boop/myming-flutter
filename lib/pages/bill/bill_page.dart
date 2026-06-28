// ════════════════════════════════════════════════════════
// bill_page.dart — 고정비 관리
// ════════════════════════════════════════════════════════
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../models/app_state.dart';
import '../../models/bill_model.dart';
import '../../theme/app_theme.dart';

class BillPage extends StatefulWidget {
  const BillPage({super.key});
  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final List<Bill> _bills = List.from(kMockBills);
  int _tabIndex = 0;

  int get _totalMonthly => _bills.fold(0, (s, b) => s + b.amount);

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final wallet = context.watch<AppState>().walletAmount.floor();

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.text),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('📋 고정비 관리',
            style: TextStyle(fontWeight: FontWeight.w900, color: AppColors.text)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.primary),
            onPressed: () => _showAddBillSheet(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── 총고정비 카드 (탭 → 항목 시트) ────────────────
          GestureDetector(
            onTap: () => _showBillListSheet(context),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Color(0xFF1A3A6B), AppColors.primary]),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('이번 달 총 고정비',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('₩${_fmt(_totalMonthly)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
                      ]),
                      Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                        const Text('마이밍 절감액',
                            style: TextStyle(color: Colors.white70, fontSize: 11)),
                        const SizedBox(height: 4),
                        Text('₩${_fmt(wallet)}',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
                      ]),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(children: [
                    ...(_bills.take(5).map((b) => Container(
                          margin: const EdgeInsets.only(right: 6),
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8)),
                          child: Center(
                              child: Text(b.type.icon,
                                  style: const TextStyle(fontSize: 15))),
                        ))),
                    if (_bills.length > 5)
                      Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: 30, height: 30,
                        decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: Text('+${_bills.length - 5}',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.white, fontWeight: FontWeight.w900))),
                      ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.35))),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text('${_bills.length}개 항목 확인',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more, color: Colors.white, size: 14),
                      ]),
                    ),
                  ]),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: (_totalMonthly > 0 ? wallet / _totalMonthly : 0.0).clamp(0.0, 1.0),
                      minHeight: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation(Colors.white),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(
                        '절감 진행률 ${(_totalMonthly > 0 ? (wallet / _totalMonthly) * 100 : 0.0).toStringAsFixed(1)}%',
                        style: const TextStyle(color: Colors.white70, fontSize: 10)),
                    Text('목표 ₩${_fmt(_totalMonthly)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 10)),
                  ]),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // ── 탭 ──────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              _TabBtn(label: '전체 청구서', active: _tabIndex == 0,
                  onTap: () => setState(() => _tabIndex = 0)),
              const SizedBox(width: 8),
              _TabBtn(label: '납부 내역', active: _tabIndex == 1,
                  onTap: () => setState(() => _tabIndex = 1)),
            ]),
          ),

          const SizedBox(height: 4),

          Expanded(
            child: _tabIndex == 1
                ? _LedgerTab()
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: _bills.length,
                    itemBuilder: (context, i) => _BillCard(
                      bill: _bills[i],
                      wallet: wallet,
                      onApply: () => _applyWallet(_bills[i]),
                      onEdit: () => _showEditSheet(context, _bills[i]),
                      onDelete: () => setState(() => _bills.removeAt(i)),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddBillSheet(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('청구서 추가',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  // ── 등록 항목 시트 ──────────────────────────────────────
  void _showBillListSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => StatefulBuilder(
        builder: (ctx2, setSt) => DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.92,
          expand: false,
          builder: (_, scrollCtrl) => Column(children: [
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 4),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('등록된 고정비 항목',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.text)),
                  Text('총 ${_bills.length}개 항목 · 월 ₩${_fmt(_totalMonthly)}',
                      style: const TextStyle(fontSize: 12, color: AppColors.muted)),
                ]),
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx2);
                    _showAddBillSheet(ctx);
                  },
                  icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
                  label: const Text('항목 추가',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
            const Divider(height: 16, indent: 20, endIndent: 20),
            Expanded(
              child: _bills.isEmpty
                  ? const Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text('📋', style: TextStyle(fontSize: 40)),
                        SizedBox(height: 8),
                        Text('등록된 고정비 항목이 없습니다',
                            style: TextStyle(
                                color: AppColors.muted, fontWeight: FontWeight.w700)),
                        SizedBox(height: 4),
                        Text('청구서 추가 버튼을 눌러 등록해 보세요',
                            style: TextStyle(color: AppColors.muted, fontSize: 12)),
                      ]))
                  : ListView.builder(
                      controller: scrollCtrl,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      itemCount: _bills.length + 1,
                      itemBuilder: (_, i) {
                        if (i == _bills.length) {
                          return Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDim,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                            ),
                            child: Row(children: [
                              const Text('합계',
                                  style: TextStyle(
                                      fontSize: 14, fontWeight: FontWeight.w900,
                                      color: AppColors.primary)),
                              const Spacer(),
                              Text('₩${_fmt(_totalMonthly)} / 월',
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w900,
                                      color: AppColors.primary)),
                            ]),
                          );
                        }
                        final bill = _bills[i];
                        return _BillListItem(
                          bill: bill,
                          onDelete: () {
                            setSt(() => _bills.removeAt(i));
                            setState(() {});
                          },
                          onEdit: () {
                            Navigator.pop(ctx2);
                            _showEditSheet(ctx, bill);
                          },
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
    );
  }

  void _applyWallet(Bill bill) {
    final state = context.read<AppState>();
    if (state.walletAmount < bill.amount) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('적립금이 부족합니다. 더 걷고 미션을 완료해 모아보세요! 👟')));
      return;
    }
    state.spend(bill.amount);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${bill.name} ₩${_fmt(bill.amount)} 납부 완료! 🎉')));
  }

  void _showAddBillSheet(BuildContext context) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _BillFormSheet(onSave: (bill) => setState(() => _bills.add(bill))),
    );
  }

  void _showEditSheet(BuildContext context, Bill bill) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) =>
          _BillFormSheet(existingBill: bill, onSave: (_) => setState(() {})),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 청구서 추가/수정 시트
// ══════════════════════════════════════════════════════════
class _BillFormSheet extends StatefulWidget {
  final Bill? existingBill;
  final void Function(Bill) onSave;
  const _BillFormSheet({this.existingBill, required this.onSave});
  @override
  State<_BillFormSheet> createState() => _BillFormSheetState();
}

class _BillFormSheetState extends State<_BillFormSheet> {
  late BillType _type;
  late TextEditingController _nameCtrl;
  late TextEditingController _amountCtrl;
  final FocusNode _nameFocus = FocusNode();
  late int _day;
  CardInfo? _cardInfo;

  @override
  void initState() {
    super.initState();
    final b = widget.existingBill;
    _type       = b?.type ?? BillType.rent;
    _nameCtrl   = TextEditingController(text: b?.name ?? '');
    _amountCtrl = TextEditingController(text: b != null ? '${b.amount}' : '');
    _day        = b?.dayOfMonth ?? 1;
    _cardInfo   = b?.cardInfo;
  }

  @override
  void dispose() {
    _nameFocus.dispose();
    _nameCtrl.dispose();
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _openCardRegister() async {
    final result = await showModalBottomSheet<CardInfo>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => _CardRegisterSheet(existing: _cardInfo),
    );
    if (result != null) setState(() => _cardInfo = result);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(children: [
                Text(widget.existingBill == null ? '청구서 추가' : '청구서 수정',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const Spacer(),
                if (widget.existingBill == null)
                  const Text('추가하면 총고정비에 자동 반영됩니다',
                      style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ]),
              const SizedBox(height: 16),

              // 종류 선택 칩
              Wrap(
                spacing: 8, runSpacing: 6,
                children: BillType.values.map((t) => GestureDetector(
                  onTap: () {
                    final name = t.label.replaceFirst(RegExp(r'^. '), '');
                    setState(() => _type = t);
                    _nameCtrl.value = TextEditingValue(
                      text: name,
                      selection: TextSelection.collapsed(offset: name.length),
                    );
                    _nameFocus.requestFocus();
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _type == t ? AppColors.primaryDim : AppColors.surface,
                      border: Border.all(
                          color: _type == t ? AppColors.primary : AppColors.border,
                          width: 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(t.label,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: _type == t ? AppColors.primary : AppColors.muted)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 12),

              // 항목명 + 금액
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _nameCtrl,
                    focusNode: _nameFocus,
                    decoration: const InputDecoration(
                        labelText: '항목명', border: OutlineInputBorder()),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                        labelText: '월 납부액 (원)', border: OutlineInputBorder()),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              ]),
              const SizedBox(height: 12),

              // 납부일
              Row(children: [
                const Text('납부일: ', style: TextStyle(fontSize: 13)),
                DropdownButton<int>(
                  value: _day,
                  items: List.generate(28, (i) =>
                      DropdownMenuItem(value: i + 1, child: Text('${i + 1}일'))),
                  onChanged: (v) => setState(() => _day = v!),
                ),
              ]),
              const SizedBox(height: 14),

              // ── 결제 방법 (카드 등록) ────────────────────────
              const Text('결제 방법',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.text)),
              const SizedBox(height: 8),
              if (_cardInfo == null)
                GestureDetector(
                  onTap: _openCardRegister,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: AppColors.border, width: 1.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('💳', style: TextStyle(fontSize: 18)),
                      SizedBox(width: 8),
                      Text('카드 등록하기',
                          style: TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w700,
                              color: AppColors.primary)),
                    ]),
                  ),
                )
              else
                _CardPreviewTile(cardInfo: _cardInfo!, onChange: _openCardRegister),

              const SizedBox(height: 20),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final bill = widget.existingBill ?? Bill(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      type: _type,
                      name: _nameCtrl.text.trim(),
                      amount: int.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0,
                      dayOfMonth: _day,
                      cardInfo: _cardInfo,
                    );
                    if (widget.existingBill != null) {
                      bill
                        ..type       = _type
                        ..name       = _nameCtrl.text.trim()
                        ..amount     = int.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0
                        ..dayOfMonth = _day
                        ..cardInfo   = _cardInfo;
                    }
                    widget.onSave(bill);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12))),
                  child: Text(widget.existingBill == null ? '추가' : '저장',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 등록 카드 미리보기 타일 ───────────────────────────────
class _CardPreviewTile extends StatelessWidget {
  final CardInfo cardInfo;
  final VoidCallback onChange;
  const _CardPreviewTile({required this.cardInfo, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryDim,
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(children: [
        const Text('💳', style: TextStyle(fontSize: 22)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(cardInfo.displayName,
              style: const TextStyle(
                  fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text)),
          Text(cardInfo.masked,
              style: const TextStyle(fontSize: 11, color: AppColors.muted,
                  letterSpacing: 1.5)),
          Text('유효기간 ${cardInfo.expiry}',
              style: const TextStyle(fontSize: 11, color: AppColors.muted)),
        ])),
        TextButton(
          onPressed: onChange,
          child: const Text('변경',
              style: TextStyle(
                  fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w700)),
        ),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 카드 등록 시트
// ══════════════════════════════════════════════════════════
class _CardRegisterSheet extends StatefulWidget {
  final CardInfo? existing;
  const _CardRegisterSheet({this.existing});
  @override
  State<_CardRegisterSheet> createState() => _CardRegisterSheetState();
}

class _CardRegisterSheetState extends State<_CardRegisterSheet> {
  String _issuer = '';
  final _numCtrl    = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl    = TextEditingController();
  final _nickCtrl   = TextEditingController();
  final _numFocus    = FocusNode();
  final _expiryFocus = FocusNode();
  final _cvcFocus    = FocusNode();

  bool get _canSave =>
      _issuer.isNotEmpty &&
      _numCtrl.text.replaceAll(' ', '').length == 16 &&
      _expiryCtrl.text.length == 5 &&
      _cvcCtrl.text.length == 3;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _issuer = e.issuer;
      // 기존 카드는 번호 마지막 4자리만 표시
      _numCtrl.text    = '            ${e.last4}'; // 플레이스홀더
      _expiryCtrl.text = e.expiry;
      _nickCtrl.text   = e.cardNickname;
    }
  }

  @override
  void dispose() {
    _numCtrl.dispose(); _expiryCtrl.dispose();
    _cvcCtrl.dispose(); _nickCtrl.dispose();
    _numFocus.dispose(); _expiryFocus.dispose(); _cvcFocus.dispose();
    super.dispose();
  }

  void _save() {
    final raw = _numCtrl.text.replaceAll(' ', '');
    final last4 = raw.length >= 4 ? raw.substring(raw.length - 4) : raw;
    Navigator.pop(context, CardInfo(
      issuer: _issuer,
      last4: last4,
      expiry: _expiryCtrl.text,
      cardNickname: _nickCtrl.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 핸들
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                      color: AppColors.border, borderRadius: BorderRadius.circular(2))),
              ),
              const SizedBox(height: 16),

              // 제목
              Row(children: [
                const Text('💳 내 카드 등록',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                const Spacer(),
                Text(widget.existing == null ? '신규 등록' : '카드 변경',
                    style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              ]),
              const SizedBox(height: 4),
              const Text('카드 정보는 기기에만 저장됩니다',
                  style: TextStyle(fontSize: 11, color: AppColors.muted)),
              const SizedBox(height: 20),

              // 카드사 선택
              const Text('카드사',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: kCardIssuers.map((name) => GestureDetector(
                  onTap: () => setState(() => _issuer = name),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 120),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                    decoration: BoxDecoration(
                      color: _issuer == name ? AppColors.primaryDim : Colors.white,
                      border: Border.all(
                          color: _issuer == name ? AppColors.primary : AppColors.border,
                          width: _issuer == name ? 2 : 1.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(name,
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w700,
                            color: _issuer == name ? AppColors.primary : AppColors.muted)),
                  ),
                )).toList(),
              ),
              const SizedBox(height: 18),

              // 카드 번호
              const Text('카드 번호',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
              const SizedBox(height: 6),
              TextField(
                controller: _numCtrl,
                focusNode: _numFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(16),
                  _CardNumberFormatter(),
                ],
                decoration: InputDecoration(
                  hintText: '0000 0000 0000 0000',
                  border: const OutlineInputBorder(),
                  suffixIcon: _numCtrl.text.replaceAll(' ', '').length == 16
                      ? const Icon(Icons.check_circle, color: AppColors.primary)
                      : null,
                ),
                style: const TextStyle(fontSize: 16, letterSpacing: 2),
                onChanged: (v) {
                  setState(() {});
                  if (v.replaceAll(' ', '').length == 16) {
                    _expiryFocus.requestFocus();
                  }
                },
              ),
              const SizedBox(height: 12),

              // 유효기간 + CVC 한 줄
              Row(children: [
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('유효기간',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: AppColors.muted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _expiryCtrl,
                      focusNode: _expiryFocus,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryFormatter(),
                      ],
                      decoration: const InputDecoration(
                          hintText: 'MM/YY', border: OutlineInputBorder()),
                      style: const TextStyle(fontSize: 14, letterSpacing: 2),
                      onChanged: (v) {
                        setState(() {});
                        if (v.length == 5) _cvcFocus.requestFocus();
                      },
                    ),
                  ]),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('CVC',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                            color: AppColors.muted)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _cvcCtrl,
                      focusNode: _cvcFocus,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      decoration: const InputDecoration(
                          hintText: '•••', border: OutlineInputBorder()),
                      style: const TextStyle(fontSize: 14, letterSpacing: 4),
                      onChanged: (v) => setState(() {}),
                    ),
                  ]),
                ),
              ]),
              const SizedBox(height: 12),

              // 카드 별칭 (선택)
              const Text('카드 별칭 (선택)',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.muted)),
              const SizedBox(height: 6),
              TextField(
                controller: _nickCtrl,
                decoration: const InputDecoration(
                    hintText: '예: 생활비 카드',
                    border: OutlineInputBorder()),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 20),

              // 등록 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _canSave ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.border,
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    widget.existing == null ? '카드 등록 완료' : '카드 변경 완료',
                    style: TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 15,
                        color: _canSave ? Colors.white : AppColors.muted),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── 카드번호 포맷터 (4자리마다 공백) ──────────────────────
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    final digits = value.text.replaceAll(' ', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(digits[i]);
    }
    final str = buf.toString();
    return value.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

// ── 유효기간 포맷터 (MM/YY) ───────────────────────────────
class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue value) {
    final digits = value.text.replaceAll('/', '');
    final buf = StringBuffer();
    for (int i = 0; i < digits.length && i < 4; i++) {
      if (i == 2) buf.write('/');
      buf.write(digits[i]);
    }
    final str = buf.toString();
    return value.copyWith(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 항목 목록 행 (바텀시트 내부)
// ══════════════════════════════════════════════════════════
class _BillListItem extends StatelessWidget {
  final Bill bill;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  const _BillListItem(
      {required this.bill, required this.onDelete, required this.onEdit});

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(14)),
      child: Row(children: [
        Container(
          width: 42, height: 42,
          decoration: BoxDecoration(
              color: AppColors.primaryDim, borderRadius: BorderRadius.circular(10)),
          child: Center(
              child: Text(bill.type.icon, style: const TextStyle(fontSize: 20))),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(bill.name,
                style: const TextStyle(
                    fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.text)),
            const SizedBox(height: 2),
            Text('매월 ${bill.dayOfMonth}일',
                style: const TextStyle(fontSize: 11, color: AppColors.muted)),
            if (bill.cardInfo != null)
              Text(bill.cardInfo!.masked,
                  style: const TextStyle(fontSize: 11, color: AppColors.muted,
                      letterSpacing: 1)),
          ]),
        ),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text('₩${_fmt(bill.amount)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.text)),
          const SizedBox(height: 4),
          Row(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
                onTap: onEdit,
                child: const Text('수정',
                    style: TextStyle(
                        fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700))),
            const SizedBox(width: 8),
            GestureDetector(
                onTap: onDelete,
                child: const Text('삭제',
                    style: TextStyle(
                        fontSize: 11, color: Colors.redAccent, fontWeight: FontWeight.w700))),
          ]),
        ]),
      ]),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 청구서 카드 (전체 청구서 탭)
// ══════════════════════════════════════════════════════════
class _BillCard extends StatelessWidget {
  final Bill bill;
  final int wallet;
  final VoidCallback onApply;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _BillCard({
    required this.bill, required this.wallet,
    required this.onApply, required this.onEdit, required this.onDelete,
  });

  String _fmt(int n) => n.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');

  @override
  Widget build(BuildContext context) {
    final canPay = wallet >= bill.amount;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Container(
            width: 50, height: 50,
            decoration: BoxDecoration(
                color: AppColors.primaryDim, borderRadius: BorderRadius.circular(12)),
            child: Center(
                child: Text(bill.type.icon, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(bill.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.text)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(
                    color: bill.dday == 0 ? const Color(0xFFFFEBEB) : AppColors.primaryDim,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(bill.ddayLabel,
                      style: TextStyle(
                          fontSize: 9, fontWeight: FontWeight.w900,
                          color: bill.dday == 0 ? Colors.red : AppColors.primary)),
                ),
              ]),
              const SizedBox(height: 2),
              Text('${bill.dayOfMonth}일 납부 · 월 ₩${_fmt(bill.amount)}',
                  style: AppTheme.caption),
              if (bill.cardInfo != null)
                Text('💳 ${bill.cardInfo!.displayName} ${bill.cardInfo!.masked}',
                    style: AppTheme.caption.copyWith(fontSize: 10)),
            ]),
          ),
          Column(children: [
            TextButton(
              onPressed: onApply,
              style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  color: canPay ? AppColors.primary : AppColors.border,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(canPay ? '차감 납부' : '잔액 부족',
                    style: TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700,
                        color: canPay ? Colors.white : AppColors.muted)),
              ),
            ),
            Row(mainAxisSize: MainAxisSize.min, children: [
              TextButton(
                onPressed: onEdit,
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('수정',
                    style: TextStyle(fontSize: 11, color: AppColors.muted)),
              ),
              const SizedBox(width: 4),
              TextButton(
                onPressed: onDelete,
                style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                child: const Text('삭제',
                    style: TextStyle(fontSize: 11, color: Colors.redAccent)),
              ),
            ]),
          ]),
        ]),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════
// 납부 내역 탭
// ══════════════════════════════════════════════════════════
class _LedgerTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final entries = context
        .watch<AppState>()
        .ledger
        .where((e) => e.type == 'spend')
        .toList();
    if (entries.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('💸', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 8),
          Text('납부 내역이 없습니다', style: AppTheme.caption),
        ]),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
      itemCount: entries.length,
      itemBuilder: (context, i) {
        final e = entries[i];
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: AppTheme.cardDecoration,
          child: Row(children: [
            Text(e.icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(e.label,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
              Text(e.time, style: AppTheme.caption),
            ])),
            Text('-₩${e.amount}',
                style: const TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 13, color: Colors.redAccent)),
          ]),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════
// 공통 위젯
// ══════════════════════════════════════════════════════════
class _TabBtn extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _TabBtn({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: active ? AppColors.primaryDim : Colors.transparent,
          border: Border.all(
              color: active ? AppColors.primary : AppColors.border, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w700,
                color: active ? AppColors.primary : AppColors.muted)),
      ),
    );
  }
}
