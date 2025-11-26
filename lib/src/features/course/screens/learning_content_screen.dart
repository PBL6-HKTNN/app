import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/models/dto/course_content.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:codemy_app/src/features/course/providers/course_content_provider.dart';
import 'package:codemy_app/src/features/course/providers/enrollment_provider.dart';
import 'package:codemy_app/src/features/course/widgets/course_progress_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class LearningContentScreen extends ConsumerWidget {
  final String courseId;
  final String? initialModuleId;
  final String? initialLessonId;

  const LearningContentScreen({
    super.key,
    required this.courseId,
    this.initialModuleId,
    this.initialLessonId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final courseContent = ref.watch(courseContentProvider(courseId));
    // Watch enrollment to get progress tracking capability
    final enrollmentAsync = ref.watch(courseEnrollmentProvider(courseId));

    return courseContent.when(
      data: (content) => enrollmentAsync.when(
        data: (enrollmentCheck) => _LearningContentView(
          courseId: courseId,
          content: content,
          initialModuleId: initialModuleId,
          initialLessonId: initialLessonId,
          enrollmentId:
              enrollmentCheck.success && enrollmentCheck.enrollment != null
              ? enrollmentCheck.enrollment!.id
              : null,
        ),
        loading: () =>
            const Scaffold(child: Center(child: CircularProgressIndicator())),
        error: (_, __) => _LearningContentView(
          courseId: courseId,
          content: content,
          initialModuleId: initialModuleId,
          initialLessonId: initialLessonId,
          enrollmentId: null,
        ),
      ),
      loading: () =>
          const Scaffold(child: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(RadixIcons.exclamationTriangle, size: 40),
              const Gap(12),
              Text(
                'Failed to load course content',
                style: Theme.of(
                  context,
                ).typography.small.copyWith(color: Colors.red),
              ),
              const Gap(8),
              Text(
                error.toString(),
                style: Theme.of(context).typography.xSmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LearningContentView extends StatefulWidget {
  final String courseId;
  final CourseContent content;
  final String? initialModuleId;
  final String? initialLessonId;
  final String? enrollmentId;

  const _LearningContentView({
    required this.courseId,
    required this.content,
    this.initialModuleId,
    this.initialLessonId,
    this.enrollmentId,
  });

  @override
  State<_LearningContentView> createState() => _LearningContentViewState();
}

class _LearningContentViewState extends State<_LearningContentView> {
  late List<TreeNode<dynamic>> _treeItems;

  @override
  void initState() {
    super.initState();
    _treeItems = _buildTreeNodes(
      widget.content.modules,
      selectedModuleId: widget.initialModuleId,
      selectedLessonId: widget.initialLessonId,
    );
  }

  @override
  void didUpdateWidget(covariant _LearningContentView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.content.modules != widget.content.modules ||
        oldWidget.initialModuleId != widget.initialModuleId ||
        oldWidget.initialLessonId != widget.initialLessonId) {
      _treeItems = _buildTreeNodes(
        widget.content.modules,
        selectedModuleId: widget.initialModuleId,
        selectedLessonId: widget.initialLessonId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      headers: [
        AppBar(
          title: Text('Course Content - ${widget.courseId}'),
          leading: [
            Button(
              style: ButtonStyle.ghost(),
              onPressed: () => context.pop(),
              child: const Icon(RadixIcons.arrowLeft),
            ),
          ],
        ),
        // Add course progress bar if enrolled
        if (widget.enrollmentId != null)
          Container(
            padding: const EdgeInsets.all(16),
            child: CourseProgressBar(
              enrollmentId: widget.enrollmentId!,
              totalLessons: _getTotalLessonsCount(),
            ),
          ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TreeView<dynamic>(
          shrinkWrap: true,
          recursiveSelection: false,
          nodes: _treeItems,
          branchLine: BranchLine.path,
          onSelectionChanged: TreeView.defaultSelectionHandler(_treeItems, (
            value,
          ) {
            setState(() {
              _treeItems = value;
            });
          }),
          builder: (context, node) {
            final data = node.data;
            if (data is Module) {
              return TreeItemView(
                onPressed: () {},
                leading: Icon(
                  node.expanded
                      ? BootstrapIcons.folder2Open
                      : BootstrapIcons.folder2,
                ),
                onExpand: TreeView.defaultItemExpandHandler(_treeItems, node, (
                  value,
                ) {
                  setState(() {
                    _treeItems = value;
                  });
                }),
                child: Text(data.title),
              );
            }

            if (data is Lesson) {
              return TreeItemView(
                onPressed: () => _navigateToLesson(context, data),
                leading: _getLessonIcon(data.lessonType),
                trailing: widget.enrollmentId != null
                    ? LessonProgressIndicator(
                        enrollmentId: widget.enrollmentId!,
                        lessonId: data.id,
                        isCurrentLesson: data.id == widget.initialLessonId,
                      )
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title),
                    Text(
                      '${_getLessonTypeText(data.lessonType)} • ${data.duration}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            }

            return TreeItemView(child: Text('${node.data}'));
          },
        ),
      ),
    );
  }

  List<TreeNode<dynamic>> _buildTreeNodes(
    List<Module> modules, {
    String? selectedModuleId,
    String? selectedLessonId,
  }) {
    return modules.map((module) {
      final lessons = module.lessons ?? <Lesson>[];
      final isModuleSelected = module.id == selectedModuleId;
      return TreeItem<dynamic>(
        data: module,
        expanded: true,
        selected: isModuleSelected,
        children: lessons
            .map(
              (lesson) => TreeItem<dynamic>(
                data: lesson,
                children: const [],
                selected: lesson.id == selectedLessonId,
              ),
            )
            .toList(),
      );
    }).toList();
  }

  Widget _getLessonIcon(LessonType type) {
    switch (type) {
      case LessonType.markdown:
        return const Icon(BootstrapIcons.fileText);
      case LessonType.video:
        return const Icon(BootstrapIcons.playCircle);
      case LessonType.quiz:
        return const Icon(BootstrapIcons.questionCircle);
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

  int _getTotalLessonsCount() {
    return widget.content.modules.fold(
      0,
      (total, module) => total + (module.lessons?.length ?? 0),
    );
  }

  void _navigateToLesson(BuildContext context, Lesson lesson) {
    final moduleId = lesson.moduleId;
    context.go('/learn/${widget.courseId}/$moduleId/${lesson.id}');
  }
}
