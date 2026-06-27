const router = require('express').Router();
const { body, query, validationResult } = require('express-validator');
const db   = require('../config/db');
const auth = require('../middleware/auth');

// GET /api/wallet/balance — 잔액 조회
router.get('/balance', auth, async (req, res, next) => {
  try {
    const { rows } = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [req.user.id]
    );
    res.json({ balance: Number(rows[0].balance) });
  } catch (err) { next(err); }
});

// GET /api/wallet/ledger — 원장 내역 (최대 50건)
router.get('/ledger', auth, [
  query('limit').optional().isInt({ min: 1, max: 100 }).toInt(),
  query('offset').optional().isInt({ min: 0 }).toInt(),
  query('type').optional().isIn(['earn', 'spend']),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const limit  = req.query.limit  ?? 50;
    const offset = req.query.offset ?? 0;
    const type   = req.query.type;

    const { rows } = await db.query(
      `SELECT id, icon, name, amount, type,
              TO_CHAR(created_at AT TIME ZONE 'Asia/Seoul', 'HH24:MI') AS time,
              created_at
       FROM wallet_ledger
       WHERE user_id = $1 ${type ? 'AND type = $4' : ''}
       ORDER BY created_at DESC
       LIMIT $2 OFFSET $3`,
      type ? [req.user.id, limit, offset, type] : [req.user.id, limit, offset]
    );
    res.json(rows);
  } catch (err) { next(err); }
});

// POST /api/wallet/earn — 보상 적립
router.post('/earn', auth, [
  body('icon').notEmpty(),
  body('name').trim().notEmpty(),
  body('amount').isInt({ min: 1 }),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const { icon, name, amount } = req.body;
    await db.query(
      `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
       VALUES ($1, $2, $3, $4, 'earn')`,
      [req.user.id, icon, name, amount]
    );
    const { rows } = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [req.user.id]
    );
    res.json({ balance: Number(rows[0].balance) });
  } catch (err) { next(err); }
});

// POST /api/wallet/spend — 지출 (교환소 구매)
router.post('/spend', auth, [
  body('amount').isInt({ min: 1 }),
  body('name').trim().notEmpty(),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const uid = req.user.id;
    const { amount, name } = req.body;

    const bal = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [uid]
    );
    if (Number(bal.rows[0].balance) < amount) {
      return res.status(400).json({ error: '잔액이 부족합니다.' });
    }

    await db.query(
      `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
       VALUES ($1, '🛍', $2, $3, 'spend')`,
      [uid, name, -amount]
    );

    const updated = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [uid]
    );
    res.json({ balance: Number(updated.rows[0].balance) });
  } catch (err) { next(err); }
});

module.exports = router;
