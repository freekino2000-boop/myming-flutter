// ════════════════════════════════════════════════════════
// offer_model.dart — 오퍼월 미션 데이터 모델
// HTML OW_OFFERS 배열 그대로 이식
// ════════════════════════════════════════════════════════

enum OfferType { simple, recom, high }
enum OfferCategory { rent, telecom, utility, subscribe, manage, insurance, transit, news }

extension OfferCategoryExt on OfferCategory {
  String get label {
    switch (this) {
      case OfferCategory.rent:      return '🏠 월세';
      case OfferCategory.telecom:   return '📱 통신비';
      case OfferCategory.utility:   return '⚡ 공과금';
      case OfferCategory.subscribe: return '🔄 구독료';
      case OfferCategory.manage:    return '🏢 관리비';
      case OfferCategory.insurance: return '🛡 보험료';
      case OfferCategory.transit:   return '🚇 교통비';
      case OfferCategory.news:      return '📰 카드뉴스';
    }
  }
}

class Offer {
  final String id;
  final OfferCategory category;
  final OfferType type;
  final String icon;
  final String name;
  final String desc;
  final int reward;
  bool clicked = false;

  Offer({required this.id, required this.category, required this.type,
      required this.icon, required this.name, required this.desc, required this.reward});
}

final List<Offer> kOffers = [
  // ── 월세 ──
  Offer(id: 'ow_rent_extra',   category: OfferCategory.rent,      type: OfferType.high,   icon: '🏠', name: '월세 수수료 0원 만들기',      desc: '미션 완료 시 월세 수수료 적립 지급',         reward: 5000),
  Offer(id: 'ow_ad_watch',     category: OfferCategory.rent,      type: OfferType.simple, icon: '🎥', name: '절감 보너스 영상 보기',        desc: '영상 보고 월세 절감머니 받기',               reward: 10),
  Offer(id: 'ow_card_view',    category: OfferCategory.rent,      type: OfferType.simple, icon: '🎁', name: '월세 절감 카드 3개 보기',      desc: '카드를 3개 이상 확인하면 절감머니 적립',     reward: 30),
  Offer(id: 'ow_rent_subsidy', category: OfferCategory.rent,      type: OfferType.high,   icon: '🏛', name: '청년 월세 지원 정책 신청',     desc: '국비 최대 ₩20만 지원 연동받기',              reward: 2000),
  // ── 통신비 ──
  Offer(id: 'ow_telecom',      category: OfferCategory.telecom,   type: OfferType.recom,  icon: '📱', name: '통신비 절감 플랜 확인하기',    desc: '통신비 혜택 확인하고 절감머니 받기',          reward: 500),
  Offer(id: 'ow_internet',     category: OfferCategory.telecom,   type: OfferType.high,   icon: '🌐', name: '인터넷 가입 혜택으로 받기',    desc: '인터넷 가입 상담 완료 시 지급',              reward: 8000),
  Offer(id: 'ow_mvno',         category: OfferCategory.telecom,   type: OfferType.recom,  icon: '📲', name: '알뜰폰 요금제 비교하기',       desc: '요금제 변경 시 절감머니 추가 지급',           reward: 800),
  Offer(id: 'ow_wifi',         category: OfferCategory.telecom,   type: OfferType.simple, icon: '📡', name: '홈 인터넷 절감 비교',          desc: '인터넷 요금 비교 완료 시 지급',              reward: 200),
  // ── 공과금 ──
  Offer(id: 'ow_electric',     category: OfferCategory.utility,   type: OfferType.recom,  icon: '⚡', name: '전기요금 절감 신청하기',       desc: '에너지 절감 신청하고 절감머니 받기',          reward: 300),
  Offer(id: 'ow_gas',          category: OfferCategory.utility,   type: OfferType.recom,  icon: '🔥', name: '가스요금 절감 신청하기',       desc: '도시가스 절감 신청하고 받기',                reward: 400),
  Offer(id: 'ow_water',        category: OfferCategory.utility,   type: OfferType.simple, icon: '💧', name: '수도요금 절약 팁 받기',        desc: '절약 팁 확인 후 절감머니 지급',              reward: 100),
  // ── 구독료 ──
  Offer(id: 'ow_subscribe',    category: OfferCategory.subscribe, type: OfferType.recom,  icon: '🔄', name: '매달 구독료 줄이기',           desc: '구독 혜택 가입하고 절감머니 받기',            reward: 500),
  Offer(id: 'ow_ott',          category: OfferCategory.subscribe, type: OfferType.recom,  icon: '📺', name: 'OTT 요금 비교하고 절감하기',   desc: '스트리밍 서비스 할인 혜택 받기',             reward: 300),
  Offer(id: 'ow_ott_bundle',   category: OfferCategory.subscribe, type: OfferType.recom,  icon: '🎬', name: '통신사 OTT 결합 할인 받기',    desc: '결합 할인 연동하고 절감머니 받기',            reward: 600),
  Offer(id: 'ow_magazine',     category: OfferCategory.subscribe, type: OfferType.simple, icon: '📰', name: '디지털 구독 정리하기',         desc: '안 쓰는 구독 정리 완료 시 지급',             reward: 150),
  // ── 관리비 ──
  Offer(id: 'ow_cleaning',     category: OfferCategory.manage,    type: OfferType.recom,  icon: '🧼', name: '입주청소·짐보관 혜택 받기',    desc: '청소 서비스 예약하고 절감머니 받기',          reward: 1000),
  Offer(id: 'ow_management',   category: OfferCategory.manage,    type: OfferType.high,   icon: '🏢', name: '관리비 절감 서비스 신청하기',  desc: '관리비 절감 서비스 신청 시 지급',            reward: 2000),
  Offer(id: 'ow_parking',      category: OfferCategory.manage,    type: OfferType.simple, icon: '🅿', name: '주차비 할인 혜택 연동',        desc: '건물 주차 할인 연동하고 받기',               reward: 300),
  // ── 보험료 ──
  Offer(id: 'ow_ins_life',     category: OfferCategory.insurance, type: OfferType.high,   icon: '🛡', name: '생명보험 리모델링 상담',        desc: '보험 점검 상담 완료 시 지급',                reward: 5000),
  Offer(id: 'ow_ins_car',      category: OfferCategory.insurance, type: OfferType.high,   icon: '🚗', name: '자동차보험 최저가 비교',        desc: '보험료 비교 완료 시 절감머니 지급',           reward: 3000),
  Offer(id: 'ow_ins_health',   category: OfferCategory.insurance, type: OfferType.recom,  icon: '💊', name: '실손보험 보장 점검하기',        desc: '보장 공백 점검 완료 시 지급',                reward: 1000),
  Offer(id: 'ow_insurance',    category: OfferCategory.insurance, type: OfferType.high,   icon: '📋', name: '보험료 종합 절감 분석',         desc: '보험료 점검 신청 시 지급',                   reward: 3000),
  // ── 교통비 ──
  Offer(id: 'ow_transit',      category: OfferCategory.transit,   type: OfferType.recom,  icon: '🚇', name: '대중교통 환급 혜택 받기',       desc: '교통카드 혜택 연동 완료 시 지급',             reward: 500),
  Offer(id: 'ow_fuel',         category: OfferCategory.transit,   type: OfferType.high,   icon: '⛽', name: '주유비 절감 카드 연동',         desc: '제휴 카드 연동 완료 시 지급',                reward: 2000),
  Offer(id: 'ow_carpool',      category: OfferCategory.transit,   type: OfferType.simple, icon: '🚌', name: '카풀 서비스 가입하기',          desc: '카풀 가입 완료 시 절감머니 지급',             reward: 300),
  // ── 카드뉴스 ──
  Offer(id: 'ow_cn_daily',     category: OfferCategory.news,      type: OfferType.simple, icon: '📰', name: '오늘의 카드뉴스 3건 읽기',      desc: '카드뉴스 탭에서 기사 3건 완독 시 지급',       reward: 30),
  Offer(id: 'ow_cn_streak',    category: OfferCategory.news,      type: OfferType.recom,  icon: '🔥', name: '3일 연속 카드뉴스 미션 완료',   desc: '3일 연속 일일 미션 완료 시 보너스 지급',      reward: 150),
  Offer(id: 'ow_cn_economy',   category: OfferCategory.news,      type: OfferType.simple, icon: '💰', name: '경제 카드뉴스 광고 시청',       desc: '경제 카테고리 기사 광고 시청 완료 시 지급',   reward: 20),
  Offer(id: 'ow_cn_tech',      category: OfferCategory.news,      type: OfferType.simple, icon: '💡', name: '테크 카드뉴스 광고 시청',       desc: '테크 카테고리 기사 광고 시청 완료 시 지급',   reward: 20),
];
