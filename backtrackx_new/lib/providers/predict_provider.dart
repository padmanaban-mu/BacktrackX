import 'dart:math';
import 'package:flutter/material.dart';
import '../services/nqueens_service.dart';
import '../services/sudoku_service.dart';
import '../services/maze_service.dart';
import '../models/backtrack_step_model.dart';

enum PredictAlgorithm { nqueens, sudoku, maze }

enum QuestionType {
  nextStep,        // What will the algorithm do next?
  whyBacktrack,    // Why did the algorithm backtrack?
  isSafePlacement, // Can a queen be placed at row R, col C?
  countValidCols,  // How many safe columns remain in row X?
  identifyConflict // Which placement caused the conflict?
}

class PredictOption {
  final String label;
  final bool isCorrect;
  final String? explanation; // shown after answering
  const PredictOption({required this.label, required this.isCorrect, this.explanation});
}

class PredictQuestion {
  final QuestionType type;
  final String prompt; // the question text shown to user
  final String hint;   // e.g. '💡 Backtracking happens when no column is safe'
  const PredictQuestion({required this.type, required this.prompt, required this.hint});
}

class PredictProvider extends ChangeNotifier {
  PredictAlgorithm _algorithm = PredictAlgorithm.nqueens;
  List<NQueensStepModel> _nqSteps = [];
  List<BacktrackStepModel> _sudokuSteps = [];
  List<MazeStepModel> _mazeSteps = [];
  int _currentStepIndex = 0;
  int _score = 0;
  int _combo = 0;
  double _multiplier = 1.0;
  int _totalXP = 0;
  bool _answered = false;
  int? _selectedOption;
  List<PredictOption> _options = [];
  PredictQuestion? _currentQuestion;
  bool _isComplete = false;
  final int _totalSteps = 10;
  String _answerExplanation = '';
  final Random _rng = Random();

  // Getters
  PredictAlgorithm get algorithm => _algorithm;
  int get currentStepIndex => _currentStepIndex;
  int get score => _score;
  int get combo => _combo;
  double get multiplier => _multiplier;
  int get totalXP => _totalXP;
  bool get answered => _answered;
  int? get selectedOption => _selectedOption;
  List<PredictOption> get options => _options;
  PredictQuestion? get currentQuestion => _currentQuestion;
  bool get isComplete => _isComplete;
  int get totalSteps => _totalSteps;
  String get answerExplanation => _answerExplanation;
  
  bool xpAwarded = false; // Flag to prevent duplicate backend calls

  NQueensStepModel? get currentNQStep => _nqSteps.isNotEmpty && _currentStepIndex < _nqSteps.length ? _nqSteps[_currentStepIndex] : null;
  MazeStepModel? get currentMazeStep => _mazeSteps.isNotEmpty && _currentStepIndex < _mazeSteps.length ? _mazeSteps[_currentStepIndex] : null;

  void initNQueens(int boardSize) {
    _algorithm = PredictAlgorithm.nqueens;
    _nqSteps = NQueensService().solveWithSteps(boardSize);
    _reset();
  }

  void initSudoku(List<List<int>> grid) {
    _algorithm = PredictAlgorithm.sudoku;
    _sudokuSteps = SudokuService().solveWithSteps(grid);
    _reset();
  }

  void initMaze(int mazeIndex) {
    _algorithm = PredictAlgorithm.maze;
    List<List<int>> initialGrid;
    if (mazeIndex == 0) {
      initialGrid = MazeService.easyMaze;
    } else if (mazeIndex == 1) {
      initialGrid = MazeService.mediumMaze;
    } else {
      initialGrid = MazeService.hardMaze;
    }
    _mazeSteps = MazeService().solveWithSteps(initialGrid);
    _reset();
  }

  void _reset() {
    _currentStepIndex = 0;
    _score = 0;
    _combo = 0;
    _multiplier = 1.0;
    _totalXP = 0;
    _isComplete = false;
    xpAwarded = false;
    _answered = false;
    _selectedOption = null;
    _answerExplanation = '';
    _generateQuestion();
    notifyListeners();
  }

  void _generateQuestion() {
    if (_algorithm == PredictAlgorithm.nqueens) {
      _generateNQQuestion();
    } else if (_algorithm == PredictAlgorithm.sudoku) {
      _generateSudokuQuestion();
    } else {
      _generateMazeQuestion();
    }
  }

  // ─── N-Queens Questions ─────────────────────────────────────────────────────

