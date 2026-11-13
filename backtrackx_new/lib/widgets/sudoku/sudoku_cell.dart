import 'package:flutter/material.dart';

class SudokuCell extends StatelessWidget {
  final int value;
  final bool isInitial;
  final bool isHighlighted;
  final bool? highlightIsValid;
  final int row;
  final int col;

  const SudokuCell({
    super.key,
    required this.value,
    required this.isInitial,
    required this.isHighlighted,
    this.highlightIsValid,
    required this.row,
    required this.col,
  });

  Color _getBackgroundColor(BuildContext context) {
    if (isHighlighted) {
      if (highlightIsValid == true) {
        return Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.3);
      } else if (highlightIsValid == false) {
        return Theme.of(context).colorScheme.error.withValues(alpha: 0.3);
      } else {
        return Theme.of(context).colorScheme.secondary.withValues(alpha: 0.3);
      }
    }
    if (isInitial) {
      return Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
    }
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    // Determine border styles for 3x3 box boundaries
    final thickBorder = BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.0);
    final thinBorder = BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2), width: 1.0);
    
    final topBorder = row % 3 == 0 ? thickBorder : thinBorder;
    final leftBorder = col % 3 == 0 ? thickBorder : thinBorder;
    final rightBorder = col == 8 ? thickBorder : thinBorder;
    final bottomBorder = row == 8 ? thickBorder : thinBorder;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: BoxDecoration(
        color: _getBackgroundColor(context),
        border: Border(
          top: topBorder,
          left: leftBorder,
          right: rightBorder,
          bottom: bottomBorder,
        ),
      ),
      child: Center(
        child: Text(
          value == 0 ? '' : value.toString(),
          style: TextStyle(
            fontSize: 22,
            fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
            color: isInitial ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
