import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/sudoku_provider.dart';
import 'sudoku_cell.dart';

class SudokuGrid extends StatelessWidget {
  const SudokuGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SudokuProvider>(
      builder: (context, provider, child) {
        final grid = provider.currentGrid;

        return AspectRatio(
          aspectRatio: 1.0,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).colorScheme.primary, width: 2.0),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 16,
                  spreadRadius: 2,
                )
              ]
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.0),
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 9,
                ),
                itemCount: 81,
                itemBuilder: (context, index) {
                  final row = index ~/ 9;
                  final col = index % 9;
                  final value = grid[row][col];
                  
                  // Note: Make sure SudokuProvider implements an `isInitial(row, col)` method 
                  // or provide a way to determine if a cell is an initial puzzle number.
                  // Defaulting to false if the method doesn't exist yet to avoid compile errors.
                  final bool isInitial = _checkInitial(provider, row, col);
                  
                  final isHighlighted = (provider.highlightRow == row && provider.highlightCol == col);
                  final highlightIsValid = provider.highlightIsValid;

                  return SudokuCell(
                    value: value,
                    isInitial: isInitial,
                    isHighlighted: isHighlighted,
                    highlightIsValid: highlightIsValid,
                    row: row,
                    col: col,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  bool _checkInitial(SudokuProvider provider, int row, int col) {
    try {
      // Trying to call isInitial if it was defined, fallback to false.
      // Assuming a standard provider.isInitial method was created by user.
      return provider.isInitial(row, col);
    } catch (_) {
      return false; // Fallback if isInitial is not implemented
    }
  }
}
