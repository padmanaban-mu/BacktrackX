import 'package:flutter/material.dart';

/// A generic placeholder screen used for every module that hasn't been
/// built yet (Learning, Sudoku, Progress, Settings, Profile). Every
/// Dashboard card and bottom-nav tab (besides Home) opens this with a
/// different title/icon. Once a module is actually built, its real
/// screen replaces the corresponding call site -- this file itself
/// doesn't need to change.
class ComingSoonScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const ComingSoonScreen({super.key, required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
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
                '/dashboard', (route) => false),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 72, color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)),
            const SizedBox(height: 16),
            Text(
              '$title is coming soon',
              style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}