  void _generateNQQuestion() {
    if (_currentStepIndex >= _nqSteps.length - 1) {
      _isComplete = true;
      notifyListeners();
      return;
    }

    final currentStep = _nqSteps[_currentStepIndex];
    final nextStep = _nqSteps[_currentStepIndex + 1];
    final queensPerRow = List<int>.from(currentStep.queensPerRow);
    
    // Pick question type based on step content and some randomness
    QuestionType qType = QuestionType.nextStep; // default
    
    // Vary question type — pick smartly based on context
    final rand = _rng.nextInt(5);
    if (rand == 0 && nextStep.action == 'remove') {
      qType = QuestionType.whyBacktrack;
    } else if (rand == 1 && currentStep.queensPerRow.length > 1) {
      qType = QuestionType.isSafePlacement;
    } else if (rand == 2 && currentStep.queensPerRow.length >= 2) {
      qType = QuestionType.countValidCols;
    } else if (rand == 3 && nextStep.action == 'conflict') {
      qType = QuestionType.identifyConflict;
    }
    
    switch (qType) {
      case QuestionType.nextStep:
        _buildNQNextStep(nextStep);
      case QuestionType.whyBacktrack:
        _buildNQWhyBacktrack(currentStep, nextStep, queensPerRow);
      case QuestionType.isSafePlacement:
        _buildNQIsSafe(currentStep, queensPerRow);
      case QuestionType.countValidCols:
        _buildNQCountValid(currentStep, queensPerRow);
      case QuestionType.identifyConflict:
        _buildNQIdentifyConflict(currentStep, nextStep);
    }
    _answered = false;
    _selectedOption = null;
    notifyListeners();
  }

  void _buildNQNextStep(NQueensStepModel nextStep) {
    _currentQuestion = const PredictQuestion(
      type: QuestionType.nextStep,
      prompt: '🤔 What will the algorithm do NEXT?',
      hint: '💡 The algorithm places, removes, or detects conflicts row by row.',
    );
    final correct = PredictOption(
      label: _nqStepLabel(nextStep),
      isCorrect: true,
      explanation: 'Correct! ${nextStep.explanation}',
    );
    final wrongs = _generateWrongNQOptions(nextStep);
    _options = [...wrongs, correct]..shuffle(_rng);
  }

  void _buildNQWhyBacktrack(NQueensStepModel current, NQueensStepModel next, List<int> queens) {
    _currentQuestion = PredictQuestion(
      type: QuestionType.whyBacktrack,
      prompt: '↩️ The algorithm just backtracked from row ${current.row}. WHY?',
      hint: '💡 Backtracking happens when NO safe column exists in the current row.',
    );
    final correctLabel = 'No valid column exists in row ${current.row} — all are under attack';
    final options = [
      PredictOption(label: correctLabel, isCorrect: true, explanation: 'Correct! When every column in a row is attacked by existing queens, backtracking is the only option.'),
      const PredictOption(label: 'A queen was placed in the wrong row', isCorrect: false, explanation: 'No — the algorithm always fills rows top to bottom.'),
      const PredictOption(label: 'The puzzle has no solution', isCorrect: false, explanation: 'No — local backtracking does not mean the whole puzzle is unsolvable.'),
      const PredictOption(label: 'The algorithm found the solution', isCorrect: false, explanation: 'No — backtracking means the algorithm is retreating, not succeeding.'),
    ]..shuffle(_rng);
    _options = options;
  }

  void _buildNQIsSafe(NQueensStepModel current, List<int> queens) {
    final int row = current.row;
    // Pick a random col to test
    final int testCol = _rng.nextInt(queens.length);
    final bool safe = NQueensService.isSafe(queens, row, testCol);
    _currentQuestion = PredictQuestion(
      type: QuestionType.isSafePlacement,
      prompt: '🔍 Can a queen be safely placed at row $row, col $testCol?',
      hint: '💡 A cell is safe if no other queen shares its row, column, or diagonal.',
    );
    final correctLabel = safe ? 'Yes — no queen attacks this cell' : 'No — this cell is under attack';
    final wrongLabel = safe ? 'No — this cell is under attack' : 'Yes — no queen attacks this cell';
    final explanation = safe
        ? 'Correct! Cell ($row, $testCol) is not on the same column or diagonal as any placed queen.'
        : 'Correct! Cell ($row, $testCol) is attacked by a queen in the same column or diagonal.';
    _options = [
      PredictOption(label: correctLabel, isCorrect: true, explanation: explanation),
      PredictOption(label: wrongLabel, isCorrect: false, explanation: ''),
      const PredictOption(label: 'The row is not yet available', isCorrect: false, explanation: ''),
      const PredictOption(label: 'Cannot determine without seeing the full board', isCorrect: false, explanation: ''),
    ]..shuffle(_rng);
  }

