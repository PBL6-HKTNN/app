import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:codemy_app/src/features/course/models/entities/lesson.dart';
import 'package:codemy_app/src/features/course/models/entities/module.dart';
import 'package:codemy_app/src/features/course/enums/lesson_type.dart';

// Mock course data
final mockCourseData = [
  Module(
    id: 'module-1',
    title: 'Introduction to Programming',
    duration: const Duration(minutes: 30),
    numLessons: 3,
    order: 1,
    createdAt: DateTime.now(),
    lessons: [
      Lesson(
        id: 'lesson-1',
        title: 'What is Programming?',
        duration: '10 min',
        lessonType: LessonType.markdown,
        orderIndex: 1,
        isPreviewable: true,
        createdAt: DateTime.now(),
      ),
      Lesson(
        id: 'lesson-2',
        title: 'Setting up Environment',
        duration: '15 min',
        lessonType: LessonType.video,
        orderIndex: 2,
        isPreviewable: true,
        createdAt: DateTime.now(),
      ),
      Lesson(
        id: 'lesson-3',
        title: 'Basic Concepts Quiz',
        duration: '5 min',
        lessonType: LessonType.quiz,
        orderIndex: 3,
        isPreviewable: false,
        createdAt: DateTime.now(),
      ),
    ],
  ),
  Module(
    id: 'module-2',
    title: 'Variables and Data Types',
    duration: const Duration(minutes: 45),
    numLessons: 3,
    order: 2,
    createdAt: DateTime.now(),
    lessons: [
      Lesson(
        id: 'lesson-4',
        title: 'Variables',
        duration: '12 min',
        lessonType: LessonType.markdown,
        orderIndex: 1,
        isPreviewable: true,
        createdAt: DateTime.now(),
      ),
      Lesson(
        id: 'lesson-5',
        title: 'Data Types',
        duration: '18 min',
        lessonType: LessonType.video,
        orderIndex: 2,
        isPreviewable: true,
        createdAt: DateTime.now(),
      ),
      Lesson(
        id: 'lesson-6',
        title: 'Practice Quiz',
        duration: '15 min',
        lessonType: LessonType.quiz,
        orderIndex: 3,
        isPreviewable: false,
        createdAt: DateTime.now(),
      ),
    ],
  ),
];

class CourseContentView extends ConsumerStatefulWidget {
  const CourseContentView({super.key});

  static void show(BuildContext context) {
    openSheet(
      context: context,
      builder: (context) => const CourseContentView(),
      position: OverlayPosition.left,
    );
  }

  @override
  ConsumerState<CourseContentView> createState() => _CourseContentViewState();
}

class _CourseContentViewState extends ConsumerState<CourseContentView> {
  late List<TreeNode<dynamic>> treeItems;

  @override
  void initState() {
    super.initState();
    treeItems = _buildTreeNodes();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.8,
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Text('Course Content', style: Theme.of(context).typography.h4),
                const Spacer(),
                Button(
                  style: ButtonStyle.ghost(),
                  onPressed: () {
                    context.pop();
                  },
                  child: const Icon(RadixIcons.cross1),
                ),
              ],
            ),
          ),
          const Divider(),
          // Tree View
          Expanded(
            child: TreeView<dynamic>(
              shrinkWrap: true,
              recursiveSelection: false,
              nodes: treeItems,
              branchLine: BranchLine.path,
              onSelectionChanged: TreeView.defaultSelectionHandler(treeItems, (
                value,
              ) {
                setState(() {
                  treeItems = value;
                });
              }),
              builder: (context, node) {
                final data = node.data;
                if (data is Module) {
                  return TreeItemView(
                    onPressed: () {
                      // Module selection - could expand/collapse
                    },
                    leading: Icon(
                      node.expanded
                          ? BootstrapIcons.folder2Open
                          : BootstrapIcons.folder2,
                    ),
                    onExpand: TreeView.defaultItemExpandHandler(
                      treeItems,
                      node,
                      (value) {
                        setState(() {
                          treeItems = value;
                        });
                      },
                    ),
                    child: Text(data.title),
                  );
                } else if (data is Lesson) {
                  return TreeItemView(
                    onPressed: () {
                      _navigateToLesson(context, data);
                    },
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
                return TreeItemView(child: Text('Unknown item'));
              },
            ),
          ),
        ],
      ),
    );
  }

  List<TreeNode<dynamic>> _buildTreeNodes() {
    return mockCourseData.map((module) {
      return TreeItem<dynamic>(
        data: module,
        expanded: true, // Modules start expanded
        children: module.lessons.map((lesson) {
          return TreeItem<dynamic>(
            data: lesson,
            children: const [], // Lessons are leaf nodes
          );
        }).toList(),
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
    // Close the sheet first
    context.pop();

    // Navigate to the lesson
    // This would need to be implemented based on your routing structure
    // For now, we'll just print the lesson info
    print('Navigate to lesson: ${lesson.id} - ${lesson.title}');
  }
}
