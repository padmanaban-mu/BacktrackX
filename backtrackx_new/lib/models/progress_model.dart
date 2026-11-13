/// One quiz attempt entry.
class QuizHistoryEntry {
  final String quizId;
  final String title;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  const QuizHistoryEntry({
    required this.quizId,
    required this.title,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  double get percentage => totalQuestions > 0 ? score / totalQuestions : 0;
  bool get passed => percentage >= 0.7;

  factory QuizHistoryEntry.fromJson(Map<String, dynamic> json) {
    final quizData = json['quizId'];
    String quizIdStr = '';
    String titleStr = 'Quiz';

    if (quizData is Map) {
      quizIdStr = quizData['_id']?.toString() ?? '';
      titleStr = quizData['question']?.toString() ?? quizData['title']?.toString() ?? 'Quiz';
    } else {
      quizIdStr = quizData?.toString() ?? '';
    }

    return QuizHistoryEntry(
      quizId: quizIdStr,
      title: titleStr,
      score: json['score'] as int? ?? 0,
      totalQuestions: json['totalQuestions'] as int? ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

/// One completed lesson entry.
class CompletedLesson {
  final String id;
  final String title;

  const CompletedLesson({required this.id, required this.title});

  factory CompletedLesson.fromJson(dynamic json) {
    if (json is Map<String, dynamic>) {
      return CompletedLesson(
        id: json['_id']?.toString() ?? '',
        title: json['title']?.toString() ?? 'Lesson',
      );
    }
    return CompletedLesson(id: json.toString(), title: 'Lesson');
  }
}

/// Aggregated progress stats for the student.
class ProgressModel {
  final int lessonsCompleted;
  final int quizzesPassed;
  final int sudokuSolved;
  final int nqueensSolved;
  final int mazeSolved;
  final int timedChallengesCompleted;
  final int predictsCompleted;
  final String totalLearningTime;
  final DateTime? lastActive;
  final int xp;
  final int level;
  final int currentStreak;
  final List<String> badges;
  final List<QuizHistoryEntry> quizHistory;
  final List<CompletedLesson> completedLessons;

  const ProgressModel({
    required this.lessonsCompleted,
    required this.quizzesPassed,
    required this.sudokuSolved,
    this.nqueensSolved = 0,
    this.mazeSolved = 0,
    this.timedChallengesCompleted = 0,
    this.predictsCompleted = 0,
    required this.totalLearningTime,
    this.lastActive,
    this.xp = 0,
    this.level = 1,
    this.currentStreak = 0,
    this.badges = const [],
    this.quizHistory = const [],
    this.completedLessons = const [],
  });

  factory ProgressModel.fromJson(Map<String, dynamic> json) {
    final rawLessons = json['lessonsCompleted'] as List? ?? [];
    final lessons = rawLessons.map((e) => CompletedLesson.fromJson(e)).toList();
    
    final rawQuizzes = json['quizScores'] as List? ?? [];
    final quizHistory = rawQuizzes
        .map((e) => QuizHistoryEntry.fromJson(e as Map<String, dynamic>))
        .toList()
        .reversed
        .toList(); // Newest first

    return ProgressModel(
      lessonsCompleted: lessons.length,
      quizzesPassed: quizHistory.where((q) => q.passed).length,
      sudokuSolved: json['sudokuSolved'] as int? ?? 0,
      nqueensSolved: json['nqueensSolved'] as int? ?? 0,
      mazeSolved: json['mazeSolved'] as int? ?? 0,
      timedChallengesCompleted: json['timedChallengesCompleted'] as int? ?? 0,
      predictsCompleted: json['predictsCompleted'] as int? ?? 0,
      totalLearningTime: json['totalLearningTime'] as String? ?? '0m',
      lastActive: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      currentStreak: json['currentStreak'] as int? ?? 0,
      badges: List<String>.from(json['badges'] as List? ?? []),
      quizHistory: quizHistory,
      completedLessons: lessons,
    );
  }

  String? get lastActiveFormatted {
    if (lastActive == null) return null;
    final diff = DateTime.now().difference(lastActive!);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}
