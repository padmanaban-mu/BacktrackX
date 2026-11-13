// Static badge definitions. Checked after every XP-awarding action.
// condition fn receives the current UserProgress document.
const BADGES = [
  { id: 'first_lesson', name: 'First Step', description: 'Complete your first lesson', icon: '📖', check: (p) => p.lessonsCompleted.length >= 1 },
  { id: 'quiz_master', name: 'Quiz Master', description: 'Pass 5 quizzes', icon: '🎯', check: (p) => p.quizScores.length >= 5 },
  { id: 'sudoku_solver', name: 'Sudoku Solver', description: 'Solve your first Sudoku', icon: '🔢', check: (p) => p.sudokuSolved >= 1 },
  { id: 'sudoku_pro', name: 'Sudoku Pro', description: 'Solve 5 Sudokus', icon: '🏆', check: (p) => p.sudokuSolved >= 5 },
  { id: 'streak_3', name: 'On Fire', description: '3-day learning streak', icon: '🔥', check: (p) => p.currentStreak >= 3 },
  { id: 'streak_7', name: 'Week Warrior', description: '7-day learning streak', icon: '⚡', check: (p) => p.currentStreak >= 7 },
  { id: 'xp_100', name: 'Century', description: 'Earn 100 XP', icon: '💯', check: (p) => p.xp >= 100 },
  { id: 'xp_500', name: 'XP Hunter', description: 'Earn 500 XP', icon: '💎', check: (p) => p.xp >= 500 },
  { id: 'level_5', name: 'Rising Star', description: 'Reach Level 5', icon: '⭐', check: (p) => p.level >= 5 },
  { id: 'all_lessons', name: 'Scholar', description: 'Complete all lessons', icon: '🎓', check: (p) => p.lessonsCompleted.length >= 5 },
];

module.exports = BADGES;
