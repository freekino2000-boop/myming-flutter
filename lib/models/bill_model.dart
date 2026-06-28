// ════════════════════════════════════════════════════════
// bill_model.dart — 고정비 청구서 데이터 모델
// ════════════════════════════════════════════════════════

enum BillType { rent, manage, electric, gas, internet, mobile, water, insurance, other }

extension BillTypeExt on BillType {
  String get label {
    switch (this) {
      case BillType.rent:      return '🏠 월세';
      case BillType.manage:    return '🏢 관리비';
      case BillType.electric:  return '⚡ 전기';
      case BillType.gas:       return '🔥 가스';
      case BillType.internet:  return '📡 인터넷';
      case BillType.mobile:    return '📱 통신';
      case BillType.water:     return '💧 수도';
      case BillType.insurance: return '🛡 보험';
      case BillType.other:     return '📄 기타';
    }
  }

  String get icon {
    switch (this) {
      case BillType.rent:      return '🏠';
      case BillType.manage:    return '🏢';
      case BillType.electric:  return '⚡';
      case BillType.gas:       return '🔥';
      case BillType.internet:  return '📡';
      case BillType.mobile:    return '📱';
      case BillType.water:     return '💧';
      case BillType.insurance: return '🛡';
      case BillType.other:     return '📄';
    }
  }
}

// ── 등록 카드 정보 ─────────────────────────────────────
class CardInfo {
  final String issuer;
  final String last4;
  final String expiry;
  final String cardNickname;

  const CardInfo({
    required this.issuer,
    required this.last4,
    required this.expiry,
    this.cardNickname = '',
  });

  String get masked => '**** **** **** $last4';
  String get displayName => cardNickname.isNotEmpty ? cardNickname : issuer;
}

// ── 청구서 ─────────────────────────────────────────────
class Bill {
  final String id;
  BillType type;
  String name;
  int amount;
  int dayOfMonth;
  CardInfo? cardInfo;
  int? savedAmount;

  Bill({
    required this.id,
    required this.type,
    required this.name,
    required this.amount,
    required this.dayOfMonth,
    this.cardInfo,
    this.savedAmount,
  });

  int get dday {
    final now = DateTime.now();
    final target = DateTime(now.year, now.month, dayOfMonth);
    final diff = target.difference(DateTime(now.year, now.month, now.day)).inDays;
    return diff >= 0
        ? diff
        : DateTime(now.year, now.month + 1, dayOfMonth)
            .difference(DateTime(now.year, now.month, now.day))
            .inDays;
  }

  String get ddayLabel => dday == 0 ? 'D-DAY' : 'D-$dday';
}

// ── 주요 카드사 목록 ───────────────────────────────────
const kCardIssuers = [
  '신한카드', 'KB국민카드', '삼성카드', '현대카드',
  '롯데카드', '우리카드', '하나카드', 'BC카드',
  'NH농협카드', '카카오뱅크', '토스뱅크', '케이뱅크',
];

// ── 목데이터 ───────────────────────────────────────────
final List<Bill> kMockBills = [
  Bill(id: 'b1', type: BillType.rent,     name: '월세',     amount: 550000, dayOfMonth: 1),
  Bill(id: 'b2', type: BillType.manage,   name: '관리비',   amount: 85000,  dayOfMonth: 5),
  Bill(id: 'b3', type: BillType.electric, name: '전기요금', amount: 38000,  dayOfMonth: 15),
  Bill(id: 'b4', type: BillType.mobile,   name: '통신요금', amount: 55000,  dayOfMonth: 18,
       cardInfo: const CardInfo(issuer: '신한카드', last4: '4521', expiry: '09/27')),
  Bill(id: 'b5', type: BillType.internet, name: '인터넷',   amount: 33000,  dayOfMonth: 20),
  Bill(id: 'b6', type: BillType.gas,      name: '가스요금', amount: 24000,  dayOfMonth: 25),
];
