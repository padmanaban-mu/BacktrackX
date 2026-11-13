require('dotenv').config();
const express = require('express');
const cors = require('cors');
const connectDB = require('./config/db');
const authRoutes = require('./routes/authRoutes');
const contentRoutes = require('./routes/contentRoutes');
const progressRoutes = require('./routes/progressRoutes');
const leaderboardRoutes = require('./routes/leaderboardRoutes');
const challengeRoutes = require('./routes/challengeRoutes');
const { notFound, errorHandler } = require('./middleware/errorMiddleware');

// Connect to MongoDB before handling any requests
connectDB();

const app = express();

// --- Core middleware ---
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// --- Health check ---
app.get('/', (req, res) => {
  res.status(200).json({
    success: true,
    data: { status: 'ok' },
    message: 'BackTrackX API is running.',
  });
});

// --- Routes ---
app.use('/api/auth', authRoutes);
app.use('/api/content', contentRoutes);
app.use('/api/progress', progressRoutes);
app.use('/api/leaderboard', leaderboardRoutes);
app.use('/api/challenge', challengeRoutes);

// --- Error handling (must be last) ---
app.use(notFound);
app.use(errorHandler);

const PORT = process.env.PORT || 5000;

app.listen(PORT, '0.0.0.0', () => {
  console.log(`BackTrackX API running on port ${PORT} [${process.env.NODE_ENV || 'development'}]`);
});
