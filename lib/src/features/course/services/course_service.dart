import 'dart:async';
import 'package:decimal/decimal.dart';
import '../../course/models/entities/course.dart';
import '../../course/models/entities/module.dart';
import '../../course/models/entities/lesson.dart';
import '../../course/enums/lesson_type.dart';

enum CourseListType { all, joined, wishlist }

class CourseService {
  final List<Course> _allCourses = [];
  CourseService() {
    _allCourses.addAll(_generateFakeCourses());
  }

  Future<List<Course>> fetchCourses({
    CourseListType type = CourseListType.all,
    int limit = 20,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    switch (type) {
      case CourseListType.joined:
        // giả lập user đã tham gia 1 số khóa học
        return _allCourses
            .where((c) => int.parse(c.id.replaceAll('c', '')) % 3 == 0)
            .take(limit)
            .toList();
      case CourseListType.wishlist:
        return _allCourses
            .where((c) => int.parse(c.id.replaceAll('c', '')) % 4 == 0)
            .take(limit)
            .toList();
      case CourseListType.all:
      default:
        return _allCourses.take(limit).toList();
    }
  }

  List<Course> _generateFakeCourses() {
    final categories = ['Flutter', 'AI', 'Web', 'DevOps', 'Design'];
    final List<Course> list = [];

    for (int i = 1; i <= 30; i++) {
      final cat = categories[i % categories.length];
      final title = '$cat Course #$i';

      final modules = List.generate(3, (m) {
        final moduleId = 'm${i}_$m';
        final lessons = List.generate(4, (l) {
          return Lesson(
            id: 'l${i}_$m$l',
            title: 'Lesson ${l + 1}',
            duration: '${10 + l * 5} min',
            lessonType: l % 3 == 0
                ? LessonType.video
                : (l % 3 == 1 ? LessonType.markdown : LessonType.quiz),
            orderIndex: l + 1,
            isPreviewable: l == 0,
            createdAt: DateTime.now().subtract(Duration(days: i + m + l)),
          );
        });

        final totalDurationMinutes = lessons.fold<int>(
          0,
          (sum, l) => sum + int.parse(l.duration.split(' ')[0]),
        );
        return Module(
          id: moduleId,
          title: 'Module ${m + 1}',
          duration: Duration(minutes: totalDurationMinutes),
          numLessons: lessons.length,
          order: m + 1,
          lessons: lessons,
          createdAt: DateTime.now().subtract(Duration(days: i + m)),
        );
      });

      final totalCourseDuration = Duration(
        minutes: modules.fold<int>(
          0,
          (sum, mod) => sum + mod.duration.inMinutes,
        ),
      );

      list.add(
        Course(
          id: 'c$i',
          title: title,
          description:
              'A comprehensive $cat course covering theory, examples, and practical exercises.',
          thumbnail: '',
          duration: totalCourseDuration,
          price: Decimal.parse((9 + i % 5).toString()),
          language: (i % 2 == 0) ? 'English' : 'Vietnamese',
          numReviews: 10 + i,
          averageRating: Decimal.parse('4.${i % 5}'),
          modules: modules,
          createdAt: DateTime.now().subtract(Duration(days: i)),
        ),
      );
    }
    return list;
  }
}
