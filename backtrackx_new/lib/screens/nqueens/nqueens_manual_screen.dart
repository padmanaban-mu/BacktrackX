import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/nqueens_service.dart';
import '../../services/progress_service.dart';
import '../../providers/auth_provider.dart';
import '../../routes/app_routes.dart';

class NQueensManualScreen extends StatefulWidget {
  const NQueensManualScreen({super.key});

  @override
  State<NQueensManualScreen> createState() => _NQueensManualScreenState();
}

class _NQueensManualScreenState extends State<NQueensManualScreen> {
  int _n = 8;
  late List<int> _queens;
  List<int> _undoStack = [];
  String? _conflictMessage;
  int? _conflictRow;
  int? _conflictCol;
  int _moves = 0;
  late Stopwatch _stopwatch;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();
    _initBoard();
  }

  void _initBoard() {
    _queens = List.filled(_n, -1);
    _undoStack = [];
    _conflictMessage = null;
    _conflictRow = null;
    _conflictCol = null;
    _moves = 0;
    _stopwatch.reset();
    _timer?.cancel();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onCellTapped(int row, int col) {
    if (_queens[row] != -1) return; // Row already has a queen
    
    // Only allow placing queen on the next available row like the algorithm
    int nextRow = 0;
    while (nextRow < _n && _queens[nextRow] != -1) {
      nextRow++;
    }
    if (row != nextRow) {
      setState(() {
        _conflictMessage = 'Must place queen on row $nextRow first!';
        _conflictRow = row;
        _conflictCol = col;
      });
      return;
    }

    if (!_stopwatch.isRunning) {
      _stopwatch.start();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {});
      });
    }

    String? reason = NQueensService.conflictReason(_queens, row, col);
    setState(() {
      _moves++;
      if (reason == null) {
        // Safe placement
        _queens[row] = col;
        _undoStack.add(row);
        _conflictMessage = null;
        _conflictRow = null;
        _conflictCol = null;

        if (_undoStack.length == _n) {
          _onSuccess();
        }
      } else {
        // Conflict
        _conflictMessage = reason;
        _conflictRow = row;
        _conflictCol = col;
      }
    });
  }

  void _undo() {
    if (_undoStack.isEmpty) return;
    setState(() {
      int lastRow = _undoStack.removeLast();
      _queens[lastRow] = -1;
      _conflictMessage = null;
      _conflictRow = null;
      _conflictCol = null;
      _moves++;
    });
  }

  Future<void> _onSuccess() async {
    _stopwatch.stop();
    _timer?.cancel();
    
    try {
      final token = context.read<AuthProvider>().token ?? '';
      await ProgressService().incrementNQueensSolved(token: token);
    } catch (e) {
      debugPrint('Failed to award XP: $e');
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Success! 🎉'),
        content: Text('You placed all $_n queens safely.\n\nMoves: $_moves\nTime: ${_formattedTime()}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _initBoard();
              });
            },
            child: const Text('Play Again'),
          ),
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

  String _formattedTime() {
    final s = _stopwatch.elapsed.inSeconds;
    final min = (s / 60).floor().toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      appBar: AppBar(
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
        title: const Text('Manual Play: N-Queens'),
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
                AppRoutes.dashboard, (route) => false),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _initBoard()),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Board Size: '),
                ...[4, 6, 8].map((size) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: ChoiceChip(
                    label: Text('$size'),
                    selected: _n == size,
                    onSelected: (selected) {
                      if (selected) {
                        setState(() {
                          _n = size;
                          _initBoard();
                        });
                      }
                    },
                  ),
                )),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Moves: $_moves', style: const TextStyle(fontSize: 16)),
                Text('Time: ${_formattedTime()}', style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_conflictMessage != null)
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.symmetric(horizontal: 16),
              color: colorScheme.error.withValues(alpha: 0.1),
              child: Text(
                _conflictMessage!,
                style: TextStyle(color: colorScheme.error, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _n,
                    ),
                    itemCount: _n * _n,
                    itemBuilder: (context, index) {
                      int row = index ~/ _n;
                      int col = index % _n;
                      bool isLight = (row + col) % 2 == 0;
                      bool hasQueen = _queens[row] == col;
                      bool isConflictCell = _conflictRow == row && _conflictCol == col;
                      
                      return GestureDetector(
                        onTap: () => _onCellTapped(row, col),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isConflictCell 
                                ? colorScheme.error.withValues(alpha: 0.5) 
                                : isLight ? Colors.white : Colors.grey[400],
                            border: Border.all(
                              color: isConflictCell ? colorScheme.error : Colors.black12,
                              width: isConflictCell ? 2 : 1,
                            ),
                          ),
                          child: Center(
                            child: hasQueen
                                ? Text(
                                    '♛',
                                    style: TextStyle(
                                      fontSize: MediaQuery.of(context).size.width / _n * 0.5,
                                      color: colorScheme.primary,
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
            child: ElevatedButton.icon(
              icon: const Icon(Icons.undo),
              label: const Text('Undo Last Queen'),
              onPressed: _undoStack.isEmpty ? null : _undo,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ),
          if (_undoStack.isNotEmpty)
            const Padding(
              padding: EdgeInsets.only(bottom: 16.0),
              child: Text('This is exactly what the algorithm does when backtracking!', style: TextStyle(fontStyle: FontStyle.italic)),
            ),
        ],
      ),
    );
  }
}
