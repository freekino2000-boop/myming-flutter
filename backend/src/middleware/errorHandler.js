module.exports = function errorHandler(err, req, res, next) {
  console.error(err.stack);
  const status = err.status || 500;
  res.status(status).json({
    error: status === 500 ? '서버 오류가 발생했습니다.' : err.message,
  });
};
