// No API imports needed for offline mode

class LeaderboardEntry {
  final int rank;
  final String name;
  final int xp;
  final int level;
  final int currentStreak;
  final int sudokuSolved;
  final List<String> badges;

  const LeaderboardEntry({required this.rank, required this.name, required this.xp, required this.level, required this.currentStreak, required this.sudokuSolved, required this.badges});

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
    rank: json['rank'] as int,
    name: json['name'] as String,
    xp: json['xp'] as int? ?? 0,
    level: json['level'] as int? ?? 1,
    currentStreak: json['currentStreak'] as int? ?? 0,
    sudokuSolved: json['sudokuSolved'] as int? ?? 0,
    badges: List<String>.from(json['badges'] as List? ?? []),
  );
}

class LeaderboardService {
  Future<Map<String, dynamic>> getLeaderboard({required String token, String scope = 'global'}) async {
    // Return static mock data for offline mode
    final entries = [
      const LeaderboardEntry(rank: 1, name: 'Alice_Dev', xp: 2500, level: 26, currentStreak: 12, sudokuSolved: 14, badges: ['recursion_master']),
      const LeaderboardEntry(rank: 2, name: 'BobTheBuilder', xp: 2200, level: 23, currentStreak: 5, sudokuSolved: 8, badges: []),
      const LeaderboardEntry(rank: 3, name: 'CharlieCode', xp: 1800, level: 19, currentStreak: 2, sudokuSolved: 10, badges: ['sudoku_solver']),
      const LeaderboardEntry(rank: 4, name: 'Student', xp: 1500, level: 16, currentStreak: 1, sudokuSolved: 5, badges: []), // The current user placeholder
      const LeaderboardEntry(rank: 5, name: 'Eve_hacker', xp: 900, level: 10, currentStreak: 0, sudokuSolved: 2, badges: []),
    ];
    return {'leaderboard': entries, 'myRank': 4};
  }
}
