// ════════════════════════════════════════════════════════
// card_news_model.dart — 카드뉴스 데이터 모델 및 목데이터
// 경제·부동산·이슈·임차 카테고리
// ════════════════════════════════════════════════════════

enum NewsCategory { economy, realty, issue, tenancy }
enum NewsTier     { top3, weekly }

extension NewsCategoryExt on NewsCategory {
  String get label {
    switch (this) {
      case NewsCategory.economy:  return '💰 경제';
      case NewsCategory.realty:   return '🏠 부동산';
      case NewsCategory.issue:    return '📢 이슈';
      case NewsCategory.tenancy:  return '🏘 임차';
    }
  }
}

class CardNews {
  final String id;
  final NewsTier tier;
  final int? rank;             // top3만 사용 (1,2,3)
  final NewsCategory category;
  final String emoji;
  final List<String> keywords;
  final String stat;
  final String headline;
  final String summary;
  final String content;        // 기사 본문 (HTML 대신 마크다운/텍스트)
  final String time;
  final int likes;
  final int bookmarks;
  final bool isNew;

  // 런타임 상태 (변경 가능)
  bool isRead    = false;
  bool isLiked   = false;
  bool isBookmarked = false;
  int  likesCount;
  int  bookmarksCount;

  CardNews({
    required this.id,
    required this.tier,
    this.rank,
    required this.category,
    required this.emoji,
    required this.keywords,
    required this.stat,
    required this.headline,
    required this.summary,
    required this.content,
    required this.time,
    required this.likes,
    required this.bookmarks,
    this.isNew = false,
  }) : likesCount = likes, bookmarksCount = bookmarks;
}

