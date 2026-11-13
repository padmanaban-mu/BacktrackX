import '../models/sudoku_puzzle_model.dart';
import '../models/backtrack_step_model.dart';

class SudokuService {
  Future<List<SudokuPuzzleModel>> getPuzzles() async {
    return const [
      SudokuPuzzleModel(id: '1', name: 'Easy Puzzle', difficulty: 'easy', initialGrid: [
        [5, 3, 0, 0, 7, 0, 0, 0, 0],
        [6, 0, 0, 1, 9, 5, 0, 0, 0],
        [0, 9, 8, 0, 0, 0, 0, 6, 0],
        [8, 0, 0, 0, 6, 0, 0, 0, 3],
        [4, 0, 0, 8, 0, 3, 0, 0, 1],
        [7, 0, 0, 0, 2, 0, 0, 0, 6],
        [0, 6, 0, 0, 0, 0, 2, 8, 0],
        [0, 0, 0, 4, 1, 9, 0, 0, 5],
        [0, 0, 0, 0, 8, 0, 0, 7, 9],
      ]),
      SudokuPuzzleModel(id: '2', name: 'Medium Puzzle', difficulty: 'medium', initialGrid: [
        [0, 2, 0, 6, 0, 8, 0, 0, 0],
        [5, 8, 0, 0, 0, 9, 7, 0, 0],
        [0, 0, 0, 0, 4, 0, 0, 0, 0],
        [3, 7, 0, 0, 0, 0, 5, 0, 0],
        [6, 0, 0, 0, 0, 0, 0, 0, 4],
        [0, 0, 8, 0, 0, 0, 0, 1, 3],
        [0, 0, 0, 0, 2, 0, 0, 0, 0],
        [0, 0, 9, 8, 0, 0, 0, 3, 6],
        [0, 0, 0, 3, 0, 6, 0, 9, 0],
      ]),
    ];
  }

  Future<SudokuPuzzleModel> getPuzzleById(String id) async {
    final puzzles = await getPuzzles();
    return puzzles.firstWhere((p) => p.id == id);
  }

  List<BacktrackStepModel> solveWithSteps(List<List<int>> grid) {
    List<BacktrackStepModel> steps = [];
    List<List<int>> currentGrid = List.generate(9, (i) => List.from(grid[i]));
    
    _solve(currentGrid, steps);
    
    return steps;
  }

  List<List<int>> solve(List<List<int>> grid) {
    List<List<int>> currentGrid = List.generate(9, (i) => List.from(grid[i]));
    _solve(currentGrid, null); // Pass null to skip recording steps
    return currentGrid;
  }

  bool _solve(List<List<int>> grid, List<BacktrackStepModel>? steps) {
    bool record = steps != null;
    
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          for (int num = 1; num <= 9; num++) {
            if (record) {
              steps.add(BacktrackStepModel(
                stepIndex: steps.length,
                row: row,
                col: col,
                value: num,
                isValid: true,
                action: 'trying',
                explanation: 'Trying $num at row $row, col $col'
              ));
            }

            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (record) {
                steps.add(BacktrackStepModel(
                  stepIndex: steps.length,
                  row: row,
                  col: col,
                  value: num,
                  isValid: true,
                  action: 'valid',
                  explanation: 'Valid: Placed $num at row $row, col $col'
                ));
              }

              if (_solve(grid, steps)) {
                return true;
              }

              // Backtrack
              grid[row][col] = 0;
              if (record) {
                steps.add(BacktrackStepModel(
                  stepIndex: steps.length,
                  row: row,
                  col: col,
                  value: num,
                  isValid: false,
                  action: 'backtrack',
                  explanation: 'Backtracking from row $row, col $col'
                ));
              }
            } else {
              if (record) {
                steps.add(BacktrackStepModel(
                  stepIndex: steps.length,
                  row: row,
                  col: col,
                  value: num,
                  isValid: false,
                  action: 'invalid',
                  explanation: 'Conflict found: $num already in row, col, or box'
                ));
              }
            }
          }
          return false;
        }
      }
    }
    return true;
  }

  bool _isValid(List<List<int>> grid, int row, int col, int num) {
    // Check row and column
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num) return false;
      if (grid[i][col] == num) return false;
    }
    // Check 3x3 box
    int startRow = row - (row % 3);
    int startCol = col - (col % 3);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if (grid[startRow + i][startCol + j] == num) return false;
      }
    }
    return true;
  }
}
