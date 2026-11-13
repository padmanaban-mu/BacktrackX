import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/nqueens_provider.dart';
import '../../widgets/common/stat_board.dart';
import '../../routes/app_routes.dart';

class NQueensVisualizerScreen extends StatefulWidget {
  const NQueensVisualizerScreen({super.key});

  @override
  State<NQueensVisualizerScreen> createState() => _NQueensVisualizerScreenState();
}

class _NQueensVisualizerScreenState extends State<NQueensVisualizerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NQueensProvider>().loadAndSolve(8);
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<NQueensProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
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
        title: const Text('N-Queens Visualizer'),
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
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, AppRoutes.nqueensManual),
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
            // Board Size Selector
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Board Size: '),
                  const SizedBox(width: 8),
                  Wrap(
                    spacing: 8,
                    children: [4, 6, 8].map((size) {
                      return ChoiceChip(
                        label: Text('$size x $size'),
                        selected: provider.boardSize == size,
                        onSelected: (selected) {
                          if (selected) {
                            provider.loadAndSolve(size);
                          }
                        },
                      );
                    }).toList(),
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms).slideY(),
            ),

            // Chessboard
            Expanded(
              flex: 3,
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.colorScheme.primary, width: 2),
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: provider.boardSize,
                        ),
                        itemCount: provider.boardSize * provider.boardSize,
                        itemBuilder: (context, index) {
                          int row = index ~/ provider.boardSize;
                          int col = index % provider.boardSize;
                          
                          bool isDarkSquare = (row + col) % 2 != 0;
                          Color cellColor = isDarkSquare 
                              ? theme.colorScheme.primary.withValues(alpha: 0.15)
                              : theme.colorScheme.surface;

                          bool hasQueen = provider.queensPerRow.length > row && provider.queensPerRow[row] == col;
                          
                          bool isAttacked = provider.attackedCells.any((cell) => cell[0] == row && cell[1] == col);
                          
                          bool isActive = provider.currentStep?.row == row && provider.currentStep?.col == col;

                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            decoration: BoxDecoration(
                              color: isAttacked 
                                ? theme.colorScheme.error.withValues(alpha: 0.35)
                                : cellColor,
                              border: Border.all(
                                color: isActive ? theme.colorScheme.primary : Colors.transparent,
                                width: isActive ? 3 : 0,
                              ),
                            ),
                            child: Center(
                              child: hasQueen 
                                ? Text(
                                    '♛',
                                    style: TextStyle(
                                      fontSize: 32 - (provider.boardSize - 4) * 2,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ).animate(key: ValueKey('$row-$col-queen')).scale(duration: 200.ms)
                                : null,
                            ),
                          );
                        },
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).scale(),
                ),
              ),
            ),
            
            // Solved Banner
            if (provider.isSolved)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: theme.colorScheme.tertiary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: theme.colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Text(
                      'Solved!',
                      style: TextStyle(
                        color: theme.colorScheme.tertiary,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn().slideY(),

            // Explanation Panel (StatBoard)
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: StatBoard(
                  action: provider.currentStep?.action,
                  explanation: provider.currentStep?.explanation,
                  stepIndex: provider.currentStepIndex,
                  totalSteps: provider.steps.length,
                  isValid: provider.currentStep?.isValid ?? false,
                  decisionRoot: 'Root: Place Queens',
                  decisionNode: provider.currentStep != null ? 'Cell (${provider.currentStep!.row}, ${provider.currentStep!.col})' : '',
                  decisionLeaf: provider.currentStep != null ? '${provider.currentStep!.action.toUpperCase()}' : '',
                ).animate().fadeIn(delay: 400.ms).slideY(),
              ),
            ),

            // Playback Controls
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0, left: 16, right: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: provider.previousStep,
                        color: theme.colorScheme.primary,
                        iconSize: 32,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                        onPressed: provider.isPlaying ? provider.pause : provider.play,
                        color: theme.colorScheme.secondary,
                        iconSize: 48,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: provider.nextStep,
                        color: theme.colorScheme.primary,
                        iconSize: 32,
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.replay),
                        onPressed: provider.reset,
                        color: theme.colorScheme.primary,
                        iconSize: 32,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 20),
                      Expanded(
                        child: Slider(
                          value: provider.speed,
                          min: 0.5,
                          max: 5.0,
                          divisions: 9,
                          label: '${provider.speed}x',
                          activeColor: theme.colorScheme.primary,
                          onChanged: provider.setSpeed,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 600.ms).slideY(),
          ],
        ),
      ),
    );
  }
}
