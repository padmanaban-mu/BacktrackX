import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/stat_board.dart';
import '../../widgets/sudoku/sudoku_grid.dart';
import '../../widgets/sudoku/playback_controls.dart';
import '../../providers/sudoku_provider.dart';
import '../../routes/app_routes.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SudokuVisualizerScreen extends StatefulWidget {
  const SudokuVisualizerScreen({super.key});

  @override
  State<SudokuVisualizerScreen> createState() => _SudokuVisualizerScreenState();
}

class _SudokuVisualizerScreenState extends State<SudokuVisualizerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SudokuProvider>().loadPuzzles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SudokuProvider>();

    return PopScope(
      canPop: provider.selectedPuzzle == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          provider.reset();
        }
      },
      child: Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Visualizer'),
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
          onPressed: () {
            if (provider.selectedPuzzle != null) {
              provider.reset();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
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
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.sudokuManual),
                  child: const Text('Manual Play'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.predict),
                  child: const Text('Predict Mode'),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.timedChallenge),
                  child: const Text('Timed Challenge'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _buildBody(context, provider),
          ),
        ],
      ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, SudokuProvider provider) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (provider.errorMessage != null) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.loadPuzzles(),
      );
    }

    if (provider.selectedPuzzle == null) {
      return _buildPuzzlePicker(provider);
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final step = provider.currentStep;
        final statBoard = StatBoard(
          action: step?.action,
          explanation: step?.explanation,
          stepIndex: provider.currentStepIndex,
          totalSteps: provider.totalSteps,
          isValid: step?.isValid ?? false,
          decisionRoot: 'Root: Solving...',
          decisionNode: step != null ? 'Cell (${step.row}, ${step.col})' : '',
          decisionLeaf: step != null ? 'Try ${step.value} → ${step.action == 'valid' ? 'Success' : step.action == 'invalid' ? 'Failed' : step.action}' : '',
        );

        if (constraints.maxWidth > 800) {
          // Desktop/Web side-by-side layout
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 3,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: const SudokuGrid().animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.95, 0.95)),
                      ),
                      const SizedBox(height: 32),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: const PlaybackControls().animate().fadeIn(delay: 200.ms),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.only(top: 32.0, right: 32.0, bottom: 32.0),
                  child: statBoard,
                ).animate().slideX(begin: 0.2, duration: 400.ms).fadeIn(),
              ),
            ],
          );
        } else {
          // Mobile vertical layout
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 400,
                    child: SudokuGrid(),
                  ),
                ).animate().fadeIn(),
                const SizedBox(height: 24),
                const PlaybackControls().animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 24),
                SizedBox(
                  height: 400,
                  child: statBoard,
                ).animate().slideY(begin: 0.2).fadeIn(),
                const SizedBox(height: 32),
              ],
            ),
          );
        }
      },
    );
  }

  Widget _buildPuzzlePicker(SudokuProvider provider) {
    final puzzles = provider.puzzles;
    if (puzzles.isEmpty) {
      return const Center(child: Text('No puzzles available.'));
    }

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(24.0),
          itemCount: puzzles.length,
          itemBuilder: (context, index) {
            final puzzle = puzzles[index];
            Color badgeColor;
            switch (puzzle.difficulty.toLowerCase()) {
              case 'easy':
                badgeColor = Theme.of(context).colorScheme.tertiary;
                break;
              case 'medium':
                badgeColor = Colors.orange;
                break;
              case 'hard':
                badgeColor = Theme.of(context).colorScheme.error;
                break;
              default:
                badgeColor = Theme.of(context).colorScheme.secondary;
            }

            return Card(
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ListTile(
                contentPadding: const EdgeInsets.all(20.0),
                title: Text(
                  puzzle.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: badgeColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: badgeColor),
                    boxShadow: [
                      BoxShadow(
                        color: badgeColor.withValues(alpha: 0.2),
                        blurRadius: 8,
                      )
                    ]
                  ),
                  child: Text(
                    puzzle.difficulty.toUpperCase(),
                    style: TextStyle(
                      color: badgeColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                onTap: () => provider.selectPuzzle(puzzle.id),
              ).animate().fadeIn(delay: Duration(milliseconds: 100 * index)).slideX(),
            );
          },
        ),
            ),
          ],
        ),
      ),
    );
  }
}
