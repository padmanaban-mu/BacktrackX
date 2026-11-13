import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/progress_model.dart';

/// Fully offline progress service that stores data locally.
class ProgressService {
  static const String _progressKey = 'offline_progress_data';

  Future<Map<String, dynamic>> _loadRaw() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_progressKey);
    if (str != null) {
      try {
        return jsonDecode(str) as Map<String, dynamic>;
      } catch (_) {}
    }
    return {
      'lessonsCompleted': [],
      'quizScores': [],
      'sudokuSolved': 0,
      'nqueensSolved': 0,
      'mazeSolved': 0,
      'totalLearningTime': '0m',
      'xp': 0,
      'level': 1,
      'currentStreak': 0,
      'badges': [],
    };
  }

  Future<void> _saveRaw(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    data['updatedAt'] = DateTime.now().toIso8601String();
    await prefs.setString(_progressKey, jsonEncode(data));
  }

  int _xpToLevel(int xp) {
    return (xp / 100).floor() + 1;
  }

  Future<ProgressModel> getProgress({required String token}) async {
    final raw = await _loadRaw();
    return ProgressModel.fromJson(raw);
  }

  Future<void> markLessonComplete({
    required String token,
    required String lessonId,
  }) async {
    final raw = await _loadRaw();
    final lessons = List.from(raw['lessonsCompleted'] as List? ?? []);
    
    bool alreadyExists = lessons.any((l) {
      if (l is String) return l == lessonId;
      if (l is Map) return l['_id'] == lessonId || l['id'] == lessonId;
      return false;
    });

    if (!alreadyExists) {
      lessons.add({'_id': lessonId, 'title': 'Lesson $lessonId'});
      raw['lessonsCompleted'] = lessons;
      
      // Automatically award XP for completing a lesson (e.g., 50 XP)
      int newXp = (raw['xp'] as int? ?? 0) + 50;
      raw['xp'] = newXp;
      raw['level'] = _xpToLevel(newXp);
      
      await _saveRaw(raw);
    }
  }

  Future<void> saveQuizScore({
    required String token,
    required String quizId,
    required int score,
    required int totalQuestions,
  }) async {
    final raw = await _loadRaw();
    final scores = List.from(raw['quizScores'] as List? ?? []);
    scores.add({
      'quizId': quizId,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': DateTime.now().toIso8601String(),
    });
    raw['quizScores'] = scores;

    // Automatically award XP based on score (e.g., 20 XP per correct answer)
    int xpEarned = score * 20;
    int newXp = (raw['xp'] as int? ?? 0) + xpEarned;
    raw['xp'] = newXp;
    raw['level'] = _xpToLevel(newXp);

    await _saveRaw(raw);
  }

  Future<void> incrementSudokuSolved({required String token}) async {
    final raw = await _loadRaw();
    raw['sudokuSolved'] = (raw['sudokuSolved'] as int? ?? 0) + 1;
    await _saveRaw(raw);
  }

  Future<Map<String, dynamic>> awardGameXP({required String token, required String action, double multiplier = 1.0}) async {
    final raw = await _loadRaw();
    int baseXP = 10;
    
    if (action == 'sudokuSolved') {
      baseXP = 30;
      raw['sudokuSolved'] = (raw['sudokuSolved'] as int? ?? 0) + 1;
    } else if (action == 'nqueensSolved') {
      baseXP = 40;
      raw['nqueensSolved'] = (raw['nqueensSolved'] as int? ?? 0) + 1;
    } else if (action == 'mazeSolved') {
      baseXP = 35;
      raw['mazeSolved'] = (raw['mazeSolved'] as int? ?? 0) + 1;
    } else if (action == 'timedChallengeSolved') {
      baseXP = 60;
      raw['timedChallengesCompleted'] = (raw['timedChallengesCompleted'] as int? ?? 0) + 1;
    } else if (action == 'predictComplete') {
      baseXP = 20;
      raw['predictsCompleted'] = (raw['predictsCompleted'] as int? ?? 0) + 1;
    } else if (action == 'dailyChallenge') {
      baseXP = 50;
    }

    int xpEarned = (baseXP * multiplier).round();
    int currentXp = raw['xp'] as int? ?? 0;
    int newXp = currentXp + xpEarned;
    raw['xp'] = newXp;
    raw['level'] = _xpToLevel(newXp);

    await _saveRaw(raw);
    return {
      'xpAwarded': xpEarned,
      'newXP': newXp,
      'newLevel': raw['level'],
    };
  }

  Future<void> incrementNQueensSolved({required String token}) async {
    final raw = await _loadRaw();
    raw['nqueensSolved'] = (raw['nqueensSolved'] as int? ?? 0) + 1;
    await _saveRaw(raw);
  }

  Future<void> incrementMazeSolved({required String token}) async {
    final raw = await _loadRaw();
    raw['mazeSolved'] = (raw['mazeSolved'] as int? ?? 0) + 1;
    await _saveRaw(raw);
  }
}
