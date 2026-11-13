import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/sudoku_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';

class SudokuManualScreen extends StatefulWidget {
  const SudokuManualScreen({super.key});

  @override
  State<SudokuManualScreen> createState() => _SudokuManualScreenState();
}

class _SudokuManualScreenState extends State<SudokuManualScreen> {
  late List<List<int>> _grid;
  late List<List<int>> _initialGrid;
  late List<List<int>> _solution;
  int? _selectedRow;
  int? _selectedCol;
  List<List<bool>> _isConflict = List.generate(9, (_) => List.filled(9, false));
  int _hintsUsed = 0;
  int _moves = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPuzzle();
  }

  Future<void> _loadPuzzle() async {
    final puzzle = await SudokuService().getPuzzleById('1');
    setState(() {
      _initialGrid = List.generate(9, (i) => List.from(puzzle.initialGrid[i]));
      _grid = List.generate(9, (i) => List.from(puzzle.initialGrid[i]));
      _solution = SudokuService().solve(_initialGrid);
      _isLoading = false;
    });
  }

  bool _isValidPlacement(List<List<int>> grid, int row, int col, int num) {
    for (int i = 0; i < 9; i++) {
      if (i != col && grid[row][i] == num) return false;
      if (i != row && grid[i][col] == num) return false;
    }
    int startRow = row - (row % 3);
    int startCol = col - (col % 3);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if ((startRow + i != row || startCol + j != col) && grid[startRow + i][startCol + j] == num) {
          return false;
        }
      }
    }
    return true;
  }

  void _onCellTapped(int row, int col) {
    if (_initialGrid[row][col] != 0) return;
    setState(() {
      _selectedRow = row;
      _selectedCol = col;
      // Clear previous conflicts when selecting a new cell
      _isConflict = List.generate(9, (_) => List.filled(9, false));
    });
  }

  void _onNumberPressed(int num) {
    if (_selectedRow == null || _selectedCol == null) return;
    int r = _selectedRow!;
    int c = _selectedCol!;
    
    setState(() {
      _moves++;
      _grid[r][c] = num;
      if (num != 0 && !_isValidPlacement(_grid, r, c, num)) {
        _isConflict[r][c] = true;
        _showConflict(r, c, num);
      } else {
        _isConflict[r][c] = false;
        _checkCompletion();
      }
    });
  }

  void _showConflict(int row, int col, int num) {
    // Highlight conflicts
    for (int i = 0; i < 9; i++) {
      if (i != col && _grid[row][i] == num) _isConflict[row][i] = true;
      if (i != row && _grid[i][col] == num) _isConflict[i][col] = true;
    }
    int startRow = row - (row % 3);
    int startCol = col - (col % 3);
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        if ((startRow + i != row || startCol + j != col) && _grid[startRow + i][startCol + j] == num) {
          _isConflict[startRow + i][startCol + j] = true;
        }
      }
    }
  }

  void _useHint() {
    if (_selectedRow == null || _selectedCol == null) return;
    int r = _selectedRow!;
    int c = _selectedCol!;
    
    setState(() {
      _grid[r][c] = _solution[r][c];
      _isConflict[r][c] = false;
      _hintsUsed++;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('-5 XP (Hint used)')),
    );
    
    _checkCompletion();
  }

  void _checkCompletion() {
    for (int i = 0; i < 9; i++) {
      for (int j = 0; j < 9; j++) {
        if (_grid[i][j] == 0 || !_isValidPlacement(_grid, i, j, _grid[i][j])) return;
      }
    }
    
    _onSuccess();
  }

  Future<void> _onSuccess() async {
    try {
      final token = context.read<AuthProvider>().token ?? '';
      await context.read<ProgressProvider>().awardGameXP(
        token: token,
        action: 'sudokuSolved',
      );
    } catch (e) {
      debugPrint('Error awarding XP: $e');
    }
    
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Puzzle Solved! 🎉'),
        content: Text('Moves: $_moves\nHints used: $_hintsUsed'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Back to Menu'),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Play: Sudoku'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
          ),
          tooltip: 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.home_rounded, color: Colors.white, size: 22),
            ),
            tooltip: 'Go to Home',
            onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil(
                '/dashboard', (route) => false),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moves: $_moves'),
                ElevatedButton.icon(
                  onPressed: _selectedRow != null && _selectedCol != null ? _useHint : null,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Hint'),
                )
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Container(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 9,
                    ),
                    itemCount: 81,
                    itemBuilder: (context, index) {
                      int row = index ~/ 9;
                      int col = index % 9;
                      bool isInitial = _initialGrid[row][col] != 0;
                      bool isSelected = _selectedRow == row && _selectedCol == col;
                      bool hasConflict = _isConflict[row][col];
                      
                      // Box borders
                      BorderSide thick = const BorderSide(color: Colors.black, width: 2);
                      BorderSide thin = BorderSide(color: Colors.grey.shade400, width: 1);
                      
                      return GestureDetector(
                        onTap: () => _onCellTapped(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? colorScheme.primary.withValues(alpha: 0.2) :
                                   hasConflict ? colorScheme.error.withValues(alpha: 0.3) :
                                   Colors.white,
                            border: Border(
                              top: row % 3 == 0 ? thick : thin,
                              left: col % 3 == 0 ? thick : thin,
                              right: col == 8 ? thick : BorderSide.none,
                              bottom: row == 8 ? thick : BorderSide.none,
                            ),
                          ),
                          child: Center(
                            child: _grid[row][col] != 0
                                ? Text(
                                    '${_grid[row][col]}',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: isInitial ? FontWeight.bold : FontWeight.normal,
                                      color: isInitial ? Colors.black : colorScheme.primary,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                ...List.generate(9, (index) {
                  int num = index + 1;
                  return FloatingActionButton(
                    heroTag: 'btn_$num',
                    onPressed: () => _onNumberPressed(num),
                    child: Text('$num'),
                  );
                }),
                FloatingActionButton(
                  heroTag: 'btn_erase',
                  onPressed: () => _onNumberPressed(0),
                  backgroundColor: colorScheme.error,
                  child: const Icon(Icons.close),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
