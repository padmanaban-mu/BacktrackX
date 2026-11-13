import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../routes/app_routes.dart';
import '../../widgets/common/loading_indicator.dart';
import '../../widgets/common/error_view.dart';
import '../../providers/learning_provider.dart';

class LessonListScreen extends StatefulWidget {
  const LessonListScreen({super.key});

  @override
  State<LessonListScreen> createState() => _LessonListScreenState();
}

class _LessonListScreenState extends State<LessonListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().loadLessons();
    });
  }

  @override
  Widget build(BuildContext context) {
    final learningProvider = context.watch<LearningProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Modules'),
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
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _buildBody(learningProvider),
    );
  }

  Widget _buildBody(LearningProvider provider) {
    if (provider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (provider.errorMessage != null) {
      return ErrorView(
        message: provider.errorMessage!,
        onRetry: () => provider.loadLessons(),
      );
    }

    final lessons = provider.lessons;
    if (lessons.isEmpty) {
      return const Center(child: Text('No lessons available.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: lessons.length,
      itemBuilder: (context, index) {
        final lesson = lessons[index];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.only(bottom: 12.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16.0),
            title: Text(
              lesson.title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                lesson.description,
                style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
            ),
            trailing: lesson.isCompleted
                ? Icon(Icons.check_circle, color: Theme.of(context).colorScheme.tertiary, size: 32)
                : Icon(Icons.chevron_right, color: Theme.of(context).colorScheme.primary),
            onTap: () {
              Navigator.pushNamed(
                context,
                AppRoutes.lessonDetail,
                arguments: lesson.id,
              );
            },
          ),
        );
      },
    );
  }
}
