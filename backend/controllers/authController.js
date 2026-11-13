const { validationResult } = require('express-validator');
const User = require('../models/User');
const generateToken = require('../utils/generateToken');
const { sendSuccess, sendError } = require('../utils/ApiResponse');

/**
 * Small wrapper so we don't need try/catch in every controller.
 * Any rejected promise is forwarded to the errorHandler middleware.
 */
const asyncHandler = (fn) => (req, res, next) => {
  Promise.resolve(fn(req, res, next)).catch(next);
};

/**
 * Runs express-validator's collected errors and, if any exist,
 * sends a 400 in the standard error envelope. Returns true if
 * validation failed (so the caller can `return` immediately).
 */
const handleValidationErrors = (req, res) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    const firstError = errors.array()[0];
    sendError(res, {
      statusCode: 400,
      code: 'VALIDATION_ERROR',
      message: firstError.msg,
    });
    return true;
  }
  return false;
};

// @route   POST /api/auth/register
// @access  Public
const register = asyncHandler(async (req, res) => {
  if (handleValidationErrors(req, res)) return;

  const { name, email, password } = req.body;

  const existingUser = await User.findOne({ email: email.toLowerCase() });
  if (existingUser) {
    return sendError(res, {
      statusCode: 409,
      code: 'DUPLICATE_EMAIL',
      message: 'An account with this email already exists.',
    });
  }

  const user = await User.create({ name, email, password });
  const token = generateToken(user._id);

  return sendSuccess(res, {
    statusCode: 201,
    message: 'Account created successfully.',
    data: {
      user: user.sanitize(),
      token,
    },
  });
});

// @route   POST /api/auth/login
// @access  Public
const login = asyncHandler(async (req, res) => {
  if (handleValidationErrors(req, res)) return;

  const { email, password } = req.body;

  // password has `select: false` on the schema, so it must be requested explicitly
  const user = await User.findOne({ email: email.toLowerCase() }).select('+password');
  if (!user) {
    return sendError(res, {
      statusCode: 401,
      code: 'INVALID_CREDENTIALS',
      message: 'Invalid email or password.',
    });
  }

  const isMatch = await user.comparePassword(password);
  if (!isMatch) {
    return sendError(res, {
      statusCode: 401,
      code: 'INVALID_CREDENTIALS',
      message: 'Invalid email or password.',
    });
  }

  const token = generateToken(user._id);

  return sendSuccess(res, {
    statusCode: 200,
    message: 'Logged in successfully.',
    data: {
      user: user.sanitize(),
      token,
    },
  });
});

// @route   GET /api/auth/me
// @access  Private (requires Bearer token)
const getMe = asyncHandler(async (req, res) => {
  // req.user is attached by the `protect` middleware
  return sendSuccess(res, {
    statusCode: 200,
    message: 'Current user fetched successfully.',
    data: {
      user: req.user.sanitize(),
    },
  });
});

// @route   POST /api/auth/logout
// @access  Private
// JWTs are stateless, so there's nothing to invalidate server-side without
// a token blacklist. This endpoint exists so the client has a clean call
// to make on logout; the real logout happens by deleting the token client-side.
const logout = asyncHandler(async (req, res) => {
  return sendSuccess(res, {
    statusCode: 200,
    message: 'Logged out successfully.',
    data: {},
  });
});

module.exports = { register, login, getMe, logout };
