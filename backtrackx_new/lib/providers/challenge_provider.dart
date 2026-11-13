import 'package:flutter/material.dart';
import '../services/challenge_service.dart';

class ChallengeProvider extends ChangeNotifier {
  final ChallengeService _service = ChallengeService();

  bool _isLoading = false;
  DailyChallenge? _daily;
  Map<String, dynamic>? _lastXpResult;

  bool get isLoading => _isLoading;
  DailyChallenge? get daily => _daily;
  Map<String, dynamic>? get lastXpResult => _lastXpResult;

  Future<void> loadDaily({required String token}) async {
    _isLoading = true;
    notifyListeners();
    _daily = await _service.getDailyChallenge(token: token);
    _isLoading = false;
    notifyListeners();
  }

  Future<void> markComplete({required String token}) async {
    _lastXpResult = await _service.completeDaily(token: token);
    if (_daily != null) {
      _daily = DailyChallenge(
        type: _daily!.type, description: _daily!.description, date: _daily!.date,
        alreadyCompleted: true, boardSize: _daily!.boardSize,
        puzzleId: _daily!.puzzleId, algorithm: _daily!.algorithm,
      );
    }
    notifyListeners();
  }
}
