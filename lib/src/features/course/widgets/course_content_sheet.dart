import 'package:codemy_app/src/features/course/enums/lesson_type.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:codemy_app/src/features/course/providers/course_content_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class CourseContentSheet extends ConsumerStatefulWidget {
  final String courseId;
  final String? currentModuleId;
  final String? currentLessonId;

  const CourseContentSheet({
    super.key,
    required this.courseId,
    this.currentModuleId,
    this.currentLessonId,
  });

  @override
  ConsumerState<CourseContentSheet> createState() => _CourseContentSheetState();
}

class _CourseContentSheetState extends ConsumerState<CourseContentSheet> {
  late List<TreeNode<dynamic>> _treeItems;

  @override
  void initState() {
    super.initState();
    _initializeTreeItems();
  }

  @override
  void didUpdateWidget(covariant CourseContentSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.courseId != widget.courseId ||
        oldWidget.currentModuleId != widget.currentModuleId ||
        oldWidget.currentLessonId != widget.currentLessonId) {
      _initializeTreeItems();
    }
  }

  void _initializeTreeItems() {
    final courseContent = ref.read(courseContentProvider(widget.courseId));
    courseContent.whenData((content) {
      if (mounted) {
        setState(() {
          _treeItems = _buildTreeNodes(
            content.modules,
            selectedModuleId: widget.currentModuleId,
            selectedLessonId: widget.currentLessonId,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final courseContent = ref.watch(courseContentProvider(widget.courseId));

    return Container(
      padding: const EdgeInsets.all(24),
      constraints: const BoxConstraints(maxWidth: 400),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Course Content').large().medium()),
              TextButton(
                density: ButtonDensity.icon,
                child: const Icon(Icons.close),
                onPressed: () => closeSheet(context),
              ),
            ],
          ),
          const Gap(8),
          Text('Navigate through course modules and lessons.').muted(),
          const Gap(16),
          SizedBox(
            height: 400, // Fixed height for the tree view
            child: courseContent.when(
              data: (content) => TreeView<dynamic>(
                shrinkWrap: true,
                recursiveSelection: false,
                nodes: _treeItems,
                branchLine: BranchLine.path,
                onSelectionChanged: TreeView.defaultSelectionHandler(
                  _treeItems,
                  (value) {
                    setState(() {
                      _treeItems = value;
                    });
                  },
                ),
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
                      onExpand: TreeView.defaultItemExpandHandler(
                        _treeItems,
                        node,
                        (value) {
                          setState(() {
                            _treeItems = value;
                          });
                        },
                      ),
                      child: Text(data.title),
                    );
                  }

                  if (data is Lesson) {
                    return TreeItemView(
                      onPressed: () => _navigateToLesson(context, data),
                      leading: _getLessonIcon(data.lessonType),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(data.title),
                          Text(
                            '${_getLessonTypeText(data.lessonType)} • ${data.duration}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(
                                context,
                              ).colorScheme.mutedForeground,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  return TreeItemView(child: Text('${node.data}'));
                },
              ),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => Center(
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
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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

  void _navigateToLesson(BuildContext context, Lesson lesson) {
    final moduleId = lesson.moduleId;
    closeSheet(context); // Close the sheet first
    context.go('/learn/${widget.courseId}/$moduleId/${lesson.id}');
  }
}