  void _buildNQCountValid(NQueensStepModel current, List<int> queens) {
    final int row = current.row;
    final int n = queens.length;
    int validCount = 0;
    for (int c = 0; c < n; c++) {
      if (NQueensService.isSafe(queens, row, c)) validCount++;
    }
    _currentQuestion = PredictQuestion(
      type: QuestionType.countValidCols,
      prompt: '📊 How many safe columns remain available in row $row?',
      hint: '💡 Count columns not attacked by any queen already on the board.',
    );
    final wrongs = <int>{};
    while (wrongs.length < 3) {
      final w = _rng.nextInt(n + 1);
      if (w != validCount) wrongs.add(w);
    }
    _options = [
      PredictOption(label: '$validCount column${validCount != 1 ? "s" : ""} safe', isCorrect: true, explanation: 'Correct! $validCount column(s) in row $row are not under attack.'),
      ...wrongs.map((w) => PredictOption(label: '$w column${w != 1 ? "s" : ""} safe', isCorrect: false, explanation: '')),
    ]..shuffle(_rng);
  }

  void _buildNQIdentifyConflict(NQueensStepModel current, NQueensStepModel next) {
    _currentQuestion = PredictQuestion(
      type: QuestionType.identifyConflict,
      prompt: '⚡ A conflict was detected at row ${next.row}, col ${next.col}. Which rule is violated?',
      hint: '💡 Three rules: same column, same row, or same diagonal.',
    );
    _options = [
      const PredictOption(label: 'Same column or diagonal as another queen', isCorrect: true, explanation: 'Correct! N-Queens forbids queens sharing a column, row, or either diagonal.'),
      const PredictOption(label: 'The cell is outside the board', isCorrect: false, explanation: ''),
      const PredictOption(label: 'Too many queens on this side', isCorrect: false, explanation: ''),
      const PredictOption(label: 'The row is already full', isCorrect: false, explanation: ''),
    ]..shuffle(_rng);
  }

  // ─── Sudoku Questions ─────────────────────────────────────────────────────

  void _generateSudokuQuestion() {
    if (_currentStepIndex >= _sudokuSteps.length - 1) {
      _isComplete = true;
      notifyListeners();
      return;
    }
    final nextStep = _sudokuSteps[_currentStepIndex + 1];
    final rand = _rng.nextInt(3);
    
    if (rand == 0 && nextStep.action == 'backtrack') {
      // Why backtrack?
      _currentQuestion = PredictQuestion(
        type: QuestionType.whyBacktrack,
        prompt: '↩️ The algorithm backtracked from (${nextStep.row}, ${nextStep.col}). Why?',
        hint: '💡 Sudoku backtracks when no digit 1-9 satisfies row, column, and 3×3 box rules simultaneously.',
      );
      _options = [
        const PredictOption(label: 'No valid digit 1-9 fits this cell without conflict', isCorrect: true, explanation: 'Correct! When all 9 digits violate at least one constraint, the algorithm must backtrack.'),
        const PredictOption(label: 'The algorithm chose the wrong row', isCorrect: false, explanation: ''),
        const PredictOption(label: 'The cell was already filled', isCorrect: false, explanation: ''),
        const PredictOption(label: 'The puzzle is unsolvable', isCorrect: false, explanation: ''),
      ]..shuffle(_rng);
    } else if (rand == 1) {
      // Is this digit valid?
      final testDigit = (nextStep.value % 9) + 1;
      final isValid = nextStep.action == 'valid';
      _currentQuestion = PredictQuestion(
        type: QuestionType.isSafePlacement,
        prompt: '🔍 Can digit ${nextStep.value} be placed at (${nextStep.row}, ${nextStep.col})?',
        hint: '💡 Check the same row, same column, and same 3×3 box.',
      );
      _options = [
        PredictOption(label: isValid ? 'Yes — no conflict in row, col, or box' : 'No — conflicts with row, col, or box constraint', isCorrect: true, explanation: 'Correct! ${nextStep.explanation}'),
        PredictOption(label: isValid ? 'No — conflicts with row, col, or box constraint' : 'Yes — no conflict in row, col, or box', isCorrect: false, explanation: ''),
        PredictOption(label: 'Digit $testDigit would work instead', isCorrect: false, explanation: ''),
        const PredictOption(label: 'Cannot place any digit here', isCorrect: false, explanation: ''),
      ]..shuffle(_rng);
    } else {
      // Next step
      _currentQuestion = const PredictQuestion(
        type: QuestionType.nextStep,
        prompt: '🤔 What will the algorithm do NEXT in the Sudoku?',
        hint: '💡 The solver tries digits 1-9 and backtracks when stuck.',
      );
      final correct = PredictOption(label: _sudokuStepLabel(nextStep), isCorrect: true, explanation: 'Correct! ${nextStep.explanation}');
      final wrongs = _generateWrongSudokuOptions(nextStep);
      _options = [...wrongs, correct]..shuffle(_rng);
    }
    _answered = false;
    _selectedOption = null;
    notifyListeners();
  }

