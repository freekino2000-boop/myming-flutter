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

const EARN_MAX_SINGLE  = 8000;
const EARN_DAILY_LIMIT = 20000;

// POST /api/wallet/earn — 보상 적립
router.post('/earn', auth, [
  body('icon').notEmpty(),
  body('name').trim().notEmpty(),
  body('amount').isInt({ min: 1, max: EARN_MAX_SINGLE }),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const uid          = req.user.id;
    const { icon, name, amount } = req.body;
    const today        = new Date().toISOString().slice(0, 10);

    const { rows: dayRows } = await db.query(
      `SELECT COALESCE(SUM(amount), 0) AS day_total
       FROM wallet_ledger
       WHERE user_id = $1 AND type = 'earn'
         AND created_at >= $2::date AND created_at < $2::date + INTERVAL '1 day'`,
      [uid, today]
    );
    if (Number(dayRows[0].day_total) + amount > EARN_DAILY_LIMIT) {
      return res.status(429).json({ error: '오늘 적립 한도에 도달했습니다.', daily_limit: EARN_DAILY_LIMIT });
    }

    await db.query(
      `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
       VALUES ($1, $2, $3, $4, 'earn')`,
      [uid, icon, name, amount]
    );
    const { rows } = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [uid]
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

  const client = await db.pool.connect();
  try {
    const uid = req.user.id;
    const { amount, name } = req.body;

    await client.query('BEGIN');

    const bal = await client.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1 FOR UPDATE',
      [uid]
    );
    if (Number(bal.rows[0].balance) < amount) {
      await client.query('ROLLBACK');
      return res.status(400).json({ error: '잔액이 부족합니다.' });
    }

    await client.query(
      `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
       VALUES ($1, '🛍', $2, $3, 'spend')`,
      [uid, name, -amount]
    );

    const updated = await client.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [uid]
    );

    await client.query('COMMIT');
    res.json({ balance: Number(updated.rows[0].balance) });
  } catch (err) {
    await client.query('ROLLBACK');
    next(err);
  } finally {
    client.release();
  }
});

module.exports = router;
