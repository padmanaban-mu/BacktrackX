import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sudoku_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class StateExplorerPanel extends StatelessWidget {
  const StateExplorerPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SudokuProvider>(
      builder: (context, provider, child) {
        final step = provider.currentStep;
        
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
                blurRadius: 20,
                spreadRadius: 2,
              )
            ]
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  border: Border(bottom: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2))),
                ),
                child: Row(
                  children: [
                    Icon(Icons.account_tree, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Algorithm State Explorer',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: step == null 
                    ? Center(
                        child: Text(
                          'Press Play to begin visualization.\nThe algorithm tree will appear here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.all(16),
                        children: [
                          _buildCurrentActionHeader(context, step.action, step.explanation),
                          const SizedBox(height: 24),
                          Text('Decision History', style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurfaceVariant)),
                          const SizedBox(height: 12),
                          // Simulated history visual tree based on the step index
                          _buildDecisionTree(context, provider),
                        ],
                      ).animate().fadeIn(),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCurrentActionHeader(BuildContext context, String action, String explanation) {
    Color actionColor;
    IconData actionIcon;
    
    switch (action) {
      case 'place':
        actionColor = Theme.of(context).colorScheme.primary;
        actionIcon = Icons.add_circle_outline;
        break;
      case 'valid':
        actionColor = Theme.of(context).colorScheme.tertiary;
        actionIcon = Icons.check_circle_outline;
        break;
      case 'invalid':
        actionColor = Theme.of(context).colorScheme.error;
        actionIcon = Icons.cancel_outlined;
        break;
      case 'backtrack':
        actionColor = Colors.orangeAccent;
        actionIcon = Icons.undo;
        break;
      default:
        actionColor = Theme.of(context).colorScheme.secondary;
        actionIcon = Icons.info_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: actionColor.withValues(alpha: 0.1),
        border: Border.all(color: actionColor, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(actionIcon, color: actionColor),
              const SizedBox(width: 8),
              Text(
                action.toUpperCase(),
                style: TextStyle(color: actionColor, fontWeight: FontWeight.bold, letterSpacing: 1.2),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            explanation,
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
          ),
        ],
      ),
    ).animate(key: ValueKey(explanation)).scale(duration: 200.ms, curve: Curves.easeOutBack);
  }

  Widget _buildDecisionTree(BuildContext context, SudokuProvider provider) {
    // In a real app we would track the stack of all moves.
    // For now we will just show the current move branching off a root.
    final step = provider.currentStep!;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTreeNode(context, 'Root: Solving...', isRoot: true, isLast: false, color: Theme.of(context).colorScheme.secondary),
        _buildTreeNode(context, 'Cell (${step.row}, ${step.col})', isRoot: false, isLast: false, color: Theme.of(context).colorScheme.onSurface),
        _buildTreeNode(
          context,
          'Try ${step.value} → ${step.action == 'valid' ? 'Success' : step.action == 'invalid' ? 'Failed' : step.action}', 
          isRoot: false, 
          isLast: true, 
          color: step.isValid ? Theme.of(context).colorScheme.tertiary : (step.action == 'invalid' ? Theme.of(context).colorScheme.error : Theme.of(context).colorScheme.primary)
        ).animate().slideX(begin: 0.2, duration: 300.ms),
      ],
    );
  }

  Widget _buildTreeNode(BuildContext context, String label, {required bool isRoot, required bool isLast, required Color color}) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: isRoot 
                ? Icon(Icons.circle, size: 12, color: Theme.of(context).colorScheme.secondary)
                : Column(
                    children: [
                      Container(width: 2, height: 16, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                      Row(
                        children: [
                          Container(width: 14, height: 2, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3)),
                          Icon(Icons.circle, size: 8, color: color),
                        ],
                      ),
                      if (!isLast) Expanded(child: Container(width: 2, color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.3))),
                    ],
                  ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 16.0),
              child: Text(
                label,
                style: TextStyle(color: color, fontWeight: isRoot ? FontWeight.bold : FontWeight.normal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
