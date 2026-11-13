import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app.dart';
import 'providers/auth_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/learning_provider.dart';
import 'providers/sudoku_provider.dart';
import 'providers/nqueens_provider.dart';
import 'providers/maze_provider.dart';
import 'providers/progress_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/leaderboard_provider.dart';
import 'providers/challenge_provider.dart';

import 'providers/predict_provider.dart';

/// App entry point. Registers every feature's Provider here with
/// MultiProvider so its state is available anywhere below BackTrackXApp
/// in the widget tree.
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProxyProvider<AuthProvider, LearningProvider>(
          create: (_) => LearningProvider(),
          update: (_, auth, learning) => learning!..setToken(auth.token),
        ),
        ChangeNotifierProvider(create: (_) => SudokuProvider()),
        ChangeNotifierProvider(create: (_) => NQueensProvider()),
        ChangeNotifierProvider(create: (_) => MazeProvider()),
        ChangeNotifierProvider(create: (_) => ProgressProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => LeaderboardProvider()),
        ChangeNotifierProvider(create: (_) => ChallengeProvider()),
        ChangeNotifierProvider(create: (_) => PredictProvider()),
      ],
      child: const BackTrackXApp(),
    ),
  );
}