// ── 목데이터 (14편) ───────────────────────────────────────
final List<CardNews> kCardNewsList = [
  // ── 일간 탑3 ────────────────────────────────────────────
  CardNews(
    id: 'cn1', tier: NewsTier.top3, rank: 1,
    category: NewsCategory.economy, emoji: '💹',
    keywords: ['가계부채', '금리인하', '1,900조'],
    stat: '▲ 1,906조원',
    headline: '가계부채 1,906조 돌파… 금리 인하 신호에도 "경고등"',
    summary: '한국은행이 올 상반기 가계부채가 1,906조원을 넘어섰다고 발표했다. '
             '기준금리 인하 기대에도 불구하고 주담대 잔액이 역대 최고를 기록하며 우려가 깊어지고 있다.',
    content: '한국은행이 발표한 2분기 가계신용 통계에 따르면 가계부채 잔액이 1,906조원으로 역대 최고치를 경신했다. '
             '전 분기 대비 18조원 증가한 수치다.\n\n'
             '주택담보대출이 핵심 증가 요인으로, 강남권 아파트 신고가 갱신이 이어지는 가운데 실수요자들의 대출 수요가 급증했다. '
             '금융당국은 스트레스 DSR 3단계 조기 적용을 검토 중인 것으로 알려졌다.\n\n'
             '전문가들은 "기준금리 인하를 앞두고 가계부채가 더 빠르게 늘어날 수 있다"며 선제적 관리가 필요하다고 경고했다.',
    time: '14분 전', likes: 1824, bookmarks: 412, isNew: true,
  ),
  CardNews(
    id: 'cn2', tier: NewsTier.top3, rank: 2,
    category: NewsCategory.realty, emoji: '🏠',
    keywords: ['강남', '신고가', '매수심리'],
    stat: '▲ 5.3% (1개월)',
    headline: '강남 3구 호가 한 달새 5%↑… 신고가 행진 재현되나',
    summary: '강남·서초·송파 아파트 단지에서 신고가 거래가 이어지며 수도권 부동산 시장에 온기가 퍼지고 있다.',
    content: '부동산원 실거래 데이터에 따르면 강남 3구의 지난달 아파트 평균 호가 상승률은 5.3%로 수도권 전체 평균을 크게 웃돌았다. '
             '대치동·반포동·잠실동 일대 대단지를 중심으로 신고가 계약이 속출하고 있다.\n\n'
             '시장에서는 금리 인하 기대와 함께 공급 부족 우려가 겹치며 수요가 몰리는 것으로 분석한다.',
    time: '38분 전', likes: 2341, bookmarks: 687, isNew: true,
  ),
  CardNews(
    id: 'cn3', tier: NewsTier.top3, rank: 3,
    category: NewsCategory.economy, emoji: '💵',
    keywords: ['원달러', '환율', '수출'],
    stat: '1,382원 (달러당)',
    headline: '원·달러 환율 1,380원대 안착… 수출 기업 "한숨 돌렸다"',
    summary: '달러 약세와 외국인 증시 순매수가 맞물리며 원화 강세가 이어지고 있다.',
    content: '서울 외환시장에서 원·달러 환율이 1,382원에 마감했다. 연고점(1,480원) 대비 100원 가까이 하락한 수준으로, '
             '전문가들은 당분간 1,350~1,400원 박스권을 예상하고 있다.\n\n'
             '국내 반도체·자동차 수출 기업들은 환율 레벨이 수익성에 긍정적이라는 반응이다.',
    time: '1시간 전', likes: 987, bookmarks: 223,
  ),

  // ── 주간 핫뉴스 ─────────────────────────────────────────
  CardNews(
    id: 'cn4', tier: NewsTier.weekly,
    category: NewsCategory.realty, emoji: '🏗',
    keywords: ['2030영끌', '청약', '생애최초'],
    stat: '20대 매수 비중 사상 최고',
    headline: '2030 "영끌" 귀환… 20대 아파트 매수 비중 역대 최고치',
    summary: '지난달 20대 아파트 매수 거래 비중이 12.4%로 집계됐다. '
             '생애최초 특별공급 확대와 금리 인하 기대가 겹치며 젊은 층의 진입이 빨라지고 있다.',
    content: '한국부동산원에 따르면 지난달 전국 아파트 매수자 중 20대 비중이 12.4%로 역대 최고치를 기록했다.\n\n'
             '생애최초 주택구매자 특별공급 비율 상향, 전세사기 트라우마에 따른 매매 전환 수요, '
             '그리고 금리 인하 기대감이 복합적으로 작용했다.',
    time: '2시간 전', likes: 1532, bookmarks: 398,
  ),
  CardNews(
    id: 'cn5', tier: NewsTier.weekly,
    category: NewsCategory.economy, emoji: '💾',
    keywords: ['삼성전자', 'AI반도체', 'HBM'],
    stat: '2분기 영업익 15조 예상',
    headline: '삼성전자, 2분기 영업익 15조 전망… AI 수주 폭증이 이끈다',
    summary: '증권가가 삼성전자의 2분기 영업이익 컨센서스를 15조원으로 상향했다.',
    content: '국내 주요 증권사들이 삼성전자의 2분기 영업이익 추정치를 평균 15조원으로 제시했다. '
             '전 분기(6.6조원) 대비 두 배 이상 성장하는 수치다.\n\n'
             '핵심 동인은 AI 서버용 고대역폭 메모리(HBM) 수요 급증이다.',
    time: '4시간 전', likes: 876, bookmarks: 201,
  ),
  CardNews(
    id: 'cn6', tier: NewsTier.weekly,
    category: NewsCategory.issue, emoji: '💡',
    keywords: ['전기요금', '공공요금', '하반기'],
    stat: '하반기 인상 여부 결정 임박',
    headline: '전기·가스 요금 또 오르나… 하반기 인상 여부 이달 결정',
    summary: '정부가 이달 말 전기·도시가스 요금 하반기 조정 계획을 발표한다.',
    content: '산업통상자원부가 이달 말 전기·가스 요금 하반기 인상 여부를 결정한다. '
             '한국전력의 누적 부채가 34조원을 넘어선 상황에서 추가 요금 인상이 불가피하다는 의견이 힘을 얻고 있다.\n\n'
             '전기요금의 경우 kWh당 7~10원 수준의 인상이 검토 중인 것으로 알려졌다.',
    time: '6시간 전', likes: 1123, bookmarks: 287,
  ),
  CardNews(
    id: 'cn7', tier: NewsTier.weekly,
    category: NewsCategory.realty, emoji: '🚇',
    keywords: ['GTX', '역세권', '교통호재'],
    stat: '수서~동탄 집값 +22%',
    headline: 'GTX-A 효과 현실화… 수서~동탄 역세권 집값 22% 뛰었다',
    summary: 'GTX-A 개통 후 6개월, 역세권 아파트 시세가 평균 22% 상승했다.',
    content: 'GTX-A 노선이 개통된 지 6개월이 지난 현재, 역세권 아파트의 시세 변화가 본격 집계됐다. '
             '수서·성남·용인·동탄 4개 역 반경 1km 이내 단지의 평균 매매가가 개통 전 대비 22.4% 상승했다.',
    time: '1일 전', likes: 2108, bookmarks: 563,
  ),
  CardNews(
    id: 'cn12', tier: NewsTier.weekly,
    category: NewsCategory.tenancy, emoji: '📄',
    keywords: ['전월세전환율', '월세', '임대차'],
    stat: '전환율 5.5% → 4.9%',
    headline: '전월세 전환율 5년 만에 최저… 전세→월세 전환 비용 줄었다',
    summary: '법정 전월세 전환율이 4.9%로 조정되며 세입자의 월세 전환 부담이 소폭 완화됐다.',
    content: '국토교통부는 주택임대차보호법 시행령 개정을 통해 법정 전월세 전환율을 기존 5.5%에서 4.9%로 낮췄다.\n\n'
             '전환율 인하는 세입자 입장에서 전세를 월세로 전환할 때 적용되는 월세 상한이 낮아진다는 의미다.',
    time: '5시간 전', likes: 1087, bookmarks: 296, isNew: true,
  ),
  CardNews(
    id: 'cn13', tier: NewsTier.weekly,
    category: NewsCategory.tenancy, emoji: '⚖️',
    keywords: ['계약갱신청구권', '임대차3법', '분쟁'],
    stat: '임대차 분쟁 3만 건 돌파',
    headline: '임대차 3법 시행 4년… 계약갱신 분쟁 3만 건 돌파, 판례는?',
    summary: '임대차 3법 시행 4년이 지난 현재 계약갱신청구권을 둘러싼 분쟁이 3만 건을 넘어섰다.',
    content: '임대차 3법 시행 4주년을 맞아 법원의 누적 분쟁 조정 건수가 3만 2,000여 건에 달한다.\n\n'
             '주요 판례에 따르면 임대인의 실거주 목적 거절은 실제 거주 의사가 명확해야 하며, '
             '갱신 거절 후 임대인이 제3자에게 임대하면 세입자는 손해배상을 청구할 수 있다.',
    time: '1일 전', likes: 892, bookmarks: 341,
  ),
  CardNews(
    id: 'cn14', tier: NewsTier.weekly,
    category: NewsCategory.tenancy, emoji: '🏦',
    keywords: ['청년월세', '주거지원', '신청방법'],
    stat: '월 최대 ₩20만 지원',
    headline: '청년 월세 특별지원 2차 신청 시작… 월 최대 20만 원, 내가 해당될까?',
    summary: '국토교통부가 청년 월세 한시 특별지원 2차 신청을 개시했다. '
             '19~34세 무주택 청년이 월세 최대 20만원을 최장 12개월 받을 수 있다.',
    content: '국토교통부와 LH가 공동 운영하는 "청년 월세 한시 특별지원" 2차 신청이 시작됐다.\n\n'
             '지원 대상은 19~34세 무주택 청년으로, 월세 20만원 이하 주택 거주 시 실제 월세의 최대 100%를 지원받는다.\n\n'
             '소득 요건은 기준 중위소득 60% 이하(1인 가구 기준 월 127만원)이며, '
             '신청은 복지로(bokjiro.go.kr) 또는 거주지 주민센터를 통해 가능하다.',
    time: '2일 전', likes: 2456, bookmarks: 731,
  ),
];
