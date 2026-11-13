/**
 * Small helpers to keep every controller returning the exact same
 * response envelope the Flutter app's ApiService expects:
 *
 * Success: { success: true, data: {...}, message: "..." }
 * Failure: { success: false, error: { code, message } }
 */

const sendSuccess = (res, { statusCode = 200, data = {}, message = '' }) => {
  return res.status(statusCode).json({
    success: true,
    data,
    message,
  });
};

const sendError = (res, { statusCode = 500, code = 'SERVER_ERROR', message = 'Something went wrong' }) => {
  return res.status(statusCode).json({
    success: false,
    error: {
      code,
      message,
    },
  });
};

module.exports = { sendSuccess, sendError };
