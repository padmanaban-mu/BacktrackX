import 'package:flutter/foundation.dart';

/// Base URL and endpoint paths for the Express.js backend.
/// Automatically selects the correct host per platform:
/// - Web (Chrome)        → http://localhost:5000/api
/// - Android Emulator    → http://10.0.2.2:5000/api  (maps to PC's localhost)
/// - Physical Android    → http://10.0.2.2:5000/api  (same network needed)
class ApiConstants {
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:5000/api';
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:5000/api';
    }
    return 'http://localhost:5000/api';
  }

  // --- Auth ---
  static String get register => '$baseUrl/auth/register';
  static String get login    => '$baseUrl/auth/login';
  static String get me       => '$baseUrl/auth/me';
  static String get logout   => '$baseUrl/auth/logout';

  // --- Content (Lessons & Quizzes) ---
  static String get lessons => '$baseUrl/content/lessons';
  static String lessonById(String id) => '$baseUrl/content/lessons/$id';
  static String quizForLesson(String lessonId) =>
      '$baseUrl/content/lessons/$lessonId/quiz';

  // --- Progress ---
  static String get progress        => '$baseUrl/progress';
  static String get progressLesson  => '$baseUrl/progress/lesson';
  static String get progressQuiz    => '$baseUrl/progress/quiz';
  static String get progressSudoku  => '$baseUrl/progress/sudoku';
  static String get progressXP      => '$baseUrl/progress/xp';
  static String get progressNQueens => '$baseUrl/progress/nqueens';
  static String get progressMaze    => '$baseUrl/progress/maze';

  // --- Leaderboard & Challenges ---
  static String get leaderboard            => '$baseUrl/leaderboard';
  static String get dailyChallenge         => '$baseUrl/challenge/daily';
  static String get dailyChallengeComplete => '$baseUrl/challenge/daily/complete';
}
