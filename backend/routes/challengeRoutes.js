const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { getDailyChallenge, completeDailyChallenge } = require('../controllers/challengeController');

router.get('/daily', protect, getDailyChallenge);
router.post('/daily/complete', protect, completeDailyChallenge);

module.exports = router;
