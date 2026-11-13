/// Central place for route name constants. Used both to build the
/// route table in app.dart and whenever a screen calls
/// Navigator.pushReplacementNamed(context, AppRoutes.someRoute).
class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String learning = '/learning';
  static const String lessonDetail = '/lesson-detail';
  static const String quiz = '/quiz';
  static const String sudoku = '/sudoku';
  static const String nqueens = '/nqueens';
  static const String maze = '/maze';
  static const String progress = '/progress';
  static const String settings = '/settings';
  static const String leaderboard = '/leaderboard';
  static const String nqueensManual = '/nqueens-manual';
  static const String sudokuManual = '/sudoku-manual';
  static const String mazeManual = '/maze-manual';
  static const String predict = '/predict';
  static const String timedChallenge = '/timed-challenge';
  static const String practiceHub = '/practice-hub';
}
