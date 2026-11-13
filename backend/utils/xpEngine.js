const UserProgress = require('../models/UserProgress');
const BADGES = require('./badgeConfig');

// XP per action
const XP_RULES = {
  lessonComplete: 20,
  quizCorrect: 10,
  quizComplete: 15,
  sudokuSolved: 30,
  nqueensSolved: 40,
  dailyChallenge: 50,
  predictCorrect: 5,
  streakBonus: 10,
};

// Level thresholds: level = floor(xp / 100) + 1, capped at 20
function xpToLevel(xp) {
  return Math.min(Math.floor(xp / 100) + 1, 20);
}

/**
 * Awards XP to a user, updates level, checks streak, checks badges.
 * Returns { xpAwarded, newXP, oldLevel, newLevel, levelUp, newBadges }
 */
async function awardXP(userId, actionKey, multiplier = 1) {
  const xpAmount = Math.round((XP_RULES[actionKey] || 10) * multiplier);

  // Update streak
  const today = new Date().toISOString().split('T')[0]; // 'YYYY-MM-DD'

  let progress = await UserProgress.findOne({ userId });
  if (!progress) {
    progress = new UserProgress({ userId });
  }

  const oldLevel = progress.level;
  const oldBadges = new Set(progress.badges);

  // Streak logic
  if (progress.lastPlayedDate !== today) {
    const yesterday = new Date(Date.now() - 86400000).toISOString().split('T')[0];
    if (progress.lastPlayedDate === yesterday) {
      progress.currentStreak += 1;
    } else if (progress.lastPlayedDate === null || progress.streakFreezeUsedThisWeek === false) {
      // Check streak freeze
      const daysSinceLast = progress.lastPlayedDate
        ? Math.floor((Date.now() - new Date(progress.lastPlayedDate).getTime()) / 86400000)
        : 999;
      if (daysSinceLast === 2 && !progress.streakFreezeUsedThisWeek) {
        progress.streakFreezeUsedThisWeek = true;
        progress.currentStreak += 1; // Freeze saved it
      } else {
        progress.currentStreak = 1; // Reset
      }
    } else {
      progress.currentStreak = 1;
    }
    progress.lastPlayedDate = today;
    if (progress.currentStreak > progress.longestStreak) {
      progress.longestStreak = progress.currentStreak;
    }
    // Reset streak freeze weekly (simple: reset on Monday)
    if (new Date().getDay() === 1) {
      progress.streakFreezeUsedThisWeek = false;
    }
  }

  progress.xp += xpAmount;
  progress.level = xpToLevel(progress.xp);

  // Check badges
  const newBadges = [];
  for (const badge of BADGES) {
    if (!oldBadges.has(badge.id) && badge.check(progress)) {
      progress.badges.push(badge.id);
      newBadges.push({ id: badge.id, name: badge.name, icon: badge.icon });
    }
  }

  await progress.save();

  return {
    xpAwarded: xpAmount,
    newXP: progress.xp,
    oldLevel,
    newLevel: progress.level,
    levelUp: progress.level > oldLevel,
    newBadges,
    currentStreak: progress.currentStreak,
  };
}

module.exports = { awardXP, XP_RULES, xpToLevel };
