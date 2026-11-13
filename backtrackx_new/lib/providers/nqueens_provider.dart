import 'package:flutter/material.dart';
import 'dart:async';
import '../services/nqueens_service.dart';

class NQueensProvider extends ChangeNotifier {
  final NQueensService _service = NQueensService();

  int _boardSize = 8;
  List<NQueensStepModel> _steps = [];
  int _currentStepIndex = 0;
  bool _isPlaying = false;
  bool _isSolved = false;
  double _speed = 1.0;
  Timer? _timer;

  int get boardSize => _boardSize;
  List<NQueensStepModel> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  bool get isPlaying => _isPlaying;
  bool get isSolved => _isSolved;
  double get speed => _speed;

  NQueensStepModel? get currentStep => 
    _steps.isNotEmpty && _currentStepIndex < _steps.length ? _steps[_currentStepIndex] : null;
    
  List<int> get queensPerRow => currentStep?.queensPerRow ?? List.filled(_boardSize, -1);
  List<List<int>> get attackedCells => currentStep?.attackedCells ?? [];

  void loadAndSolve(int n) {
    _boardSize = n;
    _steps = _service.solveWithSteps(n);
    _currentStepIndex = 0;
    _isPlaying = false;
    _isSolved = false;
    _timer?.cancel();
    notifyListeners();
  }

  void play() {
    if (_steps.isEmpty || _currentStepIndex >= _steps.length - 1) return;
    _isPlaying = true;
    notifyListeners();
    _startTimer();
  }

  void pause() {
    _isPlaying = false;
    _timer?.cancel();
    notifyListeners();
  }

  void nextStep() {
    if (_currentStepIndex < _steps.length - 1) {
      _currentStepIndex++;
      _checkSolved();
      notifyListeners();
    } else {
      pause();
    }
  }

  void previousStep() {
    if (_currentStepIndex > 0) {
      _currentStepIndex--;
      _isSolved = false;
      notifyListeners();
    }
  }
  
  void _checkSolved() {
    if (_currentStepIndex == _steps.length - 1 && _steps[_currentStepIndex].isValid && _steps[_currentStepIndex].row == _boardSize - 1 && _steps[_currentStepIndex].action == 'place') {
      _isSolved = true;
    }
  }

  void reset() {
    _currentStepIndex = 0;
    _isPlaying = false;
    _isSolved = false;
    _timer?.cancel();
    notifyListeners();
  }

  void setSpeed(double newSpeed) {
    _speed = newSpeed;
    if (_isPlaying) {
      _timer?.cancel();
      _startTimer();
    }
    notifyListeners();
  }

  void _startTimer() {
    int duration = (1000 / _speed).round();
    _timer = Timer.periodic(Duration(milliseconds: duration), (timer) {
      if (_currentStepIndex < _steps.length - 1) {
        nextStep();
      } else {
        pause();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
