const express    = require('express');
const cors       = require('cors');
const rateLimit  = require('express-rate-limit');
require('dotenv').config();

const errorHandler = require('./middleware/errorHandler');

const app = express();

// ── 기본 미들웨어 ───────────────────────────────────────────
const allowedOrigins = process.env.ALLOWED_ORIGINS
  ? process.env.ALLOWED_ORIGINS.split(',').map(o => o.trim())
  : null;

app.use(cors({
  origin: allowedOrigins
    ? (origin, cb) => {
        // 앱(origin 없음) 또는 허용된 도메인만 통과
        if (!origin || allowedOrigins.includes(origin)) return cb(null, true);
        cb(new Error(`CORS: ${origin} is not allowed`));
      }
    : '*',
}));
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// ── Rate Limit ──────────────────────────────────────────────
app.use('/api/auth', rateLimit({
  windowMs: 15 * 60 * 1000,  // 15분
  max: 20,
  message: { error: '요청이 너무 많습니다. 15분 후 다시 시도하세요.' },
}));

app.use('/api/', rateLimit({
  windowMs: 1 * 60 * 1000,   // 1분
  max: 120,
  message: { error: '요청이 너무 많습니다. 잠시 후 다시 시도하세요.' },
}));

// ── 헬스체크 ────────────────────────────────────────────────
app.get('/health', (req, res) => res.json({ status: 'ok', time: new Date().toISOString() }));

// ── 라우터 ──────────────────────────────────────────────────
app.use('/api/auth',       require('./routes/auth'));
app.use('/api/users',      require('./routes/users'));
app.use('/api/steps',      require('./routes/steps'));
app.use('/api/wallet',     require('./routes/wallet'));
app.use('/api/attendance', require('./routes/attendance'));
app.use('/api/cardnews',   require('./routes/cardnews'));
app.use('/api/games',      require('./routes/games'));
app.use('/api/offerwall',  require('./routes/offerwall'));

// ── 404 ──────────────────────────────────────────────────────
app.use((req, res) => res.status(404).json({ error: '존재하지 않는 API 경로입니다.' }));

// ── 에러 핸들러 ─────────────────────────────────────────────
app.use(errorHandler);

module.exports = app;
