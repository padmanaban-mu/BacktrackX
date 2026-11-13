class NQueensStepModel {
  final int stepIndex;
  final int row;
  final int col;
  final String action; // 'place', 'remove', 'conflict'
  final String explanation;
  final List<int> queensPerRow; // index=row, value=col (-1 if empty)
  final List<List<int>> attackedCells; // list of [row,col] pairs under attack
  final bool isValid;
  
  const NQueensStepModel({
    required this.stepIndex,
    required this.row,
    required this.col,
    required this.action,
    required this.explanation,
    required this.queensPerRow,
    required this.attackedCells,
    required this.isValid,
  });
}

class NQueensService {
  /// Public static constraint checker — reused by both the solver and manual play mode.
  /// queensPerRow: list where index=row, value=col of placed queen (-1 if none)
  static bool isSafe(List<int> queensPerRow, int row, int col) {
    for (int i = 0; i < row; i++) {
      final c = queensPerRow[i];
      if (c == -1) continue;
      if (c == col) return false; // same column
      if ((i - row).abs() == (c - col).abs()) return false; // diagonal
    }
    return true;
  }

  /// Returns the conflicting queen's row and reason, or null if safe.
  static String? conflictReason(List<int> queensPerRow, int row, int col) {
    for (int i = 0; i < row; i++) {
      final c = queensPerRow[i];
      if (c == -1) continue;
      if (c == col) return 'Conflicts with queen at row $i — same column';
      if ((i - row).abs() == (c - col).abs()) return 'Conflicts with queen at row $i — same diagonal';
    }
    return null;
  }

  List<NQueensStepModel> solveWithSteps(int n) {
    List<NQueensStepModel> steps = [];
    List<int> queensPerRow = List.filled(n, -1);
    int stepCounter = 0;

    void addStep(int row, int col, String action, String explanation, bool isValid, List<List<int>> attacked) {
      steps.add(NQueensStepModel(
        stepIndex: stepCounter++,
        row: row,
        col: col,
        action: action,
        explanation: explanation,
        queensPerRow: List.from(queensPerRow),
        attackedCells: attacked,
        isValid: isValid,
      ));
    }

    List<List<int>> getAttackedBy(int row, int col) {
      List<List<int>> attacked = [];
      for (int i = 0; i < row; i++) {
        int r = i;
        int c = queensPerRow[i];
        if (c != -1) {
          if (c == col || (r - row).abs() == (c - col).abs()) {
            attacked.add([r, c]);
          }
        }
      }
      return attacked;
    }


    bool solve(int row) {
      if (row == n) return true;

      for (int col = 0; col < n; col++) {
        queensPerRow[row] = col;
        
        List<List<int>> attacked = getAttackedBy(row, col);
        bool isValid = attacked.isEmpty;
        
        if (isValid) {
          addStep(row, col, 'place', 'Trying queen at ($row, $col). It is safe.', true, []);
          if (solve(row + 1)) return true;
          addStep(row, col, 'remove', 'Backtracking from ($row, $col) because no solution found down this path.', false, []);
        } else {
          // Add the current cell as attacked too, along with the cells attacking it
          attacked.add([row, col]);
          addStep(row, col, 'conflict', 'Conflict at ($row, $col) with existing queens.', false, attacked);
        }
        
        queensPerRow[row] = -1;
      }
      return false;
    }

    solve(0);
    return steps;
  }
}
