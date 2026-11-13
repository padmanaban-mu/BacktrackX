import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/predict_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../routes/app_routes.dart';

class PredictScreen extends StatefulWidget {
  const PredictScreen({super.key});
  @override
  State<PredictScreen> createState() => _PredictScreenState();
}

class _PredictScreenState extends State<PredictScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final p = context.read<PredictProvider>();
      // only init if not already loaded
      if (p.currentNQStep == null && !p.isComplete) {
        p.initNQueens(8);
      }
    });
  }

  Widget _buildNQueensBoard(PredictProvider provider, ColorScheme cs) {
    if (provider.currentNQStep == null) return const SizedBox();
    final n = provider.currentNQStep!.queensPerRow.length;
    final attacked = provider.currentNQStep!.attackedCells;
    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: cs.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: n),
          itemCount: n * n,
          itemBuilder: (context, index) {
            final r = index ~/ n;
            final c = index % n;
            final isLight = (r + c) % 2 == 0;
            final hasQueen = provider.currentNQStep!.queensPerRow[r] == c;
            final isAttacked = attacked.any((cell) => cell[0] == r && cell[1] == c);
            Color cellColor = isLight ? Colors.white : Colors.grey.shade300;
            if (isAttacked) cellColor = Colors.red.shade100;
            if (hasQueen) cellColor = isLight ? cs.primaryContainer : cs.primary.withOpacity(0.3);
            return Container(
              decoration: BoxDecoration(
                color: cellColor,
                border: Border.all(color: Colors.grey.shade400, width: 0.3),
              ),
              child: Center(
                child: hasQueen
                    ? Text('♛', style: TextStyle(fontSize: n <= 6 ? 20 : 14, color: cs.primary))
                    : isAttacked
                        ? Text('✗', style: TextStyle(fontSize: 10, color: Colors.red.shade300))
                        : null,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSudokuBoard(PredictProvider provider, ColorScheme cs) {
    // Show current sudoku step grid
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: cs.primary, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(child: Padding(
        padding: EdgeInsets.all(16),
        child: Text('Sudoku — see algorithm state above', style: TextStyle(fontStyle: FontStyle.italic)),
      )),
    );
  }

  Widget _buildMazeBoard(PredictProvider provider, ColorScheme cs) {
    if (provider.currentMazeStep == null) return const SizedBox();
    final grid = provider.currentMazeStep!.grid;
    final rows = grid.length;
    final cols = grid[0].length;
    return AspectRatio(
      aspectRatio: cols / rows,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: cs.primary, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols),
          itemCount: rows * cols,
          itemBuilder: (context, index) {
            final r = index ~/ cols;
            final c = index % cols;
            final val = grid[r][c];
            Color cellColor;
            Widget? child;
            if (r == 0 && c == 0) {
              cellColor = Colors.green.shade300;
              child = const Text('S', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
            } else if (r == rows - 1 && c == cols - 1) {
              cellColor = Colors.amber.shade300;
              child = const Text('E', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
            } else if (val == 1) {
              cellColor = Colors.grey.shade800;
            } else if (val == 2) {
              cellColor = cs.primaryContainer;
            } else if (val == 3) {
              cellColor = Colors.red.shade200;
            } else {
              cellColor = Colors.white;
            }
            return Container(
              decoration: BoxDecoration(
                color: cellColor,
                border: Border.all(color: Colors.grey.shade300, width: 0.2),
              ),
              child: Center(child: child),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧠 Predict the Next Step'),
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
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
      body: Consumer<PredictProvider>(
        builder: (context, provider, _) {
          if (provider.isComplete) {
            return _buildCompletionScreen(provider, cs);
          }
          return _buildGameScreen(provider, cs);
        },
      ),
    );
  }

  Widget _buildCompletionScreen(PredictProvider provider, ColorScheme cs) {
    if (!provider.xpAwarded && provider.totalXP > 0) {
      provider.xpAwarded = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final token = context.read<AuthProvider>().token ?? '';
        context.read<ProgressProvider>().awardGameXP(
          token: token,
          action: 'predictComplete',
          multiplier: provider.totalXP / 5.0, // send proportional XP
        );
      });
    }

    final percent = provider.totalSteps > 0 ? (provider.score / provider.totalSteps * 100).round() : 0;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(percent >= 70 ? '🏆' : '📚', style: const TextStyle(fontSize: 64))
                .animate().scale(duration: 600.ms, curve: Curves.elasticOut),
            const SizedBox(height: 16),
            Text(
              percent >= 70 ? 'Excellent!' : 'Keep Practicing!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: cs.primary),
            ),
            const SizedBox(height: 8),
            Text('Score: ${provider.score} / ${provider.totalSteps}',
                style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text('Total XP Earned: +${provider.totalXP} XP',
                style: TextStyle(fontSize: 18, color: cs.primary, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(color: cs.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Text('Accuracy: $percent%',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: cs.onPrimaryContainer)),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Play Again'),
                  style: ElevatedButton.styleFrom(backgroundColor: cs.primary, foregroundColor: cs.onPrimary),
                  onPressed: () => provider.initNQueens(8),
                ),
                const SizedBox(width: 16),
                OutlinedButton.icon(
                  icon: const Icon(Icons.home_rounded),
                  label: const Text('Home'),
                  onPressed: () => Navigator.of(context)
                      .pushNamedAndRemoveUntil(AppRoutes.dashboard, (r) => false),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameScreen(PredictProvider provider, ColorScheme cs) {
    final question = provider.currentQuestion;
    return Column(
      children: [
        // Progress + combo bar
        _buildProgressBar(provider, cs),
        // Board
        Expanded(
          flex: 3,
          child: _buildBoard(provider, cs),
        ),
        // Current state explanation
        if (provider.algorithm == PredictAlgorithm.nqueens && provider.currentNQStep != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 16, color: cs.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Current: ${provider.currentNQStep!.explanation}',
                    style: TextStyle(fontSize: 13, color: cs.onSurface, fontStyle: FontStyle.italic),
                  ),
                ),
              ],
            ),
          ),
        // Question prompt + hint
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                question?.prompt ?? 'What happens next?',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: cs.onPrimaryContainer),
              ),
              if (question != null) ...
                [
                  const SizedBox(height: 4),
                  Text(question.hint, style: TextStyle(fontSize: 12, color: cs.onPrimaryContainer.withOpacity(0.7))),
                ]
            ],
          ),
        ),
        // MCQ Options
        Expanded(
          flex: 4,
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            itemCount: provider.options.length,
            itemBuilder: (context, index) {
              return _buildOption(provider, cs, index);
            },
          ),
        ),
        // Answer explanation + Next
        if (provider.answered) _buildAnswerPanel(provider, cs),
      ],
    );
  }

  Widget _buildProgressBar(PredictProvider provider, ColorScheme cs) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: cs.surface,
      child: Row(
        children: [
          Text('Q ${provider.currentStepIndex + 1}/${provider.totalSteps}',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: provider.score / provider.totalSteps,
                color: cs.primary,
                backgroundColor: cs.surfaceContainerHighest,
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 12),
          if (provider.combo > 1)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text('🔥 ${provider.combo}x COMBO',
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
            )
          else
            Text('Score: ${provider.score}', style: TextStyle(color: cs.primary, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBoard(PredictProvider provider, ColorScheme cs) {
    switch (provider.algorithm) {
      case PredictAlgorithm.nqueens:
        return _buildNQueensBoard(provider, cs);
      case PredictAlgorithm.sudoku:
        return _buildSudokuBoard(provider, cs);
      case PredictAlgorithm.maze:
        return _buildMazeBoard(provider, cs);
    }
  }

  Widget _buildOption(PredictProvider provider, ColorScheme cs, int index) {
    final option = provider.options[index];
    final answered = provider.answered;
    final selected = provider.selectedOption == index;
    Color bgColor = cs.surfaceContainerHighest;
    Color textColor = cs.onSurface;
    IconData? leadIcon;
    if (answered) {
      if (option.isCorrect) {
        bgColor = Colors.green.shade400;
        textColor = Colors.white;
        leadIcon = Icons.check_circle;
      } else if (selected) {
        bgColor = Colors.red.shade400;
        textColor = Colors.white;
        leadIcon = Icons.cancel;
      }
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        borderRadius: BorderRadius.circular(12),
        color: bgColor,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: answered ? null : () => provider.selectAnswer(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: answered && option.isCorrect ? Colors.white : cs.primary.withOpacity(0.15),
                  ),
                  child: Center(
                    child: leadIcon != null
                        ? Icon(leadIcon, size: 18, color: answered && option.isCorrect ? Colors.green : Colors.white)
                        : Text(String.fromCharCode(65 + index),
                            style: TextStyle(fontWeight: FontWeight.bold, color: cs.primary)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(option.label, style: TextStyle(fontSize: 15, color: textColor, fontWeight: FontWeight.w500))),
              ],
            ),
          ),
        ),
      ).animate(delay: (index * 80).ms).slideX(begin: 0.2).fadeIn(),
    );
  }

  Widget _buildAnswerPanel(PredictProvider provider, ColorScheme cs) {
    final correct = provider.selectedOption != null && provider.options[provider.selectedOption!].isCorrect;
    final xpEarned = correct ? (5 * provider.multiplier).round() : 0;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: correct ? Colors.green.shade50 : Colors.red.shade50,
        border: Border.all(color: correct ? Colors.green : Colors.red, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(correct ? Icons.check_circle : Icons.cancel, color: correct ? Colors.green : Colors.red),
              const SizedBox(width: 8),
              Text(
                correct ? '+${xpEarned} XP${provider.combo > 1 ? " (${provider.multiplier}x combo!)" : ""}' : 'Incorrect',
                style: TextStyle(fontWeight: FontWeight.bold, color: correct ? Colors.green : Colors.red, fontSize: 16),
              ),
            ],
          ),
          if (provider.answerExplanation.isNotEmpty) ...
            [
              const SizedBox(height: 6),
              Text(provider.answerExplanation, style: TextStyle(fontSize: 13, color: Colors.grey.shade800)),
            ],
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.primary,
                foregroundColor: cs.onPrimary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () => provider.nextQuestion(),
              child: const Text('Next Question →'),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 0.3).fadeIn(duration: 300.ms);
  }
}
