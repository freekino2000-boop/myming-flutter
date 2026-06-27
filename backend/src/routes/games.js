const router = require('express').Router();
const { body, query, validationResult } = require('express-validator');
const db   = require('../config/db');
const auth = require('../middleware/auth');

const GAME_IDS   = ['brick', 'jump', 'catch', 'snake', 'tap', 'quiz', 'memory', 'reflex'];
const MAX_REWARD = { brick: 200, jump: 150, catch: 100, snake: 150, tap: 50, quiz: 50, memory: 60, reflex: 40 };

function calcReward(gameId, score) {
  switch (gameId) {
    case 'brick':  return Math.min(Math.floor(score / 10), 200);
    case 'jump':   return Math.min(score, 150);
    case 'catch':  return Math.min(Math.max(Math.floor(score / 15), 0), 100);
    case 'snake':  return Math.min(score * 3, 150);
    // WebView 게임: 클라이언트가 이미 earn 계산 후 전달
    case 'tap':    return Math.min(score, 50);
    case 'quiz':   return Math.min(score, 50);
    case 'memory': return Math.min(score, 60);
    case 'reflex': return Math.min(score, 40);
    default:       return 0;
  }
}

// GET /api/games/ranking/:gameId — 게임별 랭킹 (상위 20명)
router.get('/ranking/:gameId', auth, [
  query('limit').optional().isInt({ min: 1, max: 50 }).toInt(),
], async (req, res, next) => {
  const gameId = req.params.gameId;
  if (!GAME_IDS.includes(gameId)) return res.status(400).json({ error: '유효하지 않은 게임 ID입니다.' });

  try {
    const limit = req.query.limit ?? 20;
    const uid   = req.user.id;

    // 상위 N명 (사용자당 최고 점수)
    const { rows } = await db.query(
      `SELECT u.nickname, MAX(gs.score) AS score, MAX(gs.reward) AS reward,
              RANK() OVER (ORDER BY MAX(gs.score) DESC) AS rank,
              (gs.user_id = $1) AS is_me
       FROM game_scores gs
       JOIN users u ON u.id = gs.user_id
       WHERE gs.game_id = $2
       GROUP BY gs.user_id, u.nickname
       ORDER BY score DESC
       LIMIT $3`,
      [uid, gameId, limit]
    );

    // 내 순위 (상위 20에 없는 경우)
    const myRank = await db.query(
      `SELECT rank FROM (
         SELECT user_id, RANK() OVER (ORDER BY MAX(score) DESC) AS rank
         FROM game_scores WHERE game_id = $1 GROUP BY user_id
       ) t WHERE user_id = $2`,
      [gameId, uid]
    );

    res.json({
      ranking:  rows.map(r => ({
        ...r,
        rank:   parseInt(r.rank),
        score:  parseInt(r.score),
        reward: parseInt(r.reward),
      })),
      my_rank:  myRank.rows[0]?.rank ? parseInt(myRank.rows[0].rank) : null,
    });
  } catch (err) { next(err); }
});

// POST /api/games/score — 게임 점수 제출 + 보상 지급
router.post('/score', auth, [
  body('game_id').isIn(GAME_IDS),
  body('score').isInt({ min: 0 }),
], async (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) return res.status(400).json({ errors: errors.array() });

  try {
    const uid    = req.user.id;
    const { game_id, score } = req.body;
    const reward = calcReward(game_id, score);

    await db.query(
      'INSERT INTO game_scores (user_id, game_id, score, reward) VALUES ($1, $2, $3, $4)',
      [uid, game_id, score, reward]
    );

    if (reward > 0) {
      const gameNames = { brick: '벽돌깨기', jump: '러너', catch: '코인받기', snake: '뱀게임', tap: '탭배틀', quiz: '퀴즈왕', memory: '카드매칭', reflex: '반응속도' };
      await db.query(
        `INSERT INTO wallet_ledger (user_id, icon, name, amount, type)
         VALUES ($1, '🎮', $2, $3, 'earn')`,
        [uid, `${gameNames[game_id]} 보상`, reward]
      );
    }

    const bal = await db.query(
      'SELECT COALESCE(SUM(amount), 0) AS balance FROM wallet_ledger WHERE user_id = $1',
      [uid]
    );

    res.json({ score, reward, balance: Number(bal.rows[0].balance) });
  } catch (err) { next(err); }
});

// GET /api/games/my-scores — 내 게임 기록
router.get('/my-scores', auth, async (req, res, next) => {
  try {
    const { rows } = await db.query(
      `SELECT game_id,
              MAX(score) AS best_score,
              COUNT(*)   AS play_count,
              SUM(reward) AS total_reward
       FROM game_scores WHERE user_id = $1
       GROUP BY game_id`,
      [req.user.id]
    );
    res.json(rows);
  } catch (err) { next(err); }
});

module.exports = router;
