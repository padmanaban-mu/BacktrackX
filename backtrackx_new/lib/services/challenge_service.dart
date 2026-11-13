import 'package:shared_preferences/shared_preferences.dart';

class DailyChallenge {
  final String type; // 'nqueens', 'sudoku', 'predict'
  final String description;
  final String date;
  final bool alreadyCompleted;
  final int? boardSize;
  final String? puzzleId;
  final String? algorithm;

  const DailyChallenge({required this.type, required this.description, required this.date, required this.alreadyCompleted, this.boardSize, this.puzzleId, this.algorithm});

  factory DailyChallenge.fromJson(Map<String, dynamic> json) => DailyChallenge(
    type: json['type'] as String,
    description: json['description'] as String,
    date: json['date'] as String,
    alreadyCompleted: json['alreadyCompleted'] as bool? ?? false,
    boardSize: json['boardSize'] as int?,
    puzzleId: json['puzzleId'] as String?,
    algorithm: json['algorithm'] as String?,
  );
}

class ChallengeService {
  Future<DailyChallenge?> getDailyChallenge({required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    final isCompleted = prefs.getBool('daily_completed_${DateTime.now().toIso8601String().substring(0, 10)}') ?? false;
    
    return DailyChallenge(
      type: 'nqueens',
      description: 'Solve the 8-Queens problem under 2 minutes.',
      date: DateTime.now().toIso8601String().substring(0, 10),
      alreadyCompleted: isCompleted,
      boardSize: 8,
    );
  }

  Future<Map<String, dynamic>?> completeDaily({required String token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('daily_completed_${DateTime.now().toIso8601String().substring(0, 10)}', true);
    return {'status': 'completed', 'xpAwarded': 50};
  }
}
