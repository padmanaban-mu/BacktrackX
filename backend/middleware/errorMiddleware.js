const { sendError } = require('../utils/ApiResponse');

/**
 * Catches requests to routes that don't exist.
 */
const notFound = (req, res, next) => {
  return sendError(res, {
    statusCode: 404,
    code: 'NOT_FOUND',
    message: `Route not found: ${req.method} ${req.originalUrl}`,
  });
};

/**
 * Central error handler. Any error passed to next(err), or thrown inside
 * an async controller wrapped with asyncHandler, ends up here.
 * Converts common Mongoose/JWT errors into clean, predictable responses.
 */
const errorHandler = (err, req, res, next) => {
  console.error(err);

  // Mongoose validation error
  if (err.name === 'ValidationError') {
    const message = Object.values(err.errors)
      .map((val) => val.message)
      .join(', ');
    return sendError(res, {
      statusCode: 400,
      code: 'VALIDATION_ERROR',
      message,
    });
  }

  // Mongoose duplicate key error (e.g. duplicate email)
  if (err.code === 11000) {
    const field = Object.keys(err.keyValue)[0];
    return sendError(res, {
      statusCode: 409,
      code: 'DUPLICATE_FIELD',
      message: `An account with this ${field} already exists.`,
    });
  }

  // Mongoose invalid ObjectId
  if (err.name === 'CastError') {
    return sendError(res, {
      statusCode: 400,
      code: 'INVALID_ID',
      message: `Invalid value for ${err.path}: ${err.value}`,
    });
  }

  // JWT errors (in case they bubble up outside the auth middleware)
  if (err.name === 'JsonWebTokenError') {
    return sendError(res, {
      statusCode: 401,
      code: 'INVALID_TOKEN',
      message: 'Not authorized. Invalid token.',
    });
  }
  if (err.name === 'TokenExpiredError') {
    return sendError(res, {
      statusCode: 401,
      code: 'TOKEN_EXPIRED',
      message: 'Session expired. Please log in again.',
    });
  }

  // Fallback
  const statusCode = err.statusCode && err.statusCode >= 400 ? err.statusCode : 500;
  return sendError(res, {
    statusCode,
    code: err.code || 'SERVER_ERROR',
    message: err.message || 'Something went wrong on the server.',
  });
};

module.exports = { notFound, errorHandler };
