import 'package:codemy_app/src/presentation/layouts/main_navigation_bar.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

import '../../user/providers/auth_providers.dart';
import '../providers/course_provider.dart';
import '../widgets/course_card.dart';

class InstructorCourseScreen extends ConsumerWidget {
  const InstructorCourseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.user;

    // Only instructors may access this screen
    if (!authState.isAuthenticated || user == null || user.role != 2) {
      return MainNavigationBar(
        child: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(LucideIcons.lock, size: 48),
                  const Gap(16),
                  Text('Access Denied', style: Theme.of(context).typography.h3),
                  const Gap(8),
                  Text(
                    'You do not have permission to view instructor courses.',
                    style: Theme.of(context).typography.small,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    final userId = user.id;
    final coursesAsync = ref.watch(instructorCoursesProvider(userId));

    return MainNavigationBar(
      child: DrawerOverlay(
        child: Container(
          color: Theme.of(context).colorScheme.background,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.popover,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Button.ghost(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Icon(LucideIcons.arrowLeft),
                      ),
                      const Spacer(),
                      Text(
                        'My Courses',
                        style: Theme.of(
                          context,
                        ).typography.h4.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                Expanded(
                  child: coursesAsync.when(
                    data: (courses) {
                      if (courses.isEmpty) {
                        return Center(
                          child: Text(
                            'No courses found',
                            style: Theme.of(context).typography.h4,
                          ),
                        );
                      }
                      return material.RefreshIndicator(
                        onRefresh: () async {
                          ref.invalidate(instructorCoursesProvider(userId));
                        },
                        child: ListView.separated(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: courses.length,
                          separatorBuilder: (_, __) => const Gap(12),
                          itemBuilder: (context, index) {
                            final course = courses[index];
                            return CourseCard(course: course);
                          },
                        ),
                      );
                    },
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (err, _) => Center(
                      child: Text('Failed to load courses: ${err.toString()}'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
