const mongoose = require('mongoose');

const userProgressSchema = new mongoose.Schema({
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true, unique: true },
  lessonsCompleted: [{ type: String, ref: 'Lesson' }], // changed to String to support mock IDs
  quizScores: [{
    quizId: { type: String, ref: 'Quiz' }, // changed to String to support mock IDs
    score: Number,
    totalQuestions: Number,
    completedAt: { type: Date, default: Date.now },
  }],
  sudokuSolved: { type: Number, default: 0 },
  nqueensSolved: { type: Number, default: 0 },
  mazeSolved: { type: Number, default: 0 },
  totalTimeMinutes: { type: Number, default: 0 },
  xp: { type: Number, default: 0 },
  level: { type: Number, default: 1 },
  currentStreak: { type: Number, default: 0 },
  longestStreak: { type: Number, default: 0 },
  lastPlayedDate: { type: String, default: null }, // 'YYYY-MM-DD'
  streakFreezeUsedThisWeek: { type: Boolean, default: false },
  badges: [{ type: String }], // badge IDs
  lastDailyChallenge: { type: String, default: null }, // 'YYYY-MM-DD'
}, { timestamps: true });

module.exports = mongoose.model('UserProgress', userProgressSchema);
