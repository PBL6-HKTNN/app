import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../course/enums/lesson_type.dart';
import '../../course/models/entities/lesson.dart';
import '../../course/models/entities/module.dart';
import '../../course/providers/course_content_provider.dart';

class CourseContentView extends ConsumerStatefulWidget {
  const CourseContentView({
    super.key,
    required this.courseId,
    this.onLessonTap,
    this.showHeader = true,
  });

  final String courseId;
  final void Function(Lesson lesson)? onLessonTap;
  final bool showHeader;

  static void show(
    BuildContext context, {
    required String courseId,
    void Function(Lesson lesson)? onLessonTap,
  }) {
    openSheet(
      context: context,
      position: OverlayPosition.left,
      builder: (sheetContext) {
        final size = MediaQuery.of(sheetContext).size;
        return SizedBox(
          width: size.width * 0.45,
          height: size.height * 0.85,
          child: CourseContentView(
            courseId: courseId,
            onLessonTap: onLessonTap,
          ),
        );
      },
    );
  }

  @override
  ConsumerState<CourseContentView> createState() => _CourseContentViewState();
}

class _CourseContentViewState extends ConsumerState<CourseContentView> {
  List<TreeNode<dynamic>> _treeItems = const [];
  String _treeVersion = '';

  @override
  Widget build(BuildContext context) {
    final contentAsync = ref.watch(courseContentProvider(widget.courseId));

    return contentAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => _CourseContentError(message: error.toString()),
      data: (content) {
        final modules = content.modules;
        if (modules.isEmpty) {
          return const Center(child: Text('No lessons available yet'));
        }

        final version = modules
            .map((module) => '${module.id}-${module.numberOfLessons ?? 0}')
            .join('|');

        if (_treeItems.isEmpty || _treeVersion != version) {
          _treeItems = _buildTreeNodes(modules);
          _treeVersion = version;
        }

        final nodes = _treeItems;

        Widget tree = TreeView<dynamic>(
          shrinkWrap:
              !widget.showHeader, // Shrink for inline usage, expand for panel
          recursiveSelection: false,
          nodes: nodes,
          branchLine: BranchLine.path,
          onSelectionChanged: TreeView.defaultSelectionHandler(nodes, (value) {
            setState(() {
              _treeItems = value;
            });
          }),
          builder: (context, TreeItem<dynamic> node) {
            final data = node.data;
            if (data is Module) {
              final subtitle =
                  '${data.numberOfLessons} lessons'
                  '${data.durationMinutes}';
              return TreeItemView(
                leading: Icon(
                  node.expanded
                      ? BootstrapIcons.folder2Open
                      : BootstrapIcons.folder2,
                ),
                onExpand: TreeView.defaultItemExpandHandler(nodes, node, (
                  value,
                ) {
                  setState(() {
                    _treeItems = value;
                  });
                }),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(data.title, style: Theme.of(context).typography.small),
                    Text(
                      subtitle,
                      style: Theme.of(context).typography.xSmall.copyWith(
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            }

            if (data is Lesson) {
              return TreeItemView(
                onPressed: () => widget.onLessonTap?.call(data),
                leading: _lessonIcon(data.lessonType),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(data.title)),
                        if (data.isPreview)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: PrimaryBadge(
                              child: Text(
                                'Preview',
                                style: Theme.of(context).typography.xSmall,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      '${_lessonTypeLabel(data.lessonType)} • ${data.duration}',
                      style: Theme.of(context).typography.xSmall.copyWith(
                        color: Theme.of(context).colorScheme.mutedForeground,
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        );

        if (widget.showHeader) {
          tree = Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Course Content',
                      style: Theme.of(context).typography.h4,
                    ),
                    const Spacer(),
                    Button(
                      style: ButtonStyle.ghost(),
                      onPressed: () => context.pop(),
                      child: const Icon(RadixIcons.cross1),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(child: tree),
            ],
          );
        } else {
          // When used inline (like in course detail), wrap in SingleChildScrollView
          tree = SingleChildScrollView(child: tree);
        }

        return tree;
      },
    );
  }

  List<TreeNode<dynamic>> _buildTreeNodes(List<Module> modules) {
    return modules.map((module) {
      final lessons = module.lessons ?? [];
      return TreeItem<dynamic>(
        data: module,
        expanded: true,
        children: lessons
            .map(
              (lesson) => TreeItem<dynamic>(data: lesson, children: const []),
            )
            .toList(),
      );
    }).toList();
  }

  Widget _lessonIcon(LessonType type) {
    switch (type) {
      case LessonType.markdown:
        return const Icon(BootstrapIcons.fileText);
      case LessonType.video:
        return const Icon(BootstrapIcons.playCircle);
      case LessonType.quiz:
        return const Icon(BootstrapIcons.questionCircle);
    }
  }

  String _lessonTypeLabel(LessonType type) {
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

class _CourseContentError extends StatelessWidget {
  final String message;

  const _CourseContentError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(RadixIcons.exclamationTriangle, size: 32),
        const Gap(12),
        Text(
          'Unable to load lessons',
          style: Theme.of(context).typography.small,
        ),
        const Gap(8),
        Text(
          message,
          style: Theme.of(context).typography.xSmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
