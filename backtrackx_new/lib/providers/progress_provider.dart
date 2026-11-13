import 'package:flutter/material.dart';
import '../models/progress_model.dart';
import '../services/progress_service.dart';

/// Manages progress/stats state for the Progress screen.
/// Loads data from ProgressService and exposes it to the UI.
/// Pass the JWT token when calling [loadProgress] so the
/// service can make authenticated requests to the backend.
class ProgressProvider extends ChangeNotifier {
  final ProgressService _progressService = ProgressService();

  bool _isLoading = false;
  String? _errorMessage;
  ProgressModel? _progress;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ProgressModel? get progress => _progress;

  int get xp => _progress?.xp ?? 0;
  int get level => _progress?.level ?? 1;
  int get currentStreak => _progress?.currentStreak ?? 0;
  List<String> get badges => _progress?.badges ?? [];

  /// Loads progress data from the backend.
  /// [token] is the JWT from AuthProvider. If null, falls back to empty stats.
  Future<void> loadProgress({String? token}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _progress = await _progressService.getProgress(
        token: token ?? '',
      );
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load progress data.';
      // Provide empty defaults so the UI never crashes
      _progress = const ProgressModel(
        lessonsCompleted: 0,
        quizzesPassed: 0,
        sudokuSolved: 0,
        totalLearningTime: '0m',
        lastActive: null,
      );
    }
    notifyListeners();
  }

  Future<void> awardGameXP({required String token, required String action, double multiplier = 1.0}) async {
    try {
      await _progressService.awardGameXP(
        token: token,
        action: action,
        multiplier: multiplier,
      );
      // Reload to reflect new XP instantly
      await loadProgress(token: token);
    } catch (_) {}
  }
}
