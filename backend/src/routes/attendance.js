const router = require('express').Router();
const db   = require('../config/db');
const auth = require('../middleware/auth');

const ATTEND_REWARD = 10;

// GET /api/attendance — 이번 달 출석 목록
router.get('/', auth, async (req, res, next) => {
  try {
    const now = new Date();
    const ym  = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, '0')}`;
    const { rows } = await db.query(
      `SELECT TO_CHAR(date, 'YYYY-MM-DD') AS date
       FROM attendance
       WHERE user_id = $1 AND TO_CHAR(date, 'YYYY-MM') = $2
       ORDER BY date`,
      [req.user.id, ym]
    );
    const today = now.toISOString().slice(0, 10);
    const attendedToday = rows.some(r => r.date === today);
    res.json({ dates: rows.map(r => r.date), attended_today: attendedToday });
  } catch (err) { next(err); }
});

// POST /api/attendance/check — 출석 체크
router.post('/check', auth, async (req, res, next) => {
  try {
    const uid   = req.user.id;
    const today = new Date().toISOString().slice(0, 10);

    const exists = await db.query(
      'SELECT id FROM attendance WHERE user_id = $1 AND date = $2',
      [uid, today]
    );
    if (exists.rows.length) {
      return res.status(409).json({ error: '오늘 이미 출석 체크했습니다.', attended_today: true });
    }

    await db.query('INSERT INTO attendance (user_id, date) VALUES ($1, $2)', [uid, today]);
    await db.query(
      `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
       VALUES ($1, '📅', '출석 체크', $2, 'earn')`,
      [uid, ATTEND_REWARD]
    );

    const bal = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [uid]
    );

    res.json({
      date:    today,
      reward:  ATTEND_REWARD,
      balance: Number(bal.rows[0].balance),
    });
  } catch (err) { next(err); }
});

module.exports = router;
