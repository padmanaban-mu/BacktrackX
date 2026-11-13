const UserProgress = require('../models/UserProgress');
const { sendSuccess, sendError } = require('../utils/ApiResponse');
const { awardXP } = require('../utils/xpEngine');

const getProgress = async (req, res) => {
  try {
    let progress = await UserProgress.findOne({ userId: req.user._id });
    if (!progress) progress = await UserProgress.create({ userId: req.user._id });
    sendSuccess(res, { data: progress });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

const markLessonComplete = async (req, res) => {
  try {
    const { lessonId } = req.body;
    await UserProgress.findOneAndUpdate(
      { userId: req.user._id },
      { $addToSet: { lessonsCompleted: lessonId } },
      { upsert: true }
    );
    const xpResult = await awardXP(req.user._id, 'lessonComplete');
    sendSuccess(res, { data: xpResult, message: 'Lesson marked complete.' });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

const saveQuizScore = async (req, res) => {
  try {
    const { quizId, score, totalQuestions } = req.body;
    await UserProgress.findOneAndUpdate(
      { userId: req.user._id },
      { $push: { quizScores: { quizId, score, totalQuestions } } },
      { upsert: true }
    );
    const xpResult = await awardXP(req.user._id, 'quizComplete');
    sendSuccess(res, { data: xpResult, message: 'Quiz score saved.' });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

const incrementSudokuSolved = async (req, res) => {
  try {
    await UserProgress.findOneAndUpdate(
      { userId: req.user._id },
      { $inc: { sudokuSolved: 1 } },
      { upsert: true }
    );
    const xpResult = await awardXP(req.user._id, 'sudokuSolved');
    sendSuccess(res, { data: xpResult, message: 'Sudoku solved.' });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

const awardGameXP = async (req, res) => {
  try {
    const { action, multiplier } = req.body;
    const xpResult = await awardXP(req.user._id, action, multiplier || 1);
    sendSuccess(res, { data: xpResult });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

const incrementNQueensSolved = async (req, res) => {
  try {
    await UserProgress.findOneAndUpdate(
      { userId: req.user._id },
      { $inc: { nqueensSolved: 1 } },
      { upsert: true }
    );
    const xpResult = await awardXP(req.user._id, 'nqueensSolved');
    sendSuccess(res, { data: xpResult, message: 'N-Queens solved.' });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

const incrementMazeSolved = async (req, res) => {
  try {
    await UserProgress.findOneAndUpdate(
      { userId: req.user._id },
      { $inc: { mazeSolved: 1 } },
      { upsert: true }
    );
    const xpResult = await awardXP(req.user._id, 'nqueensSolved');
    sendSuccess(res, { data: xpResult, message: 'Maze solved.' });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

module.exports = { getProgress, markLessonComplete, saveQuizScore, incrementSudokuSolved, awardGameXP, incrementNQueensSolved, incrementMazeSolved };
