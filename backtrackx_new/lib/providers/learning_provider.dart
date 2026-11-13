import 'package:flutter/material.dart';
import '../models/lesson_model.dart';
import '../models/quiz_model.dart';
import '../services/learning_service.dart';
import '../services/progress_service.dart';

/// Manages state for the Learning module: lesson list, lesson detail, and quizzes.
/// Screens listen via Consumer/context.watch; they never call LearningService directly.
class LearningProvider extends ChangeNotifier {
  final LearningService _learningService = LearningService();
  final ProgressService _progressService = ProgressService();

  String? _token;
  String? _lessonId;

  void setToken(String? token) {
    _token = token;
  }

  // --- Lesson list state ---
  bool _isLoading = false;
  String? _errorMessage;
  List<LessonModel> _lessons = [];
  final Set<String> _completedLessonIds = {}; // Persist locally during session

  // --- Current lesson detail ---
  LessonModel? _currentLesson;

  // --- Quiz state ---
  List<QuizModel> _quizQuestions = [];
  int _currentQuizIndex = 0;
  int? _selectedOptionIndex;
  bool _hasAnswered = false;
  int _correctAnswers = 0;
  bool _quizCompleted = false;

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<LessonModel> get lessons => _lessons;
  LessonModel? get currentLesson => _currentLesson;
  List<QuizModel> get quizQuestions => _quizQuestions;
  int get currentQuizIndex => _currentQuizIndex;
  int? get selectedOptionIndex => _selectedOptionIndex;
  bool get hasAnswered => _hasAnswered;
  int get correctAnswers => _correctAnswers;
  bool get quizCompleted => _quizCompleted;

  QuizModel? get currentQuestion =>
      _quizQuestions.isNotEmpty && _currentQuizIndex < _quizQuestions.length
          ? _quizQuestions[_currentQuizIndex]
          : null;

  /// Loads all lessons from the service.
  Future<void> loadLessons() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final freshLessons = await _learningService.getLessons(token: _token);
      // Restore completion status from our session cache
      _lessons = freshLessons.map((l) {
        if (_completedLessonIds.contains(l.id)) {
          return LessonModel(
            id: l.id,
            title: l.title,
            description: l.description,
            content: l.content,
            order: l.order,
            isCompleted: true,
          );
        }
        return l;
      }).toList();
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load lessons. Please try again.';
    }
    notifyListeners();
  }

  /// Loads a single lesson by ID for the detail screen.
  Future<void> loadLesson(String lessonId) async {
    _lessonId = lessonId;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final fetched = await _learningService.getLessonById(lessonId, token: _token);
      _currentLesson = _completedLessonIds.contains(fetched.id)
          ? LessonModel(
              id: fetched.id,
              title: fetched.title,
              description: fetched.description,
              content: fetched.content,
              order: fetched.order,
              isCompleted: true,
            )
          : fetched;
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load lesson.';
    }
    notifyListeners();
  }

  /// Loads quiz questions for a specific lesson and resets quiz state.
  Future<void> loadQuiz(String lessonId) async {
    _lessonId = lessonId;
    _isLoading = true;
    _errorMessage = null;
    _currentQuizIndex = 0;
    _selectedOptionIndex = null;
    _hasAnswered = false;
    _correctAnswers = 0;
    _quizCompleted = false;
    notifyListeners();

    try {
      _quizQuestions = await _learningService.getQuizForLesson(lessonId, token: _token);
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load quiz.';
    }
    notifyListeners();
  }

  /// Called when the user selects an answer option.
  void selectOption(int index) {
    if (_hasAnswered) return; // Can't change answer after submitting
    _selectedOptionIndex = index;
    notifyListeners();
  }

  /// Submits the selected answer and checks if it's correct.
  void submitAnswer() {
    if (_selectedOptionIndex == null || _hasAnswered) return;

    _hasAnswered = true;
    if (_selectedOptionIndex == currentQuestion?.correctIndex) {
      _correctAnswers++;
    }
    notifyListeners();
  }

  /// Moves to the next question, or marks quiz as completed.
  void nextQuestion() {
    if (_currentQuizIndex < _quizQuestions.length - 1) {
      _currentQuizIndex++;
      _selectedOptionIndex = null;
      _hasAnswered = false;
    } else {
      _quizCompleted = true;
      _progressService.saveQuizScore(
        token: _token ?? '',
        quizId: 'quiz_$_lessonId',
        score: _correctAnswers,
        totalQuestions: _quizQuestions.length,
      );
    }
    notifyListeners();
  }

  /// Resets the quiz to start over.
  void resetQuiz() {
    _currentQuizIndex = 0;
    _selectedOptionIndex = null;
    _hasAnswered = false;
    _correctAnswers = 0;
    _quizCompleted = false;
    notifyListeners();
  }

  /// Marks a lesson as completed locally.
  void markLessonCompleted(String lessonId) {
    _completedLessonIds.add(lessonId); // Remember for this session
    
    final index = _lessons.indexWhere((l) => l.id == lessonId);
    if (index != -1) {
      // Create a mutable copy of the list before modifying it
      // This prevents 'Cannot modify an unmodifiable list' errors from const mock data
      final newLessons = List<LessonModel>.from(_lessons);
      newLessons[index] = LessonModel(
        id: newLessons[index].id,
        title: newLessons[index].title,
        description: newLessons[index].description,
        content: newLessons[index].content,
        order: newLessons[index].order,
        isCompleted: true,
      );
      _lessons = newLessons;
    }
    notifyListeners();
  }

  Future<void> markLessonCompleteOnBackend() async {
    if (_currentLesson != null) {
      await _progressService.markLessonComplete(
        token: _token ?? '',
        lessonId: _currentLesson!.id,
      );
    }
  }
}
