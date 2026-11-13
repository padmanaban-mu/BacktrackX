import 'package:flutter/material.dart';

/// Manages dashboard state: quick statistics and recent activity.
/// Currently uses placeholder data since progress is tracked locally;
/// will later pull from ProgressService when the backend supports it.
import '../services/progress_service.dart';

class DashboardProvider extends ChangeNotifier {
  final ProgressService _progressService = ProgressService();
  bool _isLoading = false;
  String? _errorMessage;

  int _lessonsCompleted = 0;
  int _sudokuSolved = 0;
  String _learningTime = '0m';
  List<Map<String, String>> _recentActivity = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  int get lessonsCompleted => _lessonsCompleted;
  int get sudokuSolved => _sudokuSolved;
  String get learningTime => _learningTime;
  List<Map<String, String>> get recentActivity => _recentActivity;

  Future<void> loadDashboard({String? token}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final progress = await _progressService.getProgress(token: token ?? '');
      _lessonsCompleted = progress.lessonsCompleted;
      _sudokuSolved = progress.sudokuSolved;
      _learningTime = progress.totalLearningTime;

      // Generate recent activity dynamically from history
      _recentActivity = [
        {'text': 'Logged in', 'time': 'Just now'},
      ];
      for (var lesson in progress.completedLessons.take(2)) {
        _recentActivity.add({'text': 'Completed ${lesson.title}', 'time': 'Recently'});
      }
      for (var quiz in progress.quizHistory.take(2)) {
        _recentActivity.add({'text': 'Completed ${quiz.title}', 'time': 'Recently'});
      }

      _isLoading = false;
      _errorMessage = null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load dashboard data';
    }
    notifyListeners();
  }

  void incrementLessonsCompleted() {
    _lessonsCompleted++;
    notifyListeners();
  }

  void incrementSudokuSolved() {
    _sudokuSolved++;
    notifyListeners();
  }
}
