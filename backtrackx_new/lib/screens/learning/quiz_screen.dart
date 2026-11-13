import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/primary_button.dart';
import '../../providers/learning_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late String lessonId;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is String) {
        lessonId = args;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.read<LearningProvider>().loadQuiz(lessonId);
        });
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningProvider>();
    final currentQuestion = provider.currentQuestion;
    
    String appBarTitle = 'Quiz';
    if (currentQuestion != null && !provider.quizCompleted) {
      final currentQuestionNum = provider.currentQuizIndex + 1;
      final totalQuestions = provider.quizQuestions.length;
      appBarTitle = 'Quiz - Question $currentQuestionNum/$totalQuestions';
    } else if (provider.quizCompleted) {
      appBarTitle = 'Quiz Completed';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
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
                AppRoutes.dashboard, (route) => false),
          ),
          const SizedBox(width: 8),
        ],
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(provider),
    );
  }

  Widget _buildBody(LearningProvider provider) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (provider.errorMessage != null) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.loadQuiz(lessonId),
      );
    }

    if (provider.quizCompleted) {
      return _buildScoreCard(provider);
    }

    final question = provider.currentQuestion;
    if (question == null) {
      return const Center(child: Text('No questions available.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            question.question,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 24),
          ...List.generate(question.options.length, (index) {
            final option = question.options[index];
            final isSelected = provider.selectedOptionIndex == index;
            final hasAnswered = provider.hasAnswered;
            final isCorrectOption = index == question.correctIndex;

            Color backgroundColor = Theme.of(context).scaffoldBackgroundColor;
            Color borderColor = Colors.grey.shade300;

            if (hasAnswered) {
              if (isCorrectOption) {
                backgroundColor = Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1);
                borderColor = Theme.of(context).colorScheme.tertiary;
              } else if (isSelected) {
                backgroundColor = Theme.of(context).colorScheme.error.withValues(alpha: 0.1);
                borderColor = Theme.of(context).colorScheme.error;
              }
            } else if (isSelected) {
              backgroundColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.1);
              borderColor = Theme.of(context).colorScheme.primary;
            }

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: hasAnswered
                    ? null
                    : () => context.read<LearningProvider>().selectOption(index),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: backgroundColor,
                    border: Border.all(color: borderColor, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: hasAnswered
                            ? (isCorrectOption ? Theme.of(context).colorScheme.tertiary : (isSelected ? Theme.of(context).colorScheme.error : Colors.grey))
                            : (isSelected ? Theme.of(context).colorScheme.primary : Colors.grey),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onSurface,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (provider.hasAnswered && question.explanation.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5)),
              ),
              child: Text(
                question.explanation,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurface),
              ),
            ),
          ],
          const SizedBox(height: 32),
          if (!provider.hasAnswered)
            PrimaryButton(
              label: 'Submit',
              onPressed: provider.selectedOptionIndex == null
                  ? null
                  : () => context.read<LearningProvider>().submitAnswer(),
            )
          else
            PrimaryButton(
              label: 'Next Question',
              onPressed: () => context.read<LearningProvider>().nextQuestion(),
            ),
        ],
      ),
    );
  }

  Widget _buildScoreCard(LearningProvider provider) {
    final total = provider.quizQuestions.length;
    final score = provider.correctAnswers;
    final double percentage = total > 0 ? (score / total) : 0;
    
    Color resultColor = percentage >= 0.7 ? Theme.of(context).colorScheme.tertiary : Theme.of(context).colorScheme.error;
    IconData resultIcon = percentage >= 0.7 ? Icons.emoji_events : Icons.refresh;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(resultIcon, size: 80, color: resultColor),
                const SizedBox(height: 24),
                const Text(
                  'Quiz Complete!',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  'You scored $score/$total',
                  style: TextStyle(
                    fontSize: 24,
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 32),
                PrimaryButton(
                  label: 'Back to Lessons',
                  onPressed: () {
                    Navigator.popUntil(context, ModalRoute.withName(AppRoutes.learning));
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
