import 'dart:async';
import 'package:flutter/material.dart';
import '../models/backtrack_step_model.dart';
import '../models/sudoku_puzzle_model.dart';
import '../services/sudoku_service.dart';

/// The most important provider in the app: manages the Sudoku visualizer state.
///
/// Responsibilities:
/// - Load puzzles and select one for visualization
/// - Run the backtracking solver to generate steps
/// - Play/pause step-by-step animation with configurable speed
/// - Track current step, highlighted cell, and grid state
///
/// Screens NEVER call SudokuService directly — they go through this provider.
class SudokuProvider extends ChangeNotifier {
  final SudokuService _sudokuService = SudokuService();

  // --- Puzzle data ---
  bool _isLoading = false;
  String? _errorMessage;
  List<SudokuPuzzleModel> _puzzles = [];
  SudokuPuzzleModel? _selectedPuzzle;

  // --- Visualization state ---
  List<List<int>> _currentGrid = [];
  List<List<int>> _initialGrid = [];
  List<BacktrackStepModel> _steps = [];
  int _currentStepIndex = -1; // -1 = before first step
  bool _isPlaying = false;
  bool _isSolved = false;
  double _speed = 1.0; // playback speed multiplier
  Timer? _playbackTimer;

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<SudokuPuzzleModel> get puzzles => _puzzles;
  SudokuPuzzleModel? get selectedPuzzle => _selectedPuzzle;

  List<List<int>> get currentGrid => _currentGrid;
  int get currentStepIndex => _currentStepIndex;
  int get totalSteps => _steps.length;
  bool get isPlaying => _isPlaying;
  bool get isSolved => _isSolved;
  double get speed => _speed;

  /// The current step being visualized (null if before first step).
  BacktrackStepModel? get currentStep =>
      _currentStepIndex >= 0 && _currentStepIndex < _steps.length
          ? _steps[_currentStepIndex]
          : null;

  /// Currently highlighted cell coordinates (null if no step active).
  int? get highlightRow => currentStep?.row;
  int? get highlightCol => currentStep?.col;

  /// Whether the current highlight should be green (valid) or red (invalid).
  bool? get highlightIsValid => currentStep?.isValid;

  /// Whether a cell is part of the initial puzzle (not solver-placed).
  bool isInitial(int row, int col) {
    if (_initialGrid.isEmpty) return false;
    return _initialGrid[row][col] != 0;
  }

  /// Loads all available puzzles from the service.
  Future<void> loadPuzzles() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _puzzles = await _sudokuService.getPuzzles();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load puzzles.';
    }
    notifyListeners();
  }

  /// Selects a puzzle and runs the backtracking solver to generate steps.
  Future<void> selectPuzzle(String puzzleId) async {
    _isLoading = true;
    _errorMessage = null;
    _isSolved = false;
    _currentStepIndex = -1;
    _isPlaying = false;
    _playbackTimer?.cancel();
    notifyListeners();

    try {
      _selectedPuzzle = await _sudokuService.getPuzzleById(puzzleId);

      // Deep copy the initial grid
      _initialGrid = _selectedPuzzle!.initialGrid
          .map((row) => List<int>.from(row))
          .toList();
      _currentGrid = _selectedPuzzle!.initialGrid
          .map((row) => List<int>.from(row))
          .toList();

      // Generate all backtracking steps
      _steps = _sudokuService.solveWithSteps(
        _selectedPuzzle!.initialGrid.map((row) => List<int>.from(row)).toList(),
      );

      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to solve puzzle.';
    }
    notifyListeners();
  }

  /// Starts automatic step-by-step playback.
  void play() {
    if (_steps.isEmpty || _isSolved) return;

    _isPlaying = true;
    notifyListeners();

    // Calculate delay based on speed: base 500ms, faster with higher speed
    final delay = Duration(milliseconds: (500 / _speed).round());

    _playbackTimer = Timer.periodic(delay, (_) {
      if (_currentStepIndex < _steps.length - 1) {
        _advanceOneStep();
      } else {
        // Reached the end
        pause();
        _isSolved = true;
        notifyListeners();
      }
    });
  }

  /// Pauses automatic playback.
  void pause() {
    _isPlaying = false;
    _playbackTimer?.cancel();
    _playbackTimer = null;
    notifyListeners();
  }

  /// Advances to the next step manually.
  void nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      _advanceOneStep();
    }
  }

  /// Goes back to the previous step manually.
  void previousStep() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      _rebuildGridToStep(_currentStepIndex);
      notifyListeners();
    } else if (_currentStepIndex == 0) {
      _currentStepIndex = -1;
      _currentGrid = _initialGrid.map((row) => List<int>.from(row)).toList();
      notifyListeners();
    }
  }

  /// Resets the visualization to the beginning.
  void reset() {
    pause();
    _currentStepIndex = -1;
    _isSolved = false;
    _currentGrid = _initialGrid.map((row) => List<int>.from(row)).toList();
    notifyListeners();
  }

  /// Changes playback speed.
  void setSpeed(double newSpeed) {
    _speed = newSpeed;

    // If currently playing, restart the timer with new speed
    if (_isPlaying) {
      pause();
      play();
    } else {
      notifyListeners();
    }
  }

  /// Applies one step forward and updates the grid.
  void _advanceOneStep() {
    _currentStepIndex++;
    final step = _steps[_currentStepIndex];

    // Update the grid based on the step action
    if (step.action == 'place' || step.action == 'valid') {
      _currentGrid[step.row][step.col] = step.value;
    } else if (step.action == 'backtrack' || step.action == 'invalid') {
      _currentGrid[step.row][step.col] = 0;
    }

    if (_currentStepIndex == _steps.length - 1) {
      _isSolved = true;
    }

    notifyListeners();
  }

  /// Rebuilds the grid state by replaying all steps up to [targetStep].
  void _rebuildGridToStep(int targetStep) {
    // Start from initial grid
    _currentGrid = _initialGrid.map((row) => List<int>.from(row)).toList();

    // Replay all steps up to targetStep
    for (int i = 0; i <= targetStep; i++) {
      final step = _steps[i];
      if (step.action == 'place' || step.action == 'valid') {
        _currentGrid[step.row][step.col] = step.value;
      } else if (step.action == 'backtrack' || step.action == 'invalid') {
        _currentGrid[step.row][step.col] = 0;
      }
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    super.dispose();
  }
}
