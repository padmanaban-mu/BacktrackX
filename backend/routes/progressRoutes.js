const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { getProgress, markLessonComplete, saveQuizScore, incrementSudokuSolved, awardGameXP, incrementNQueensSolved, incrementMazeSolved } = require('../controllers/progressController');

router.use(protect); // All progress routes are protected
router.get('/', getProgress);
router.post('/lesson', markLessonComplete);
router.post('/quiz', saveQuizScore);
router.post('/sudoku', incrementSudokuSolved);
router.post('/xp', awardGameXP);
router.post('/nqueens', protect, incrementNQueensSolved);
router.post('/maze', protect, incrementMazeSolved);

module.exports = router;
