import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../providers/maze_provider.dart';
import '../../widgets/common/stat_board.dart';
import '../../routes/app_routes.dart';

class MazeVisualizerScreen extends StatefulWidget {
  const MazeVisualizerScreen({super.key});

  @override
  State<MazeVisualizerScreen> createState() => _MazeVisualizerScreenState();
}

class _MazeVisualizerScreenState extends State<MazeVisualizerScreen> {
  int _selectedMaze = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MazeProvider>().loadAndSolve(_selectedMaze);
    });
  }

  void _onMazeSelected(int index) {
    setState(() {
      _selectedMaze = index;
    });
    context.read<MazeProvider>().loadAndSolve(index);
  }

  Widget _buildCell(int val, int r, int c, int rows, int cols) {
    Color color;
    Widget? icon;
    if (r == 0 && c == 0) {
      color = Colors.green.withValues(alpha: 0.3);
      icon = const Icon(Icons.play_arrow, color: Colors.green);
    } else if (r == rows - 1 && c == cols - 1) {
      color = Colors.amber.withValues(alpha: 0.3);
      icon = const Icon(Icons.star, color: Colors.amber);
    } else {
      switch (val) {
        case 1: color = Theme.of(context).colorScheme.onSurface; break;
        case 2: color = Theme.of(context).colorScheme.primary; break;
        case 3: color = Colors.red.withValues(alpha: 0.5); break;
        default: color = Theme.of(context).colorScheme.surface; break;
      }
    }
    
    return Container(
      decoration: BoxDecoration(
        color: color,
        border: Border.all(color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(child: icon),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<MazeProvider>();
    final grid = provider.currentGrid;
    final rows = grid.isNotEmpty ? grid.length : 0;
    final cols = grid.isNotEmpty ? grid[0].length : 0;

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
        title: const Text('Maze Visualizer'),
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
          IconButton(
            icon: const Icon(Icons.sports_esports),
            tooltip: 'Manual Play',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.mazeManual),
          ),
          IconButton(
            icon: const Icon(Icons.psychology),
            tooltip: 'Predict Mode',
            onPressed: () {
              // Not directly navigating to predict unless predict provider sets it up.
              // Just a placeholder or route to predict.
              Navigator.of(context).pushNamed(AppRoutes.predict);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChoiceChip(
                    label: const Text('Easy (5x5)'),
                    selected: _selectedMaze == 0,
                    onSelected: (_) => _onMazeSelected(0),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Medium (7x7)'),
                    selected: _selectedMaze == 1,
                    onSelected: (_) => _onMazeSelected(1),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Hard (9x9)'),
                    selected: _selectedMaze == 2,
                    onSelected: (_) => _onMazeSelected(2),
                  ),
                ],
              ),
            ),
            if (provider.isSolved)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Theme.of(context).colorScheme.tertiary),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary),
                    const SizedBox(width: 8),
                    Text('PATH FOUND!', style: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ).animate().fadeIn().scale(),
            Expanded(
              flex: 3,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: cols > 0 ? cols / rows : 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols > 0 ? cols : 1,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: rows * cols,
                      itemBuilder: (context, index) {
                        final r = index ~/ cols;
                        final c = index % cols;
                        return _buildCell(grid[r][c], r, c, rows, cols);
                      },
                    ),
                  ),
                ),
              ),
            ),
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
                  decisionRoot: 'Root: Start (0, 0)',
                  decisionNode: provider.currentStep != null ? 'Cell (${provider.currentStep!.row}, ${provider.currentStep!.col})' : '',
                  decisionLeaf: provider.currentStep != null ? '${provider.currentStep!.action.toUpperCase()}' : '',
                ).animate().fadeIn(delay: 400.ms).slideY(),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.skip_previous),
                        onPressed: provider.previousStep,
                      ),
                      IconButton(
                        icon: Icon(provider.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                        iconSize: 48,
                        color: Theme.of(context).colorScheme.primary,
                        onPressed: provider.isPlaying ? provider.pause : provider.play,
                      ),
                      IconButton(
                        icon: const Icon(Icons.skip_next),
                        onPressed: provider.nextStep,
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: provider.reset,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.speed, size: 20),
                      Expanded(
                        child: Slider(
                          value: provider.speed,
                          min: 0.5,
                          max: 5.0,
                          divisions: 9,
                          onChanged: provider.setSpeed,
                        ),
                      ),
                      Text('${provider.speed.toStringAsFixed(1)}x'),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
