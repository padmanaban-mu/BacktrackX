import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'constants/app_strings.dart';
import 'routes/app_routes.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';
import 'screens/learning/lesson_list_screen.dart';
import 'screens/learning/lesson_detail_screen.dart';
import 'screens/learning/quiz_screen.dart';
import 'screens/sudoku/sudoku_visualizer_screen.dart';
import 'screens/nqueens/nqueens_visualizer_screen.dart';
import 'screens/maze/maze_visualizer_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/leaderboard/leaderboard_screen.dart';
import 'providers/settings_provider.dart';
import 'screens/nqueens/nqueens_manual_screen.dart';
import 'screens/sudoku/sudoku_manual_screen.dart';
import 'screens/maze/maze_manual_screen.dart';
import 'screens/predict/predict_screen.dart';
import 'screens/challenge/timed_challenge_screen.dart';
import 'screens/practice/practice_hub_screen.dart';

/// Root widget: configures Material 3 theming and the named route table.
/// MultiProvider setup happens one level above this, in main.dart.
class BackTrackXApp extends StatelessWidget {
  const BackTrackXApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsProvider>(
      builder: (context, settingsProvider, child) {
        return MaterialApp(
          title: AppStrings.appName,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFFDFEFE), // Warm White
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF900C3F),      // Rich Crimson
              secondary: Color(0xFFF5B041),    // Rich Gold
              surface: Color(0xFFFFFFFF),
              error: Color(0xFFC0392B),
              tertiary: Color(0xFF27AE60),     // Success Green
              onSurface: Color(0xFF2C3E50),    // textPrimary
              onSurfaceVariant: Color(0xFF475569), // textSecondary (darker for readability)
            ),
            textTheme: GoogleFonts.exo2TextTheme(ThemeData.light().textTheme).copyWith(
              bodyLarge: GoogleFonts.exo2(color: const Color(0xFF2C3E50)),
              bodyMedium: GoogleFonts.exo2(color: const Color(0xFF475569)),
              displayLarge: GoogleFonts.exo2(color: const Color(0xFF2C3E50), fontWeight: FontWeight.bold),
              titleLarge: GoogleFonts.exo2(color: const Color(0xFF900C3F), fontWeight: FontWeight.bold),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF900C3F),
              foregroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Colors.white),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFFFFFFFF),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: const Color(0xFF900C3F).withValues(alpha: 0.1), width: 1),
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF170B11), // Deep Dark Crimson-tinted
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFFC70039),      // Bright Crimson
              secondary: Color(0xFFFFC300),    // Bright Gold
              surface: Color(0xFF24111A),
              error: Color(0xFFFF5252),
              tertiary: Color(0xFF69F0AE),     // Success Green
              onSurface: Color(0xFFF8FAFC),    // textPrimary
              onSurfaceVariant: Color(0xFFB0BEC5), // textSecondary
            ),
            textTheme: GoogleFonts.exo2TextTheme(ThemeData.dark().textTheme).copyWith(
              bodyLarge: GoogleFonts.exo2(color: const Color(0xFFF8FAFC)),
              bodyMedium: GoogleFonts.exo2(color: const Color(0xFFB0BEC5)),
              displayLarge: GoogleFonts.exo2(color: const Color(0xFFF8FAFC), fontWeight: FontWeight.bold),
              titleLarge: GoogleFonts.exo2(color: const Color(0xFFC70039), fontWeight: FontWeight.bold),
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Color(0xFF170B11),
              foregroundColor: Color(0xFFF8FAFC),
              elevation: 0,
              centerTitle: true,
              iconTheme: IconThemeData(color: Color(0xFFC70039)),
            ),
            cardTheme: CardThemeData(
              color: const Color(0xFF24111A),
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: const Color(0xFFC70039).withValues(alpha: 0.1), width: 1),
              ),
            ),
          ),
          themeMode: settingsProvider.darkMode ? ThemeMode.dark : ThemeMode.light,
          initialRoute: AppRoutes.splash,
          routes: {
            AppRoutes.splash: (context) => const SplashScreen(),
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.register: (context) => const RegisterScreen(),
            AppRoutes.dashboard: (context) => const DashboardScreen(),
            AppRoutes.learning: (context) => const LessonListScreen(),
            AppRoutes.lessonDetail: (context) => const LessonDetailScreen(),
            AppRoutes.quiz: (context) => const QuizScreen(),
            AppRoutes.sudoku: (context) => const SudokuVisualizerScreen(),
            AppRoutes.nqueens: (context) => const NQueensVisualizerScreen(),
            AppRoutes.maze: (context) => const MazeVisualizerScreen(),
            AppRoutes.progress: (context) => const ProgressScreen(),
            AppRoutes.settings: (context) => const SettingsScreen(),
            AppRoutes.leaderboard: (context) => const LeaderboardScreen(),
            AppRoutes.nqueensManual: (context) => const NQueensManualScreen(),
            AppRoutes.sudokuManual: (context) => const SudokuManualScreen(),
            AppRoutes.mazeManual: (context) => const MazeManualScreen(),
            AppRoutes.predict: (context) => const PredictScreen(),
            AppRoutes.timedChallenge: (context) => const TimedChallengeScreen(),
            AppRoutes.practiceHub: (context) => const PracticeHubScreen(),
          },
        );
      }
    );
  }
}
