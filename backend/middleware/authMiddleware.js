const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { sendError } = require('../utils/ApiResponse');

/**
 * Verifies the Bearer token sent in the Authorization header,
 * loads the matching user, and attaches it to req.user.
 * Used to protect routes like GET /api/auth/me.
 */
const protect = async (req, res, next) => {
  let token;

  const authHeader = req.headers.authorization;
  if (authHeader && authHeader.startsWith('Bearer ')) {
    token = authHeader.split(' ')[1];
  }

  if (!token) {
    return sendError(res, {
      statusCode: 401,
      code: 'NO_TOKEN',
      message: 'Not authorized. No token provided.',
    });
  }

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    const user = await User.findById(decoded.id);
    if (!user) {
      return sendError(res, {
        statusCode: 401,
        code: 'USER_NOT_FOUND',
        message: 'Not authorized. User for this token no longer exists.',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return sendError(res, {
        statusCode: 401,
        code: 'TOKEN_EXPIRED',
        message: 'Session expired. Please log in again.',
      });
    }
    return sendError(res, {
      statusCode: 401,
      code: 'INVALID_TOKEN',
      message: 'Not authorized. Invalid token.',
    });
  }
};

module.exports = { protect };