  // ─── Maze Questions ────────────────────────────────────────────────────────

  void _generateMazeQuestion() {
    if (_currentStepIndex >= _mazeSteps.length - 1) {
      _isComplete = true;
      notifyListeners();
      return;
    }
    final nextStep = _mazeSteps[_currentStepIndex + 1];
    final rand = _rng.nextInt(3);

    if (rand == 0 && nextStep.action == 'backtrack') {
      _currentQuestion = PredictQuestion(
        type: QuestionType.whyBacktrack,
        prompt: '↩️ The path explorer backtracked from (${nextStep.row}, ${nextStep.col}). Why?',
        hint: '💡 Backtracking in maze means the current path is a dead end — all neighbors are walls or visited.',
      );
      _options = [
        const PredictOption(label: 'Dead end — all adjacent cells are walls or already visited', isCorrect: true, explanation: 'Correct! In DFS maze solving, backtracking means no unvisited neighbors exist from the current cell.'),
        const PredictOption(label: 'The exit was found in a different direction', isCorrect: false, explanation: ''),
        const PredictOption(label: 'The algorithm reset to start', isCorrect: false, explanation: ''),
        const PredictOption(label: 'A loop was detected', isCorrect: false, explanation: ''),
      ]..shuffle(_rng);
    } else if (rand == 1) {
      _currentQuestion = PredictQuestion(
        type: QuestionType.isSafePlacement,
        prompt: '🚪 Can the algorithm move to (${nextStep.row}, ${nextStep.col})?',
        hint: '💡 A move is valid if the cell is within bounds, not a wall (1), and not already visited.',
      );
      final canMove = nextStep.action == 'move' || nextStep.action == 'solved';
      _options = [
        PredictOption(label: canMove ? 'Yes — open cell, not yet visited' : 'No — wall or already visited', isCorrect: true, explanation: 'Correct! ${nextStep.explanation}'),
        PredictOption(label: canMove ? 'No — wall or already visited' : 'Yes — open cell, not yet visited', isCorrect: false, explanation: ''),
        const PredictOption(label: 'Move is valid but leads to a dead end', isCorrect: false, explanation: ''),
        const PredictOption(label: 'Only diagonal moves are allowed', isCorrect: false, explanation: ''),
      ]..shuffle(_rng);
    } else {
      _currentQuestion = const PredictQuestion(
        type: QuestionType.nextStep,
        prompt: '🤔 What will the maze explorer do NEXT?',
        hint: '💡 The DFS explorer moves, hits walls, or backtracks when stuck.',
      );
      final correct = PredictOption(label: _mazeStepLabel(nextStep), isCorrect: true, explanation: 'Correct! ${nextStep.explanation}');
      final wrongs = _generateWrongMazeOptions(nextStep);
      _options = [...wrongs, correct]..shuffle(_rng);
    }
    _answered = false;
    _selectedOption = null;
    notifyListeners();
  }

  // ─── Label helpers ─────────────────────────────────────────────────────────

  String _nqStepLabel(NQueensStepModel step) {
    if (step.action == 'place') return 'Place queen at row ${step.row}, col ${step.col}';
    if (step.action == 'remove') return 'Backtrack — remove queen from row ${step.row}';
    return 'Conflict at row ${step.row}, col ${step.col} — skip';
  }

  String _sudokuStepLabel(BacktrackStepModel step) {
    if (step.action == 'valid') return 'Place ${step.value} at (${step.row}, ${step.col})';
    if (step.action == 'backtrack') return 'Backtrack from (${step.row}, ${step.col})';
    if (step.action == 'invalid') return 'Skip ${step.value} at (${step.row}, ${step.col}) — conflict';
    return 'Try ${step.value} at (${step.row}, ${step.col})';
  }

