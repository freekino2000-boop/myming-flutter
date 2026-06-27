const router = require('express').Router();
const { query, validationResult } = require('express-validator');
const db   = require('../config/db');
const auth = require('../middleware/auth');

// Flutter kOffers와 동일한 목 데이터 (DB 오퍼 테이블 없을 때 폴백)
const OFFERS = [
  { id:'of001', icon:'📱', name:'알뜰폰 요금제 변경', desc:'현재 통신사에서 알뜰폰으로 변경하고 월 3만원 절약', category:'telecom', type:'recom', reward:3000 },
  { id:'of002', icon:'💡', name:'전기요금 절약 미션', desc:'에너지 절약 설정 완료 시 보상 지급', category:'utility', type:'simple', reward:500 },
  { id:'of003', icon:'🏠', name:'월세 보증보험 가입', desc:'안심 월세보증보험 가입으로 보증금 안전하게', category:'rent', type:'high', reward:8000 },
  { id:'of004', icon:'📺', name:'OTT 구독 정리', desc:'안 보는 OTT 해지하고 월 1.5만원 절약', category:'subscribe', type:'recom', reward:1500 },
  { id:'of005', icon:'🚇', name:'대중교통 정기권 등록', desc:'교통카드 정기권으로 월 교통비 절약', category:'transit', type:'simple', reward:300 },
  { id:'of006', icon:'🏦', name:'인터넷 은행 주거래 변경', desc:'카카오뱅크/토스 주거래 전환으로 수수료 0원', category:'manage', type:'recom', reward:2000 },
  { id:'of007', icon:'📰', name:'신문 구독 해지', desc:'안 읽는 신문 구독 해지', category:'news', type:'simple', reward:200 },
  { id:'of008', icon:'🔒', name:'실손보험 점검', desc:'중복 보험 정리로 월 보험료 절약', category:'insurance', type:'high', reward:5000 },
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
