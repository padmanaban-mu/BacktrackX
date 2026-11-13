import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:convert';
import '../../routes/app_routes.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_view.dart';
import '../../widgets/common/primary_button.dart';
import '../../widgets/learning/diagram_widget.dart';
import '../../providers/learning_provider.dart';

class LessonDetailScreen extends StatefulWidget {
  const LessonDetailScreen({super.key});

  @override
  State<LessonDetailScreen> createState() => _LessonDetailScreenState();
}

class _LessonDetailScreenState extends State<LessonDetailScreen> {
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
          context.read<LearningProvider>().loadLesson(lessonId);
        });
      }
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<LearningProvider>();
    final lesson = provider.currentLesson;

    return Scaffold(
      appBar: AppBar(
        title: Text(lesson?.title ?? 'Lesson Detail'),
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
        ],
      ),
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
        onRetry: () => provider.loadLesson(lessonId),
      );
    }

    final lesson = provider.currentLesson;
    if (lesson == null) {
      return const Center(child: Text('Lesson not found.'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                lesson.title,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ).animate().fadeIn(duration: 400.ms).slideX(),
              const SizedBox(height: 12),
              Text(
                lesson.description,
                style: TextStyle(
                  fontSize: 18,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ).animate().fadeIn(delay: 200.ms).slideX(),
              ..._buildDynamicContent(lesson.content),
              
              const SizedBox(height: 40),
              PrimaryButton(
                label: 'Take Quiz',
                onPressed: () {
                  // Track in background without blocking UI
                  context.read<LearningProvider>().markLessonCompleteOnBackend();
                  context.read<LearningProvider>().markLessonCompleted(lesson.id);
                  
                  // Navigate instantly
                  Navigator.pushNamed(context, AppRoutes.quiz, arguments: lesson.id);
                },
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDynamicContent(String content) {
    List<Widget> widgets = [];
    final lines = content.split('\n');
    int delay = 400;

    for (String line in lines) {
      if (line.trim().isEmpty) continue;
      
      try {
        final Map<String, dynamic> data = jsonDecode(line);
        if (data['type'] == 'text') {
          widgets.add(
            Container(
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                boxShadow: [
                  BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05), blurRadius: 10)
                ]
              ),
              padding: const EdgeInsets.all(24.0),
              child: Text(
                data['body'] ?? '',
                style: TextStyle(
                  fontSize: 16,
                  height: 1.8,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.2),
          );
        } else if (data['type'] == 'diagram') {
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: Column(
                children: [
                  DiagramWidget(diagramType: data['diagramType'] ?? 'tree')
                      .animate().fadeIn(delay: delay.ms).scale(),
                  if (data['caption'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        data['caption'],
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ).animate().fadeIn(delay: (delay + 100).ms),
                    ),
                ],
              ),
            )
          );
        }
      } catch (e) {
        // Fallback if not JSON
        widgets.add(
           Padding(
             padding: const EdgeInsets.only(bottom: 24.0),
             child: Text(
               line,
               style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
             ),
           )
        );
      }
      delay += 200;
    }
    
    return widgets;
  }
}
