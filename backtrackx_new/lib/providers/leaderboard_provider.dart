import 'package:flutter/material.dart';
import '../services/leaderboard_service.dart';

class LeaderboardProvider extends ChangeNotifier {
  final LeaderboardService _service = LeaderboardService();

  bool _isLoading = false;
  String _scope = 'global'; // 'global' | 'weekly'
  List<LeaderboardEntry> _entries = [];
  Map<String, dynamic>? _myRank;
  String? _error;

  bool get isLoading => _isLoading;
  String get scope => _scope;
  List<LeaderboardEntry> get entries => _entries;
  Map<String, dynamic>? get myRank => _myRank;
  String? get error => _error;

  Future<void> load({required String token, String scope = 'global'}) async {
    _isLoading = true;
    _scope = scope;
    _error = null;
    notifyListeners();
    try {
      final result = await _service.getLeaderboard(token: token, scope: scope);
      _entries = result['leaderboard'] as List<LeaderboardEntry>;
      _myRank = result['myRank'] as Map<String, dynamic>?;
    } catch (e) {
      _error = 'Failed to load leaderboard.';
    }
    _isLoading = false;
    notifyListeners();
  }

  void toggleScope(String newScope, {required String token}) {
    load(token: token, scope: newScope);
  }
}
