const { sendSuccess, sendError } = require('../utils/ApiResponse');
const UserProgress = require('../models/UserProgress');
const { awardXP } = require('../utils/xpEngine');

// Deterministic daily puzzle: seed by day-of-year
const DAILY_PUZZLES = [
  { type: 'nqueens', boardSize: 6, description: 'Solve the 6-Queens problem without any hints!' },
  { type: 'nqueens', boardSize: 8, description: 'Master the classic 8-Queens problem!' },
  { type: 'sudoku', puzzleId: '1', description: 'Solve the Easy Sudoku as fast as you can!' },
  { type: 'sudoku', puzzleId: '2', description: 'Tackle the Medium Sudoku for bonus XP!' },
  { type: 'nqueens', boardSize: 4, description: 'Warm up with the 4-Queens problem!' },
  { type: 'predict', algorithm: 'nqueens', boardSize: 8, description: 'Predict the algorithm moves for 8-Queens!' },
  { type: 'predict', algorithm: 'sudoku', puzzleId: '1', description: 'Predict backtracking steps for Easy Sudoku!' },
];

const getDailyChallenge = async (req, res) => {
  try {
    const now = new Date();
    const dayOfYear = Math.floor((now - new Date(now.getFullYear(), 0, 0)) / 86400000);
    const puzzle = DAILY_PUZZLES[dayOfYear % DAILY_PUZZLES.length];
    const today = now.toISOString().split('T')[0];

    // Check if user already completed today
    const progress = await UserProgress.findOne({ userId: req.user._id }).lean();
    const alreadyCompleted = progress?.lastDailyChallenge === today;

    sendSuccess(res, { data: { ...puzzle, date: today, alreadyCompleted } });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

const completeDailyChallenge = async (req, res) => {
  try {
    const today = new Date().toISOString().split('T')[0];
    const progress = await UserProgress.findOne({ userId: req.user._id });
    if (progress?.lastDailyChallenge === today) {
      return sendError(res, { statusCode: 400, code: 'ALREADY_DONE', message: 'Daily challenge already completed today.' });
    }
    await UserProgress.findOneAndUpdate(
      { userId: req.user._id },
      { lastDailyChallenge: today },
      { upsert: true }
    );
    const xpResult = await awardXP(req.user._id, 'dailyChallenge');
    sendSuccess(res, { data: xpResult, message: 'Daily challenge complete! +50 XP' });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

module.exports = { getDailyChallenge, completeDailyChallenge };
