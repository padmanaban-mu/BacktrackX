import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/dashboard/app_bottom_nav_bar.dart';
import '../../widgets/dashboard/feature_card.dart';
import '../../widgets/dashboard/stat_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      context.read<ProgressProvider>().loadProgress(token: token);
    });
  }

  Future<void> _handleLogout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  Future<void> _handleBottomNavTap(BuildContext context, int index) async {
    switch (index) {
      case 1:
        await Navigator.of(context).pushNamed(AppRoutes.learning);
        break;
      case 2:
        await Navigator.of(context).pushNamed(AppRoutes.progress);
        break;
      case 3:
        await Navigator.of(context).pushNamed(AppRoutes.settings);
        break;
    }
    if (context.mounted) {
      final token = context.read<AuthProvider>().token;
      context.read<ProgressProvider>().loadProgress(token: token);
    }
  }

  Future<void> _navigateTo(BuildContext context, String route) async {
    await Navigator.of(context).pushNamed(route);
    if (context.mounted) {
      final token = context.read<AuthProvider>().token;
      context.read<ProgressProvider>().loadProgress(token: token);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final firstName = (user != null && user.name.isNotEmpty) ? user.name.split(' ').first : 'Student';
    final provider = context.watch<ProgressProvider>();
    final progress = provider.progress;
    final xp = progress?.xp ?? 0;
    final level = progress?.level ?? 1;
    final streak = progress?.currentStreak ?? 0;
    final double xpProgress = (xp % 100) / 100.0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        title: Text('BackTrackX', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
        actions: [
          PopupMenuButton<String>(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), blurRadius: 10)
                ],
              ),
              child: Icon(Icons.person, color: Theme.of(context).colorScheme.primary, size: 20),
            ),
            onSelected: (value) {
              if (value == 'logout') {
                _handleLogout(context);
              } else if (value == 'profile') {
                _navigateTo(context, AppRoutes.settings);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'profile', child: Text('Profile')),
              PopupMenuItem(value: 'logout', child: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error))),
            ],
          ),
          const SizedBox(width: 16),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(40),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Text('Level $level', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: 8),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: xpProgress,
                      minHeight: 8,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('$xp XP', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
                if (streak > 0) ...[
                  const SizedBox(width: 8),
                  const Text('🔥', style: TextStyle(fontSize: 16)),
                  Text('$streak', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                ],
              ],
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            // --- Greeting ---
            Text(
              'Welcome, $firstName',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ).animate().fadeIn(duration: 400.ms).slideX(),
            const SizedBox(height: 8),
            Text(
              'Ready to master backtracking today?',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ).animate().fadeIn(delay: 100.ms).slideX(),
            const SizedBox(height: 32),

            // --- Daily Challenge ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Theme.of(context).colorScheme.secondary.withValues(alpha: 0.2), Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star, color: Colors.yellow, size: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Daily Challenge', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Theme.of(context).colorScheme.onSurface)),
                        const SizedBox(height: 4),
                        Text('Solve N-Queens on a 5x5 board', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _navigateTo(context, AppRoutes.nqueens),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Theme.of(context).scaffoldBackgroundColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Start'),
                  )
                ],
              ),
            ).animate().fadeIn(delay: 200.ms).slideY(),
            const SizedBox(height: 32),

            // --- Dashboard Cards (2x2 grid) ---
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.88,
              children: [
                FeatureCard(
                  icon: Icons.menu_book_rounded,
                  title: 'Learn',
                  description: 'Interactive theory',
                  iconColor: Theme.of(context).colorScheme.primary,
                  onTap: () => _navigateTo(context, AppRoutes.learning),
                ),
                FeatureCard(
                  icon: Icons.grid_view_rounded,
                  title: 'Sudoku',
                  description: 'Watch the algorithm',
                  iconColor: Theme.of(context).colorScheme.secondary,
                  onTap: () => _navigateTo(context, AppRoutes.sudoku),
                ),
                FeatureCard(
                  icon: Icons.route_rounded,
                  title: 'Maze',
                  description: 'Pathfinding algorithm',
                  iconColor: Colors.purple,
                  onTap: () => _navigateTo(context, AppRoutes.maze),
                ),
                FeatureCard(
                  icon: Icons.bar_chart_rounded,
                  title: 'Progress',
                  description: 'Track your journey',
                  iconColor: const Color(0xFFF08C00),
                  onTap: () => _navigateTo(context, AppRoutes.progress),
                ),
                FeatureCard(
                  icon: Icons.grid_on_rounded,
                  title: 'N-Queens',
                  description: 'Chessboard algorithm',
                  iconColor: Theme.of(context).colorScheme.tertiary,
                  onTap: () => _navigateTo(context, AppRoutes.nqueens),
                ),
                FeatureCard(
                  icon: Icons.code_rounded,
                  title: 'Practice Hub',
                  description: 'LeetCode & GFG',
                  iconColor: Colors.deepPurple,
                  onTap: () => _navigateTo(context, AppRoutes.practiceHub),
                ),
              ],
            ).animate().fadeIn(delay: 300.ms).scale(),
            const SizedBox(height: 32),

            // --- Quick Statistics ---
            Text(
              'Your Statistics',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: StatCard(icon: Icons.menu_book_rounded, value: '${progress?.lessonsCompleted ?? 0}', label: 'Lessons', iconColor: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: 12),
                Expanded(child: StatCard(icon: Icons.grid_view_rounded, value: '${progress?.sudokuSolved ?? 0}', label: 'Sudokus', iconColor: Theme.of(context).colorScheme.secondary)),
                const SizedBox(width: 12),
                Expanded(child: StatCard(icon: Icons.timer_outlined, value: progress?.totalLearningTime ?? '0m', label: 'Time', iconColor: const Color(0xFFF08C00))),
              ],
            ).animate().fadeIn(delay: 500.ms),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: 0,
        onTap: (index) => _handleBottomNavTap(context, index),
      ),
    );
  }
}
