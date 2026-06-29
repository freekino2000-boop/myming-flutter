const router = require('express').Router();
const { query, validationResult } = require('express-validator');
const db   = require('../config/db');
const auth = require('../middleware/auth');

const OFFERS = [
  // 월세
  { id:'ow_rent_extra',   icon:'🏠', name:'월세 수수료 0원 만들기',      desc:'미션 완료 시 월세 수수료 적립 지급',         category:'rent',      type:'high',   reward:5000 },
  { id:'ow_ad_watch',     icon:'🎥', name:'절감 보너스 영상 보기',        desc:'영상 보고 월세 절감머니 받기',               category:'rent',      type:'simple', reward:10   },
  { id:'ow_card_view',    icon:'🎁', name:'월세 절감 카드 3개 보기',      desc:'카드를 3개 이상 확인하면 절감머니 적립',     category:'rent',      type:'simple', reward:30   },
  { id:'ow_rent_subsidy', icon:'🏛', name:'청년 월세 지원 정책 신청',     desc:'국비 최대 ₩20만 지원 연동받기',              category:'rent',      type:'high',   reward:2000 },
  // 통신비
  { id:'ow_telecom',      icon:'📱', name:'통신비 절감 플랜 확인하기',    desc:'통신비 혜택 확인하고 절감머니 받기',          category:'telecom',   type:'recom',  reward:500  },
  { id:'ow_internet',     icon:'🌐', name:'인터넷 가입 혜택으로 받기',    desc:'인터넷 가입 상담 완료 시 지급',              category:'telecom',   type:'high',   reward:8000 },
  { id:'ow_mvno',         icon:'📲', name:'알뜰폰 요금제 비교하기',       desc:'요금제 변경 시 절감머니 추가 지급',           category:'telecom',   type:'recom',  reward:800  },
  { id:'ow_wifi',         icon:'📡', name:'홈 인터넷 절감 비교',          desc:'인터넷 요금 비교 완료 시 지급',              category:'telecom',   type:'simple', reward:200  },
  // 공과금
  { id:'ow_electric',     icon:'⚡', name:'전기요금 절감 신청하기',       desc:'에너지 절감 신청하고 절감머니 받기',          category:'utility',   type:'recom',  reward:300  },
  { id:'ow_gas',          icon:'🔥', name:'가스요금 절감 신청하기',       desc:'도시가스 절감 신청하고 받기',                category:'utility',   type:'recom',  reward:400  },
  { id:'ow_water',        icon:'💧', name:'수도요금 절약 팁 받기',        desc:'절약 팁 확인 후 절감머니 지급',              category:'utility',   type:'simple', reward:100  },
  // 구독료
  { id:'ow_subscribe',    icon:'🔄', name:'매달 구독료 줄이기',           desc:'구독 혜택 가입하고 절감머니 받기',            category:'subscribe', type:'recom',  reward:500  },
  { id:'ow_ott',          icon:'📺', name:'OTT 요금 비교하고 절감하기',   desc:'스트리밍 서비스 할인 혜택 받기',             category:'subscribe', type:'recom',  reward:300  },
  { id:'ow_ott_bundle',   icon:'🎬', name:'통신사 OTT 결합 할인 받기',    desc:'결합 할인 연동하고 절감머니 받기',            category:'subscribe', type:'recom',  reward:600  },
  { id:'ow_magazine',     icon:'📰', name:'디지털 구독 정리하기',         desc:'안 쓰는 구독 정리 완료 시 지급',             category:'subscribe', type:'simple', reward:150  },
  // 관리비
  { id:'ow_cleaning',     icon:'🧼', name:'입주청소·짐보관 혜택 받기',    desc:'청소 서비스 예약하고 절감머니 받기',          category:'manage',    type:'recom',  reward:1000 },
  { id:'ow_management',   icon:'🏢', name:'관리비 절감 서비스 신청하기',  desc:'관리비 절감 서비스 신청 시 지급',            category:'manage',    type:'high',   reward:2000 },
  { id:'ow_parking',      icon:'🅿', name:'주차비 할인 혜택 연동',        desc:'건물 주차 할인 연동하고 받기',               category:'manage',    type:'simple', reward:300  },
  // 보험료
  { id:'ow_ins_life',     icon:'🛡', name:'생명보험 리모델링 상담',        desc:'보험 점검 상담 완료 시 지급',                category:'insurance', type:'high',   reward:5000 },
  { id:'ow_ins_car',      icon:'🚗', name:'자동차보험 최저가 비교',        desc:'보험료 비교 완료 시 절감머니 지급',           category:'insurance', type:'high',   reward:3000 },
  { id:'ow_ins_health',   icon:'💊', name:'실손보험 보장 점검하기',        desc:'보장 공백 점검 완료 시 지급',                category:'insurance', type:'recom',  reward:1000 },
  { id:'ow_insurance',    icon:'📋', name:'보험료 종합 절감 분석',         desc:'보험료 점검 신청 시 지급',                   category:'insurance', type:'high',   reward:3000 },
  // 교통비
  { id:'ow_transit',      icon:'🚇', name:'대중교통 환급 혜택 받기',       desc:'교통카드 혜택 연동 완료 시 지급',             category:'transit',   type:'recom',  reward:500  },
  { id:'ow_fuel',         icon:'⛽', name:'주유비 절감 카드 연동',         desc:'제휴 카드 연동 완료 시 지급',                category:'transit',   type:'high',   reward:2000 },
  { id:'ow_carpool',      icon:'🚌', name:'카풀 서비스 가입하기',          desc:'카풀 가입 완료 시 절감머니 지급',             category:'transit',   type:'simple', reward:300  },
  // 카드뉴스
  { id:'ow_cn_daily',     icon:'📰', name:'오늘의 카드뉴스 3건 읽기',      desc:'카드뉴스 탭에서 기사 3건 완독 시 지급',       category:'news',      type:'simple', reward:30   },
  { id:'ow_cn_streak',    icon:'🔥', name:'3일 연속 카드뉴스 미션 완료',   desc:'3일 연속 일일 미션 완료 시 보너스 지급',      category:'news',      type:'recom',  reward:150  },
  { id:'ow_cn_economy',   icon:'💰', name:'경제 카드뉴스 광고 시청',       desc:'경제 카테고리 기사 광고 시청 완료 시 지급',   category:'news',      type:'simple', reward:20   },
  { id:'ow_cn_tech',      icon:'💡', name:'테크 카드뉴스 광고 시청',       desc:'테크 카테고리 기사 광고 시청 완료 시 지급',   category:'news',      type:'simple', reward:20   },
];

