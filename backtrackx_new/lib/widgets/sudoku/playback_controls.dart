import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sudoku_provider.dart';

class PlaybackControls extends StatefulWidget {
  const PlaybackControls({super.key});

  @override
  State<PlaybackControls> createState() => _PlaybackControlsState();
}

class _PlaybackControlsState extends State<PlaybackControls> {
  double _currentSpeed = 1.0;

  @override
  Widget build(BuildContext context) {
    return Consumer<SudokuProvider>(
      builder: (context, provider, child) {
        final total = provider.totalSteps;
        final current = provider.currentStepIndex;
        final double progress = total > 0 ? (current / total).clamp(0.0, 1.0) : 0.0;
        
        final canGoPrevious = current > 0;
        final canGoNext = current < total;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              color: Theme.of(context).colorScheme.primary,
              minHeight: 8.0,
              borderRadius: BorderRadius.circular(4.0),
            ),
            const SizedBox(height: 12),
            Text(
              'Step $current / $total',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: canGoPrevious ? () => provider.previousStep() : null,
                  tooltip: 'Previous Step',
                ),
                IconButton(
                  icon: Icon(
                    provider.isPlaying ? Icons.pause : Icons.play_arrow,
                    size: 32,
                  ),
                  color: Theme.of(context).colorScheme.primary,
                  onPressed: () {
                    if (provider.isPlaying) {
                      provider.pause();
                    } else {
                      provider.play();
                    }
                  },
                  tooltip: provider.isPlaying ? 'Pause' : 'Play',
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: canGoNext ? () => provider.nextStep() : null,
                  tooltip: 'Next Step',
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  color: Theme.of(context).colorScheme.error,
                  onPressed: () => provider.reset(),
                  tooltip: 'Reset',
                ),
                const SizedBox(width: 24),
                DropdownButton<double>(
                  value: _currentSpeed,
                  dropdownColor: Theme.of(context).scaffoldBackgroundColor,
                  items: const [
                    DropdownMenuItem(value: 0.5, child: Text('0.5x Speed')),
                    DropdownMenuItem(value: 1.0, child: Text('1x Speed')),
                    DropdownMenuItem(value: 1.5, child: Text('1.5x Speed')),
                    DropdownMenuItem(value: 2.0, child: Text('2x Speed')),
                    DropdownMenuItem(value: 3.0, child: Text('3x Speed')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _currentSpeed = value;
                      });
                      provider.setSpeed(value);
                    }
                  },
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
