const UserProgress = require('../models/UserProgress');
const User = require('../models/User');
const { sendSuccess, sendError } = require('../utils/ApiResponse');

const getLeaderboard = async (req, res) => {
  try {
    const scope = req.query.scope || 'global'; // 'global' | 'weekly'
    
    let matchStage = {};
    if (scope === 'weekly') {
      const weekAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      matchStage = { updatedAt: { $gte: weekAgo } };
    }

    const topUsers = await UserProgress.find(matchStage)
      .sort({ xp: -1 })
      .limit(50)
      .populate('userId', 'name email')
      .lean();

    const leaderboard = topUsers.map((p, index) => ({
      rank: index + 1,
      name: p.userId?.name || 'Unknown',
      xp: p.xp || 0,
      level: p.level || 1,
      currentStreak: p.currentStreak || 0,
      sudokuSolved: p.sudokuSolved || 0,
      lessonsCompleted: (p.lessonsCompleted || []).length,
      badges: p.badges || [],
    }));

    // Find current user's rank
    const myProgress = await UserProgress.findOne({ userId: req.user._id }).lean();
    let myRank = null;
    if (myProgress) {
      const higherCount = await UserProgress.countDocuments({ xp: { $gt: myProgress.xp || 0 } });
      myRank = {
        rank: higherCount + 1,
        xp: myProgress.xp || 0,
        level: myProgress.level || 1,
        currentStreak: myProgress.currentStreak || 0,
      };
    }

    sendSuccess(res, { data: { leaderboard, myRank } });
  } catch (err) {
    sendError(res, { statusCode: 500, code: 'SERVER_ERROR', message: err.message });
  }
};

module.exports = { getLeaderboard };