// GET /api/offerwall — 미션 목록
router.get('/', auth, [
  query('category').optional(),
  query('type').optional().isIn(['recom', 'simple', 'high']),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const uid  = req.user.id;
    const cat  = req.query.category;
    const type = req.query.type;

    // 완료한 미션 ID 조회
    const done = await db.query(
      'SELECT offer_id FROM offer_completions WHERE user_id = $1',
      [uid]
    );
    const doneSet = new Set(done.rows.map(r => r.offer_id));

    let list = OFFERS;
    if (cat)  list = list.filter(o => o.category === cat);
    if (type) list = list.filter(o => o.type === type);

    list = list
      .map(o => ({ ...o, completed: doneSet.has(o.id) }))
      .sort((a, b) => b.reward - a.reward);

    res.json(list);
  } catch (err) { next(err); }
});

// POST /api/offerwall/:offerId/complete — 미션 완료 + 보상
router.post('/:offerId/complete', auth, async (req, res, next) => {
  try {
    const uid     = req.user.id;
    const offerId = req.params.offerId;
    const offer   = OFFERS.find(o => o.id === offerId);
    if (!offer) return res.status(404).json({ error: '미션을 찾을 수 없습니다.' });

    const exists = await db.query(
      'SELECT id FROM offer_completions WHERE user_id = $1 AND offer_id = $2',
      [uid, offerId]
    );
    if (exists.rows.length) {
      return res.status(409).json({ error: '이미 완료된 미션입니다.' });
    }

    await db.query(
      'INSERT INTO offer_completions (user_id, offer_id, reward) VALUES ($1, $2, $3)',
      [uid, offerId, offer.reward]
    );
    await db.query(
      `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
       VALUES ($1, $2, $3, $4, 'earn')`,
      [uid, offer.icon, offer.name, offer.reward]
    );

    const bal = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [uid]
    );

    res.json({ offer_id: offerId, reward: offer.reward, balance: Number(bal.rows[0].balance) });
  } catch (err) { next(err); }
});

module.exports = router;
