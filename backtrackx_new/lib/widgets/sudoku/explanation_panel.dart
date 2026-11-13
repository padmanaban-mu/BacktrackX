import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sudoku_provider.dart';

class ExplanationPanel extends StatelessWidget {
  const ExplanationPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SudokuProvider>(
      builder: (context, provider, child) {
        final step = provider.currentStep;

        if (step == null) {
          return Card(
            color: Theme.of(context).scaffoldBackgroundColor,
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Text(
                  'Press Play to start the visualization',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }

        IconData iconData;
        Color iconColor;

        // Based on typical action types
        switch (step.action) {
          case 'place':
            iconData = Icons.add_circle_outline;
            iconColor = Theme.of(context).colorScheme.primary;
            break;
          case 'valid':
            iconData = Icons.check_circle_outline;
            iconColor = Theme.of(context).colorScheme.tertiary;
            break;
          case 'invalid':
            iconData = Icons.cancel_outlined;
            iconColor = Theme.of(context).colorScheme.error;
            break;
          case 'backtrack':
            iconData = Icons.undo;
            iconColor = Colors.orange; // Custom semantic color for backtrack
            break;
          default:
            iconData = Icons.info_outline;
            iconColor = Theme.of(context).colorScheme.secondary;
        }

        return Card(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: iconColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconData, color: iconColor, size: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Cell (${step.row}, ${step.col}) - Value: ${step.value}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        step.explanation,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontSize: 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
