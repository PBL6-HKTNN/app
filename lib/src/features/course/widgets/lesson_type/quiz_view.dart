import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/models/entities/quiz/index.dart';
import 'package:codemy_app/src/features/course/providers/quiz_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class QuizView extends ConsumerWidget {
  final Lesson lesson;
  final String courseId;
  final String moduleId;

  const QuizView({
    super.key,
    required this.lesson,
    required this.courseId,
    required this.moduleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final quizAsync = ref.watch(quizByLessonProvider(lesson.id));

    return quizAsync.when(
      data: (quiz) => _buildQuizContent(context, quiz),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(RadixIcons.exclamationTriangle, size: 48),
              const Gap(12),
              Text(
                'Failed to load quiz: $error',
                style: Theme.of(
                  context,
                ).typography.small.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuizContent(BuildContext context, Quiz quiz) {
    final questionsCount = quiz.questions.length;
    final quizUri = Uri(
      path: '/learn/$courseId/$moduleId/${lesson.id}/quiz',
      queryParameters: {'quizId': quiz.id},
    );

    return Card(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(quiz.title, style: Theme.of(context).typography.h4),
                    const Gap(8),
                    if ((quiz.description ?? '').isNotEmpty)
                      Text(
                        quiz.description!,
                        style: Theme.of(context).typography.small.copyWith(
                          color: Theme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                  ],
                ),
              ),
              PrimaryBadge(child: Text('$questionsCount questions')),
            ],
          ),
          const Gap(16),
          Wrap(
            spacing: 16,
            runSpacing: 12,
            children: [
              Chip(
                leading: Icon(RadixIcons.target),
                child: Text('Passing: ${quiz.passingMarks}'),
              ),
              Chip(
                leading: Icon(LucideIcons.trophy),
                child: Text('Total Marks: ${quiz.totalMarks}'),
              ),
              Chip(
                leading: Icon(RadixIcons.clock),
                child: Text('Duration: ${_formatDuration(lesson.duration)}'),
              ),
              Chip(
                leading: Icon(RadixIcons.star),
                child: Text(
                  lesson.isPreview ? 'Preview available' : 'Enrolled only',
                ),
              ),
            ],
          ),
          const Gap(24),
          Text(
            'Ready to attempt this quiz? We will track your answers and score once you begin.',
            style: Theme.of(context).typography.small.copyWith(
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
          ),
          const Gap(16),
          Button(
            style: ButtonStyle.primary(size: ButtonSize.normal),
            onPressed: () => context.push(quizUri.toString()),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(RadixIcons.play),
                Gap(8),
                Text('Start Quiz Attempt'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(String raw) {
    final parts = raw.split(':');
    if (parts.length == 3) {
      final hours = int.tryParse(parts[0]) ?? 0;
      final minutes = int.tryParse(parts[1]) ?? 0;
      if (hours > 0) {
        return '${hours}h ${minutes}m';
      }
      return '${minutes}m';
    }
    return raw;
  }
}
