import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/maze_service.dart';
import '../../services/progress_service.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class MazeManualScreen extends StatefulWidget {
  const MazeManualScreen({super.key});

  @override
  State<MazeManualScreen> createState() => _MazeManualScreenState();
}

class _MazeManualScreenState extends State<MazeManualScreen> {
  int _selectedMaze = 0;
  List<List<int>> _grid = [];
  int _rows = 0;
  int _cols = 0;
  
  int _playerR = 0;
  int _playerC = 0;
  
  List<List<int>> _pathHistory = [];
  int _moveCount = 0;
  bool _isSolved = false;

  @override
  void initState() {
    super.initState();
    _loadMaze(0);
  }

  void _loadMaze(int index) {
    setState(() {
      _selectedMaze = index;
      if (index == 0) {
        _grid = MazeService.easyMaze.map((row) => List<int>.from(row)).toList();
      } else if (index == 1) _grid = MazeService.mediumMaze.map((row) => List<int>.from(row)).toList();
      else _grid = MazeService.hardMaze.map((row) => List<int>.from(row)).toList();
      
      _rows = _grid.length;
      _cols = _grid[0].length;
      
      _playerR = 0;
      _playerC = 0;
      _pathHistory = [[0, 0]];
      _grid[0][0] = 2; // path taken
      _moveCount = 0;
      _isSolved = false;
    });
  }

  void _move(int dr, int dc) {
    if (_isSolved) return;
    
    int nr = _playerR + dr;
    int nc = _playerC + dc;
    
    if (MazeService.canMove(_grid, nr, nc)) {
      setState(() {
        _playerR = nr;
        _playerC = nc;
        _moveCount++;
        _pathHistory.add([nr, nc]);
        _grid[nr][nc] = 2; // mark path
        
        if (nr == _rows - 1 && nc == _cols - 1) {
          _isSolved = true;
          _showSuccessDialog();
        }
      });
    }
  }

  void _undo() {
    if (_pathHistory.length > 1 && !_isSolved) {
      setState(() {
        final last = _pathHistory.removeLast();
        _grid[last[0]][last[1]] = 0; // unmark path
        final current = _pathHistory.last;
        _playerR = current[0];
        _playerC = current[1];
        _moveCount++;
      });
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('This is backtracking! You went back a step.'), duration: Duration(milliseconds: 1000)),
      );
    }
  }

  void _showSuccessDialog() {
    final token = context.read<AuthProvider>().token ?? '';
    ProgressService().incrementMazeSolved(token: token);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Maze Solved!'),
        content: Text('You found the path in $_moveCount moves!\n\n+50 XP'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Finish'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _loadMaze(_selectedMaze);
            },
            child: const Text('Play Again'),
          )
        ],
      ),
    );
  }

  Widget _buildCell(int val, int r, int c) {
    Color color;
    Widget? icon;
    
    if (r == _playerR && c == _playerC) {
      color = Theme.of(context).colorScheme.primary;
      icon = const Icon(Icons.person, color: Colors.white);
    } else if (r == _rows - 1 && c == _cols - 1) {
      color = Colors.amber.withValues(alpha: 0.3);
      icon = const Icon(Icons.star, color: Colors.amber);
    } else {
      switch (val) {
        case 1: color = Theme.of(context).colorScheme.onSurface; break;
        case 2: color = Theme.of(context).colorScheme.primary.withValues(alpha: 0.3); break;
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
        title: const Text('Manual Play'),
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
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.refresh), onPressed: () => _loadMaze(_selectedMaze)),
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
                  ChoiceChip(label: const Text('Easy'), selected: _selectedMaze == 0, onSelected: (_) => _loadMaze(0)),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('Medium'), selected: _selectedMaze == 1, onSelected: (_) => _loadMaze(1)),
                  const SizedBox(width: 8),
                  ChoiceChip(label: const Text('Hard'), selected: _selectedMaze == 2, onSelected: (_) => _loadMaze(2)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text('Moves: $_moveCount', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: _cols > 0 ? _cols / _rows : 1,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: _cols > 0 ? _cols : 1,
                        crossAxisSpacing: 4,
                        mainAxisSpacing: 4,
                      ),
                      itemCount: _rows * _cols,
                      itemBuilder: (context, index) {
                        return _buildCell(_grid[index ~/ _cols][index % _cols], index ~/ _cols, index % _cols);
                      },
                    ),
                  ),
                ),
              ),
            ),
            // D-Pad
            Container(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    iconSize: 48,
                    onPressed: () => _move(-1, 0),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        iconSize: 48,
                        onPressed: () => _move(0, -1),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: _undo,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        child: const Text('UNDO'),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward),
                        iconSize: 48,
                        onPressed: () => _move(0, 1),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    iconSize: 48,
                    onPressed: () => _move(1, 0),
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
