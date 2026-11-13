import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/leaderboard_provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final token = context.read<AuthProvider>().token ?? '';
      context.read<LeaderboardProvider>().load(token: token);
    });
  }

  Widget _buildMedal(int rank) {
    switch (rank) {
      case 1:
        return const Text('🥇', style: TextStyle(fontSize: 24));
      case 2:
        return const Text('🥈', style: TextStyle(fontSize: 24));
      case 3:
        return const Text('🥉', style: TextStyle(fontSize: 24));
      default:
        return Text('#$rank', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold));
    }
  }

  Color? _getRankColor(int rank, BuildContext context) {
    if (rank == 1) return Colors.amber.withValues(alpha: 0.2);
    if (rank == 2) return Colors.grey.shade400.withValues(alpha: 0.2);
    if (rank == 3) return Colors.brown.shade300.withValues(alpha: 0.2);
    return Theme.of(context).cardTheme.color;
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LeaderboardProvider>();
    final token = context.read<AuthProvider>().token ?? '';
    final isGlobal = provider.scope == 'global';
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
  icon: Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
  ),
  tooltip: 'Back',
  onPressed: () => Navigator.of(context).pop(),
),
        title: const Text('Leaderboard 🏆'),
        actions: [
          IconButton(
  icon: Container(
    padding: const EdgeInsets.all(6),
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.25),
      borderRadius: BorderRadius.circular(8),
    ),
    child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
  ),
  tooltip: 'Go to Home',
  onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
    AppRoutes.dashboard, (route) => false),
),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ToggleButtons(
              isSelected: [isGlobal, !isGlobal],
              onPressed: (index) {
                final newScope = index == 0 ? 'global' : 'weekly';
                if (provider.scope != newScope) {
                  provider.toggleScope(newScope, token: token);
                }
              },
              borderRadius: BorderRadius.circular(8),
              selectedColor: colorScheme.onPrimary,
              fillColor: colorScheme.primary,
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('All Time')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('This Week')),
              ],
            ),
          ),
          if (provider.isLoading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (provider.error != null)
            Expanded(child: Center(child: Text(provider.error!)))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: provider.entries.length,
                itemBuilder: (context, index) {
                  final entry = provider.entries[index];
                  return Card(
                    color: _getRankColor(entry.rank, context),
                    margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    child: ListTile(
                      leading: _buildMedal(entry.rank),
                      title: Text(entry.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('Level ${entry.level} • ${entry.xp} XP'),
                      trailing: entry.currentStreak > 0
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('🔥'),
                                Text('${entry.currentStreak}', style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
                              ],
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
          if (!provider.isLoading && provider.myRank != null && (provider.myRank!['rank'] as int) > 50)
            Container(
              color: colorScheme.primaryContainer,
              padding: const EdgeInsets.all(16),
              child: SafeArea(
                child: Row(
                  children: [
                    Text('#${provider.myRank!['rank']}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 16),
                    const Expanded(child: Text('You', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                    Text('${provider.myRank!['xp']} XP', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