  String _mazeStepLabel(MazeStepModel step) {
    if (step.action == 'move') return 'Move to (${step.row}, ${step.col})';
    if (step.action == 'backtrack') return 'Backtrack from (${step.row}, ${step.col})';
    if (step.action == 'wall') return 'Hit wall at (${step.row}, ${step.col})';
    if (step.action == 'solved') return 'Reach exit at (${step.row}, ${step.col})';
    return 'Action at (${step.row}, ${step.col})';
  }

  // ─── Wrong option generators ───────────────────────────────────────────────

  List<PredictOption> _generateWrongNQOptions(NQueensStepModel correctStep) {
    final wrongs = <PredictOption>[];
    final actions = ['place', 'remove', 'conflict'];
    for (int i = 0; i < 3; i++) {
      final wrongAction = actions[(actions.indexOf(correctStep.action) + i + 1) % 3];
      final wrongCol = (correctStep.col + i + 1) % 8;
      String label;
      if (wrongAction == 'place') {
        label = 'Place queen at row ${correctStep.row}, col $wrongCol';
      } else if (wrongAction == 'remove') {
        label = 'Backtrack — remove queen from row ${(correctStep.row + 1) % 8}';
      } else {
        label = 'Conflict at row ${correctStep.row}, col $wrongCol — skip';
      }
      wrongs.add(PredictOption(label: label, isCorrect: false, explanation: ''));
    }
    return wrongs;
  }

  List<PredictOption> _generateWrongSudokuOptions(BacktrackStepModel correctStep) {
    final wrongs = <PredictOption>[];
    final wrongVal1 = (correctStep.value % 9) + 1;
    final wrongVal2 = ((correctStep.value + 1) % 9) + 1;
    wrongs.add(PredictOption(label: 'Place $wrongVal1 at (${correctStep.row}, ${correctStep.col})', isCorrect: false, explanation: ''));
    wrongs.add(PredictOption(label: 'Backtrack from (${(correctStep.row + 1) % 9}, ${correctStep.col})', isCorrect: false, explanation: ''));
    wrongs.add(PredictOption(label: 'Skip $wrongVal2 at (${correctStep.row}, ${correctStep.col}) — conflict', isCorrect: false, explanation: ''));
    return wrongs;
  }

  List<PredictOption> _generateWrongMazeOptions(MazeStepModel correctStep) {
    final wrongs = <PredictOption>[];
    final actions = ['move', 'backtrack', 'wall'];
    for (int i = 0; i < 3; i++) {
      final wrongAction = actions[(actions.indexOf(correctStep.action) + i + 1) % 3];
      final wrongR = correctStep.row + (i % 2 == 0 ? 1 : 0);
      final wrongC = correctStep.col + (i % 2 == 1 ? 1 : 0);
      String label;
      if (wrongAction == 'move') {
        label = 'Move to ($wrongR, $wrongC)';
      } else if (wrongAction == 'backtrack') {
        label = 'Backtrack from ($wrongR, $wrongC)';
      } else {
        label = 'Hit wall at ($wrongR, $wrongC)';
      }
      wrongs.add(PredictOption(label: label, isCorrect: false, explanation: ''));
    }
    return wrongs;
  }

  // ─── Answer selection & progression ───────────────────────────────────────

  void selectAnswer(int index) {
    if (_answered) return;
    _selectedOption = index;
    _answered = true;
    final selected = _options[index];
    if (selected.isCorrect) {
      _score++;
      _combo++;
      if (_combo >= 3) {
        _multiplier = 2.0;
      } else if (_combo >= 2) {
        _multiplier = 1.5;
      }
      final xpEarned = (5 * _multiplier).round();
      _totalXP += xpEarned;
      _answerExplanation = selected.explanation ?? 'Correct!';
    } else {
      _combo = 0;
      _multiplier = 1.0;
      // Find the correct option's explanation
      final correctOpt = _options.firstWhere((o) => o.isCorrect, orElse: () => const PredictOption(label: '', isCorrect: true));
      _answerExplanation = correctOpt.explanation ?? 'The correct answer was: ${correctOpt.label}';
    }
    notifyListeners();
  }

  void nextQuestion() {
    _currentStepIndex++;
    int len = 0;
    if (_algorithm == PredictAlgorithm.nqueens) {
      len = _nqSteps.length;
    } else if (_algorithm == PredictAlgorithm.sudoku) {
      len = _sudokuSteps.length;
    } else {
      len = _mazeSteps.length;
    }
    if (_score >= _totalSteps || _currentStepIndex >= len - 1) {
      _isComplete = true;
      notifyListeners();
      return;
    }
    _generateQuestion();
    notifyListeners();
  }
}
