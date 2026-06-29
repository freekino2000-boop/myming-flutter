const router = require('express').Router();
const { body, validationResult } = require('express-validator');
const db   = require('../config/db');
const auth = require('../middleware/auth');

// GET /api/steps/today — 오늘 걸음수
router.get('/today', auth, async (req, res, next) => {
  try {
    const today = new Date().toISOString().slice(0, 10);
    const { rows } = await db.query(
      'SELECT steps FROM steps WHERE user_id = $1 AND date = $2',
      [req.user.id, today]
    );
    res.json({ steps: rows[0]?.steps ?? 0, date: today });
  } catch (err) { next(err); }
});

// POST /api/steps/sync — 걸음수 동기화 (앱에서 주기적 호출)
router.post('/sync', auth, [
  body('steps').isInt({ min: 0 }),
  body('date').optional().isDate(),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const uid   = req.user.id;
    const today = req.body.date ?? new Date().toISOString().slice(0, 10);
    const steps = req.body.steps;
    const rate  = 0.01;

    const prev = await db.query(
      'SELECT steps FROM steps WHERE user_id = $1 AND date = $2',
      [uid, today]
    );
    const prevSteps = prev.rows[0]?.steps ?? 0;
    const added     = Math.max(0, steps - prevSteps);

    await db.query(
      `INSERT INTO steps (user_id, date, steps)
       VALUES ($1, $2, $3)
       ON CONFLICT (user_id, date) DO UPDATE SET steps = GREATEST(steps.steps, $3)`,
      [uid, today, steps]
    );

    if (added > 0) {
      const earnAmount = Math.ceil(added * rate);
      await db.query(
        `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
         VALUES ($1, '👟', '걷기 적립', $2, 'earn')`,
        [uid, earnAmount]
      );
    }

    const balance = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [uid]
    );

    res.json({ steps, date: today, balance: Number(balance.rows[0].balance) });
  } catch (err) { next(err); }
});

// GET /api/steps/history — 최근 7일 걸음수
router.get('/history', auth, async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT date, steps FROM steps
       WHERE user_id = $1 AND date >= CURRENT_DATE - 6
       ORDER BY date`,
      [req.user.id]
    );
    res.json(rows);
  } catch (err) { next(err); }
});

module.exports = router;
