class MazeStepModel {
  final int stepIndex;
  final int row;
  final int col;
  final String action; // 'move', 'backtrack', 'wall', 'solved'
  final String explanation;
  final List<List<int>> grid; // snapshot
  final bool isValid;

  const MazeStepModel({
    required this.stepIndex,
    required this.row,
    required this.col,
    required this.action,
    required this.explanation,
    required this.grid,
    required this.isValid,
  });
}

class MazeService {
  static const List<List<int>> easyMaze = [
    [0, 0, 1, 0, 0],
    [1, 0, 1, 0, 1],
    [0, 0, 0, 0, 0],
    [0, 1, 1, 1, 0],
    [0, 0, 0, 1, 0],
  ];

  static const List<List<int>> mediumMaze = [
    [0, 1, 0, 0, 0, 0, 0],
    [0, 1, 0, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 1, 0],
    [1, 1, 1, 1, 0, 1, 0],
    [0, 0, 0, 1, 0, 0, 0],
    [0, 1, 0, 1, 1, 1, 1],
    [0, 1, 0, 0, 0, 0, 0],
  ];

  static const List<List<int>> hardMaze = [
    [0, 0, 0, 1, 0, 0, 0, 1, 0],
    [1, 1, 0, 1, 0, 1, 0, 1, 0],
    [0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 1, 1, 1, 1, 1, 1, 1, 0],
    [0, 0, 0, 0, 0, 0, 0, 1, 0],
    [1, 1, 1, 1, 1, 1, 0, 1, 0],
    [0, 0, 0, 0, 0, 1, 0, 1, 0],
    [0, 1, 1, 1, 0, 1, 0, 0, 0],
    [0, 0, 0, 1, 0, 0, 1, 1, 0],
  ];

  static bool canMove(List<List<int>> grid, int row, int col) {
    if (row < 0 || row >= grid.length || col < 0 || col >= grid[0].length) return false;
    return grid[row][col] != 1;
  }

  List<MazeStepModel> solveWithSteps(List<List<int>> initialMaze) {
    List<MazeStepModel> steps = [];
    int stepCounter = 0;
    List<List<int>> grid = initialMaze.map((row) => List<int>.from(row)).toList();
    int rows = grid.length;
    int cols = grid[0].length;

    void addStep(int r, int c, String action, String expl, bool valid) {
      steps.add(MazeStepModel(
        stepIndex: stepCounter++,
        row: r,
        col: c,
        action: action,
        explanation: expl,
        grid: grid.map((row) => List<int>.from(row)).toList(),
        isValid: valid,
      ));
    }

    bool solve(int r, int c) {
      if (r < 0 || r >= rows || c < 0 || c >= cols) return false;
      if (grid[r][c] == 1) {
        addStep(r, c, 'wall', 'Hit a wall at ($r, $c).', false);
        return false;
      }
      if (grid[r][c] == 2 || grid[r][c] == 3) {
        return false;
      }

      grid[r][c] = 2; // path taken

      if (r == rows - 1 && c == cols - 1) {
        addStep(r, c, 'solved', 'Reached the exit at ($r, $c)!', true);
        return true;
      } else {
        addStep(r, c, 'move', 'Moved to ($r, $c).', true);
      }

      if (solve(r, c + 1)) return true;
      if (solve(r + 1, c)) return true;
      if (solve(r, c - 1)) return true;
      if (solve(r - 1, c)) return true;

      grid[r][c] = 3; // backtracked
      addStep(r, c, 'backtrack', 'Dead end. Backtracking from ($r, $c).', false);

      return false;
    }

    solve(0, 0);
    return steps;
  }
}
