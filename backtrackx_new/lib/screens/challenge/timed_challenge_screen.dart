import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/nqueens_service.dart';
import '../../services/progress_service.dart';
import '../../providers/auth_provider.dart';
import '../../providers/progress_provider.dart';
import '../../routes/app_routes.dart';

class TimedChallengeScreen extends StatefulWidget {
  const TimedChallengeScreen({super.key});

  @override
  State<TimedChallengeScreen> createState() => _TimedChallengeScreenState();
}

class _TimedChallengeScreenState extends State<TimedChallengeScreen> {
  int _n = 8; // Default Hard
  late List<int> _queens;
  List<int> _undoStack = [];
  String? _conflictMessage;
  int? _conflictRow;
  int? _conflictCol;
  
  late int _remainingSeconds;
  Timer? _timer;
  bool _isPlaying = false;
  bool _isGameOver = false;

  final Map<int, int> _difficultyTimes = {
    4: 5 * 60, // Easy: 5 min
    6: 3 * 60, // Medium: 3 min
    8: 2 * 60, // Hard: 2 min
  };

  @override
  void initState() {
    super.initState();
    _remainingSeconds = _difficultyTimes[_n]!;
    _initBoard();
  }

  void _initBoard() {
    _queens = List.filled(_n, -1);
    _undoStack = [];
    _conflictMessage = null;
    _conflictRow = null;
    _conflictCol = null;
  }

  void _startGame() {
    setState(() {
      _isPlaying = true;
      _isGameOver = false;
      _remainingSeconds = _difficultyTimes[_n]!;
      _initBoard();
    });
    
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _endGame(false);
      }
    });
  }

  void _endGame(bool success) async {
    _timer?.cancel();
    setState(() {
      _isPlaying = false;
      _isGameOver = true;
    });

    if (success) {
      double multiplier = 1.0;
      if (_remainingSeconds > _difficultyTimes[_n]! * 0.5) {
        multiplier = 2.0;
      } else if (_remainingSeconds > _difficultyTimes[_n]! * 0.25) {
        multiplier = 1.5;
      }

      try {
        final token = context.read<AuthProvider>().token ?? '';
        await context.read<ProgressProvider>().awardGameXP(
          token: token,
          action: 'timedChallengeSolved',
          multiplier: multiplier,
        );
      } catch (e) {
        debugPrint('Failed to award XP: $e');
      }
    }

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(success ? 'Challenge Completed! 🎉' : 'Time Up! ⏰'),
        content: Text(success 
            ? 'You placed all $_n queens safely.\nTime remaining: ${_formattedTime()}'
            : 'You ran out of time! Try a lower difficulty or practice in manual mode.'),
        actions: [
          if (!success)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _startGame();
              },
              child: const Text('Try Again'),
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

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onCellTapped(int row, int col) {
    if (!_isPlaying || _isGameOver) return;
    if (_queens[row] != -1) return; 
    
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

    String? reason = NQueensService.conflictReason(_queens, row, col);
    setState(() {
      if (reason == null) {
        _queens[row] = col;
        _undoStack.add(row);
        _conflictMessage = null;
        _conflictRow = null;
        _conflictCol = null;

        if (_undoStack.length == _n) {
          _endGame(true);
        }
      } else {
        _conflictMessage = reason;
        _conflictRow = row;
        _conflictCol = col;
      }
    });
  }

  void _undo() {
    if (!_isPlaying || _isGameOver || _undoStack.isEmpty) return;
    setState(() {
      int lastRow = _undoStack.removeLast();
      _queens[lastRow] = -1;
      _conflictMessage = null;
      _conflictRow = null;
      _conflictCol = null;
    });
  }

  String _formattedTime() {
    final min = (_remainingSeconds / 60).floor().toString().padLeft(2, '0');
    final sec = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$min:$sec';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final colorScheme = Theme.of(context).colorScheme;
    final isWarning = _remainingSeconds <= 30;

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
        title: const Text('Timed Challenge'),
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
        ],
      ),
      body: Column(
        children: [
          if (!_isPlaying && !_isGameOver)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text('Select Difficulty:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _DifficultyButton(label: 'Easy (4x4)', n: 4, currentN: _n, onSelect: (val) => setState(() => _n = val)),
                      _DifficultyButton(label: 'Medium (6x6)', n: 6, currentN: _n, onSelect: (val) => setState(() => _n = val)),
                      _DifficultyButton(label: 'Hard (8x8)', n: 8, currentN: _n, onSelect: (val) => setState(() => _n = val)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _startGame,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    ),
                    child: const Text('START CHALLENGE', style: TextStyle(fontSize: 18)),
                  )
                ],
              ),
            ),
          
          if (_isPlaying || _isGameOver) ...[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              color: isWarning ? colorScheme.error.withValues(alpha: 0.2) : null,
              child: Center(
                child: Text(
                  _formattedTime(),
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: isWarning ? colorScheme.error : colorScheme.onSurface,
                  ),
                ),
              ),
            ),
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
                label: const Text('Undo'),
                onPressed: _undoStack.isEmpty || !_isPlaying ? null : _undo,
              ),
            ),
          ]
        ],
      ),
    );
  }
}

class _DifficultyButton extends StatelessWidget {
  final String label;
  final int n;
  final int currentN;
  final Function(int) onSelect;

  const _DifficultyButton({required this.label, required this.n, required this.currentN, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final isSelected = n == currentN;
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: () => onSelect(n),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary : Colors.transparent,
          border: Border.all(color: colorScheme.primary),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
