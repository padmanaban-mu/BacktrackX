import 'package:flutter/material.dart';
import 'dart:async';
import '../services/maze_service.dart';

class MazeProvider extends ChangeNotifier {
  final MazeService _service = MazeService();

  List<List<int>> _initialGrid = [];
  List<MazeStepModel> _steps = [];
  int _currentStepIndex = 0;
  bool _isPlaying = false;
  bool _isSolved = false;
  double _speed = 1.0;
  Timer? _timer;

  List<MazeStepModel> get steps => _steps;
  int get currentStepIndex => _currentStepIndex;
  bool get isPlaying => _isPlaying;
  bool get isSolved => _isSolved;
  double get speed => _speed;

  MazeStepModel? get currentStep => 
    _steps.isNotEmpty && _currentStepIndex < _steps.length ? _steps[_currentStepIndex] : null;

  List<List<int>> get currentGrid => currentStep?.grid ?? _initialGrid;

  void loadAndSolve(int mazeIndex) {
    if (mazeIndex == 0) {
      _initialGrid = MazeService.easyMaze;
    } else if (mazeIndex == 1) {
      _initialGrid = MazeService.mediumMaze;
    } else {
      _initialGrid = MazeService.hardMaze;
    }
    
    _steps = _service.solveWithSteps(_initialGrid);
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
    if (_currentStepIndex == _steps.length - 1 && _steps[_currentStepIndex].action == 'solved') {
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
