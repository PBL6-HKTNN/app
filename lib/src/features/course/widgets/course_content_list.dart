import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:codemy_app/src/features/course/providers/enrollment_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CourseContentList extends ConsumerWidget {
  final List<Module> modules;
  final String courseId;
  final String? enrollmentId;
  final String? currentLessonId;
  final Function(String moduleId, String lessonId)? onLessonSelect;
  final String? defaultExpandedModuleId;

  const CourseContentList({
    super.key,
    required this.modules,
    required this.courseId,
    this.enrollmentId,
    this.currentLessonId,
    this.onLessonSelect,
    this.defaultExpandedModuleId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final completedLessonsAsync = enrollmentId != null
        ? ref.watch(completedLessonsProvider(enrollmentId!))
        : const AsyncValue.data(<String>[]);
    final completedLessons = completedLessonsAsync.maybeWhen(
      data: (data) => data,
      orElse: () => <String>[],
    );

    if (modules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              BootstrapIcons.bookmarkX,
              size: 48,
              color: Theme.of(context).colorScheme.mutedForeground,
            ),
            const Gap(16),
            Text(
              'No modules available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
            const Gap(8),
            Text(
              'Course content will appear here once added.',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Sort modules by order
    final sortedModules = List<Module>.from(modules)
      ..sort((a, b) => a.order.compareTo(b.order));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Accordion(
        items: sortedModules
            .map(
              (module) => _buildModuleItem(
                module,
                completedLessons,
                enrollmentId,
                context,
              ),
            )
            .toList(),
      ),
    );
  }

  AccordionItem _buildModuleItem(
    Module module,
    List<String> completedLessons,
    String? enrollmentId,
    BuildContext context,
  ) {
    final lessons = module.lessons ?? <Lesson>[];
    // Sort lessons by their index in the list since order field may not exist
    final sortedLessons = List<Lesson>.from(lessons);

    final completedCount = sortedLessons
        .where((lesson) => completedLessons.contains(lesson.id))
        .length;

    final isCurrentModule =
        currentLessonId != null &&
        sortedLessons.any((lesson) => lesson.id == currentLessonId);

    final shouldExpand =
        defaultExpandedModuleId == module.id || isCurrentModule;

    return AccordionItem(
      expanded: shouldExpand,
      trigger: AccordionTrigger(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    module.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Gap(4),
                  Row(
                    children: [
                      Icon(
                        BootstrapIcons.playCircle,
                        size: 14,
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                      const Gap(6),
                      Text(
                        '${sortedLessons.length} lessons',
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                      if (enrollmentId != null) ...[
                        const Gap(16),
                        Icon(
                          BootstrapIcons.checkCircle,
                          size: 14,
                          color: completedCount == sortedLessons.length
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.muted,
                        ),
                        const Gap(6),
                        Text(
                          '$completedCount/${sortedLessons.length} completed',
                          style: TextStyle(
                            fontSize: 13,
                            color: completedCount == sortedLessons.length
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.mutedForeground,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      content: Padding(
        padding: const EdgeInsets.only(left: 0, right: 0, bottom: 8),
        child: Column(
          children: sortedLessons
              .map(
                (lesson) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildLessonItem(
                    lesson,
                    module.id,
                    completedLessons,
                    context,
                  ),
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildLessonItem(
    Lesson lesson,
    String moduleId,
    List<String> completedLessons,
    BuildContext context,
  ) {
    final isCompleted = completedLessons.contains(lesson.id);
    final isCurrent = lesson.id == currentLessonId;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Card(
        child: GestureDetector(
          onTap: () => onLessonSelect?.call(moduleId, lesson.id),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 10),
            child: Row(
              children: [
                // Lesson type icon
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: isCurrent
                        ? Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1)
                        : Theme.of(context).colorScheme.background,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Center(
                    child: Icon(
                      _getLessonIcon(lesson.lessonType),
                      size: 14,
                      color: isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).colorScheme.mutedForeground,
                    ),
                  ),
                ),
                const Gap(10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: isCurrent
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: isCurrent
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      const Gap(1),
                      Text(
                        _getLessonTypeText(lesson.lessonType),
                        style: TextStyle(
                          fontSize: 11,
                          color: Theme.of(context).colorScheme.mutedForeground,
                        ),
                      ),
                    ],
                  ),
                ),
                // Completion indicator
                Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.muted,
                    shape: BoxShape.circle,
                  ),
                  child: isCompleted
                      ? const Icon(
                          BootstrapIcons.check,
                          size: 10,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getLessonIcon(LessonType type) {
    switch (type) {
      case LessonType.markdown:
        return BootstrapIcons.fileText;
      case LessonType.video:
        return BootstrapIcons.playCircle;
      case LessonType.quiz:
        return BootstrapIcons.questionCircle;
    }
  }

  String _getLessonTypeText(LessonType type) {
    switch (type) {
      case LessonType.markdown:
        return 'Reading';
      case LessonType.video:
        return 'Video';
      case LessonType.quiz:
        return 'Quiz';
    }
  }
}
