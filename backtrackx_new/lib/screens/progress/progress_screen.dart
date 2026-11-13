import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../providers/progress_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token;
      context.read<ProgressProvider>().loadProgress(token: token);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<ProgressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Progress'),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: Colors.white, size: 18),
          ),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
            ),
            tooltip: 'Go to Home',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                AppRoutes.dashboard, (route) => false),
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.bar_chart), text: 'Overview'),
            Tab(icon: Icon(Icons.history), text: 'History'),
            Tab(icon: Icon(Icons.emoji_events), text: 'Achievements'),
          ],
        ),
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: provider.isLoading
          ? const Center(child: LoadingIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(context, provider),
                _buildHistoryTab(context, provider),
                _buildAchievementsTab(context, provider),
              ],
            ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, ProgressProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final p = provider.progress;
    final xp = p?.xp ?? 0;
    final level = p?.level ?? 1;
    final xpInLevel = xp % 100;
    final streak = p?.currentStreak ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [cs.primary, cs.primary.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Level $level',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                    Row(
                      children: [
                        const Text('🔥', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 4),
                        Text('$streak day streak',
                            style: const TextStyle(
                                color: Colors.white70, fontSize: 14)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: xpInLevel / 100.0,
                    minHeight: 10,
                    backgroundColor: Colors.white30,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                const SizedBox(height: 6),
                Text('$xpInLevel / 100 XP to next level',
                    style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text('Statistics',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: cs.onSurface)),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.4,
            children: [
              _statCard(context, 'Lessons\nCompleted',
                  '${p?.lessonsCompleted ?? 0}', Icons.menu_book, cs.primary),
              _statCard(context, 'Quizzes\nPassed',
                  '${p?.quizzesPassed ?? 0}', Icons.quiz, cs.tertiary),
              _statCard(context, 'Sudoku\nSolved',
                  '${p?.sudokuSolved ?? 0}', Icons.grid_on, cs.secondary),
              _statCard(context, 'N-Queens\nSolved',
                  '${p?.nqueensSolved ?? 0}', Icons.grid_4x4, Colors.purple),
              _statCard(context, 'Maze\nSolved',
                  '${p?.mazeSolved ?? 0}', Icons.route, Colors.teal),
              _statCard(context, 'Total XP', '${p?.xp ?? 0}',
                  Icons.star, Colors.orange),
              _statCard(context, 'Timed\nChallenges',
                  '${p?.timedChallengesCompleted ?? 0}', Icons.timer, Colors.deepOrange),
              _statCard(context, 'Predict\nModes',
                  '${p?.predictsCompleted ?? 0}', Icons.psychology, Colors.deepPurple),
            ],
          ),
          const SizedBox(height: 16),
          if (p?.lastActiveFormatted != null)
            Center(
              child: Text(
                'Last active: ${p!.lastActiveFormatted}',
                style: TextStyle(
                    color: cs.onSurfaceVariant, fontStyle: FontStyle.italic),
              ),
            ),
        ],
      ),
    );
  }

  Widget _statCard(BuildContext context, String title, String value,
      IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 26, color: color),
            const SizedBox(height: 6),
            Text(value,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 4),
            Flexible(
              child: Text(title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 11,
                      color: Theme.of(context).colorScheme.onSurfaceVariant)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(BuildContext context, ProgressProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final p = provider.progress;
    final lessons = p?.completedLessons ?? [];
    final quizzes = p?.quizHistory ?? [];

    if (lessons.isEmpty && quizzes.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history_edu, size: 64, color: cs.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No history yet.',
                style: TextStyle(fontSize: 18, color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Complete lessons and quizzes to see them here!',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lessons.isNotEmpty) ...[
            _sectionHeader(context, 'Lessons Completed', lessons.length),
            const SizedBox(height: 8),
            ...lessons.map((lesson) => Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: cs.primary.withOpacity(0.1),
                      child: Icon(Icons.check_circle, color: cs.primary, size: 20),
                    ),
                    title: Text(lesson.title,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Completed'),
                  ),
                )),
            const SizedBox(height: 24),
          ],
          if (quizzes.isNotEmpty) ...[
            _sectionHeader(context, 'Quiz History', quizzes.length),
            const SizedBox(height: 8),
            ...quizzes.asMap().entries.map((entry) {
              final idx = entry.key;
              final quiz = entry.value;
              final dateStr =
                  '${quiz.completedAt.day}/${quiz.completedAt.month}/${quiz.completedAt.year}';
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: quiz.passed
                        ? Colors.green.withOpacity(0.15)
                        : Colors.red.withOpacity(0.15),
                    child: Text(
                      '${(quiz.percentage * 100).round()}%',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: quiz.passed ? Colors.green : Colors.red),
                    ),
                  ),
                  title: Text('Quiz Attempt #${quizzes.length - idx}',
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${quiz.score}/${quiz.totalQuestions} correct  ·  $dateStr'),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: quiz.passed
                          ? Colors.green.withOpacity(0.1)
                          : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      quiz.passed ? 'PASS' : 'FAIL',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: quiz.passed ? Colors.green : Colors.red),
                    ),
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title, int count) {
    return Row(
      children: [
        Text(title,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary)),
        ),
      ],
    );
  }

  Widget _buildAchievementsTab(
      BuildContext context, ProgressProvider provider) {
    final cs = Theme.of(context).colorScheme;
    final badges = provider.progress?.badges ?? [];

    final Map<String, Map<String, String>> badgeInfo = {
      'first_lesson': {'icon': 'book', 'label': 'First Lesson', 'desc': 'Completed your first lesson'},
      'quiz_master': {'icon': 'target', 'label': 'Quiz Master', 'desc': 'Passed 5 quizzes'},
      'sudoku_solver': {'icon': 'grid', 'label': 'Sudoku Solver', 'desc': 'Solved your first Sudoku'},
      'nqueens_hero': {'icon': 'queen', 'label': 'N-Queens Hero', 'desc': 'Solved N-Queens puzzle'},
      'streak_3': {'icon': 'fire', 'label': '3-Day Streak', 'desc': '3 days in a row'},
      'streak_7': {'icon': 'lightning', 'label': 'Week Warrior', 'desc': '7 days in a row'},
      'xp_100': {'icon': 'star', 'label': 'Century', 'desc': 'Reached 100 XP'},
      'xp_500': {'icon': 'trophy', 'label': 'XP Legend', 'desc': 'Reached 500 XP'},
      'daily_champion': {'icon': 'calendar', 'label': 'Daily Champion', 'desc': 'Completed daily challenge'},
      'backtrack_master': {'icon': 'brain', 'label': 'Backtrack Master', 'desc': 'Mastered backtracking'},
    };

    final IconData Function(String) iconFor = (key) {
      switch (key) {
        case 'fire': return Icons.local_fire_department;
        case 'lightning': return Icons.bolt;
        case 'star': return Icons.star;
        case 'trophy': return Icons.emoji_events;
        case 'brain': return Icons.psychology;
        case 'grid': return Icons.grid_on;
        case 'target': return Icons.adjust;
        case 'queen': return Icons.grid_4x4;
        case 'calendar': return Icons.calendar_today;
        default: return Icons.menu_book;
      }
    };

    if (badges.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.emoji_events, size: 64, color: cs.primary.withOpacity(0.3)),
            const SizedBox(height: 16),
            Text('No badges yet!',
                style: TextStyle(fontSize: 18, color: cs.onSurfaceVariant)),
            const SizedBox(height: 8),
            Text('Complete challenges to earn your first badge.',
                textAlign: TextAlign.center,
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badgeId = badges[index];
        final info = badgeInfo[badgeId] ??
            {'icon': 'book', 'label': badgeId, 'desc': 'Achievement unlocked'};
        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(iconFor(info['icon']!),
                    size: 36, color: cs.primary),
                const SizedBox(height: 8),
                Text(info['label']!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Text(info['desc']!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11, color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        );
      },
    );
  }
}
